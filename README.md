# SmartMushroom App ![Version](https://img.shields.io/badge/version-1.0.0%2B1-3b82f6)

## Descrição Geral do App
**SmartMushroom App** é uma plataforma mobile para monitoramento e controle de salas de cultivo de cogumelos em tempo real. O aplicativo concentra telemetria ambiental, histórico de fases e ajustes de parâmetros operacionais em uma única experiência responsiva.

### O que o app faz
- Consolida leituras de sensores (temperatura, umidade, CO₂) e apresenta dashboards em tempo real.
- Permite alterar setpoints e fases de cultivo seguindo regras pré-configuradas.
- Disponibiliza gráficos agregados (24h, diário, semanal e mensal) para análise de tendência.
- Expõe atalhos para acionar/desligar atuadores críticos (ventilação, iluminação, irrigação).

### Público-alvo
- Gestores de fazendas indoor e produtores de cogumelos gourmet.
- Técnicos responsáveis por salas de cultivo distribuídas.
- Equipes de P&D que precisam correlacionar dados ambientais com produtividade.

### Problema que ele resolve
- Reduz o retrabalho de acompanhar sensores dispersos.
- Centraliza decisões operacionais (mudança de fase, ajustes finos, finalização de lotes).
- Documenta automaticamente o histórico do cultivo, facilitando auditorias e compliance.

## Arquitetura do Projeto
### Padrões utilizados
- **MVVM (Model-View-ViewModel)** nas features (ex.: `SalaViewModel`, `EditarParametrosViewModel`).
- **Feature-first + Clean-ish layering**: `features/`, `core/`, `models/`, `screen/`.
- **Provider** como gerenciador de estado reativo.
- **Repository/DataSource** simplificado via *RemoteDataSource* (Dio) e `ChartDataModel`.

### Explicação das camadas
1. **Presentation (`screen/`, `features/**/presentation`)** – Widgets e páginas modulares, desacopladas via ViewModels.
2. **Application/State (`features/**/viewmodels`)** – Lógicas de orquestração, tratamento de loading/erro, regra de negócio leve.
3. **Data (`features/**/data`)** – Acesso HTTP via `DioClient`, mapeamento de modelos e normalização de respostas.
4. **Core (`core/`)** – Config, temas, exceções, cliente HTTP reutilizável.
5. **Models (`models/`)** – DTOs e entidades serializáveis.

### Fluxo de dados
1. Widget aciona ação em ViewModel (`SalaViewModel.initialize`).
2. ViewModel chama DataSource (ex.: `SalaRemoteDataSource.fetchChartData`).
3. DataSource usa `DioClient` + `ApiConfig` para montar requests autenticadas.
4. Resposta JSON é convertida em `ChartDataModel`, `LoteModel`, etc.
5. ViewModel expõe `ValueNotifier`/`ValueNotifier<double>` para Widgets atualizarem automaticamente.

### Diagrama simplificado
```mermaid
graph TD
    UI[Widgets e Páginas] --> VM[ViewModels (Provider)]
    VM --> DS[Remote DataSource (Dio)]
    DS --> API[SmartMushroom API]
    API -->|JSON| DS -->|Modelos| VM --> UI
    Core[(Core Config/Theme)] --> UI
    Core --> DS
```

## Funcionalidades Principais
| Funcionalidade | Caso de uso |
| --- | --- |
| Painel de salas e lotes | Acompanhar status de cada sala, último ciclo e atuadores em um grid responsivo |
| Gráficos ambientais (24h/Diário/Semanal/Mensal) | Investigar picos de CO₂/temperatura/umidade antes de agir |
| Controle de atuadores | Ativar/desativar nebulização, ventilação ou iluminação remotamente |
| Edição de parâmetros | Ajustar setpoints por fase, salvar e registrar histórico automaticamente |
| Finalização / exclusão de lote | Encerrar ciclos preservando dados para consulta futura |
| Configuração de IP do servidor | Adaptar o app a ambientes on-premise alterando a baseURL dinâmica |

## Tecnologias Utilizadas
| Tecnologia | Versão / Uso |
| --- | --- |
| Flutter | 3.7.0 (SDK `sdk: ^3.7.0`) |
| Dart | 3.7.x |
| Provider | 6.1.2 – estado reativo |
| Dio | 5.4.3+1 – HTTP client com interceptação |
| fl_chart | 0.70.2 – visualização gráfica |
| intl | 0.18.1 – formatação de datas/numéricos |
| get_storage | 2.1.1 – persistência simples (IP do servidor) |
| flutter_lints / flutter_test | Qualidade e testes |

## Como Executar o Projeto
### Pré-requisitos
- Flutter SDK 3.7.0+ (`flutter --version`).
- Dart SDK empacotado com Flutter.
- Emulador Android/iOS configurado ou dispositivo físico com modo desenvolvedor.
- Acesso à rede onde o SmartMushroom API está publicado.

### Passo a passo
```bash
# 1. Instale dependênciaslutter pub get

# 2. (Opcional) Limpe cacheslutter clean && flutter pub get

# 3. Execute em debuglutter run --flavor development -t lib/main.dart
# ou simplesmente
flutter run
```

## Configuração de Ambiente
- O endpoint base é definido por `ApiConfig`, que lê o IP salvo no `GetStorage` com chave `server_ip`.
- Primeira execução usa o IP padrão `192.168.15.2`. Ajustes podem ser feitos pela **tela de IP** (`lib/screen/ip_page.dart`) ou manualmente via `GetStorage`:
```dart
import 'package:get_storage/get_storage.dart';

Future<void> overrideIp(String ip) async {
  await GetStorage().write('server_ip', ip);
}
```
- Não há `.env`; tokens/URL são resolvidos dinamicamente. Garanta que o backend aceite HTTP (ou adapte `ApiConfig` para HTTPS/autenticação).

## Estrutura do Projeto
```
lib/
├─ core/            # Configurações, tema, Dio client, exceções
├─ features/
│  ├─ editar_parametros/
│  │   ├─ data/              # Remote datasources
│  │   └─ presentation/      # Pages, viewmodels, widgets específicos
│  ├─ sala/ ...
├─ models/          # DTOs e entidades compartilhadas
├─ api/             # Serviços auxiliares (ex.: api_service)
├─ screen/          # Páginas legacy / glue code (home, sala, charts)
├─ widgets/         # Componentes reutilizáveis
└─ main.dart        # Entry point + rotas iniciais
```
- **core/theme**: `app_theme.dart`, `app_colors.dart`, `theme_notifier.dart`.
- **screen/chart**: componentes visuais (ring, linecharts, donut).
- **features**: cada módulo segue MVVM (data → presentation/viewmodels → widgets específicos).

## Integração com API
- Comunicação via HTTP/JSON com `DioClient`, baseURL dinâmica `http://<ip>/smartmushroom-api/`.
- Principais endpoints:
  - `GET framework/lote/listarIdLote/{id}` → `LoteModel`.
  - `GET framework/leitura/listarUltimaLeitura/{id}` → `LeituraModel`.
  - `GET framework/leitura/grafico/{id}` com query `metric`, `aggregation`, `start_date`, `end_date` → `ChartDataModel`.
  - `POST framework/controleAtuador/adicionar` body `idAtuador`, `idLote`, `statusAtuador`.
  - `DELETE framework/lote/deletar/{id}` e `.../deletar_fisico/{id}`.

### Exemplo de resposta de gráfico
```json
{
  "chart_type": "line",
  "metadata": {
    "title": "Temperatura",
    "x_axis_label": "Data",
    "y_axis_label": "°C",
    "color": "#FF7A00"
  },
  "data": [
    {"x": "2025-11-13T10:00:00Z", "y": 22.4, "label": "13/11 10h"},
    {"x": "2025-11-13T11:00:00Z", "y": 22.9, "label": "13/11 11h"}
  ]
}
```

## Boas práticas utilizadas
- **SOLID**: separação clara de responsabilidades (ViewModel não conhece widgets, DataSource não conhece UI).
- **Reutilização de widgets**: gráficos, `CustomAppBar`, cards e contêineres de parâmetros desacoplados.
- **Gerenciamento de estado**: Provider + `ChangeNotifier` para granularidade fina e `ValueNotifier` nos controles interativos.
- **Tratamento consistente de erros**: `ApiException` concentra mensagens e status code.
- **Internacionalização de datas**: `intl` com locale `pt_BR` aplicado às labels.

## Testes
- Testes default em `test/widget_test.dart` (Widget smoke test).
- Para executar:
```bash
flutter test                    # roda todos os testes
flutter test test/widget_test.dart
```
- Recomenda-se adicionar testes de ViewModel (mock de `SalaRemoteDataSource`) e Golden tests para widgets críticos.

## Build e Deploy
```bash
# Gerar APK de releaselutter build apk --release

# Gerar Android App Bundle (Play Store)
flutter build appbundle --release

# (Opcional) iOS
flutter build ipa --config-only # requer Xcode/macOS
```
- Configure keystore (Android) em `android/key.properties`.
- Para publicar: subir `.aab` no Google Play Console, configurar track interna e rollout gradual.

## Roadmap
- [ ] Implementar autenticação e perfis de usuário.
- [ ] Exportar relatórios em PDF/CSV diretamente do app.
- [ ] Push notifications para alertas críticos de sensores.
- [ ] Suporte offline com cache local e sincronização.
- [ ] Testes instrumentados para fluxos completos de sala/lote.

## Contribuição
1. Faça um fork e crie uma branch (`git checkout -b feature/nova-feature`).
2. Garanta `flutter analyze` e `flutter test` sem falhas.
3. Abra um PR descrevendo o contexto, screenshots e passos de teste manual.
4. Aguarde review; responda aos comentários com commits adicionais.

## Licença
Projeto de uso interno. Direitos reservados à equipe SmartMushroom até definição de licença pública. Entre em contato antes de reutilizar ou distribuir.

## Contato / Suporte
- Abra uma issue neste repositório descrevendo o problema.
- Ou envie um e-mail para **dev@smartmushroom.io** com logs (`flutter run -v`) e capturas da tela relevante.

# SmartMushroom App ![Version](https://img.shields.io/badge/version-1.0.0%2B1-3b82f6)

## Visao geral
SmartMushroom App e uma plataforma mobile para monitorar e controlar salas de cultivo de cogumelos em tempo real. Consolida telemetria ambiental, historico de fases e ajustes de parametros operacionais em uma unica experiencia responsiva.

### O que o app faz
- Leituras de sensores (temperatura, umidade, CO2) em dashboards ao vivo.
- Alteracao de setpoints e fases de cultivo conforme regras pre-configuradas.
- Graficos agregados (24h, diario, semanal e mensal) para analise de tendencia.
- Atalhos para acionar/desligar atuadores criticos (ventilacao, iluminacao, irrigacao).

### Estrutura e arquitetura
- **Feature-first + MVVM** em `lib/src`: `features/<dominio>/{data,domain,presentation,widgets}`.
- **Core**: configuracoes, tema, excecoes, HTTP (`dio_client.dart`, interceptors).
- **State**: Provider/ChangeNotifier com ViewModels para orquestrar chamadas e estados.
- **Shared**: modelos reaproveitados entre features.

Fluxo resumido: Widget -> ViewModel -> RemoteDataSource -> API -> Model -> ViewModel -> Widget.

## Como rodar
### Requisitos
- Flutter 3.7.0+ (Dart 3.7.x). Confira com `flutter --version`.
- Emulador ou dispositivo configurado.
- Backend SmartMushroom acessivel na rede.

### Passo a passo
```bash
# 1) Dependencias
flutter pub get

# 2) (Opcional) limpar caches
flutter clean && flutter pub get

# 3) Executar
flutter run --flavor development -t lib/main.dart
# ou simplesmente
flutter run
```

## Configuracao de ambiente
- Endpoint base definido por `ApiConfig`, lendo o IP salvo em `GetStorage` com chave `server_ip`.
- IP padrao inicial: `192.168.15.2`.
- Ajuste o IP pela tela de configuracao (`lib/src/features/auth/presentation/pages/ip_page.dart`) ou manualmente via `GetStorage`.
- Nao ha `.env`; URLs e tokens sao resolvidos dinamicamente. Adeque para HTTPS/autenticacao se necessario.

## Estrutura do projeto (resumida)
```
lib/
  src/
    app.dart
    core/           # configuracoes, tema, rede, DI
    features/
      auth/         # login, splash, ip
      home/         # dashboard principal
      painel_salas/ # listagem e resumo das salas
      sala/         # detalhes, graficos e atuadores
      criar_lote/   # criacao de lotes
      editar_parametros/ # setpoints e fases
    shared/         # modelos e widgets comuns
  main.dart
```

## Tecnologias principais
- Flutter 3.7.0, Dart 3.7.x
- Provider para estado
- Dio 5.x com interceptor de auth
- fl_chart para graficos
- get_storage para persistencia leve
- intl para formatacao

## Testes
```bash
flutter test
flutter test test/widget_test.dart
```
Recomendado evoluir com testes de ViewModel e goldens para widgets criticos.

## Build e deploy
```bash
flutter build apk --release
flutter build appbundle --release
# iOS (macOS/Xcode):
# flutter build ipa --config-only
```
Configure o keystore Android em `android/key.properties`. Para publicar, envie o `.aab` ao Google Play e use rollout gradual.

## Roadmap
- [x] Refactor para estrutura feature-first em `lib/src`.
- [x] Fluxo de login e configuracao de IP.
- [ ] Perfis e autorizacao por role.
- [ ] Relatorios exportaveis (PDF/CSV).
- [ ] Push notifications para alertas criticos.
- [ ] Suporte offline e sincronizacao.

## Como contribuir
1) Crie uma branch: `git checkout -b feature/sua-feature`.
2) Rode `flutter analyze` e `flutter test`.
3) Abra PR descrevendo contexto, screenshots e passos de teste.
4) Ajuste conforme o review.

## Licenca
Uso interno. Direitos reservados a equipe SmartMushroom ate definicao de licenca publica.

## Suporte
- Abra uma issue descrevendo o problema.
- Ou envie e-mail para **dev@smartmushroom.io** com logs (`flutter run -v`) e prints relevantes.

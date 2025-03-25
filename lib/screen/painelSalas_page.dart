import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:smartmushroom_app/screen/widgets/sala_card.dart';

class PainelsalasPage extends StatefulWidget {
  const PainelsalasPage({super.key});

  @override
  State<PainelsalasPage> createState() => _PainelsalasPageState();
}

class _PainelsalasPageState extends State<PainelsalasPage> {
  late Timer _timer;
  List _salas = []; // Lista para armazenar os dados das salas
  bool _isLoading = true; // Indica se está carregando os dados
  bool _hasError = false; // Indica se houve erro na requisição

  @override
  void initState() {
    super.initState();
    fetchSalas(); // Carrega os dados iniciais

    // Atualiza automaticamente os dados a cada 10 segundos
    _timer = Timer.periodic(Duration(seconds: 10), (timer) {
      fetchSalas();
    });
  }

  @override
  void dispose() {
    _timer.cancel(); // Cancela o Timer ao sair da tela
    super.dispose();
  }

  Future<void> fetchSalas() async {
    try {
      final response = await http.get(
        //TROCAR PARA O IP DA MAQUINA DE VOCÊS (abre o cmd e digita ipconfig e pega o numero do ipv4)
        Uri.parse('http://192.168.1.66/smartmushroom-api/salas.php'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _salas = data['sala'] ?? [];
          _isLoading = false;
          _hasError = false;
        });
      } else {
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Painel de Salas")),
      body: RefreshIndicator(
        onRefresh: fetchSalas, // Atualiza ao puxar para baixo
        child:
            _isLoading
                ? const Center(
                  child: CircularProgressIndicator(),
                ) // Tela de carregamento
                : _hasError
                ? Center(
                  child: Text('Erro ao carregar dados'),
                ) // Mensagem de erro
                : ListView.builder(
                  itemCount: _salas.length,
                  itemBuilder: (context, index) {
                    final sala = _salas[index];

                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SalaCard(
                        nomeSala: sala['nomeSala'] ?? 'Sem nome',
                        nomeCogumelo: sala['nomeCogumelo'] ?? '',
                        faseCultivo: sala['nomeFaseCultivo'] ?? '',
                        dataInicio: sala['dataInicio'] ?? '',
                        idLote: sala['idLote'].toString(),
                        temperatura:
                            sala['temperatura'] != null
                                ? double.tryParse(
                                      sala['temperatura'].toString(),
                                    )?.toStringAsFixed(0) ??
                                    '--'
                                : '--',
                        umidade:
                            sala['umidade'] != null
                                ? double.tryParse(
                                      sala['umidade'].toString(),
                                    )?.toStringAsFixed(0) ??
                                    '--'
                                : '--',
                        co2:
                            sala['co2'] != null
                                ? double.tryParse(
                                      sala['co2'].toString(),
                                    )?.toStringAsFixed(0) ??
                                    '--'
                                : '--',
                      ),
                    );
                  },
                ),
      ),
    );
  }
}

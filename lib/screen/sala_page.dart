// Importações de bibliotecas nativas
import 'dart:async';
import 'dart:convert';

// Importações de pacotes externos
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// Importações locais
import 'package:smartmushroom_app/constants.dart';
import 'package:smartmushroom_app/screen/cadastroSalas_page.dart';
import 'package:smartmushroom_app/screen/chart/bar_indicator.dart';
import 'package:smartmushroom_app/screen/chart/co2_linechart.dart';
import 'package:smartmushroom_app/screen/chart/humidity_linechart.dart';
import 'package:smartmushroom_app/screen/chart/ring_chart.dart';
import 'package:smartmushroom_app/screen/chart/temperature_linechart.dart';
import 'package:smartmushroom_app/screen/widgets/custom_app_bar.dart';

class SalaPage extends StatefulWidget {
  final String nomeSala;
  final String idLote; // Recebe o idLote

  const SalaPage({super.key, required this.nomeSala, required this.idLote});

  @override
  State<SalaPage> createState() => _SalaPageState();
}

class _SalaPageState extends State<SalaPage> {
  late Timer _timer;
  Map<String, dynamic> _dadosSala = {}; // Dados da sala
  bool _isLoading = true;
  bool _hasFetchError = false; // Indica erro no fetch da sala
  Map<int, bool> _atuadoresStatus = {};

  @override
  void initState() {
    super.initState();
    _carregarEstadosLocais();
    fetchSala();
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      fetchSala();
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Future<void> _carregarEstadosLocais() async {
    Map<int, bool> estados = {};
    for (int id = 1; id <= 4; id++) {
      final status = await carregarStatusLocal(id);
      estados[id] = status ?? false; // padrão: desligado (false)
    }
    setState(() {
      _atuadoresStatus = estados;
    });
  }

  Future<bool?> carregarStatusLocal(int idAtuador) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('atuador_$idAtuador');
  }

  Future<void> salvarStatusLocal(int idAtuador, bool status) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('atuador_$idAtuador', status);
  }

  Future<void> fetchSala() async {
    try {
      final response = await http.get(
        Uri.parse(
          '${apiBaseUrl}nomesala.php?nomeSala=${Uri.encodeComponent(widget.nomeSala)}&idLote=${Uri.encodeComponent(widget.idLote)}',
        ),
      );

      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['sala'] != null && data['sala'].isNotEmpty) {
          debugPrint('Dados recebidos: ${data['sala'][0]}');

          setState(() {
            _dadosSala = data['sala'][0];
            _isLoading = false;
            _hasFetchError = false;
          });
        } else {
          debugPrint('Sala está vazia ou nula');
          setState(() {
            _hasFetchError = true;
            _isLoading = false;
          });
        }
      } else {
        debugPrint('Erro: Status Code ${response.statusCode}');
        setState(() {
          _hasFetchError = true;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Exceção ao buscar sala: $e');
      setState(() {
        _hasFetchError = true;
        _isLoading = false;
      });
    }
  }

  Future<void> _alterarStatusAtuador(int idAtuador) async {
    // Atualiza a interface para indicar que algo está acontecendo (opcional)
    try {
      final response = await http.post(
        Uri.parse('${apiBaseUrl}controle_atuadores.php'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {'idAtuador': idAtuador.toString()},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['mensagem'] == 'Status do atuador atualizado com sucesso') {
          // Atualiza o status local e salva no SharedPreferences
          setState(() {
            _atuadoresStatus[idAtuador] =
                !(_atuadoresStatus[idAtuador] ?? false);
          });
          await salvarStatusLocal(idAtuador, _atuadoresStatus[idAtuador]!);
          // Feedback para o usuário
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Atuador atualizado com sucesso')),
          );
        } else {
          // Se a mensagem não bater, exibe erro
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Erro ao atualizar atuador')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro: ${response.statusCode} ao atualizar atuador'),
          ),
        );
      }
    } catch (e) {
      debugPrint("Erro ao alterar status: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao alterar status: $e')));
    }
  }

  Future<void> _finalizarLote() async {
    try {
      final response = await http.delete(
        Uri.parse('${apiBaseUrl}salas.php?idLote=${widget.idLote}'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['message'] == 'Lote finalizado com sucesso') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Lote finalizado com sucesso!')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Erro ao finalizar lote!')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Erro ao conectar ao servidor: ${response.statusCode}',
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(234, 234, 234, 1),
      appBar: CustomAppBar(title: widget.nomeSala),
      drawer: const Drawer(),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _hasFetchError
              ? const Center(child: Text('Erro ao carregar dados.'))
              : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(defaultPadding),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: RingChart(
                              temperatura: _dadosSala['temperatura'] ?? '--',
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildInfoItem(
                                  'Cogumelo',
                                  _dadosSala['nomeCogumelo'],
                                ),
                                _buildInfoItem(
                                  'Fase',
                                  _dadosSala['nomeFaseCultivo'],
                                ),
                                _buildInfoItem(
                                  'Data Início',
                                  _dadosSala['dataInicio'],
                                ),
                                _buildInfoItem('Lote', _dadosSala['idLote']),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          BarIndicator(
                            label: 'Umidade',
                            icon: Icons.water_drop_outlined,
                            percentage: 50,
                            valueLabel: _dadosSala['umidade'],
                            color: Colors.blueAccent,
                          ),
                          const SizedBox(width: defaultPadding),
                          BarIndicator(
                            label: 'Nível CO²',
                            icon: Icons.cloud_outlined,
                            percentage: 50,
                            valueLabel: _dadosSala['co2'],
                            color: Colors.orangeAccent,
                          ),
                        ],
                      ),
                      const SizedBox(height: defaultPadding),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: List.generate(4, (index) {
                          int idAtuador = index + 1;
                          bool isAtivo = _atuadoresStatus[idAtuador] ?? false;
                          Color buttonColor =
                              isAtivo
                                  ? const Color.fromARGB(255, 97, 247, 28)
                                  : secontaryColor;

                          // Definir ícones e rótulos diferentes para cada atuador
                          IconData icon;
                          String label;
                          switch (idAtuador) {
                            case 1:
                              icon = Icons.water; // Exemplo: umidificador
                              label = 'Umidade';
                              break;

                            case 2:
                              icon = Icons.air; // Exemplo: ventilação
                              label = 'Ventilação';
                              break;

                            case 3:
                              icon = Icons.light_mode; // Exemplo: iluminação
                              label = 'Iluminação';
                              break;

                            case 4:
                              icon = Icons.ac_unit; // Exemplo: ar condicionado
                              label = 'Temperatura';
                              break;

                            default:
                              icon = Icons.lightbulb;
                              label = 'Atuador';
                          }

                          return Column(
                            children: [
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: buttonColor,
                                  shape: const CircleBorder(),
                                  padding: const EdgeInsets.all(20),
                                ),
                                onPressed: () async {
                                  await _alterarStatusAtuador(idAtuador);
                                },
                                child: Icon(
                                  icon,
                                  color: Colors.white,
                                  size: 25,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(label, style: const TextStyle(fontSize: 12)),
                            ],
                          );
                        }),
                      ),
                      const SizedBox(height: defaultPadding),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          InkWell(
                            onTap: () {
                              modalFinalizaLote();
                            },
                            child: Container(
                              height: 50,
                              width: MediaQuery.of(context).size.width * 0.45,
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: const Center(
                                child: Text(
                                  "Finalizar Lote",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => const CadastrosalasPage(),
                                ),
                              );
                            },
                            child: Container(
                              height: 50,
                              width: MediaQuery.of(context).size.width * 0.45,
                              decoration: BoxDecoration(
                                color: secontaryColor,
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: const Center(
                                child: Text(
                                  "Editar Sala",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: defaultPadding),
                      _buildChartSection('Temperatura', TemperatureLinechart()),
                      const SizedBox(height: defaultPadding),
                      _buildChartSection('Umidade', HumidityLinechart()),
                      const SizedBox(height: defaultPadding),
                      _buildChartSection('Co²', Co2Linechart()),
                    ],
                  ),
                ),
              ),
    );
  }

  Widget _buildInfoItem(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
          Text(
            '$value',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildChartSection(String title, Widget chart) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        chart,
      ],
    );
  }

  void modalFinalizaLote() async {
    await showDialog(
      barrierDismissible: false,
      barrierColor: Colors.black.withAlpha(100),
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: primaryColor,
          title: const Text(
            'Finalizar o Lote?',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          content: const Text(
            'Essa é uma ação que não poderá ser revertida!',
            style: TextStyle(fontSize: 17, color: Colors.white),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text(
                'Cancelar',
                style: TextStyle(color: Colors.white),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                await _finalizarLote();
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text(
                'Finalizar',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }
}

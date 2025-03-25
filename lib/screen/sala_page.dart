// Importações de bibliotecas nativas
import 'dart:async';
import 'dart:convert';

// Importações de pacotes externos
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// Importações locais
import 'package:smartmshroom_app/constants.dart';
import 'package:smartmshroom_app/screen/chart/co2_linechart.dart';
import 'package:smartmshroom_app/screen/chart/humidity_linechart.dart';
import 'package:smartmshroom_app/screen/chart/ring_chart.dart';
import 'package:smartmshroom_app/screen/chart/temperature_linechart.dart';

class SalaPage extends StatefulWidget {
  final String nomeSala;
  final String idLote; // Adicionando idLote como parâmetro

  const SalaPage({
    super.key,
    required this.nomeSala,
    required this.idLote, // Recebendo o idLote
  });

  @override
  State<SalaPage> createState() => _SalaPageState();
}

class _SalaPageState extends State<SalaPage> {
  late Timer _timer;
  Map<String, dynamic> _dadosSala = {}; // Dados da sala
  bool _isLoading = true;
  bool _hasError = false;
  Map<int, bool> _atuadoresStatus = {};

  @override
  void initState() {
    super.initState();
    _carregarEstadosLocais();
    fetchSala();
    _timer = Timer.periodic(Duration(seconds: 10), (timer) {
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
          'http://192.168.15.9/smartmushroom-api/nomesala.php?nomeSala=${Uri.encodeComponent(widget.nomeSala)}&idLote=${Uri.encodeComponent(widget.idLote)}',
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
            _hasError = false;
          });
        } else {
          debugPrint('Sala está vazia ou nula');
          setState(() {
            _hasError = true;
            _isLoading = false;
          });
        }
      } else {
        debugPrint('Erro: Status Code ${response.statusCode}');
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Exceção ao buscar sala: $e');
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  Future<void> alterarStatusAtuador(int idAtuador) async {
    setState(() {});

    try {
      final response = await http.post(
        Uri.parse('http://192.168.15.9/smartmushroom-api/atuadores.php'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {'idAtuador': idAtuador.toString()},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['mensagem'] == 'Status do atuador atualizado com sucesso') {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          setState(() {
            _atuadoresStatus[idAtuador] =
                !(_atuadoresStatus[idAtuador] ?? false);
            prefs.setBool('atuador_$idAtuador', _atuadoresStatus[idAtuador]!);
            _hasError = false;
          });
        }
      } else {
        setState(() {
          _hasError = true;
        });
      }
    } catch (e) {
      print("Erro ao alterar status: $e");
      setState(() {
        _hasError = true;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(234, 234, 234, 1),
      appBar: AppBar(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        title: Text(
          ' ${widget.nomeSala}',
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_back_rounded),
          ),
        ],
      ),
      drawer: Drawer(),
      body: SingleChildScrollView(
        child:
            _isLoading
                ? Center(child: CircularProgressIndicator())
                : _hasError
                ? Center(child: Text('Erro ao carregar dados.'))
                : Padding(
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
                          SizedBox(width: 16),
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
                      SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildLeituraCard(
                            'Umidade',
                            _dadosSala['umidade'] ?? '--',
                            Icons.water_drop_outlined,
                            '%',
                          ),
                          SizedBox(width: 16),
                          _buildLeituraCard(
                            'Nível Co²',
                            _dadosSala['co2'] ?? '--',
                            Icons.co2,
                            'ppm',
                          ),
                        ],
                      ),
                      SizedBox(height: defaultPadding),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: List.generate(4, (index) {
                          int idAtuador = index + 1;
                          bool isAtivo = _atuadoresStatus[idAtuador] ?? false;
                          Color buttonColor =
                              isAtivo
                                  ? Color.fromARGB(255, 97, 247, 28)
                                  : secontaryColor;

                          IconData icon;
                          switch (idAtuador) {
                            case 1:
                            case 2:
                            case 3:
                            case 4:
                              icon = Icons.lightbulb;
                              break;
                            default:
                              icon = Icons.device_unknown;
                          }

                          return ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: buttonColor,
                              shape: CircleBorder(),
                              padding: EdgeInsets.all(20),
                            ),
                            onPressed: () async {
                              await alterarStatusAtuador(idAtuador);
                            },
                            child: Icon(icon, color: Colors.white, size: 25),
                          );
                        }),
                      ),
                      SizedBox(height: defaultPadding),
                      _buildChartSection('Temperatura', TemperatureLinechart()),
                      SizedBox(height: defaultPadding),
                      _buildChartSection('Umidade', HumidityLinechart()),
                      SizedBox(height: defaultPadding),
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
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
          Text(
            '$value',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildLeituraCard(
    String label,
    dynamic value,
    IconData icon,
    String label1,
  ) {
    return Expanded(
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          color: primaryColor,
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    label,
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                  Icon(icon, color: Colors.white),
                ],
              ),
              SizedBox(height: 10),
              Center(
                child: Text(
                  '$value $label1',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChartSection(String title, Widget chart) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        chart,
      ],
    );
  }
}

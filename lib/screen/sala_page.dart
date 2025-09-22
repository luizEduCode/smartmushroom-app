import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:smartmushroom_app/constants.dart';
import 'package:smartmushroom_app/models/salas_lotes_ativos.dart';
import 'package:smartmushroom_app/models/status_atuador.dart';
import 'package:smartmushroom_app/screen/chart/co2_linechart.dart';
import 'package:smartmushroom_app/screen/chart/humidity_linechart.dart';
import 'package:smartmushroom_app/screen/chart/ring_chart.dart';
import 'package:smartmushroom_app/screen/chart/temperature_linechart.dart';
import 'package:smartmushroom_app/screen/editarParametros_page.dart';
import 'package:smartmushroom_app/screen/widgets/custom_app_bar.dart';

class SalaPage extends StatefulWidget {
  final String nomeSala;
  final String idLote;
  final String? idSala;

  const SalaPage({
    super.key,
    required this.nomeSala,
    required this.idLote,
    this.idSala,
  });

  @override
  State<SalaPage> createState() => _SalaPageState();
}

class _SalaPageState extends State<SalaPage> {
  late Timer _timer;
  Map<String, dynamic> _dadosSala = {};
  bool _isLoading = true;
  bool _hasFetchError = false;
  Map<int, bool> _atuadoresStatus = {};
  bool _loadingAtuadores = false;
  int? _idCogumelo;
  int? _idFaseCultivo;

  @override
  void initState() {
    super.initState();
    _carregarStatusAtuadores();
    fetchSala();
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      fetchSala();
      _carregarStatusAtuadores();
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Future<void> fetchSala() async {
    try {
      final response = await http.get(
        Uri.parse('${getApiBaseUrl()}framework/sala/listarSalasComLotesAtivos'),
        headers: {'Accept': 'application/json'},
      );

      debugPrint('Status Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final salasComLotes = SalaLotesAtivos.fromJson(data);

        Salas? salaEncontrada;
        Lotes? loteEncontrado;

        for (var sala in salasComLotes.salas ?? []) {
          for (var lote in sala.lotes ?? []) {
            if (lote.idLote?.toString() == widget.idLote) {
              salaEncontrada = sala;
              loteEncontrado = lote;
              break;
            }
          }
          if (salaEncontrada != null) break;
        }

        if (mounted) {
          setState(() {
            if (salaEncontrada != null && loteEncontrado != null) {
              _dadosSala = {
                'idSala': salaEncontrada.idSala,
                'nomeSala': salaEncontrada.nomeSala,
                'idLote': loteEncontrado.idLote,
                'dataInicio': loteEncontrado.dataInicio,
                'status': loteEncontrado.status,
                'nomeCogumelo': loteEncontrado.nomeCogumelo,
                'nomeFaseCultivo': loteEncontrado.nomeFaseCultivo,
                'temperatura': loteEncontrado.temperatura,
                'umidade': loteEncontrado.umidade,
                'co2': loteEncontrado.co2,
              };
              _idCogumelo = loteEncontrado.idCogumelo;
              _idFaseCultivo = loteEncontrado.idFaseCultivo;
              _isLoading = false;
              _hasFetchError = false;
            } else {
              _hasFetchError = true;
              _isLoading = false;
            }
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _hasFetchError = true;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasFetchError = true;
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _carregarStatusAtuadores() async {
    try {
      final response = await http.get(
        Uri.parse("${getApiBaseUrl()}framework/controleAtuador/listarTodos"),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        if (mounted) {
          setState(() {
            for (var item in data) {
              try {
                final atuador = StatusAtuador.fromJson(item);
                _atuadoresStatus[atuador.idAtuador] =
                    atuador.statusAtuador?.toLowerCase() == "ativo";
              } catch (e) {
                debugPrint("Erro ao parsear atuador: $e");
              }
            }
          });
        }
      } else {
        debugPrint("Erro ao carregar status: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Erro ao buscar status: $e");
    }
  }

  Future<void> _alterarStatusAtuador(int idAtuador) async {
    if (_loadingAtuadores) return;

    bool statusAtual = _atuadoresStatus[idAtuador] ?? false;
    bool novoStatus = !statusAtual;

    setState(() {
      _loadingAtuadores = true;
      _atuadoresStatus[idAtuador] = novoStatus;
    });

    final Map<String, dynamic> payload = {
      "idAtuador": idAtuador,
      "statusAtuador": novoStatus ? "ativo" : "inativo",
    };

    debugPrint('Enviando PUT para alterar atuador: ${jsonEncode(payload)}');

    try {
      final response = await http.post(
        Uri.parse("${getApiBaseUrl()}framework/controleAtuador/alterar"),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode(payload),
      );

      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Resposta do servidor: ${response.body}');

      if (response.statusCode == 200) {
        await _carregarStatusAtuadores();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Status alterado com sucesso!')),
          );
        }
      } else if (response.statusCode == 400) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Erro 400: Parâmetros inválidos.\nVerifique o JSON enviado.',
              ),
            ),
          );
        }
        setState(() => _atuadoresStatus[idAtuador] = statusAtual);
      } else {
        throw Exception('Erro ao atualizar status: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Erro ao alterar status do atuador: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro ao alterar status: $e')));
        setState(() => _atuadoresStatus[idAtuador] = statusAtual);
      }
    } finally {
      if (mounted) setState(() => _loadingAtuadores = false);
    }
  }

  Future<void> _finalizarLote() async {
    try {
      final response = await http.delete(
        Uri.parse('${getApiBaseUrl()}framework/lote/deletar/${widget.idLote}'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['message'] == 'Lote finalizado com sucesso') {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Lote finalizado com sucesso!')),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Erro ao finalizar lote!')),
            );
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Erro ao conectar ao servidor: ${response.statusCode}',
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro: $e')));
      }
    }
  }

  Future<void> _excluirLote() async {
    try {
      final response = await http.delete(
        Uri.parse(
          '${getApiBaseUrl()}framework/lote/deletar_fisico/${widget.idLote}',
        ),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['message'] == 'Lote excluido com sucesso') {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Lote excluido com sucesso!')),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Erro ao excluir lote!')),
            );
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Erro ao conectar ao servidor: ${response.statusCode}',
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro: $e')));
      }
    }
  }

  Color _getHumidityColor(double humidity) {
    if (humidity < 30) return Colors.red;
    if (humidity < 60) return Colors.orange;
    if (humidity < 80) return Colors.green;
    return Colors.blue;
  }

  Color _getCO2Color(double co2) {
    if (co2 < 400) return Colors.green;
    if (co2 < 1000) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(234, 234, 234, 1),
      appBar: CustomAppBar(title: widget.nomeSala),
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
                      // Seção superior - RingChart e informações
                      Row(
                        children: [
                          Expanded(
                            child: RingChart(
                              temperatura:
                                  _dadosSala['temperatura']?.toString() ?? '--',
                              valor:
                                  double.tryParse(
                                    _dadosSala['temperatura']?.toString() ??
                                        '0',
                                  ) ??
                                  0,
                            ),
                          ),
                          const SizedBox(width: 20), // Aumentado o espaçamento
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildInfoItem(
                                  'Cogumelo',
                                  _dadosSala['nomeCogumelo'],
                                ),
                                const SizedBox(
                                  height: defaultPadding / 2,
                                ), // Aumentado
                                _buildInfoItem(
                                  'Fase Cultivo',
                                  _dadosSala['nomeFaseCultivo'],
                                ),
                                const SizedBox(
                                  height: defaultPadding / 2,
                                ), // Aumentado
                                _buildInfoItem(
                                  'Data Início',
                                  _dadosSala['dataInicio'],
                                ),
                                const SizedBox(
                                  height: defaultPadding / 2,
                                ), // Aumentado
                                _buildInfoItem('Lote', _dadosSala['idLote']),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20), // Aumentado
                      // Seção de umidade e CO2
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Umidade',
                                  style: TextStyle(
                                    fontSize: 16, // Aumentado
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8), // Adicionado
                                LinearProgressIndicator(
                                  value:
                                      (double.tryParse(
                                            _dadosSala['umidade']?.toString() ??
                                                '0',
                                          ) ??
                                          0) /
                                      100,
                                  backgroundColor: Colors.grey[500],
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    _getHumidityColor(
                                      double.tryParse(
                                            _dadosSala['umidade']?.toString() ??
                                                '0',
                                          ) ??
                                          0,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 6), // Adicionado
                                Text(
                                  '${_dadosSala['umidade']?.toString() ?? '--'}%',
                                  style: const TextStyle(
                                    fontSize: 16,
                                  ), // Aumentado
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 20), // Aumentado
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Nível CO²',
                                  style: TextStyle(
                                    fontSize: 16, // Aumentado
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8), // Adicionado
                                LinearProgressIndicator(
                                  value:
                                      (double.tryParse(
                                            _dadosSala['co2']?.toString() ??
                                                '0',
                                          ) ??
                                          0) /
                                      5000,
                                  backgroundColor: Colors.grey[500],
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    _getCO2Color(
                                      double.tryParse(
                                            _dadosSala['co2']?.toString() ??
                                                '0',
                                          ) ??
                                          0,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 6), // Adicionado
                                Text(
                                  '${_dadosSala['co2']?.toString() ?? '--'}ppm',
                                  style: const TextStyle(
                                    fontSize: 16,
                                  ), // Aumentado
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24), // Aumentado
                      // Seção dos atuadores
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: List.generate(4, (index) {
                          int idAtuador = index + 1;
                          bool isAtivo = _atuadoresStatus[idAtuador] ?? false;
                          Color buttonColor =
                              isAtivo
                                  ? const Color.fromARGB(255, 97, 247, 28)
                                  : secontaryColor;

                          IconData icon;
                          String label;
                          switch (idAtuador) {
                            case 1:
                              icon = Icons.water;
                              label = 'Umidade';
                              break;
                            case 2:
                              icon = Icons.air;
                              label = 'Ventilação';
                              break;
                            case 3:
                              icon = Icons.light_mode;
                              label = 'Iluminação';
                              break;
                            case 4:
                              icon = Icons.ac_unit;
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
                                onPressed:
                                    _loadingAtuadores
                                        ? null
                                        : () =>
                                            _alterarStatusAtuador(idAtuador),
                                child:
                                    _loadingAtuadores &&
                                            _atuadoresStatus[idAtuador] !=
                                                isAtivo
                                        ? const CircularProgressIndicator(
                                          valueColor: AlwaysStoppedAnimation(
                                            Colors.white,
                                          ),
                                        )
                                        : Icon(
                                          icon,
                                          color: Colors.white,
                                          size: 25, // Aumentado
                                        ),
                              ),
                              const SizedBox(height: 8), // Aumentado
                              Text(
                                label,
                                style: const TextStyle(
                                  fontSize: 11,
                                ), // Aumentado
                              ),
                            ],
                          );
                        }),
                      ),
                      const SizedBox(height: 24), // Aumentado
                      // Seção dos botões de ação
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => EditarParametrosPage(
                                        idLote: widget.idLote,
                                        idCogumelo: _idCogumelo ?? 0,
                                        idFaseCultivo: _idFaseCultivo ?? 0,
                                      ),
                                ),
                              );
                            },
                            child: Container(
                              height: 45, // Aumentado
                              width: MediaQuery.of(context).size.width * 0.35,
                              decoration: BoxDecoration(
                                color: secontaryColor,
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: const Center(
                                child: Text(
                                  "Editar Sala",
                                  style: TextStyle(
                                    fontSize: 18, // Ajustado
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: modalFinalizaLote,
                            child: Container(
                              height: 45, // Aumentado
                              width: MediaQuery.of(context).size.width * 0.35,
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: const Center(
                                child: Text(
                                  "Finalizar",
                                  style: TextStyle(
                                    fontSize: 18, // Ajustado
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: modalExcluirLote,
                            child: Container(
                              height: 45, // Aumentado
                              width:
                                  MediaQuery.of(context).size.width *
                                  0.15, // Ajustado
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.delete,
                                  color: Colors.white,
                                  size: 28,
                                ), // Aumentado
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24), // Aumentado
                      // Seção dos gráficos
                      _buildChartSection(
                        'Temperatura',
                        const TemperatureLinechart(),
                      ),
                      const SizedBox(height: 20), // Aumentado
                      _buildChartSection('Umidade', const HumidityLinechart()),
                      const SizedBox(height: 20), // Aumentado
                      _buildChartSection('Co²', const Co2Linechart()),
                      const SizedBox(
                        height: 16,
                      ), // Adicionado espaçamento final
                    ],
                  ),
                ),
              ),
    );
  }

  Widget _buildInfoItem(String label, dynamic value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ), // Ajustado
        ),
        const SizedBox(height: 1), // Adicionado
        Text(
          value?.toString() ?? '--',
          style: const TextStyle(
            fontSize: 17,
            // fontWeight: FontWeight.bold,
          ), // Ajustado
        ),
      ],
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
        const SizedBox(height: 12), // Aumentado
        chart,
      ],
    );
  }

  void modalFinalizaLote() {
    showDialog(
      barrierDismissible: false,
      barrierColor: Colors.black.withAlpha(100),
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: primaryColor,
          title: const Text(
            'Deseja finalizar o Lote?',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          content: const Text(
            'Essa é uma ação que não poderá ser revertida, e todos os dados do lote permanecerão registrados.',
            style: TextStyle(fontSize: 17, color: Colors.white),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Cancelar',
                style: TextStyle(color: Colors.white),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _finalizarLote();
                if (mounted) {
                  Navigator.of(context).pop();
                }
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

  void modalExcluirLote() {
    showDialog(
      barrierDismissible: false,
      barrierColor: Colors.black.withAlpha(100),
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: primaryColor,
          title: const Text(
            'Deseja excluir o Lote?',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          content: const Text(
            'Essa é uma ação que não poderá ser revertida, ao excluir o lote, todos os dados relacionados a ele serão apagados!',
            style: TextStyle(fontSize: 17, color: Colors.white),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Cancelar',
                style: TextStyle(color: Colors.white),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _excluirLote();
                if (mounted) {
                  Navigator.of(context).pop();
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text(
                'Excluir',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }
}

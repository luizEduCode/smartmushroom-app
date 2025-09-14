// Importações de bibliotecas nativas
import 'dart:async';
import 'dart:convert';

// Importações de pacotes externos
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// Importações locais
import 'package:smartmushroom_app/constants.dart';
import 'package:smartmushroom_app/models/salas_lotes_ativos.dart';
import 'package:smartmushroom_app/screen/chart/bar_indicator.dart';
import 'package:smartmushroom_app/screen/chart/co2_linechart.dart';
import 'package:smartmushroom_app/screen/chart/humidity_linechart.dart';
import 'package:smartmushroom_app/screen/chart/ring_chart.dart';
import 'package:smartmushroom_app/screen/chart/temperature_linechart.dart';
import 'package:smartmushroom_app/screen/editarParametros_page.dart';
import 'package:smartmushroom_app/screen/widgets/custom_app_bar.dart';

class SalaPage extends StatefulWidget {
  final String nomeSala;
  final String idLote;
  final String? idSala; // idSala agora é opcional (nullable)

  const SalaPage({
    super.key,
    required this.nomeSala,
    required this.idLote,
    this.idSala, // removido 'required'
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
      estados[id] = status ?? false;
    }
    if (mounted) {
      setState(() {
        _atuadoresStatus = estados;
      });
    }
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
        Uri.parse('${getApiBaseUrl()}framework/sala/listarSalasComLotesAtivos'),
        headers: {'Accept': 'application/json'},
      );

      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Usando a model para parsear os dados
        final salasComLotes = SalaLotesAtivos.fromJson(data);

        // Encontrar a sala específica pelo ID do lote
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

  Future<void> _alterarStatusAtuador(int idAtuador) async {
    final bool atual = _atuadoresStatus[idAtuador] ?? false;
    final String novoStatus = !atual ? 'ativo' : 'inativo';

    try {
      final response = await http.post(
        Uri.parse('${getApiBaseUrl()}controle_atuadores.php'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {'idAtuador': idAtuador.toString(), 'statusAtuador': novoStatus},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['mensagem'].toString().contains('atualizado')) {
          if (mounted) {
            setState(() {
              _atuadoresStatus[idAtuador] = !atual;
            });
          }
          await salvarStatusLocal(idAtuador, !atual);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Atuador atualizado com sucesso')),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Erro ao atualizar atuador')),
            );
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ${response.statusCode} ao atualizar')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro ao alterar status: $e')));
      }
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
                      Row(
                        children: [
                          Expanded(
                            child: RingChart(
                              temperatura:
                                  _dadosSala['temperatura']?.toString() ?? '--',
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
                            valueLabel:
                                _dadosSala['umidade']?.toString() ?? '--',
                            color: Colors.blueAccent,
                          ),
                          const SizedBox(width: defaultPadding),
                          BarIndicator(
                            label: 'Nível CO²',
                            icon: Icons.cloud_outlined,
                            percentage: 50,
                            valueLabel: _dadosSala['co2']?.toString() ?? '--',
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
                                    () => _alterarStatusAtuador(idAtuador),
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
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => EditarParametrosPage(
                                        idLote: widget.idLote,
                                      ),
                                ),
                              );
                            },
                            child: Container(
                              height: 50,
                              width: MediaQuery.of(context).size.width * 0.38,
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
                          InkWell(
                            onTap: modalFinalizaLote,
                            child: Container(
                              height: 50,
                              width: MediaQuery.of(context).size.width * 0.38,
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
                            onTap: modalExcluirLote,
                            child: Container(
                              height: 50,
                              width: MediaQuery.of(context).size.width * 0.14,
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: const Center(
                                child: Icon(Icons.delete, color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: defaultPadding),
                      _buildChartSection(
                        'Temperatura',
                        const TemperatureLinechart(),
                      ),
                      const SizedBox(height: defaultPadding),
                      _buildChartSection('Umidade', const HumidityLinechart()),
                      const SizedBox(height: defaultPadding),
                      _buildChartSection('Co²', const Co2Linechart()),
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
            value?.toString() ?? '--',
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

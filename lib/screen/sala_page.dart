import 'dart:async';
import 'package:flutter/material.dart';

import 'package:smartmushroom_app/constants.dart';
import 'package:smartmushroom_app/core/network/api_exception.dart';
import 'package:smartmushroom_app/core/network/dio_client.dart';
import 'package:smartmushroom_app/features/sala/data/sala_remote_datasource.dart';
import 'package:smartmushroom_app/screen/chart/co2_linechart.dart';
import 'package:smartmushroom_app/screen/chart/humidity_linechart.dart';
import 'package:smartmushroom_app/screen/chart/ring_chart.dart';
import 'package:smartmushroom_app/screen/chart/temperature_linechart.dart';
import 'package:smartmushroom_app/screen/editarParametros_page.dart';
import 'package:smartmushroom_app/screen/widgets/custom_app_bar.dart';

import 'package:smartmushroom_app/models/Controle_Atuador_Model.dart';
import 'package:smartmushroom_app/models/Lote_Model.dart';
import 'package:smartmushroom_app/models/Leitura_Model.dart';

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
  late final SalaRemoteDataSource _dataSource;

  bool _isLoading = true;
  bool _hasFetchError = false;
  bool _loadingAtuadores = false;

  LoteModel? _lote; // dados fixos do lote
  LeituraModel? _leitura; // última leitura (tempo real)
  final Map<int, bool> _atuadoresStatus = {}; // 1..4

  int? _idCogumelo;
  int? _idFaseCultivo; // manter para compat com EditarParametrosPage (0 se null)

  @override
  void initState() {
    super.initState();
    _dataSource = SalaRemoteDataSource(DioClient());
    _carregarTudo(); // primeira carga
    _timer = Timer.periodic(const Duration(seconds: 10), (_) {
      _buscarUltimaLeitura(); // somente o que muda
      _carregarStatusAtuadores(); // status dos botões
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  // ---------- Orquestração ----------
  Future<void> _carregarTudo() async {
    setState(() {
      _isLoading = true;
      _hasFetchError = false;
    });
    try {
      await _buscarDadosLote(); // fixa cabeçalho
      await _buscarUltimaLeitura(); // dinâmica
      await _carregarStatusAtuadores(); // botões
      if (mounted) setState(() => _isLoading = false);
    } catch (_) {
      if (mounted)
        setState(() {
          _hasFetchError = true;
          _isLoading = false;
        });
    }
  }

  // ---------- Lote ----------
  Future<void> _buscarDadosLote() async {
    final lote = await _dataSource.fetchLote(widget.idLote);
    if (!mounted) return;
    setState(() {
      _lote = lote;
      _idCogumelo = lote.idCogumelo;
      // _idFaseCultivo permanece null (0 na navegação) até existir na API
    });
  }

  // ---------- Leitura (tempo real) ----------
  Future<void> _buscarUltimaLeitura() async {
    final leitura = await _dataSource.fetchUltimaLeitura(widget.idLote);
    if (!mounted) return;
    setState(() {
      _leitura = leitura;
    });
  }

  Future<void> _carregarStatusAtuadores() async {
    try {
      final registros = await _dataSource.fetchControleAtuadores(widget.idLote);

      final Map<int, ControleAtuadorModel> maisRecentePorAtuador = {};

      for (final registro in registros) {
        final id = registro.idAtuador;
        final atual = maisRecentePorAtuador[id];
        if (atual == null) {
          maisRecentePorAtuador[id] = registro;
        } else {
          final dtNovo = _parseDateTime(registro.dataCriacao);
          final dtAtual = _parseDateTime(atual.dataCriacao);
          if (dtNovo.isAfter(dtAtual)) {
            maisRecentePorAtuador[id] = registro;
          }
        }
      }

      final Map<int, bool> novosStatus = {};
      maisRecentePorAtuador.forEach((id, m) {
        final ativo = (m.statusAtuador).toLowerCase() == 'ativo';
        novosStatus[id] = ativo;
      });

      if (mounted) {
        setState(() {
          _atuadoresStatus
            ..clear()
            ..addAll(novosStatus);
        });
      }
    } catch (e) {
      debugPrint('Erro _carregarStatusAtuadores: $e');
    }
  }

  DateTime _parseDateTime(String? s) {
    // Esperado: "YYYY-MM-DD HH:MM:SS"
    if (s == null || s.isEmpty) return DateTime.fromMillisecondsSinceEpoch(0);
    try {
      return DateTime.parse(s.replaceFirst(' ', 'T')); // torna ISO-like
    } catch (_) {
      return DateTime.fromMillisecondsSinceEpoch(0);
    }
  }

  // ---------- Alterar status atuador ----------
  Future<void> _alterarStatusAtuador(int idAtuador) async {
    if (_loadingAtuadores) return;
    final atual = _atuadoresStatus[idAtuador] ?? false;
    final novo = !atual;

    setState(() {
      _loadingAtuadores = true;
      _atuadoresStatus[idAtuador] = novo; // otimista
    });

    try {
      await _dataSource.alterarStatusAtuador(
        idAtuador: idAtuador,
        idLote: widget.idLote,
        ativo: novo,
      );
      await _carregarStatusAtuadores();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Status alterado com sucesso!')),
        );
      }
    } on ApiException catch (e) {
      setState(() => _atuadoresStatus[idAtuador] = atual); // rollback
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message)),
        );
      }
    } catch (e) {
      setState(() => _atuadoresStatus[idAtuador] = atual); // rollback
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro: $e')));
      }
    } finally {
      if (mounted) setState(() => _loadingAtuadores = false);
    }
  }

  // ---------- Finalizar / Excluir ----------
  Future<void> _finalizarLote() async {
    try {
      final message = await _dataSource.finalizarLote(widget.idLote);
      if (mounted) {
        if (message == 'Lote finalizado com sucesso') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Lote finalizado com sucesso!')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                message.isNotEmpty
                    ? message
                    : 'Erro ao finalizar lote!',
              ),
            ),
          );
        }
      }
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: ${e.message}')),
        );
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
      final message = await _dataSource.excluirLote(widget.idLote);
      if (mounted) {
        if (message == 'Lote excluido com sucesso') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Lote excluido com sucesso!')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                message.isNotEmpty
                    ? message
                    : 'Erro ao excluir lote!',
              ),
            ),
          );
        }
      }
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: ${e.message}')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro: $e')));
      }
    }
  }

  // ---------- Helpers de cor ----------
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

  // ---------- UI ----------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(234, 234, 234, 1),
      appBar: CustomAppBar(title: _lote?.nomeSala ?? widget.nomeSala),
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
                      // Topo — RingChart + infos
                      Row(
                        children: [
                          Expanded(
                            child: RingChart(
                              temperatura: _leitura?.temperatura ?? '--',
                              valor: _leitura?.temperaturaNum ?? 0.0,
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildInfoItem('Cogumelo', _lote?.nomeCogumelo),
                                const SizedBox(height: defaultPadding / 2),
                                _buildInfoItem(
                                  'Data Início',
                                  _lote?.dataInicio,
                                ),
                                const SizedBox(height: defaultPadding / 2),
                                _buildInfoItem('Lote', _lote?.idLote),
                                const SizedBox(height: defaultPadding / 2),
                                _buildInfoItem(
                                  'Sala',
                                  _lote?.nomeSala ?? widget.nomeSala,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Indicadores — Umidade e CO2
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Umidade',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                LinearProgressIndicator(
                                  value: ((_leitura?.umidadeNum ?? 0.0) / 100)
                                      .clamp(0, 1),
                                  backgroundColor: Colors.grey[500],
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    _getHumidityColor(
                                      _leitura?.umidadeNum ?? 0.0,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text('${_leitura?.umidade ?? '--'}%'),
                              ],
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Nível CO²',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                LinearProgressIndicator(
                                  value: ((_leitura?.co2Num ?? 0.0) / 5000)
                                      .clamp(0, 1),
                                  backgroundColor: Colors.grey[500],
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    _getCO2Color(_leitura?.co2Num ?? 0.0),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text('${_leitura?.co2 ?? '--'}ppm'),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Botões de atuadores
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: List.generate(4, (index) {
                          final idAtuador = index + 1;
                          final isAtivo = _atuadoresStatus[idAtuador] ?? false;
                          final buttonColor =
                              isAtivo
                                  ? const Color.fromARGB(255, 97, 247, 28)
                                  : secontaryColor;

                          IconData icon;
                          String label;
                          switch (idAtuador) {
                            case 1: // umidificador (umidade)
                              icon = Icons.water_drop;
                              label = 'Umidade';
                              break;
                            case 2: // aquecedor (temperatura)
                              icon =
                                  Icons.ac_unit; // ou Icons.thermostat_outlined
                              label = 'Temperatura';
                              break;
                            case 3: // exaustor (CO2)
                              icon = Icons.air;
                              label = 'Ventilação';
                              break;
                            case 4: // luz
                              icon = Icons.light_mode;
                              label = 'Iluminação';
                              break;
                            default:
                              icon = Icons.device_hub;
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
                                    _loadingAtuadores
                                        ? const SizedBox(
                                          height: 22,
                                          width: 22,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 3,
                                            valueColor: AlwaysStoppedAnimation(
                                              Colors.white,
                                            ),
                                          ),
                                        )
                                        : Icon(
                                          icon,
                                          color: Colors.white,
                                          size: 25,
                                        ),
                              ),
                              const SizedBox(height: 8),
                              Text(label, style: const TextStyle(fontSize: 11)),
                            ],
                          );
                        }),
                      ),

                      const SizedBox(height: 24),

                      // Ações
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
                              height: 45,
                              width: MediaQuery.of(context).size.width * 0.35,
                              decoration: BoxDecoration(
                                color: secontaryColor,
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: const Center(
                                child: Text(
                                  "Editar Sala",
                                  style: TextStyle(
                                    fontSize: 18,
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
                              height: 45,
                              width: MediaQuery.of(context).size.width * 0.35,
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: const Center(
                                child: Text(
                                  "Finalizar",
                                  style: TextStyle(
                                    fontSize: 18,
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
                              height: 45,
                              width: MediaQuery.of(context).size.width * 0.15,
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.delete,
                                  color: Colors.white,
                                  size: 28,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Gráficos (fl_chart)
                      _buildChartSection(
                        'Temperatura',
                        const TemperatureLinechart(),
                      ),
                      const SizedBox(height: 20),
                      _buildChartSection('Umidade', const HumidityLinechart()),
                      const SizedBox(height: 20),
                      _buildChartSection('Co²', const Co2Linechart()),
                      const SizedBox(height: 16),
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
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 1),
        Text(value?.toString() ?? '--', style: const TextStyle(fontSize: 17)),
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
        const SizedBox(height: 12),
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
                if (mounted) Navigator.of(context).pop();
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
                if (mounted) Navigator.of(context).pop();
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

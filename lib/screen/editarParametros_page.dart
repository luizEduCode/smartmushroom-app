import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:smartmushroom_app/constants.dart';
import 'package:http/http.dart' as http;
import 'package:smartmushroom_app/models/parametrosidLote_model.dart';
import 'package:smartmushroom_app/screen/widgets/custom_app_bar.dart';
import 'dart:async';

// Classe modelo para as fases de cultivo
class FaseCultivo {
  final int idFaseCultivo;
  final String nomeFaseCultivo;

  FaseCultivo({required this.idFaseCultivo, required this.nomeFaseCultivo});

  factory FaseCultivo.fromJson(Map<String, dynamic> json) {
    return FaseCultivo(
      idFaseCultivo: int.tryParse(json['idFaseCultivo'].toString()) ?? 0,
      nomeFaseCultivo: json['nomeFaseCultivo'] ?? '',
    );
  }
}

class EditarParametrosPage extends StatefulWidget {
  final String idLote;
  final int? idCogumelo;
  final int? idFaseCultivo; // Novo parâmetro opcional

  const EditarParametrosPage({
    super.key,
    required this.idLote,
    this.idCogumelo,
    this.idFaseCultivo,
  });

  @override
  State<EditarParametrosPage> createState() => _EditarParametrosPageState();
}

class _EditarParametrosPageState extends State<EditarParametrosPage> {
  double _temperaturaMin = 22;
  double _temperaturaMax = 26;
  double _umidadeMin = 65;
  double _umidadeMax = 75;
  double _co2Max = 1500;
  bool _loading = true;
  String _errorMessage = '';
  bool _loadingPhases = false;
  String? _erroPhases;
  List<FaseCultivo> _cultivationPhases = [];
  String? _selectedPhase;

  @override
  void initState() {
    super.initState();

    debugPrint('idFaseCultivo recebido: ${widget.idFaseCultivo}');
    debugPrint('idLote: ${widget.idLote}');
    debugPrint('idCogumelo: ${widget.idCogumelo}');

    // Primeiro carrega as fases
    _carregarFasesCultivo().then((_) {
      // Depois que as fases carregarem, decide como carregar os parâmetros
      if (widget.idFaseCultivo != null) {
        debugPrint('Fase selecionada inicialmente: ${widget.idFaseCultivo}');
        _selectedPhase = widget.idFaseCultivo.toString();
        _carregarParametrosPorFase(_selectedPhase!);
      } else {
        debugPrint('Nenhuma fase recebida - carregando parâmetros atuais');
        _carregarParametrosAtuais();
      }
    });
  }

  Future<void> _carregarParametrosAtuais() async {
    try {
      final response = await http.get(
        Uri.parse(
          '${getApiBaseUrl()}framework/parametros/listarIdParametro/${widget.idLote}',
        ),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final parametros = ParametrosIdLote.fromJson(data);

        setState(() {
          _temperaturaMin = double.parse(parametros.temperaturaMin ?? '0');
          _temperaturaMax = double.parse(parametros.temperaturaMax ?? '0');
          _umidadeMin = double.parse(parametros.umidadeMin ?? '0');
          _umidadeMax = double.parse(parametros.umidadeMax ?? '0');
          _co2Max = double.parse(parametros.co2Max ?? '0');

          _loading = false;
        });
      } else if (response.statusCode == 404) {
        final data = jsonDecode(response.body);
        setState(() {
          _errorMessage = data['error'] ?? 'Configuração não existe';
          _loading = false;
        });
      } else {
        throw Exception('Erro HTTP ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Falha ao carregar: ${e.toString()}';
        _loading = false;
      });
    }
  }

  Future<void> _carregarParametrosPorFase(String idFase) async {
    setState(() => _loading = true); // 👈 Adicione isso

    try {
      final response = await http.get(
        Uri.parse(
          "${getApiBaseUrl()}framework/faseCultivo/listarIdFaseCultivo/$idFase",
        ),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          _temperaturaMin =
              double.tryParse(data['temperaturaMin'].toString()) ??
              _temperaturaMin;
          _temperaturaMax =
              double.tryParse(data['temperaturaMax'].toString()) ??
              _temperaturaMax;
          _umidadeMin =
              double.tryParse(data['umidadeMin'].toString()) ?? _umidadeMin;
          _umidadeMax =
              double.tryParse(data['umidadeMax'].toString()) ?? _umidadeMax;
          _co2Max = double.tryParse(data['co2Max'].toString()) ?? _co2Max;
          _loading = false; // 👈 E isso
        });
      } else {
        throw Exception("Erro HTTP ${response.statusCode}");
      }
    } catch (e) {
      setState(() => _loading = false); // 👈 E isso no catch
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Falha ao carregar parâmetros: $e")),
        );
      }
    }
  }

  Future<void> _salvarParametros() async {
    if (_selectedPhase == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Selecione uma fase de cultivo')),
        );
      }
      return;
    }

    try {
      final response = await http.put(
        Uri.parse('${getApiBaseUrl()}configuracao.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'idLote': widget.idLote,
          'temperaturaMin': _temperaturaMin,
          'temperaturaMax': _temperaturaMax,
          'umidadeMin': _umidadeMin,
          'umidadeMax': _umidadeMax,
          'co2Max': _co2Max,
          'idFaseCultivo': int.tryParse(_selectedPhase!) ?? 0, // 👈 garante INT
        }),
      );

      if (response.statusCode == 200) {
        if (mounted) {
          Navigator.pop(context, true);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Sucesso ao salvar parâmetros!')),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao salvar: ${response.body}')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro: ${e.toString()}')));
      }
    }
  }

  Future<void> _carregarFasesCultivo() async {
    if (widget.idCogumelo == null) {
      setState(() {
        _erroPhases = 'ID do cogumelo não fornecido';
        _loadingPhases = false;
      });
      return;
    }

    setState(() {
      _loadingPhases = true;
      _erroPhases = null;
    });

    try {
      final url = Uri.parse(
        "${getApiBaseUrl()}framework/faseCultivo/listarPorCogumelo/${widget.idCogumelo}",
      );

      final response = await http.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final dynamic data = jsonDecode(response.body);
        List<FaseCultivo> fases = [];

        // Processa diferentes formatos de resposta
        if (data is List) {
          fases =
              data
                  .map<FaseCultivo>((json) => FaseCultivo.fromJson(json))
                  .toList();
        } else if (data is Map<String, dynamic>) {
          if (data['success'] == true) {
            if (data['data'] is List) {
              fases =
                  (data['data'] as List)
                      .map<FaseCultivo>((json) => FaseCultivo.fromJson(json))
                      .toList();
            } else if (data['data'] is Map && data['data']['fases'] is List) {
              fases =
                  (data['data']['fases'] as List)
                      .map<FaseCultivo>((json) => FaseCultivo.fromJson(json))
                      .toList();
            } else if (data['fases'] is List) {
              fases =
                  (data['fases'] as List)
                      .map<FaseCultivo>((json) => FaseCultivo.fromJson(json))
                      .toList();
            }
          } else {
            throw Exception(data['message'] ?? 'Erro ao carregar fases');
          }
        }

        setState(() {
          _cultivationPhases = fases;
          _loadingPhases = false;
        });
      } else {
        throw Exception('Erro HTTP ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _erroPhases = 'Falha ao carregar fases: ${e.toString()}';
        _loadingPhases = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Editar Parâmetros'),
      body:
          _loading
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage.isNotEmpty
              ? Center(child: Text(_errorMessage))
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 24,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Center(
                              child: Text(
                                'Dados do Lote',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: defaultPadding),
                            DropdownButtonFormField<String>(
                              decoration: InputDecoration(
                                labelText: 'Fase de Cultivo',
                                border: const OutlineInputBorder(),
                                prefixIcon: const Icon(Icons.timeline),
                              ),
                              value: _selectedPhase,
                              items:
                                  _cultivationPhases.map((fase) {
                                    return DropdownMenuItem<String>(
                                      value: fase.idFaseCultivo.toString(),
                                      child: Text(fase.nomeFaseCultivo),
                                    );
                                  }).toList(),
                              onChanged:
                                  _loadingPhases
                                      ? null
                                      : (value) {
                                        setState(() => _selectedPhase = value);
                                        if (value != null) {
                                          _carregarParametrosPorFase(value);
                                        }
                                      },
                              hint:
                                  _loadingPhases
                                      ? const Text("Carregando fases...")
                                      : _erroPhases != null
                                      ? Text(_erroPhases!)
                                      : const Text("Selecione uma fase"),
                              icon:
                                  _loadingPhases
                                      ? const SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                      : const Icon(Icons.arrow_drop_down),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: defaultPadding),
                    _buildTemperaturaSlider(),
                    _buildUmidadeSlider(),
                    _buildCo2Slider(),
                    const SizedBox(height: defaultPadding),
                    ElevatedButton.icon(
                      onPressed: _salvarParametros,
                      icon: const Icon(Icons.save, color: Colors.white),
                      label: const Text(
                        'Salvar Parâmetros',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
    );
  }

  Widget _buildTemperaturaSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Temperatura Mínima (°C)',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        Slider(
          value: _temperaturaMin,
          min: 10,
          max: 28,
          divisions: 10,
          label: _temperaturaMin.toStringAsFixed(1),
          onChanged: (value) => setState(() => _temperaturaMin = value),
        ),
        const Text(
          'Temperatura Máxima (°C)',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        Slider(
          value: _temperaturaMax,
          min: 20,
          max: 30,
          divisions: 10,
          label: _temperaturaMax.toStringAsFixed(1),
          onChanged: (value) => setState(() => _temperaturaMax = value),
        ),
      ],
    );
  }

  Widget _buildUmidadeSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Umidade Mínima (%)',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        Slider(
          value: _umidadeMin,
          min: 50,
          max: 90,
          divisions: 20,
          label: _umidadeMin.toStringAsFixed(1),
          onChanged: (value) => setState(() => _umidadeMin = value),
        ),
        const Text(
          'Umidade Máxima (%)',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        Slider(
          value: _umidadeMax,
          min: 60,
          max: 100,
          divisions: 20,
          label: _umidadeMax.toStringAsFixed(1),
          onChanged: (value) => setState(() => _umidadeMax = value),
        ),
      ],
    );
  }

  Widget _buildCo2Slider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'CO₂ Máximo (ppm)',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        Slider(
          value: _co2Max,
          min: 500,
          max: 5000,
          divisions: 25,
          label: _co2Max.toStringAsFixed(0),
          onChanged: (value) => setState(() => _co2Max = value),
        ),
      ],
    );
  }
}

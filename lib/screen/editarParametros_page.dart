import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:smartmushroom_app/constants.dart';
import 'package:http/http.dart' as http;
import 'package:smartmushroom_app/screen/widgets/custom_app_bar.dart';
import 'dart:async';

class EditarParametrosPage extends StatefulWidget {
  final String idLote;

  const EditarParametrosPage({super.key, required this.idLote});

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
  List<Map<String, dynamic>> _cultivationPhases = [];
  String? _selectedPhase;

  @override
  void initState() {
    super.initState();
    _carregarParametrosAtuais();
    _carregarFasesCultivo();
  }

  Future<void> _carregarParametrosAtuais() async {
    try {
      final response = await http.get(
        Uri.parse('${getApiBaseUrl()}configuracao.php?idLote=${widget.idLote}'),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (data['configuracao'] != null) {
          setState(() {
            _temperaturaMin = double.parse(
              data['configuracao']['temperaturaMin'],
            );
            _temperaturaMax = double.parse(
              data['configuracao']['temperaturaMax'],
            );
            _umidadeMin = double.parse(data['configuracao']['umidadeMin']);
            _umidadeMax = double.parse(data['configuracao']['umidadeMax']);
            _co2Max = double.parse(data['configuracao']['co2Max']);
            _loading = false;
          });
        } else {
          setState(() {
            _errorMessage = 'Configurações padrão carregadas';
            _loading = false;
          });
        }
      } else if (response.statusCode == 404) {
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

  Future<void> _salvarParametros() async {
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
          'idFaseCultivo': _selectedPhase,
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
    setState(() {
      _loadingPhases = true;
      _erroPhases = null;
    });

    try {
      final url = Uri.parse('${getApiBaseUrl()}lote.php?action=fases-cultivo');
      final response = await http.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          setState(() {
            _cultivationPhases = List<Map<String, dynamic>>.from(data['data']);
            _loadingPhases = false;
          });
        } else {
          throw Exception(data['message'] ?? 'Erro ao carregar fases');
        }
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
                    // Card para Sala
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
                            // Dropdown Fase (agora dinâmico)
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
                                      value: fase['idFaseCultivo'].toString(),
                                      child: Text(fase['nomeFaseCultivo']),
                                    );
                                  }).toList(),
                              onChanged:
                                  _loadingPhases
                                      ? null
                                      : (value) => setState(
                                        () => _selectedPhase = value,
                                      ),
                              hint:
                                  _loadingPhases
                                      ? const Text("Carregando fases...")
                                      : _erroPhases != null
                                      ? Text(_erroPhases!)
                                      : const Text("Selecione uma fase"),
                              disabledHint:
                                  _loadingPhases
                                      ? const Text("Carregando fases...")
                                      : _erroPhases != null
                                      ? Text(_erroPhases!)
                                      : const Text("Nenhuma fase disponível"),
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
          min: 18,
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
          max: 3000,
          divisions: 25,
          label: _co2Max.toStringAsFixed(0),
          onChanged: (value) => setState(() => _co2Max = value),
        ),
      ],
    );
  }
}

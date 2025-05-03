import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:smartmushroom_app/constants.dart';
import 'package:http/http.dart' as http;
import 'package:smartmushroom_app/screen/widgets/custom_app_bar.dart';

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
  int _idSala = 0;

  @override
  void initState() {
    super.initState();
    _carregarParametrosAtuais();
  }

  Future<void> _carregarParametrosAtuais() async {
    try {
      final response = await http.get(
        // Uri.parse('${getApiBaseUrl()}configuracao.php?idLote=${widget.idLote}'),
        Uri.parse('${getApiBaseUrl()}configuracao.php?idLote=1'),
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
            _idSala = data['idSala'] ?? '';
            _loading = false;
          });
        } else {
          setState(() {
            _errorMessage = 'Configurações padrão carregadas';
            _idSala = data['idSala'] ?? '';
            _loading = false;
          });
        }
      } else if (response.statusCode == 404) {
        setState(() {
          _errorMessage = data['error'] ?? 'Configuração não existe';
          _idSala = data['idSala'] ?? '';
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
        }),
      );

      if (response.statusCode == 200) {
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro: ${e.toString()}')));
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
                    _buildTemperaturaSlider(),
                    _buildUmidadeSlider(),
                    _buildCo2Slider(),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: _salvarParametros,
                      child: const Text('SALVAR ALTERAÇÕES'),
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

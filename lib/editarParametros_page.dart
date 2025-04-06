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
  double _temperatura = 24;
  double _umidade = 70;
  double _co2 = 1500;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _carregarParametrosAtuais();
  }

  Future<void> _carregarParametrosAtuais() async {
    try {
      final response = await http.get(
        Uri.parse('${apiBaseUrl}configuracao.php?idLote=${widget.idLote}'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _temperatura = data['temperatura'];
          _umidade = data['umidade'];
          _co2 = data['co2'];
          _loading = false;
        });
      }
    } catch (e) {
      debugPrint('Erro ao carregar parâmetros: $e');
    }
  }

  Future<void> _salvarParametros() async {
    try {
      final response = await http.put(
        Uri.parse('${apiBaseUrl}configuracao.php'),
        body: {
          'idLote': widget.idLote,
          'temperatura': _temperatura.toString(),
          'umidade': _umidade.toString(),
          'co2': _co2.toString(),
        },
      );

      if (response.statusCode == 200) {
        Navigator.pop(context);
      }
    } catch (e) {
      debugPrint('Erro ao salvar parâmetros: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Editar Salas'),
      body:
          _loading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Slider(
                      value: _temperatura,
                      min: 18,
                      max: 30,
                      label: 'Temperatura: ${_temperatura.round()}°C',
                      onChanged:
                          (value) => setState(() => _temperatura = value),
                    ),
                    Slider(
                      value: _umidade,
                      min: 0,
                      max: 100,
                      label: 'Umidade: ${_umidade.round()}%',
                      onChanged: (value) => setState(() => _umidade = value),
                    ),
                    Slider(
                      value: _co2,
                      min: 0,
                      max: 3000,
                      label: 'CO₂: ${_co2.round()}ppm',
                      onChanged: (value) => setState(() => _co2 = value),
                    ),
                    ElevatedButton(
                      onPressed: _salvarParametros,
                      child: const Text('Salvar Alterações'),
                    ),
                  ],
                ),
              ),
    );
  }
}

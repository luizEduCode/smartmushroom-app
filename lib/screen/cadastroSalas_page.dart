import 'package:flutter/material.dart';
import 'package:smartmushroom_app/constants.dart';
import 'package:smartmushroom_app/screen/sala_page.dart';

class CadastrosalasPage extends StatefulWidget {
  const CadastrosalasPage({super.key});

  @override
  State<CadastrosalasPage> createState() => _CadastrosalasPageState();
}

class _CadastrosalasPageState extends State<CadastrosalasPage> {
  // Controlador para o campo "Nome da Sala"
  final TextEditingController _salaController = TextEditingController();

  // Dropdown: Tipo de cogumelo e fase de cultivo
  String? _selectedMushroom;
  String? _selectedPhase;

  final List<String> mushroomTypes = [
    'Shimeji Branco',
    'Shitake',
    'Paris',
    'Ganoderma',
  ];

  final List<String> cultivationPhases = [
    'Colonização',
    'Indução',
    'Frutificação',
  ];

  // Switch para setar parâmetros padrão
  bool setarPadraoFase = false;

  // Valores dos sliders
  double temperatura = 24;
  double umidade = 70;
  double co2 = 1500;
  double iluminacao = 12;

  void _onSalvar() {
    debugPrint(
      'Salvando sala...\n'
      'Nome da Sala: ${_salaController.text}\n'
      'Tipo de Cogumelo: $_selectedMushroom\n'
      'Fase de Cultivo: $_selectedPhase\n'
      'Setar parâmetros padrão: $setarPadraoFase\n'
      'Temperatura: $temperatura\n'
      'Umidade: $umidade\n'
      'CO₂: $co2\n'
      'Luminosidade: $iluminacao\n',
    );
    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (context) => SalaPage(idLote: '1', nomeSala: _salaController.text),
      ),
    );
  }

  void _onFinalizar() {
    debugPrint('Finalizando lote...');
  }

  Widget _buildSlider({
    required String label,
    required IconData icon,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required String unit,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: Colors.grey[700]),
            const SizedBox(width: 8),
            Text(
              '$label: ${value.round()} $unit',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ],
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: divisions,
          label: '${value.round()} $unit',
          onChanged: onChanged,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Cadastro Salas",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ========= CARD: Dados da Sala =========
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
                        'Dados da Sala',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _salaController,
                      decoration: const InputDecoration(
                        labelText: 'Nome da Sala',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.meeting_room),
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Tipo do Cogumelo',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.eco),
                      ),
                      value: _selectedMushroom,
                      hint: const Text("Escolha um tipo de cogumelo"),
                      items:
                          mushroomTypes
                              .map(
                                (type) => DropdownMenuItem<String>(
                                  value: type,
                                  child: Text(type),
                                ),
                              )
                              .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedMushroom = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Fase de Cultivo',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.timeline),
                      ),
                      value: _selectedPhase,
                      hint: const Text("Escolha a fase do cultivo"),
                      items:
                          cultivationPhases
                              .map(
                                (phase) => DropdownMenuItem<String>(
                                  value: phase,
                                  child: Text(phase),
                                ),
                              )
                              .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedPhase = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // ========= CARD: Parâmetros da Fase =========
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
                        'Parâmetros da Fase',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Setar parâmetros padrão da fase'),
                      value: setarPadraoFase,
                      onChanged: (value) {
                        setState(() {
                          setarPadraoFase = value;
                          if (setarPadraoFase) {
                            temperatura = 24;
                            umidade = 70;
                            co2 = 1500;
                            iluminacao = 12;
                          }
                        });
                      },
                    ),
                    const Divider(),
                    _buildSlider(
                      label: 'Temperatura',
                      icon: Icons.thermostat,
                      value: temperatura,
                      min: 18,
                      max: 30,
                      divisions: 12,
                      unit: '°C',
                      onChanged: (value) {
                        setState(() {
                          temperatura = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildSlider(
                      label: 'Umidade',
                      icon: Icons.water_drop_outlined,
                      value: umidade,
                      min: 0,
                      max: 100,
                      divisions: 100,
                      unit: '%',
                      onChanged: (value) {
                        setState(() {
                          umidade = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildSlider(
                      label: 'CO₂',
                      icon: Icons.co2_outlined,
                      value: co2,
                      min: 0,
                      max: 3000,
                      divisions: 60,
                      unit: 'ppm',
                      onChanged: (value) {
                        setState(() {
                          co2 = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildSlider(
                      label: 'Luminosidade',
                      icon: Icons.lightbulb_outline,
                      value: iluminacao,
                      min: 0,
                      max: 24,
                      divisions: 24,
                      unit: '',
                      onChanged: (value) {
                        setState(() {
                          iluminacao = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // ========= BOTÕES =========
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton.icon(
                  onPressed: _onSalvar,
                  icon: const Icon(Icons.save),
                  label: const Text('Salvar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.greenAccent,

                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:smartmushroom_app/constants.dart';
import 'package:smartmushroom_app/screen/sala_page.dart';
import 'package:smartmushroom_app/screen/widgets/custom_app_bar.dart';

class CriarLotePage extends StatefulWidget {
  const CriarLotePage({super.key});

  @override
  State<CriarLotePage> createState() => _CriarLotePageState();
}

class _CriarLotePageState extends State<CriarLotePage> {
  // Lista de salas (consultada via API)
  List<Map<String, dynamic>> _salasFinalizadas = [];
  String? _selectedSala;
  bool _loadingSalas = true;
  String? _erroSalas;

  // Listas fixas conforme solicitado
  final List<String> mushroomTypes = ['Shimeji', 'Champignon', 'Shitake'];

  final List<String> cultivationPhases = ['Colonização', 'Frutificação'];

  String? _selectedMushroom;
  String? _selectedPhase;

  @override
  void initState() {
    super.initState();
    _carregarSalasFinalizadas();
  }

  Future<void> _carregarSalasFinalizadas() async {
    setState(() {
      _loadingSalas = true;
      _erroSalas = null;
    });

    try {
      final url = Uri.parse('${apiBaseUrl}lote.php?action=salas-disponiveis');
      debugPrint('Tentando acessar: $url');

      final response = await http
          .get(url, headers: {'Accept': 'application/json'})
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          setState(() {
            _salasFinalizadas = List<Map<String, dynamic>>.from(
              data['data']['salas_disponiveis'],
            );
            _loadingSalas = false;
          });
        } else {
          throw Exception(data['message'] ?? 'Erro na API');
        }
      } else {
        throw Exception('Erro HTTP ${response.statusCode}');
      }
    } on TimeoutException {
      setState(() {
        _erroSalas = 'Timeout: Servidor não respondeu';
        _loadingSalas = false;
      });
    } catch (e) {
      setState(() {
        _erroSalas = 'Falha ao carregar salas: ${e.toString()}';
        _loadingSalas = false;
      });
      debugPrint('Erro detalhado: $e');
    }
  }

  Future<void> _criarLote() async {
    if (_selectedSala == null ||
        _selectedMushroom == null ||
        _selectedPhase == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Preencha todos os campos')));
      return;
    }

    try {
      // Encontra a sala selecionada
      final salaSelecionada = _salasFinalizadas.firstWhere(
        (sala) => sala['nomeSala'] == _selectedSala,
      );

      // Mapeia os nomes para IDs
      final Map<String, int> cogumeloIds = {
        'Shimeji': 1,
        'Champignon': 2,
        'Shitake': 3,
      };

      final Map<String, int> faseIds = {'Colonização': 1, 'Frutificação': 2};

      // Valores padrão para as leituras iniciais
      // const double temperaturaInicial = 25.0;
      // const double umidadeInicial = 70.0;
      // const int co2Inicial = 800;
      // const int luzInicial = 1;

      final response = await http
          .post(
            Uri.parse('${apiBaseUrl}lote.php'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'idSala': salaSelecionada['idSala'],
              'idCogumelo': cogumeloIds[_selectedMushroom],
              'idFase': faseIds[_selectedPhase],
              // 'temperatura': temperaturaInicial,
              // 'umidade': umidadeInicial,
              // 'co2': co2Inicial,
              // 'luz': luzInicial,
            }),
          )
          .timeout(const Duration(seconds: 10));

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (responseData['success'] == true) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder:
                  (context) => SalaPage(
                    idLote: responseData['idLote'].toString(),
                    nomeSala: _selectedSala!,
                  ),
            ),
          );
        } else {
          throw Exception(responseData['message'] ?? 'Erro ao criar lote');
        }
      } else {
        throw Exception(
          'Erro HTTP ${response.statusCode}: ${responseData['message']}',
        );
      }
    } on FormatException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Formato de resposta inválido do servidor'),
        ),
      );
      debugPrint('FormatException: $e');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao criar lote: ${e.toString()}')),
      );
      debugPrint('Erro ao criar lote: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Criar Novo Lote'),
      body: SingleChildScrollView(
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
                    const SizedBox(height: 16),
                    // Dropdown Sala (consulta API)
                    _loadingSalas
                        ? const LinearProgressIndicator()
                        : _erroSalas != null
                        ? Text(
                          _erroSalas!,
                          style: const TextStyle(color: Colors.red),
                        )
                        : DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            labelText: 'Sala Disponível',
                            border: const OutlineInputBorder(),
                            prefixIcon: const Icon(Icons.meeting_room),
                            filled: true,
                            fillColor:
                                (_loadingSalas ||
                                        _erroSalas != null ||
                                        _salasFinalizadas.isEmpty)
                                    ? Colors.grey[200]
                                    : null,
                          ),
                          value: _selectedSala,
                          items:
                              _salasFinalizadas.map((sala) {
                                return DropdownMenuItem<String>(
                                  value: sala['nomeSala'],
                                  child: Text(sala['nomeSala']),
                                );
                              }).toList(),
                          // Isso é o que realmente desabilita o dropdown
                          onChanged:
                              (_loadingSalas ||
                                      _erroSalas != null ||
                                      _salasFinalizadas.isEmpty)
                                  ? null
                                  : (value) =>
                                      setState(() => _selectedSala = value),
                          // Dicas condicionais
                          hint:
                              _loadingSalas
                                  ? const Text("Carregando salas...")
                                  : _erroSalas != null
                                  ? Text(_erroSalas!)
                                  : _salasFinalizadas.isEmpty
                                  ? const Text("Nenhuma sala disponível")
                                  : const Text("Selecione uma sala"),
                          // Texto quando desabilitado
                          disabledHint:
                              _loadingSalas
                                  ? const Text("Carregando salas...")
                                  : _erroSalas != null
                                  ? Text(_erroSalas!)
                                  : const Text("Nenhuma sala disponível"),
                          // Ícone condicional
                          icon:
                              _loadingSalas
                                  ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                  : const Icon(Icons.arrow_drop_down),
                        ),
                    const SizedBox(height: 16),
                    // Dropdown Cogumelo (dados fixos)
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Tipo de Cogumelo',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.eco),
                      ),
                      value: _selectedMushroom,
                      items:
                          mushroomTypes.map((type) {
                            return DropdownMenuItem<String>(
                              value: type,
                              child: Text(type),
                            );
                          }).toList(),
                      onChanged:
                          (value) => setState(() => _selectedMushroom = value),
                      hint: const Text("Selecione um cogumelo"),
                    ),
                    const SizedBox(height: 16),
                    // Dropdown Fase (dados fixos)
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Fase de Cultivo',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.timeline),
                      ),
                      value: _selectedPhase,
                      items:
                          cultivationPhases.map((phase) {
                            return DropdownMenuItem<String>(
                              value: phase,
                              child: Text(phase),
                            );
                          }).toList(),
                      onChanged:
                          (value) => setState(() => _selectedPhase = value),
                      hint: const Text("Selecione uma fase"),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Botão Criar Lote
            ElevatedButton.icon(
              onPressed: _criarLote,
              icon: const Icon(Icons.save, color: Colors.white),
              label: const Text(
                'Criar Lote',
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
}

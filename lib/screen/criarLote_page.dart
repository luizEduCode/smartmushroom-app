import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:smartmushroom_app/constants.dart';
import 'package:smartmushroom_app/screen/sala_page.dart';
import 'package:smartmushroom_app/screen/widgets/custom_app_bar.dart';
import 'package:smartmushroom_app/models/fases_cultivo_model.dart';
import 'package:smartmushroom_app/models/cogumelos_model.dart';
import 'package:smartmushroom_app/models/salas_disponiveis_model.dart';

class CriarLotePage extends StatefulWidget {
  const CriarLotePage({super.key});

  @override
  State<CriarLotePage> createState() => _CriarLotePageState();
}

class _CriarLotePageState extends State<CriarLotePage> {
  List<SalaDisponivel> _salasFinalizadas = [];
  SalaDisponivel? _selectedSala;
  bool _loadingSalas = true;
  String? _erroSalas;

  List<cogumelos> _mushroomTypes = [];
  List<fases_cultivo> _cultivationPhases = [];
  cogumelos? _selectedMushroom;
  fases_cultivo? _selectedPhase;
  bool _loadingMushrooms = true;
  bool _loadingPhases = true;
  String? _erroMushrooms;
  String? _erroPhases;

  @override
  void initState() {
    super.initState();
    _carregarSalasFinalizadas();
    _carregarTiposCogumelos();
  }

  Future<void> _carregarSalasFinalizadas() async {
    setState(() {
      _loadingSalas = true;
      _erroSalas = null;
    });

    try {
      final url = Uri.parse(
        "${getApiBaseUrl()}framework/lote/listarSalasDisponiveis",
      );
      final response = await http.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final dynamic data = jsonDecode(response.body);

        // Verificar se a resposta é uma lista diretamente
        if (data is List) {
          _salasFinalizadas =
              data.map((json) => SalaDisponivel.fromJson(json)).toList();
        }
        // Verificar se a resposta é um mapa com estrutura esperada
        else if (data is Map<String, dynamic>) {
          if (data['success'] == true) {
            List<dynamic> salasList = [];

            if (data['data'] is List) {
              salasList = data['data'];
            } else if (data['data'] is Map &&
                data['data']['salas_disponiveis'] is List) {
              salasList = data['data']['salas_disponiveis'];
            } else if (data['salas_disponiveis'] is List) {
              salasList = data['salas_disponiveis'];
            }

            _salasFinalizadas =
                salasList.map((json) => SalaDisponivel.fromJson(json)).toList();
          } else {
            _erroSalas = data['message'] ?? 'Erro ao carregar salas';
          }
        } else {
          _erroSalas = 'Formato de resposta inesperado da API';
        }
      } else {
        _erroSalas = 'Erro HTTP ${response.statusCode}';
      }
    } catch (e) {
      _erroSalas = 'Falha ao carregar salas: $e';
    } finally {
      if (mounted) setState(() => _loadingSalas = false);
    }
  }

  Future<void> _carregarTiposCogumelos() async {
    setState(() {
      _loadingMushrooms = true;
      _erroMushrooms = null;
    });

    try {
      final url = Uri.parse("${getApiBaseUrl()}framework/cogumelo/listarTodos");
      final response = await http.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final dynamic data = jsonDecode(response.body);

        // Verificar se a resposta é uma lista diretamente
        if (data is List) {
          _mushroomTypes =
              data.map((json) {
                try {
                  return cogumelos.fromJson(json);
                } catch (_) {
                  return cogumelos(
                    idCogumelo: 0,
                    nomeCogumelo: 'Erro no parsing',
                    descricao: 'Erro no parsing',
                  );
                }
              }).toList();
        }
        // Verificar se a resposta é um mapa com estrutura esperada
        else if (data is Map<String, dynamic>) {
          if (data['success'] == true) {
            List<dynamic> cogumelosList = [];

            if (data['data'] is List) {
              cogumelosList = data['data'];
            } else if (data['data'] is Map &&
                data['data']['cogumelos'] is List) {
              cogumelosList = data['data']['cogumelos'];
            } else if (data['cogumelos'] is List) {
              cogumelosList = data['cogumelos'];
            }

            _mushroomTypes =
                cogumelosList.map((json) {
                  try {
                    return cogumelos.fromJson(json);
                  } catch (_) {
                    return cogumelos(
                      idCogumelo: 0,
                      nomeCogumelo: 'Erro no parsing',
                      descricao: 'Erro no parsing',
                    );
                  }
                }).toList();
          } else {
            _erroMushrooms = data['message'] ?? 'Erro ao carregar cogumelos';
          }
        } else {
          _erroMushrooms = 'Formato de resposta inesperado da API';
        }
      } else {
        _erroMushrooms = 'Erro HTTP ${response.statusCode}';
      }
    } catch (e) {
      _erroMushrooms = 'Falha ao carregar cogumelos: $e';
    } finally {
      if (mounted) setState(() => _loadingMushrooms = false);
    }
  }

  Future<void> _carregarFasesCultivo() async {
    if (_selectedMushroom == null) return;

    setState(() {
      _loadingPhases = true;
      _erroPhases = null;
    });

    try {
      final url = Uri.parse(
        "${getApiBaseUrl()}framework/faseCultivo/listarPorCogumelo/${_selectedMushroom!.idCogumelo}",
      );
      final response = await http.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final dynamic data = jsonDecode(response.body);

        // Verificar se a resposta é uma lista diretamente
        if (data is List) {
          _cultivationPhases =
              data.map((json) {
                try {
                  return fases_cultivo.fromJson(json);
                } catch (_) {
                  return fases_cultivo(
                    idFaseCultivo: 0,
                    nomeFaseCultivo: 'Erro no parsing',
                  );
                }
              }).toList();
        }
        // Verificar se a resposta é um mapa com estrutura esperada
        else if (data is Map<String, dynamic>) {
          if (data['success'] == true) {
            List<dynamic> fasesList = [];

            if (data['data'] is List) {
              fasesList = data['data'];
            } else if (data['data'] is Map && data['data']['fases'] is List) {
              fasesList = data['data']['fases'];
            } else if (data['fases'] is List) {
              fasesList = data['fases'];
            }

            _cultivationPhases =
                fasesList.map((json) {
                  try {
                    return fases_cultivo.fromJson(json);
                  } catch (_) {
                    return fases_cultivo(
                      idFaseCultivo: 0,
                      nomeFaseCultivo: 'Erro no parsing',
                    );
                  }
                }).toList();
          } else {
            _erroPhases = data['message'] ?? 'Erro ao carregar fases';
          }
        } else {
          _erroPhases = 'Formato de resposta inesperado da API';
        }
      } else {
        _erroPhases = 'Erro HTTP ${response.statusCode}';
      }
    } catch (e) {
      _erroPhases = 'Falha ao carregar fases: $e';
    } finally {
      if (mounted) setState(() => _loadingPhases = false);
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
      final url = Uri.parse('${getApiBaseUrl()}framework/lote/adicionar');
      final now = DateTime.now();
      final dataInicio =
          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

      final response = await http.post(
        url,
        headers: {'Accept': 'application/json'},
        body: {
          'idSala': _selectedSala!.idSala.toString(),
          'idCogumelo': _selectedMushroom!.idCogumelo.toString(),
          'dataInicio': dataInicio,
          'status': 'ativo',
          'faseCultivo': _selectedPhase!.idFaseCultivo.toString(),
        },
      );

      if (response.statusCode == 201) {
        final responseData = jsonDecode(response.body);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lote criado com sucesso!')),
        );

        final idLote = responseData['idLote']?.toString() ?? '0';

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder:
                (context) =>
                    SalaPage(idLote: idLote, nomeSala: _selectedSala!.nomeSala),
          ),
        );
      } else {
        throw Exception('Erro HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      debugPrint('Erro: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao criar lote: ${e.toString()}')),
      );
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
                    _buildSalaDropdown(),
                    const SizedBox(height: 16),
                    _buildCogumeloDropdown(),
                    const SizedBox(height: 16),
                    _buildFaseDropdown(),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
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

  Widget _buildSalaDropdown() {
    if (_loadingSalas) {
      return const Column(
        children: [
          LinearProgressIndicator(),
          SizedBox(height: 8),
          Text('Carregando salas...', style: TextStyle(color: Colors.grey)),
        ],
      );
    }

    if (_erroSalas != null) {
      return Text(
        _erroSalas!,
        style: const TextStyle(color: Colors.red),
        textAlign: TextAlign.center,
      );
    }

    if (_salasFinalizadas.isEmpty) {
      return const Text(
        'Nenhuma sala disponível',
        style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
        textAlign: TextAlign.center,
      );
    }

    return DropdownButtonFormField<SalaDisponivel>(
      decoration: const InputDecoration(
        labelText: 'Sala Disponível',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.meeting_room),
      ),
      value: _selectedSala,
      items:
          _salasFinalizadas.map((sala) {
            return DropdownMenuItem<SalaDisponivel>(
              value: sala,
              child: Text(sala.nomeSala),
            );
          }).toList(),
      onChanged: (value) => setState(() => _selectedSala = value),
      hint: const Text("Selecione uma sala"),
    );
  }

  Widget _buildCogumeloDropdown() {
    if (_loadingMushrooms) {
      return const Column(
        children: [
          LinearProgressIndicator(),
          SizedBox(height: 8),
          Text('Carregando cogumelos...', style: TextStyle(color: Colors.grey)),
        ],
      );
    }

    if (_erroMushrooms != null) {
      return Text(
        _erroMushrooms!,
        style: const TextStyle(color: Colors.red),
        textAlign: TextAlign.center,
      );
    }

    if (_mushroomTypes.isEmpty) {
      return const Text(
        'Nenhum cogumelo disponível',
        style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
        textAlign: TextAlign.center,
      );
    }

    return DropdownButtonFormField<cogumelos>(
      decoration: const InputDecoration(
        labelText: 'Tipo de Cogumelo',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.eco),
      ),
      value: _selectedMushroom,
      items:
          _mushroomTypes.map((cogumelo) {
            return DropdownMenuItem<cogumelos>(
              value: cogumelo,
              child: Text(cogumelo.nomeCogumelo),
            );
          }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedMushroom = value;
          _selectedPhase = null;
          _cultivationPhases = [];
        });
        _carregarFasesCultivo();
      },
      hint: const Text("Selecione um cogumelo"),
    );
  }

  Widget _buildFaseDropdown() {
    if (_selectedMushroom == null) {
      return const Text(
        "Selecione primeiro um cogumelo",
        style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
        textAlign: TextAlign.center,
      );
    }

    if (_loadingPhases) {
      return const Column(
        children: [
          LinearProgressIndicator(),
          SizedBox(height: 8),
          Text('Carregando fases...', style: TextStyle(color: Colors.grey)),
        ],
      );
    }

    if (_erroPhases != null) {
      return Text(
        _erroPhases!,
        style: const TextStyle(color: Colors.red),
        textAlign: TextAlign.center,
      );
    }

    if (_cultivationPhases.isEmpty) {
      return const Text(
        'Nenhuma fase disponível para este cogumelo',
        style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
        textAlign: TextAlign.center,
      );
    }

    return DropdownButtonFormField<fases_cultivo>(
      decoration: const InputDecoration(
        labelText: 'Fase de Cultivo',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.timeline),
      ),
      value: _selectedPhase,
      items:
          _cultivationPhases.map((fase) {
            return DropdownMenuItem<fases_cultivo>(
              value: fase,
              child: Text(fase.nomeFaseCultivo ?? 'Fase sem nome'),
            );
          }).toList(),
      onChanged: (value) => setState(() => _selectedPhase = value),
      hint: const Text("Selecione uma fase"),
    );
  }
}

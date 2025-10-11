import 'dart:async';
import 'package:flutter/material.dart';
import 'package:smartmushroom_app/core/network/api_exception.dart';
import 'package:smartmushroom_app/core/network/dio_client.dart';
import 'package:smartmushroom_app/features/criar_lote/data/criar_lote_remote_datasource.dart';
import 'package:smartmushroom_app/models/fases_cultivo_model.dart';
import 'package:smartmushroom_app/models/cogumelos_model.dart';
import 'package:smartmushroom_app/models/salas_disponiveis_model.dart';
import 'package:smartmushroom_app/screen/sala_page.dart';
import 'package:smartmushroom_app/screen/widgets/custom_app_bar.dart';

class CriarLotePage extends StatefulWidget {
  const CriarLotePage({super.key});

  @override
  State<CriarLotePage> createState() => _CriarLotePageState();
}

class _CriarLotePageState extends State<CriarLotePage> {
  late final CriarLoteRemoteDataSource _dataSource;
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
    _dataSource = CriarLoteRemoteDataSource(DioClient());
    _carregarSalasFinalizadas();
    _carregarTiposCogumelos();
  }

  Future<void> _carregarSalasFinalizadas() async {
    setState(() {
      _loadingSalas = true;
      _erroSalas = null;
    });

    try {
      final salas = await _dataSource.fetchSalasDisponiveis();
      if (mounted) {
        setState(() {
          _salasFinalizadas = salas;
        });
      }
    } on ApiException catch (e) {
      if (mounted) {
        setState(() {
          _erroSalas = e.message;
        });
      } else {
        _erroSalas = e.message;
      }
    } catch (e) {
      final mensagem = 'Falha ao carregar salas: $e';
      if (mounted) {
        setState(() {
          _erroSalas = mensagem;
        });
      } else {
        _erroSalas = mensagem;
      }
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
      final cogumelosList = await _dataSource.fetchCogumelos();
      if (mounted) {
        setState(() {
          _mushroomTypes = cogumelosList;
        });
      }
    } on ApiException catch (e) {
      if (mounted) {
        setState(() {
          _erroMushrooms = e.message;
        });
      } else {
        _erroMushrooms = e.message;
      }
    } catch (e) {
      final mensagem = 'Falha ao carregar cogumelos: $e';
      if (mounted) {
        setState(() {
          _erroMushrooms = mensagem;
        });
      } else {
        _erroMushrooms = mensagem;
      }
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
      final fases =
          await _dataSource.fetchFasesPorCogumelo(_selectedMushroom!.idCogumelo);
      if (mounted) {
        setState(() {
          _cultivationPhases = fases;
        });
      }
    } on ApiException catch (e) {
      if (mounted) {
        setState(() {
          _erroPhases = e.message;
        });
      } else {
        _erroPhases = e.message;
      }
    } catch (e) {
      final mensagem = 'Falha ao carregar fases: $e';
      if (mounted) {
        setState(() {
          _erroPhases = mensagem;
        });
      } else {
        _erroPhases = mensagem;
      }
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
      final now = DateTime.now();
      final dataInicio =
          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

      final idLote = await _dataSource.criarLote(
        idSala: _selectedSala!.idSala,
        idCogumelo: _selectedMushroom!.idCogumelo,
        idFaseCultivo: _selectedPhase!.idFaseCultivo ?? 0,
        dataInicio: dataInicio,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lote criado com sucesso!')),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => SalaPage(
              idLote: idLote.isNotEmpty ? idLote : '0',
              nomeSala: _selectedSala!.nomeSala,
            ),
          ),
        );
      }
    } on ApiException catch (e) {
      debugPrint('Erro: ${e.message}');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao criar lote: ${e.message}')),
        );
      }
    } catch (e) {
      debugPrint('Erro: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao criar lote: ${e.toString()}')),
        );
      }
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

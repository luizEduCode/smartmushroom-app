import 'dart:async';
import 'package:flutter/material.dart';
import 'package:smartmushroom_app/core/network/api_exception.dart';
import 'package:smartmushroom_app/core/network/dio_client.dart';
import 'package:smartmushroom_app/features/criar_lote/data/criar_lote_remote_datasource.dart';
import 'package:smartmushroom_app/models/Antigas/cogumelos_model.dart';
import 'package:smartmushroom_app/models/Antigas/fases_cultivo_model.dart';
import 'package:smartmushroom_app/models/Antigas/salas_disponiveis_model.dart';
import 'package:smartmushroom_app/screen/sala_page.dart';
import 'package:smartmushroom_app/screen/widgets/custom_app_bar.dart';

const double _pagePadding = 20.0;

class CriarLotePage extends StatefulWidget {
  const CriarLotePage({super.key});

  @override
  State<CriarLotePage> createState() => _CriarLotePageState();
}

class _CriarLotePageState extends State<CriarLotePage> {
  late final CriarLoteRemoteDataSource _dataSource;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  List<SalaDisponivel> _salasFinalizadas = [];
  SalaDisponivel? _selectedSala;
  bool _loadingSalas = true;
  String? _erroSalas;

  List<Cogumelos> _mushroomTypes = [];
  List<fases_cultivo> _cultivationPhases = [];
  Cogumelos? _selectedMushroom;
  fases_cultivo? _selectedPhase;
  bool _loadingMushrooms = true;
  bool _loadingPhases = true;
  String? _erroMushrooms;
  String? _erroPhases;

  bool _isSubmitting = false;

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
      final selectedId = _selectedSala?.idSala;
      if (mounted) {
        setState(() {
          _salasFinalizadas = salas;
          _selectedSala =
              selectedId == null
                  ? null
                  : _firstWhereOrNull(
                    salas,
                    (sala) => sala.idSala == selectedId,
                  );
        });
      }
    } on ApiException catch (e) {
      if (mounted) {
        setState(() => _erroSalas = e.message);
      } else {
        _erroSalas = e.message;
      }
    } catch (e) {
      final mensagem = 'Falha ao carregar salas: $e';
      if (mounted) {
        setState(() => _erroSalas = mensagem);
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
      final selectedId = _selectedMushroom?.idCogumelo;
      if (mounted) {
        setState(() {
          _mushroomTypes = cogumelosList;
          _selectedMushroom =
              selectedId == null
                  ? null
                  : _firstWhereOrNull(
                    cogumelosList,
                    (cogumelo) => cogumelo.idCogumelo == selectedId,
                  );
        });
      }
    } on ApiException catch (e) {
      if (mounted) {
        setState(() => _erroMushrooms = e.message);
      } else {
        _erroMushrooms = e.message;
      }
    } catch (e) {
      final mensagem = 'Falha ao carregar cogumelos: $e';
      if (mounted) {
        setState(() => _erroMushrooms = mensagem);
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
      final fases = await _dataSource.fetchFasesPorCogumelo(
        _selectedMushroom!.idCogumelo,
      );
      final selectedId = _selectedPhase?.idFaseCultivo;
      if (mounted) {
        setState(() {
          _cultivationPhases = fases;
          _selectedPhase =
              selectedId == null
                  ? null
                  : _firstWhereOrNull(
                    fases,
                    (fase) => fase.idFaseCultivo == selectedId,
                  );
        });
      }
    } on ApiException catch (e) {
      if (mounted) {
        setState(() => _erroPhases = e.message);
      } else {
        _erroPhases = e.message;
      }
    } catch (e) {
      final mensagem = 'Falha ao carregar fases: $e';
      if (mounted) {
        setState(() => _erroPhases = mensagem);
      } else {
        _erroPhases = mensagem;
      }
    } finally {
      if (mounted) setState(() => _loadingPhases = false);
    }
  }

  Future<void> _refreshAll() async {
    await Future.wait([
      _carregarSalasFinalizadas(),
      _carregarTiposCogumelos(),
      if (_selectedMushroom != null) _carregarFasesCultivo(),
    ]);
  }

  Future<void> _criarLote() async {
    if (_isSubmitting) return;
    if (!(_formKey.currentState?.validate() ?? false)) {
      _showSnack('Preencha todas as informações para continuar.');
      return;
    }

    if (_selectedSala == null ||
        _selectedMushroom == null ||
        _selectedPhase == null) {
      _showSnack('Preencha todos os campos!');
      return;
    }

    final agora = DateTime.now();
    final dataInicio =
        '${agora.year}-${agora.month.toString().padLeft(2, '0')}-${agora.day.toString().padLeft(2, '0')}';

    try {
      setState(() => _isSubmitting = true);
      final idLote = await _dataSource.criarLote(
        idSala: _selectedSala!.idSala,
        idCogumelo: _selectedMushroom!.idCogumelo,
        idFaseCultivo: _selectedPhase!.idFaseCultivo ?? 0,
        dataInicio: dataInicio,
      );

      if (!mounted) return;
      _showSnack('Lote criado com sucesso!', isError: false);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder:
              (context) => SalaPage(
                idLote: idLote.isNotEmpty ? idLote : '0',
                nomeSala: _selectedSala!.nomeSala,
              ),
        ),
      );
    } on ApiException catch (e) {
      debugPrint('Erro: ${e.message}');
      if (mounted) {
        _showSnack('Erro ao criar lote: ${e.message}', isError: true);
      }
    } catch (e) {
      debugPrint('Erro: $e');
      if (mounted) {
        _showSnack('Erro ao criar lote: ${e.toString()}', isError: true);
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: const CustomAppBar(title: 'Criar Novo Lote'),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshAll,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(_pagePadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Crie um novo lote selecionando sala, cogumelo e fase.',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.75),
                  ),
                ),
                const SizedBox(height: 16),
                Form(
                  key: _formKey,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: theme.colorScheme.outlineVariant,
                      ),
                    ),
                    child: Column(
                      children: [
                        _buildSalaDropdown(context),
                        const SizedBox(height: 20),
                        _buildCogumeloDropdown(context),
                        const SizedBox(height: 20),
                        _buildFaseDropdown(context),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _isSubmitting ? null : _criarLote,
                    icon:
                        _isSubmitting
                            ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation(
                                  theme.colorScheme.onPrimary,
                                ),
                              ),
                            )
                            : const Icon(Icons.save),
                    label: Text(_isSubmitting ? 'Criando lote...' : 'Criar lote'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      textStyle: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSalaDropdown(BuildContext context) {
    if (_loadingSalas) {
      return _buildLoadingState('Carregando salas disponíveis...');
    }

    if (_erroSalas != null) {
      return _buildErrorState(_erroSalas!);
    }

    if (_salasFinalizadas.isEmpty) {
      return _buildInfoState(
        'Nenhuma sala disponível para novos lotes no momento.',
      );
    }

    return DropdownButtonFormField<SalaDisponivel>(
      decoration: _inputDecoration(
        context,
        label: 'Sala disponível',
        icon: Icons.meeting_room_outlined,
      ),
      initialValue : _selectedSala,
      items:
          _salasFinalizadas.map((sala) {
            return DropdownMenuItem<SalaDisponivel>(
              value: sala,
              child: Text(sala.nomeSala),
            );
          }).toList(),
      onChanged: (value) => setState(() => _selectedSala = value),
      validator: (value) => value == null ? 'Selecione uma sala.' : null,
      hint: const Text('Selecione uma sala'),
    );
  }

  Widget _buildCogumeloDropdown(BuildContext context) {
    if (_loadingMushrooms) {
      return _buildLoadingState('Carregando catálogo de cogumelos...');
    }

    if (_erroMushrooms != null) {
      return _buildErrorState(_erroMushrooms!);
    }

    if (_mushroomTypes.isEmpty) {
      return _buildInfoState(
        'Nenhum cogumelo disponível. Atualize ou tente novamente mais tarde.',
      );
    }

    return DropdownButtonFormField<Cogumelos>(
      decoration: _inputDecoration(
        context,
        label: 'Tipo de cogumelo',
        icon: Icons.eco_outlined,
      ),
      initialValue : _selectedMushroom,
      items:
          _mushroomTypes.map((cogumelo) {
            return DropdownMenuItem<Cogumelos>(
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
      validator: (value) => value == null ? 'Selecione um cogumelo.' : null,
      hint: const Text('Selecione um cogumelo'),
    );
  }

  Widget _buildFaseDropdown(BuildContext context) {
    if (_selectedMushroom == null) {
      return _buildInfoState(
        'Primeiro selecione um cogumelo para liberar as fases de cultivo.',
      );
    }

    if (_loadingPhases) {
      return _buildLoadingState('Carregando fases disponíveis...');
    }

    if (_erroPhases != null) {
      return _buildErrorState(_erroPhases!);
    }

    if (_cultivationPhases.isEmpty) {
      return _buildInfoState(
        'Nenhuma fase disponível para o cogumelo selecionado. Escolha outra espécie.',
      );
    }

    return DropdownButtonFormField<fases_cultivo>(
      decoration: _inputDecoration(
        context,
        label: 'Fase de cultivo',
        icon: Icons.timeline,
      ),
      initialValue : _selectedPhase,
      items:
          _cultivationPhases.map((fase) {
            return DropdownMenuItem<fases_cultivo>(
              value: fase,
              child: Text(fase.nomeFaseCultivo ?? 'Fase sem nome'),
            );
          }).toList(),
      onChanged: (value) => setState(() => _selectedPhase = value),
      validator: (value) => value == null ? 'Selecione uma fase.' : null,
      hint: const Text('Selecione uma fase'),
    );
  }

  InputDecoration _inputDecoration(
    BuildContext context, {
    required String label,
    required IconData icon,
  }) {
    final scheme = Theme.of(context).colorScheme;
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: scheme.surfaceVariant.withOpacity(0.35),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }

  Widget _buildLoadingState(String message) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const LinearProgressIndicator(),
        const SizedBox(height: 8),
        Text(message, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }

  Widget _buildErrorState(String message) {
    return Text(
      message,
      style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
      textAlign: TextAlign.start,
    );
  }

  Widget _buildInfoState(String message) {
    return Text(
      message,
      style: const TextStyle(
        color: Colors.grey,
        fontStyle: FontStyle.italic,
      ),
      textAlign: TextAlign.start,
    );
  }

  T? _firstWhereOrNull<T>(Iterable<T> items, bool Function(T item) predicate) {
    for (final item in items) {
      if (predicate(item)) return item;
    }
    return null;
  }

  void _showSnack(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor:
            isError
                ? Theme.of(context).colorScheme.error
                : Theme.of(context).colorScheme.primary,
      ),
    );
  }
}

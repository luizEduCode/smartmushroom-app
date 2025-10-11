import 'package:flutter/material.dart';
import 'package:smartmushroom_app/constants.dart';
import 'package:smartmushroom_app/core/network/api_exception.dart';
import 'package:smartmushroom_app/core/network/dio_client.dart';
import 'package:smartmushroom_app/features/editar_parametros/data/editar_parametros_remote_datasource.dart';
import 'package:smartmushroom_app/models/fases_cultivo_model.dart';
import 'package:smartmushroom_app/screen/widgets/custom_app_bar.dart';

class EditarParametrosPage extends StatefulWidget {
  final String idLote;
  final int? idCogumelo;
  final int? idFaseCultivo;

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
  late final EditarParametrosRemoteDataSource _dataSource;
  // Valores dos parâmetros
  double _temperaturaMin = 22;
  double _temperaturaMax = 26;
  double _umidadeMin = 65;
  double _umidadeMax = 75;
  double _co2Max = 1500;

  // Estados de carregamento e erro
  bool _loading = true;
  bool _loadingPhases = false;
  String _errorMessage = '';
  String? _erroPhases;

  // Controle de fases
  List<fases_cultivo> _cultivationPhases = [];
  String? _selectedPhase;
  static const String _semFase = 'nenhuma_fase';
  bool _valoresModificadosManual = false;
  int? _idFaseCultivoOriginal;
  bool _mantemFaseOriginal = true;

  @override
  void initState() {
    super.initState();
    _dataSource = EditarParametrosRemoteDataSource(DioClient());
    _inicializarDados();
  }

  void _inicializarDados() {
    debugPrint('idFaseCultivo recebido: ${widget.idFaseCultivo}');
    debugPrint('idLote: ${widget.idLote}');
    debugPrint('idCogumelo: ${widget.idCogumelo}');

    _idFaseCultivoOriginal = widget.idFaseCultivo;

    _carregarParametrosAtuais().then((_) {
      _carregarFasesCultivo();
    });
  }

  Future<void> _carregarParametrosAtuais() async {
    try {
      final parametros = await _dataSource.fetchParametros(widget.idLote);

      setState(() {
        _temperaturaMin = double.parse(parametros.temperaturaMin ?? '22');
        _temperaturaMax = double.parse(parametros.temperaturaMax ?? '26');
        _umidadeMin = double.parse(parametros.umidadeMin ?? '65');
        _umidadeMax = double.parse(parametros.umidadeMax ?? '75');
        _co2Max = double.parse(parametros.co2Max ?? '1500');
        _loading = false;
        _mantemFaseOriginal = true;
      });
    } on ApiException catch (e) {
      setState(() {
        _errorMessage = e.message;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Falha ao carregar: ${e.toString()}';
        _loading = false;
      });
    }
  }

  Future<void> _carregarParametrosPorFase(String idFase) async {
    if (_valoresModificadosManual) {
      setState(() => _loading = false);
      return;
    }

    setState(() => _loading = true);

    try {
      final fase = await _dataSource.fetchParametrosPorFase(idFase);

      if (fase != null) {
        setState(() {
          _temperaturaMin = fase.temperaturaMin ?? _temperaturaMin;
          _temperaturaMax = fase.temperaturaMax ?? _temperaturaMax;
          _umidadeMin = fase.umidadeMin ?? _umidadeMin;
          _umidadeMax = fase.umidadeMax ?? _umidadeMax;
          _co2Max = fase.co2Max ?? _co2Max;
          _loading = false;
        });
      } else {
        setState(() => _loading = false);
      }
    } on ApiException catch (e) {
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Falha ao carregar parâmetros: ${e.message}')),
        );
      }
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Falha ao carregar parâmetros: $e")),
        );
      }
    }
  }

  Future<void> _salvarParametros() async {
    try {
      final int? idFaseCultivoParaEnviar = _obterIdFaseParaEnviar();

      await _dataSource.salvarParametros(
        idLote: widget.idLote,
        temperaturaMin: _temperaturaMin,
        temperaturaMax: _temperaturaMax,
        umidadeMin: _umidadeMin,
        umidadeMax: _umidadeMax,
        co2Max: _co2Max,
        idFaseCultivo: idFaseCultivoParaEnviar,
      );

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sucesso ao salvar parâmetros!')),
        );
      }
    } on ApiException catch (e) {
      _mostrarErro('Erro: ${e.message}');
    } catch (e) {
      _mostrarErro('Erro: ${e.toString()}');
    }
  }

  int? _obterIdFaseParaEnviar() {
    if (_selectedPhase == _semFase && _mantemFaseOriginal) {
      return _idFaseCultivoOriginal;
    } else if (_selectedPhase == _semFase) {
      return null;
    } else {
      return int.tryParse(_selectedPhase!);
    }
  }

  void _mostrarErro(String mensagem) {
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(mensagem)));
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
      final fases = await _dataSource.fetchFasesPorCogumelo(widget.idCogumelo!);

      _removerFaseAtualDaLista(fases);

      setState(() {
        _cultivationPhases = fases;
        _loadingPhases = false;
        _selectedPhase = _semFase;
      });
    } on ApiException catch (e) {
      setState(() {
        _erroPhases = 'Falha ao carregar fases: ${e.message}';
        _loadingPhases = false;
      });
    } catch (e) {
      setState(() {
        _erroPhases = 'Falha ao carregar fases: ${e.toString()}';
        _loadingPhases = false;
      });
    }
  }

  void _removerFaseAtualDaLista(List<fases_cultivo> fases) {
    if (_idFaseCultivoOriginal != null) {
      fases.removeWhere((fase) => fase.idFaseCultivo == _idFaseCultivoOriginal);
    }
  }

  void _onFaseSelecionada(String? value) {
    setState(() {
      _selectedPhase = value;
      _mantemFaseOriginal = false;
    });

    if (value != null) {
      if (value == _semFase) {
        _carregarParametrosAtuais();
      } else {
        _carregarParametrosPorFase(value);
      }
    }
  }

  void _restaurarParametros() {
    if (_valoresModificadosManual) {
      setState(() {
        _valoresModificadosManual = false;
        _mantemFaseOriginal = true;
      });
      _carregarParametrosAtuais();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Editar Parâmetros'),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage.isNotEmpty) {
      return Center(child: Text(_errorMessage));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          if (_valoresModificadosManual) _buildBannerModificacao(),
          _buildCardDadosLote(),
          const SizedBox(height: defaultPadding),
          _buildTemperaturaSlider(),
          _buildUmidadeSlider(),
          _buildCo2Slider(),
          _buildBotoesAcao(),
        ],
      ),
    );
  }

  Widget _buildBannerModificacao() {
    return Container(
      padding: const EdgeInsets.all(8),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.amber[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Row(
        children: [
          Icon(Icons.info, color: Colors.amber),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Valores modificados manualmente',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardDadosLote() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Center(
              child: Text(
                'Dados do Lote',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: defaultPadding),
            _buildDropdownFaseCultivo(),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownFaseCultivo() {
    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(
        labelText: 'Fase de Cultivo',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.timeline),
      ),
      value: _selectedPhase,
      items: _buildDropdownItems(),
      onChanged: _loadingPhases ? null : _onFaseSelecionada,
      hint: _buildHintDropdown(),
      icon: _buildIconDropdown(),
    );
  }

  List<DropdownMenuItem<String>> _buildDropdownItems() {
    return [
      const DropdownMenuItem<String>(
        value: _semFase,
        child: Text('Parâmetros Atuais do Lote'),
      ),
      ..._cultivationPhases.map((fase) {
        return DropdownMenuItem<String>(
          value: (fase.idFaseCultivo ?? 0).toString(),
          child: Text(fase.nomeFaseCultivo ?? ''),
        );
      }).toList(),
    ];
  }

  Widget _buildHintDropdown() {
    if (_loadingPhases) {
      return const Text("Carregando fases...");
    } else if (_erroPhases != null) {
      return Text(_erroPhases!);
    } else {
      return const Text("Selecione uma fase");
    }
  }

  Widget _buildIconDropdown() {
    return _loadingPhases
        ? const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        )
        : const Icon(Icons.arrow_drop_down);
  }

  Widget _buildBotoesAcao() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _valoresModificadosManual ? _restaurarParametros : null,
            icon: const Icon(Icons.settings_backup_restore_rounded),
            label: const Text('Restaurar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        const SizedBox(width: defaultPadding),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _salvarParametros,
            icon: const Icon(Icons.save, color: Colors.white),
            label: const Text('Salvar', style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
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
          onChanged: _onTemperaturaMinChanged,
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
          onChanged: _onTemperaturaMaxChanged,
        ),
      ],
    );
  }

  void _onTemperaturaMinChanged(double value) {
    setState(() {
      _temperaturaMin = value;
      _valoresModificadosManual = true;
    });
  }

  void _onTemperaturaMaxChanged(double value) {
    setState(() {
      _temperaturaMax = value;
      _valoresModificadosManual = true;
    });
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
          onChanged: _onUmidadeMinChanged,
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
          onChanged: _onUmidadeMaxChanged,
        ),
      ],
    );
  }

  void _onUmidadeMinChanged(double value) {
    setState(() {
      _umidadeMin = value;
      _valoresModificadosManual = true;
    });
  }

  void _onUmidadeMaxChanged(double value) {
    setState(() {
      _umidadeMax = value;
      _valoresModificadosManual = true;
    });
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
          onChanged: _onCo2MaxChanged,
        ),
      ],
    );
  }

  void _onCo2MaxChanged(double value) {
    setState(() {
      _co2Max = value;
      _valoresModificadosManual = true;
    });
  }
}

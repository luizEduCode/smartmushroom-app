import 'package:flutter/material.dart';
import 'package:smartmushroom_app/screen/editar_parametros/widgets/controlador_parametros.dart';

enum ParametroTipo { temperatura, umidade, co2 }

class ParametroCardContainer extends StatefulWidget {
  final String idLote;
  final ParametroTipo tipo;

  // Estado de AUTO
  final bool autoMode;
  final VoidCallback? onToggleAuto;

  // Overrides vindos da página (faixa ideal + valor inicial)
  final double? idealMinOverride;
  final double? idealMaxOverride;
  final double? initialValueOverride;

  // Notificador opcional para controlar o valor do slider a partir do pai
  final ValueNotifier<double>? valueController;

  // Callback para expor o valor atual quando o usuário mexer
  final ValueChanged<double>? onUserChanged;

  const ParametroCardContainer({
    super.key,
    required this.idLote,
    required this.tipo,
    this.autoMode = false,
    this.onToggleAuto,
    this.idealMinOverride,
    this.idealMaxOverride,
    this.initialValueOverride,
    this.valueController,
    this.onUserChanged,
  });

  @override
  State<ParametroCardContainer> createState() => _ParametroCardContainerState();
}

class _ParametroCardContainerState extends State<ParametroCardContainer> {
  late double _valorAtual;
  late double _idealMin;
  late double _idealMax;
  late double _sliderMin;
  late double _sliderMax;

  // label, unidade e ícone por tipo
  String get _label => switch (widget.tipo) {
    ParametroTipo.temperatura => 'Temperatura',
    ParametroTipo.umidade => 'Umidade',
    ParametroTipo.co2 => 'CO\u2082',
  };

  String get _unit => switch (widget.tipo) {
    ParametroTipo.temperatura => '°C',
    ParametroTipo.umidade => '%',
    ParametroTipo.co2 => 'ppm',
  };

  IconData get _icon => switch (widget.tipo) {
    ParametroTipo.temperatura => Icons.thermostat,
    ParametroTipo.umidade => Icons.water_drop,
    ParametroTipo.co2 => Icons.cloud_outlined,
  };

  @override
  void initState() {
    super.initState();
    _definirFaixaSlider();
    _idealMin = widget.idealMinOverride ?? _sliderMin;
    _idealMax = widget.idealMaxOverride ?? _sliderMax;

    // valor inicial
    _valorAtual = _coerceValue(widget.initialValueOverride ?? _mediaIdeal());

    // ouvir controlador externo (se vier)
    widget.valueController?.addListener(_onExternalValue);
  }

  @override
  void didUpdateWidget(covariant ParametroCardContainer oldWidget) {
    super.didUpdateWidget(oldWidget);

    // atualiza faixas se overrides mudarem
    if (oldWidget.idealMinOverride != widget.idealMinOverride ||
        oldWidget.idealMaxOverride != widget.idealMaxOverride) {
      _idealMin = widget.idealMinOverride ?? _idealMin;
      _idealMax = widget.idealMaxOverride ?? _idealMax;

      // se estiver em AUTO, recentra no novo ideal
      if (widget.autoMode) {
        _setValorInterno(_mediaIdeal(), fireCallback: false);
      }
    }

    // se mudou o controller, remova listener antigo e adicione no novo
    if (oldWidget.valueController != widget.valueController) {
      oldWidget.valueController?.removeListener(_onExternalValue);
      widget.valueController?.addListener(_onExternalValue);
    }
  }

  @override
  void dispose() {
    widget.valueController?.removeListener(_onExternalValue);
    super.dispose();
  }

  void _definirFaixaSlider() {
    switch (widget.tipo) {
      case ParametroTipo.temperatura:
        _sliderMin = 10;
        _sliderMax = 35;
        break;
      case ParametroTipo.umidade:
        _sliderMin = 40;
        _sliderMax = 100;
        break;
      case ParametroTipo.co2:
        _sliderMin = 300;
        _sliderMax = 5000;
        break;
    }
  }

  double _mediaIdeal() => (_idealMin + _idealMax) / 2;

  double _coerceValue(double v) => v.clamp(_sliderMin, _sliderMax);

  void _onExternalValue() {
    final v = widget.valueController!.value;
    _setValorInterno(v, fireCallback: false);
  }

  void _setValorInterno(double v, {bool fireCallback = true}) {
    final coerced = _coerceValue(v);
    if (coerced == _valorAtual) return;
    setState(() => _valorAtual = coerced);
    if (fireCallback) widget.onUserChanged?.call(_valorAtual);
  }

  void _onSliderChanged(double v) {
    _setValorInterno(v, fireCallback: true);
  }

  @override
  Widget build(BuildContext context) {
    return ControladorParametros(
      label: _label,
      unit: _unit,
      iconData: _icon,
      value: _valorAtual,
      onChanged: _onSliderChanged,
      onToggleAuto: widget.onToggleAuto ?? () {},
      min: _sliderMin,
      max: _sliderMax,
      idealMin: _idealMin,
      idealMax: _idealMax,
      autoMode: widget.autoMode,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:smartmushroom_app/core/network/dio_client.dart';
import 'package:smartmushroom_app/models/fase_cultivo_model.dart';
import 'package:smartmushroom_app/screen/editar_parametros/data/editar_parametros_remote.dart';

class DropdownFasesCultivo extends StatefulWidget {
  final int idCogumelo;
  final int? idFaseSelecionada;
  final ValueChanged<FaseCultivoModel?>? onChanged;
  const DropdownFasesCultivo({
    super.key,
    required this.idCogumelo,
    this.idFaseSelecionada,
    this.onChanged,
  });

  @override
  State<DropdownFasesCultivo> createState() => _DropdownFasesCultivoState();
}

class _DropdownFasesCultivoState extends State<DropdownFasesCultivo> {
  late final EditarParametrosRemote _remote;
  List<FaseCultivoModel> _fases = [];
  FaseCultivoModel? _faseSelecionada;
  bool _loading = true;
  String? _err;

  @override
  void initState() {
    super.initState();
    _remote = EditarParametrosRemote(DioClient());
    _carregar();
  }

  Future<void> _carregar() async {
    setState(() {
      _loading = true;
      _err = null;
    });

    try {
      final fases = await _remote.getFasesPorCogumelo(widget.idCogumelo);
      FaseCultivoModel? pre;
      if (widget.idFaseSelecionada != null) {
        pre = fases.firstWhere(
          (fase) => fase.idFaseCultivo == widget.idFaseSelecionada,
          orElse: () => fases.first,
        );
      }
      setState(() {
        _fases = fases;
        _faseSelecionada = pre ?? (fases.isNotEmpty ? fases.first : null);
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _err = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    if (_loading) {
      return Center(
        child: SizedBox(
          height: 32,
          width: 32,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            valueColor: AlwaysStoppedAnimation(scheme.primary),
          ),
        ),
      );
    }

    if (_err != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Não foi possível carregar as fases.',
            style: textTheme.bodyMedium?.copyWith(color: scheme.error),
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: _carregar,
            icon: Icon(Icons.refresh, color: scheme.primary),
            label: const Text('Tentar novamente'),
          ),
        ],
      );
    }

    final OutlineInputBorder baseBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: scheme.outlineVariant),
    );

    return DropdownButtonFormField<FaseCultivoModel>(
      value: _faseSelecionada,
      items:
          _fases
              .map(
                (f) => DropdownMenuItem(
                  value: f,
                  child: Text(
                    f.nomeFaseCultivo ?? 'Fase sem nome',
                    style: textTheme.bodyMedium,
                  ),
                ),
              )
              .toList(),
      icon: Icon(Icons.arrow_drop_down, color: scheme.primary),
      dropdownColor: scheme.surface,
      onChanged: (v) {
        setState(() => _faseSelecionada = v);
        widget.onChanged?.call(v);
      },
      decoration: InputDecoration(
        labelText: 'Fase de Cultivo',
        filled: true,
        fillColor: scheme.surfaceContainerHighest,
        labelStyle: textTheme.labelLarge,
        border: baseBorder,
        enabledBorder: baseBorder,
        focusedBorder: baseBorder.copyWith(
          borderSide: BorderSide(color: scheme.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: EdgeInsets.symmetric(horizontal: 16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         border: Border.all(color: Colors.green.shade200, width: 2),
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: DropdownButtonHideUnderline(
//         child: DropdownButton<String>(
//           value: faseSelecionada,
//           isExpanded: true,
//           hint: const Text(
//             'Selecione uma fase de cultivo',
//             style: TextStyle(
//               fontWeight: FontWeight.w600,
//               color: Colors.black54,
//             ),
//           ),
//           icon: Icon(Icons.arrow_drop_down, color: Colors.green.shade200),
//           items:
//               fases.map((fase) {
//                 return DropdownMenuItem<String>(
//                   value: fase,
//                   child: Text(
//                     fase,
//                     style: TextStyle(fontWeight: FontWeight.w600),
//                   ),
//                 );
//               }).toList(),
//           onChanged: (value) {
//             setState(() => faseSelecionada = value);
//             if (widget.onChanged != null) {
//               widget.onChanged!(value);
//             }
//           },
//         ),
//       ),
//     );
//   }
// }

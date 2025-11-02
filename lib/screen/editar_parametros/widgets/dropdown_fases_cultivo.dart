import 'package:flutter/material.dart';
import 'package:smartmushroom_app/core/network/dio_client.dart';
import 'package:smartmushroom_app/models/Fase_Cultivo_Model.dart';
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
    if (_loading) return const CircularProgressIndicator();
    if (_err != null) return Text(_err!);

    return DropdownButtonFormField(
      value: _faseSelecionada,
      items:
          _fases
              .map(
                (f) => DropdownMenuItem(
                  value: f,
                  child: Text(f.nomeFaseCultivo ?? 'Fase sem nome'),
                ),
              )
              .toList(),
      onChanged: (v) {
        setState(() => _faseSelecionada = v);
        widget.onChanged?.call(v);
      },
      decoration: InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        labelText: 'Fase de Cultivo',
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

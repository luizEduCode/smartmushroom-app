import 'package:flutter/material.dart';
import 'package:smartmushroom_app/models/fase_cultivo_model.dart';

class DropdownFasesCultivo extends StatelessWidget {
  const DropdownFasesCultivo({
    super.key,
    required this.fases,
    required this.selectedId,
    this.onChanged,
  });

  final List<FaseCultivoModel> fases;
  final int? selectedId;
  final ValueChanged<FaseCultivoModel?>? onChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    if (fases.isEmpty) {
      return Text(
        'Nenhuma fase disponível para o cogumelo selecionado.',
        style: textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
      );
    }

    final selected = fases.firstWhere(
      (fase) => fase.idFaseCultivo == selectedId,
      orElse: () => fases.first,
    );

    final OutlineInputBorder baseBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: scheme.outlineVariant),
    );

    return DropdownButtonFormField<FaseCultivoModel>(
      initialValue: selected,
      icon: Icon(Icons.arrow_drop_down, color: scheme.primary),
      dropdownColor: scheme.surface,
      items:
          fases
              .map(
                (fase) => DropdownMenuItem<FaseCultivoModel>(
                  value: fase,
                  child: Text(
                    fase.nomeFaseCultivo ?? 'Fase sem nome',
                    style: textTheme.bodyMedium,
                  ),
                ),
              )
              .toList(),
      onChanged: onChanged,
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

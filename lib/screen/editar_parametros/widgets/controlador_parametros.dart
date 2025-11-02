import 'package:flutter/material.dart';

enum ParamLevel { low, ideal, high }

ParamLevel evalParamLevel({
  required double value,
  required double idealMin,
  required double idealMax,
}) {
  if (value < idealMin) return ParamLevel.low;
  if (value > idealMax) return ParamLevel.high;
  return ParamLevel.ideal;
}

class ParamVisualTheme {
  final Color cardBg;
  final Color accent;
  final Color chipBorder;
  final String chipLabel;
  final IconData chipIcon;
  final Color trackBase;
  final Color trackLeft;

  const ParamVisualTheme({
    required this.cardBg,
    required this.accent,
    required this.chipBorder,
    required this.chipLabel,
    required this.chipIcon,
    required this.trackBase,
    required this.trackLeft,
  });
}

ParamVisualTheme themeFor(ParamLevel level) {
  switch (level) {
    case ParamLevel.low:
      return ParamVisualTheme(
        cardBg: const Color(0xFFEFF7FF),
        accent: const Color(0xFF1D4ED8),
        chipBorder: const Color(0xFFBFDBFE),
        chipLabel: 'Baixo',
        chipIcon: Icons.south_east,
        trackBase: const Color(0xFFE5E7EB),
        trackLeft: Colors.black87,
      );
    case ParamLevel.high:
      return ParamVisualTheme(
        cardBg: const Color(0xFFFFF2E5),
        accent: const Color(0xFFEA580C),
        chipBorder: const Color(0xFFFECBA1),
        chipLabel: 'Alto',
        chipIcon: Icons.trending_up,
        trackBase: const Color(0xFFE5E7EB),
        trackLeft: Colors.black87,
      );
    case ParamLevel.ideal:
    default:
      return ParamVisualTheme(
        cardBg: const Color(0xFFEFFAF1),
        accent: const Color(0xFF22C55E),
        chipBorder: const Color(0xFFD1FAE5),
        chipLabel: 'Ideal',
        chipIcon: Icons.check,
        trackBase: const Color(0xFFE5E7EB),
        trackLeft: Colors.black87,
      );
  }
}

class ControladorParametros extends StatelessWidget {
  final String label;
  final String unit;
  final IconData iconData;

  final double value;
  final double min;
  final double max;
  final double idealMin;
  final double idealMax;
  final bool autoMode;

  final ValueChanged<double> onChanged;
  final VoidCallback onToggleAuto;

  const ControladorParametros({
    super.key,
    required this.label,
    required this.unit,
    required this.iconData,
    required this.value,
    required this.onChanged,
    required this.onToggleAuto,
    this.min = 15,
    this.max = 30,
    this.idealMin = 18,
    this.idealMax = 25,
    this.autoMode = false,
  });

  @override
  Widget build(BuildContext context) {
    final dark = const Color(0xFF1F2937);

    final level = evalParamLevel(
      value: value,
      idealMin: idealMin,
      idealMax: idealMax,
    );

    final t = themeFor(level);

    return Card(
      elevation: 0,
      color: t.cardBg,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _SquareIcon(
                  color: Colors.white,
                  child: Icon(iconData, color: t.accent),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: TextStyle(
                          color: dark,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'Ideal: ${idealMin.toStringAsFixed(0)}–${idealMax.toStringAsFixed(0)} $unit',
                        style: TextStyle(
                          color: dark.withOpacity(0.6),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                _AutoButton(active: autoMode, onTap: onToggleAuto),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Text(
                  value.toStringAsFixed(0),
                  style: TextStyle(
                    color: t.accent,
                    fontSize: 40,
                    fontWeight: FontWeight.w800,
                    height: 1,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  unit,
                  style: TextStyle(
                    color: dark.withOpacity(0.8),
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                _Pill(
                  text: t.chipLabel,
                  icon: t.chipIcon,
                  borderColor: t.chipBorder,
                  accent: t.accent,
                ),
              ],
            ),
            const SizedBox(height: 8),
            _IdealRangeSlider(
              value: value,
              min: min,
              max: max,
              idealMin: idealMin,
              idealMax: idealMax,
              onChanged: onChanged,
              activeColor: t.accent,
              baseTrackColor: t.trackBase,
              lowTrackColor: t.trackLeft,
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _TinyTag('${min.toStringAsFixed(0)} $unit'),
                _TinyTag('${max.toStringAsFixed(0)} $unit'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ---- Átomos ----

class _SquareIcon extends StatelessWidget {
  final Color color;
  final Widget child;
  const _SquareIcon({required this.color, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.center,
      child: child,
    );
  }
}

class _AutoButton extends StatelessWidget {
  final bool active;
  final VoidCallback onTap;
  const _AutoButton({required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final green = const Color(0xFF22C55E);
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Row(
            children: [
              Icon(Icons.bolt, size: 16, color: active ? green : Colors.black54),
              const SizedBox(width: 4),
              Text(
                'Auto',
                style: TextStyle(
                  color: active ? green : Colors.black87,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String text;
  final IconData icon;
  final Color borderColor;
  final Color accent;

  const _Pill({
    required this.text,
    required this.icon,
    required this.borderColor,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: borderColor, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: accent),
          const SizedBox(width: 8),
          Text(text, style: TextStyle(fontWeight: FontWeight.w700, color: accent)),
        ],
      ),
    );
  }
}

class _IdealRangeSlider extends StatelessWidget {
  final double value, min, max, idealMin, idealMax;
  final ValueChanged<double> onChanged;
  final Color activeColor;
  final Color baseTrackColor;
  final Color lowTrackColor;

  const _IdealRangeSlider({
    required this.value,
    required this.min,
    required this.max,
    required this.idealMin,
    required this.idealMax,
    required this.onChanged,
    required this.activeColor,
    required this.baseTrackColor,
    required this.lowTrackColor,
  });

  double _norm(double min, double max, double v) => (v - min) / (max - min);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (_, constraints) {
      final w = constraints.maxWidth;
      final xVal = _norm(min, max, value) * w;
      final xIdealL = _norm(min, max, idealMin) * w;
      final xIdealR = _norm(min, max, idealMax) * w;

      return Stack(
        alignment: Alignment.centerLeft,
        children: [
          // trilha base
          Container(
            height: 8,
            decoration: BoxDecoration(
              color: baseTrackColor,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          // faixa esquerda escura (efeito)
          Container(
            height: 8,
            width: xVal.clamp(0, w),
            decoration: BoxDecoration(
              color: lowTrackColor,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          // faixa ideal translúcida
          Positioned(
            left: xIdealL,
            child: Container(
              width: (xIdealR - xIdealL).clamp(0, w),
              height: 8,
              decoration: BoxDecoration(
                color: activeColor.withOpacity(0.25),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          // marcadores
          Positioned(left: xIdealL - 1, child: Container(width: 2, height: 16, color: activeColor)),
          Positioned(left: xIdealR - 1, child: Container(width: 2, height: 16, color: activeColor)),

          // slider transparente
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 0,
              activeTrackColor: Colors.transparent,
              inactiveTrackColor: Colors.transparent,
              overlayShape: SliderComponentShape.noOverlay,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
            ),
            child: Slider(
              value: value.clamp(min, max),
              min: min,
              max: max,
              divisions: (max - min).round(),
              onChanged: onChanged,
            ),
          ),
        ],
      );
    });
  }
}

class _TinyTag extends StatelessWidget {
  final String text;
  const _TinyTag(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
      child: Text(
        text,
        style: const TextStyle(color: Colors.black87, fontSize: 11, fontWeight: FontWeight.w600),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class BarIndicator extends StatelessWidget {
  final String label;
  final IconData icon;
  final double percentage; // de 0 a 100
  final String valueLabel;
  final Color color;

  const BarIndicator({
    super.key,
    required this.label,
    required this.icon,
    required this.percentage,
    required this.valueLabel,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1C29),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Icon(icon, color: Colors.white, size: 16),
              ],
            ),
            const SizedBox(height: 10),
            Stack(
              children: [
                Container(
                  height: 5,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[800],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                Container(
                  height: 5,
                  width:
                      percentage > 100
                          ? double.infinity
                          : (percentage / 100) *
                              MediaQuery.of(context).size.width *
                              0.3, // ajuste proporcional
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              valueLabel,
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

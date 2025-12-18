import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Parlamento yarım dairesi gösterimi
class SeatDistributionWidget extends StatelessWidget {
  final Map<String, int> seatsByParty;
  final Map<String, Color> partyColors;

  const SeatDistributionWidget({
    super.key,
    required this.seatsByParty,
    required this.partyColors,
  });

  List<Color> _buildSeatColors() {
    final List<Color> colors = [];
    final sorted = seatsByParty.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    for (final entry in sorted) {
      final color = partyColors[entry.key] ?? Colors.grey;
      colors.addAll(List<Color>.filled(entry.value, color));
    }
    return colors;
  }

  @override
  Widget build(BuildContext context) {
    final seatColors = _buildSeatColors();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Koltuk Dağılımı",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(12),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return CustomPaint(
                  painter: _ParliamentPainter(
                    seatColors: seatColors,
                    seatRadius: 4,
                    gap: 3,
                  ),
                  size: Size(
                    constraints.maxWidth,
                    constraints.maxHeight,
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _ParliamentPainter extends CustomPainter {
  final List<Color> seatColors;
  final double seatRadius;
  final double gap;

  _ParliamentPainter({
    required this.seatColors,
    required this.seatRadius,
    required this.gap,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (seatColors.isEmpty) return;

    final paint = Paint()..style = PaintingStyle.fill;
    final seatDiameter = seatRadius * 2;
    final center = Offset(size.width / 2, size.height);
    double currentRadius = math.min(size.width / 2, size.height) - seatRadius;

    // Fit as many rings as the height allows
    final maxRings =
        (size.height / (seatDiameter + gap)).floor().clamp(1, 14);

    int colorIndex = 0;
    for (int ring = 0;
        ring < maxRings && colorIndex < seatColors.length;
        ring++) {
      if (currentRadius <= seatRadius) break;

      final seatsInRing = math.max(
        2,
        (math.pi * currentRadius / (seatDiameter + gap)).floor(),
      );

      for (int i = 0; i < seatsInRing && colorIndex < seatColors.length; i++) {
        final angle = math.pi - (math.pi * i / (seatsInRing - 1));
        final dx = center.dx + math.cos(angle) * currentRadius;
        final dy = center.dy - math.sin(angle) * currentRadius;

        paint.color = seatColors[colorIndex];
        canvas.drawCircle(Offset(dx, dy), seatRadius, paint);
        colorIndex++;
      }

      currentRadius -= seatDiameter + gap;
    }
  }

  @override
  bool shouldRepaint(covariant _ParliamentPainter oldDelegate) {
    return oldDelegate.seatColors != seatColors ||
        oldDelegate.seatRadius != seatRadius ||
        oldDelegate.gap != gap;
  }
}

import 'dart:math' as math;

import 'package:flutter/material.dart';

class PartyBlock {
  final Color color;
  final int seats;

  PartyBlock(this.color, this.seats);
}

/// Parlamento yarim dairesi gosterimi
class SeatDistributionWidget extends StatelessWidget {
  final Map<String, int> seatsByParty;
  final Map<String, Color> partyColors;
  final List<int> markerThresholds;

  const SeatDistributionWidget({
    super.key,
    required this.seatsByParty,
    required this.partyColors,
    this.markerThresholds = const [300, 360, 400],
  });

  List<PartyBlock> _buildBlocks() {
    final sorted = seatsByParty.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sorted.map((entry) {
      return PartyBlock(
        partyColors[entry.key] ?? Colors.grey,
        entry.value,
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final blocks = _buildBlocks();
    final totalSeats = blocks.fold<int>(0, (sum, block) => sum + block.seats);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Koltuk DaŽYŽñlŽñmŽñ",
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
                    blocks: blocks,
                    totalSeats: totalSeats,
                    markerThresholds: markerThresholds,
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
  final List<PartyBlock> blocks;
  final int totalSeats;
  final List<int> markerThresholds;

  _ParliamentPainter({
    required this.blocks,
    required this.totalSeats,
    required this.markerThresholds,
  });

  double _angleForThreshold(int seat) {
    return math.pi * (seat / totalSeats);
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (blocks.isEmpty || totalSeats == 0) return;

    final center = Offset(size.width / 2, size.height);
    const rows = 9;
    final maxRadius =
        math.min(size.width * 0.45, size.height * 0.95);
    final seatRadius = math.min(size.width, size.height) / 120;
    final rowSpacing = maxRadius / rows;

    final markerPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = Colors.black54;

    for (final threshold in markerThresholds) {
      if (threshold <= 0 || threshold > totalSeats) continue;
      final markerAngle = math.pi - _angleForThreshold(threshold);
      final innerRadius = maxRadius - (rows - 1) * rowSpacing;
      final start = Offset(
        center.dx + innerRadius * math.cos(markerAngle),
        center.dy - innerRadius * math.sin(markerAngle),
      );
      final end = Offset(
        center.dx + maxRadius * math.cos(markerAngle),
        center.dy - maxRadius * math.sin(markerAngle),
      );
      canvas.drawLine(start, end, markerPaint);
    }

    double startAngle = math.pi;

    for (final block in blocks) {
      final sweepAngle = math.pi * (block.seats / totalSeats);

      _drawPartyBlock(
        canvas: canvas,
        center: center,
        startAngle: startAngle,
        sweepAngle: sweepAngle,
        color: block.color,
        size: size,
        rows: rows,
        maxRadius: maxRadius,
        seatRadius: seatRadius,
        rowSpacing: rowSpacing,
      );

      startAngle -= sweepAngle;
    }
  }

  void _drawPartyBlock({
    required Canvas canvas,
    required Offset center,
    required double startAngle,
    required double sweepAngle,
    required Color color,
    required Size size,
    required int rows,
    required double maxRadius,
    required double seatRadius,
    required double rowSpacing,
  }) {
    final paint = Paint()..color = color;

    for (int row = 0; row < rows; row++) {
      final radius = maxRadius - row * rowSpacing;
      final seatsInRow = (sweepAngle * radius / (seatRadius * 2)).floor();

      if (seatsInRow <= 0) continue;

      for (int i = 0; i < seatsInRow; i++) {
        final angle = startAngle - (sweepAngle * i / seatsInRow);
        final offset = Offset(
          center.dx + radius * math.cos(angle),
          center.dy - radius * math.sin(angle),
        );
        canvas.drawCircle(offset, seatRadius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _ParliamentPainter oldDelegate) {
    return oldDelegate.blocks != blocks ||
        oldDelegate.totalSeats != totalSeats ||
        oldDelegate.markerThresholds != markerThresholds;
  }
}

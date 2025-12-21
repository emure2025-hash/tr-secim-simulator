import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'color_engine.dart';

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

  String _initials(String name) {
    final trimmed = name.trim();
    if (trimmed.length <= 2) return trimmed.toUpperCase();
    return trimmed.substring(0, 2).toUpperCase();
  }

  Widget _buildPartyLogo(String party, Color fallbackColor) {
    final logoPath = logoForParty(party);
    if (logoPath == null) {
      return CircleAvatar(
        radius: 9,
        backgroundColor: fallbackColor,
        child: Text(
          _initials(party),
          style: const TextStyle(fontSize: 9, color: Colors.white),
        ),
      );
    }

    return CircleAvatar(
      radius: 9,
      backgroundColor: Colors.white,
      child: ClipOval(
        child: Image.asset(
          logoPath,
          width: 18,
          height: 18,
          fit: BoxFit.contain,
        ),
      ),
    );
  }

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

  List<MapEntry<String, int>> _buildLegendEntries() {
    final entries = seatsByParty.entries
        .where((entry) => entry.value > 0)
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return entries;
  }

  @override
  Widget build(BuildContext context) {
    final blocks = _buildBlocks();
    final totalSeats = blocks.fold<int>(0, (sum, block) => sum + block.seats);
    final legendEntries = _buildLegendEntries();

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
        if (legendEntries.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: legendEntries.map((entry) {
              final color = partyColors[entry.key] ?? Colors.grey;
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: color.withOpacity(0.25)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildPartyLogo(entry.key, color),
                    const SizedBox(width: 6),
                    Text(
                      entry.key,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      "${entry.value}",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: color,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
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
        math.min(size.width * 0.42, size.height * 0.84);
    final seatRadius = math.min(size.width, size.height) / 120;
    final rowSpacing = maxRadius / rows;
    const baseGapAngle = math.pi / 90;
    const markerOuterPad = 10.0;
    const markerLineLength = 18.0;

    final markerPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = Colors.black54;
    final labelFillPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.white.withOpacity(0.85);
    final labelBorderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = Colors.black26;
    const labelTextStyle = TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.w600,
      color: Colors.black87,
    );

    final placedLabelRects = <Rect>[];
    final fixedOffsets = <int, Offset>{
      300: const Offset(-18, -6),
      360: const Offset(18, -12),
      400: const Offset(12, 6),
    };
    for (int i = 0; i < markerThresholds.length; i++) {
      final threshold = markerThresholds[i];
      if (threshold <= 0 || threshold > totalSeats) continue;
      final markerAngle = math.pi - _angleForThreshold(threshold);
      final innerRadius = maxRadius - (rows - 1) * rowSpacing;
      final startRadius = maxRadius + markerOuterPad;
      final endRadius = maxRadius + markerOuterPad + markerLineLength;
      final start = Offset(
        center.dx + startRadius * math.cos(markerAngle),
        center.dy - startRadius * math.sin(markerAngle),
      );
      final end = Offset(
        center.dx + endRadius * math.cos(markerAngle),
        center.dy - endRadius * math.sin(markerAngle),
      );
      canvas.drawLine(start, end, markerPaint);

      final direction = Offset(
        end.dx - center.dx,
        end.dy - center.dy,
      );
      final length = math.max(direction.distance, 0.001);
      final normal = Offset(direction.dx / length, direction.dy / length);
      final tangent = Offset(-normal.dy, normal.dx);
      final tangentialShift = (i.isEven ? -1.0 : 1.0) * 10;
      final baseOffset = Offset(
        end.dx + normal.dx * 16 + tangent.dx * tangentialShift,
        end.dy + normal.dy * 16 + tangent.dy * tangentialShift,
      ) +
          (fixedOffsets[threshold] ?? Offset.zero);
      final labelText = threshold.toString();
      final textPainter = TextPainter(
        text: TextSpan(style: labelTextStyle, text: labelText),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      const padding = 4.0;
      final boxWidth = textPainter.width + padding * 2;
      final boxHeight = textPainter.height + padding * 2;

      Rect resolveRect(Offset offset) {
        final rawLeft = offset.dx - (textPainter.width / 2) - padding;
        final rawTop = offset.dy - (textPainter.height / 2) - padding;
        final clampedLeft = rawLeft.clamp(0.0, size.width - boxWidth);
        final clampedTop = rawTop.clamp(0.0, size.height - boxHeight);
        return Rect.fromLTWH(clampedLeft, clampedTop, boxWidth, boxHeight);
      }

      double overlapScore(Rect rect) {
        double score = 0.0;
        for (final other in placedLabelRects) {
          if (!rect.overlaps(other)) continue;
          final intersect = rect.intersect(other);
          score += intersect.width * intersect.height;
        }
        return score;
      }

      final radialSteps = <double>[0, 8, 16, 24, 32, 40];
      final tangentialSteps = <double>[0, 8, 16, 24, 32];
      Rect? bestRect;
      double bestScore = double.infinity;
      double bestDistance = double.infinity;
      for (final radialStep in radialSteps) {
        for (final tangentialStep in tangentialSteps) {
          final tangentialSigns =
              tangentialStep == 0 ? const [1.0] : const [1.0, -1.0];
          for (final sign in tangentialSigns) {
            final candidateOffset = baseOffset +
                normal * radialStep +
                tangent * (tangentialStep * sign);
            final rect = resolveRect(candidateOffset);
            final score = overlapScore(rect);
            final distance = (candidateOffset - baseOffset).distance;
            if (score == 0) {
              bestRect = rect;
              bestScore = 0;
              bestDistance = distance;
              break;
            }
            if (score < bestScore ||
                (score == bestScore && distance < bestDistance)) {
              bestRect = rect;
              bestScore = score;
              bestDistance = distance;
            }
          }
          if (bestScore == 0) break;
        }
        if (bestScore == 0) break;
      }

      final bgRect = bestRect ?? resolveRect(baseOffset);

      final bgRRect = RRect.fromRectAndRadius(
        bgRect,
        const Radius.circular(6),
      );
      canvas.drawRRect(bgRRect, labelFillPaint);
      canvas.drawRRect(bgRRect, labelBorderPaint);
      textPainter.paint(
        canvas,
        Offset(
          bgRect.left + padding,
          bgRect.top + padding,
        ),
      );
      placedLabelRects.add(bgRect);
    }

    double startAngle = math.pi;

    for (final block in blocks) {
      final rawSweep = math.pi * (block.seats / totalSeats);
      final gapAngle = math.min(baseGapAngle, rawSweep * 0.25);
      final sweepAngle = rawSweep - gapAngle;
      if (sweepAngle <= 0) {
        startAngle -= rawSweep;
        continue;
      }

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

      startAngle -= rawSweep;
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

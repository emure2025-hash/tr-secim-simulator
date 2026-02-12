import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'color_engine.dart';

class PartyBlock {
  final String label;
  final Color color;
  final int seats;

  PartyBlock(this.label, this.color, this.seats);
}

/// Parlamento yarim dairesi gosterimi
class SeatDistributionWidget extends StatefulWidget {
  final Map<String, int> seatsByParty;
  final Map<String, Color> partyColors;
  final List<int> markerThresholds;

  const SeatDistributionWidget({
    super.key,
    required this.seatsByParty,
    required this.partyColors,
    this.markerThresholds = const [],
  });

  @override
  State<SeatDistributionWidget> createState() => _SeatDistributionWidgetState();
}

class _SeatDistributionWidgetState extends State<SeatDistributionWidget> {
  String? _selectedParty;

  String _initials(String name) {
    final trimmed = name.trim();
    if (trimmed.length <= 2) return trimmed.toUpperCase();
    return trimmed.substring(0, 2).toUpperCase();
  }

  Widget _buildPartyLogo(
    String party,
    Color fallbackColor, {
    bool highlighted = false,
  }) {
    final logoPath = logoForParty(party);
    final radius = highlighted ? 11.0 : 9.0;
    final avatar = logoPath == null
        ? CircleAvatar(
            radius: radius,
            backgroundColor: fallbackColor,
            child: Text(
              _initials(party),
              style: const TextStyle(fontSize: 9, color: Colors.white),
            ),
          )
        : CircleAvatar(
            radius: radius,
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

    if (!highlighted) return avatar;
    return Container(
      padding: const EdgeInsets.all(1),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: fallbackColor, width: 1.4),
      ),
      child: avatar,
    );
  }

  List<PartyBlock> _buildBlocks() {
    final sorted = widget.seatsByParty.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sorted.map((entry) {
      return PartyBlock(
        entry.key,
        widget.partyColors[entry.key] ?? Colors.grey,
        entry.value,
      );
    }).toList();
  }

  List<MapEntry<String, int>> _buildLegendEntries() {
    final entries = widget.seatsByParty.entries
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
    final activeParty = _selectedParty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Koltuk dağılımı (semi-circle)",
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
                final paintSize = Size(
                  constraints.maxWidth,
                  constraints.maxHeight,
                );
                return CustomPaint(
                  painter: _ParliamentPainter(
                    blocks: blocks,
                    totalSeats: totalSeats,
                    markerThresholds: widget.markerThresholds,
                    highlightedParty: activeParty,
                  ),
                  size: paintSize,
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
              final color = widget.partyColors[entry.key] ?? Colors.grey;
              final isHighlighted = entry.key == activeParty;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedParty = isHighlighted ? null : entry.key;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color:
                        isHighlighted ? color.withOpacity(0.12) : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isHighlighted
                          ? color.withOpacity(0.85)
                          : color.withOpacity(0.25),
                      width: isHighlighted ? 1.5 : 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black
                            .withOpacity(isHighlighted ? 0.08 : 0.04),
                        blurRadius: isHighlighted ? 8 : 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildPartyLogo(
                        entry.key,
                        color,
                        highlighted: isHighlighted,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        entry.key,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                          color: isHighlighted ? color : Colors.black87,
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
  final String? highlightedParty;

  _ParliamentPainter({
    required this.blocks,
    required this.totalSeats,
    required this.markerThresholds,
    this.highlightedParty,
  });

  double _angleForThreshold(int seat) {
    return math.pi * (seat / totalSeats);
  }

  Offset _lineEndBeforeRect(
    Offset start,
    Offset direction,
    Rect rect, {
    double gap = 2,
    required Offset fallbackEnd,
  }) {
    const double infinity = 1e9;
    double tMin = -infinity;
    double tMax = infinity;

    void updateAxis(double startCoord, double dirCoord, double min, double max) {
      if (dirCoord == 0) {
        if (startCoord < min || startCoord > max) {
          tMin = 1;
          tMax = 0;
        }
        return;
      }
      final t1 = (min - startCoord) / dirCoord;
      final t2 = (max - startCoord) / dirCoord;
      final tLow = math.min(t1, t2);
      final tHigh = math.max(t1, t2);
      if (tLow > tMin) tMin = tLow;
      if (tHigh < tMax) tMax = tHigh;
    }

    updateAxis(start.dx, direction.dx, rect.left, rect.right);
    updateAxis(start.dy, direction.dy, rect.top, rect.bottom);

    if (tMax < 0 || tMin > tMax) {
      return fallbackEnd;
    }

    final tHit = tMin >= 0 ? tMin : tMax;
    if (tHit <= 0) return fallbackEnd;
    final tEnd = math.max(0, tHit - gap);
    return Offset(
      start.dx + direction.dx * tEnd,
      start.dy + direction.dy * tEnd,
    );
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
    const baseLabelOffset = 16.0;
    const radialSteps = <double>[0, 10, 20, 30, 40, 50];
    for (int i = 0; i < markerThresholds.length; i++) {
      final threshold = markerThresholds[i];
      if (threshold <= 0 || threshold > totalSeats) continue;
      final markerAngle = math.pi - _angleForThreshold(threshold);
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

      final direction = Offset(
        end.dx - center.dx,
        end.dy - center.dy,
      );
      final length = math.max(direction.distance, 0.001);
      final normal = Offset(direction.dx / length, direction.dy / length);
      final baseOffset = Offset(
        end.dx + normal.dx * baseLabelOffset,
        end.dy + normal.dy * baseLabelOffset,
      );
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

      Rect? bestRect;
      double bestScore = double.infinity;
      double bestDistance = double.infinity;
      for (final radialStep in radialSteps) {
        final candidateOffset = baseOffset + normal * radialStep;
        final rect = resolveRect(candidateOffset);
        final score = overlapScore(rect);
        if (score == 0) {
          bestRect = rect;
          bestScore = 0;
          bestDistance = radialStep;
          break;
        }
        if (score < bestScore ||
            (score == bestScore && radialStep < bestDistance)) {
          bestRect = rect;
          bestScore = score;
          bestDistance = radialStep;
        }
      }

      final bgRect = bestRect ?? resolveRect(baseOffset);

      final lineEnd = _lineEndBeforeRect(
        start,
        normal,
        bgRect,
        fallbackEnd: end,
      );
      canvas.drawLine(start, lineEnd, markerPaint);

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

    final highlight = highlightedParty;
    final hasHighlight = highlight != null &&
        blocks.any((b) => b.label == highlight && b.seats > 0);

    if (hasHighlight) {
      double startAngle = math.pi;
      for (final block in blocks) {
        final rawSweep = math.pi * (block.seats / totalSeats);
        final gapAngle = math.min(baseGapAngle, rawSweep * 0.25);
        final sweepAngle = rawSweep - gapAngle;
        if (sweepAngle <= 0) {
          startAngle -= rawSweep;
          continue;
        }

        if (block.label != highlight) {
          _drawPartyBlock(
            canvas: canvas,
            center: center,
            startAngle: startAngle,
            sweepAngle: sweepAngle,
            color: block.color.withOpacity(0.2),
            size: size,
            rows: rows,
            maxRadius: maxRadius,
            seatRadius: seatRadius,
            rowSpacing: rowSpacing,
            seatRadiusScale: 0.85,
            radiusBoost: 0.0,
          );
        }
        startAngle -= rawSweep;
      }

      double highlightStart = math.pi;
      for (final block in blocks) {
        final rawSweep = math.pi * (block.seats / totalSeats);
        final gapAngle = math.min(baseGapAngle, rawSweep * 0.25);
        final sweepAngle = rawSweep - gapAngle;
        if (sweepAngle <= 0) {
          highlightStart -= rawSweep;
          continue;
        }

        if (block.label == highlight) {
          _drawPartyBlock(
            canvas: canvas,
            center: center,
            startAngle: highlightStart,
            sweepAngle: sweepAngle,
            color: block.color,
            size: size,
            rows: rows,
            maxRadius: maxRadius,
            seatRadius: seatRadius,
            rowSpacing: rowSpacing,
            seatRadiusScale: 1.35,
            radiusBoost: seatRadius * 1.1,
            haloColor: block.color.withOpacity(0.35),
            haloRadiusScale: 1.7,
            strokeColor: Colors.white.withOpacity(0.9),
            strokeWidth: 1.4,
          );
          break;
        }
        highlightStart -= rawSweep;
      }
    } else {
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
    double seatRadiusScale = 1.0,
    double radiusBoost = 0.0,
    Color? haloColor,
    double haloRadiusScale = 1.0,
    Color? strokeColor,
    double strokeWidth = 1.0,
  }) {
    final paint = Paint()..color = color;
    final drawRadius = seatRadius * seatRadiusScale;
    final haloRadius = seatRadius * haloRadiusScale;
    Paint? haloPaint;
    if (haloColor != null) {
      haloPaint = Paint()..color = haloColor;
    }
    Paint? strokePaint;
    if (strokeColor != null) {
      strokePaint = Paint()
        ..color = strokeColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth;
    }

    for (int row = 0; row < rows; row++) {
      final baseRadius = maxRadius - row * rowSpacing;
      final radius = baseRadius + radiusBoost;
      final seatsInRow =
          (sweepAngle * baseRadius / (seatRadius * 2)).floor();

      if (seatsInRow <= 0) continue;

      for (int i = 0; i < seatsInRow; i++) {
        final angle = startAngle - (sweepAngle * i / seatsInRow);
        final offset = Offset(
          center.dx + radius * math.cos(angle),
          center.dy - radius * math.sin(angle),
        );
        if (haloPaint != null) {
          canvas.drawCircle(offset, haloRadius, haloPaint);
        }
        canvas.drawCircle(offset, drawRadius, paint);
        if (strokePaint != null) {
          canvas.drawCircle(offset, drawRadius, strokePaint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _ParliamentPainter oldDelegate) {
    return oldDelegate.blocks != blocks ||
        oldDelegate.totalSeats != totalSeats ||
        oldDelegate.markerThresholds != markerThresholds ||
        oldDelegate.highlightedParty != highlightedParty;
  }
}

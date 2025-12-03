import 'package:flutter/material.dart';
import 'color_engine.dart';

// -------------------------------------------------------------
// TÜRKİYE HARİTASI WIDGET'I
// -------------------------------------------------------------
class MapWidget extends StatelessWidget {
  final List<dynamic> features;
  final double scale;
  final Offset offset;
  final Map<String, double> nationalVotes;
  final ValueChanged<ScaleUpdateDetails> onScaleUpdate;

  const MapWidget({
    required this.features,
    required this.scale,
    required this.offset,
    required this.nationalVotes,
    required this.onScaleUpdate,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onScaleUpdate: onScaleUpdate,
      child: SizedBox.expand(
        child: CustomPaint(
          painter: MapPainter(
            features: features,
            scale: scale,
            offset: offset,
            nationalVotes: nationalVotes,
          ),
        ),
      ),
    );
  }
}

// -------------------------------------------------------------
// TÜRKİYE HARİTASI ÇİZİMİ
// -------------------------------------------------------------
class MapPainter extends CustomPainter {
  final List<dynamic> features;
  final double scale;
  final Offset offset;
  final Map<String, double> nationalVotes;

  MapPainter({
    required this.features,
    required this.scale,
    required this.offset,
    required this.nationalVotes,
  });

  static const double minLon = 25.0;
  static const double maxLon = 45.0;
  static const double minLat = 35.8;
  static const double maxLat = 42.2;

  @override
  void paint(Canvas canvas, Size size) {
    final lonRange = maxLon - minLon;
    final latRange = maxLat - minLat;

    final scaleX = size.width / lonRange;
    final scaleY = size.height / latRange;
    final realScale = (scaleX < scaleY ? scaleX : scaleY) * 1.05;

    // Haritayı ekranın üst kısmına ortala (zoom/pan öncesi)
    final mapWidth = lonRange * realScale;
    final mapHeight = latRange * realScale;
    final centerOffsetX = (size.width - mapWidth) / 2;
    final centerOffsetY = (size.height - mapHeight) / 2;

    canvas.translate(offset.dx + centerOffsetX, offset.dy + centerOffsetY);
    canvas.scale(scale);

    final strokePaint = Paint()
      ..color = Colors.blueGrey.shade600
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.7 / scale;

    for (var feature in features) {
      final properties = feature["properties"];
      final city = properties?["name"] as String? ?? properties?["NAME"] as String? ?? "Bilinmeyen";
      final geom = feature["geometry"];
      if (geom == null) continue;

      final regionColor = nationalVotes.isNotEmpty
          ? computeRegionColor(city: city, nationalVotes: nationalVotes)
          : Colors.grey.shade300;

      final fillPaint = Paint()
        ..color = regionColor
        ..style = PaintingStyle.fill;

      if (geom["type"] == "Polygon") {
        for (var ring in geom["coordinates"]) {
          _drawPath(canvas, ring, fillPaint, strokePaint, realScale);
        }
      }

      if (geom["type"] == "MultiPolygon") {
        for (var poly in geom["coordinates"]) {
          for (var ring in poly) {
            _drawPath(canvas, ring, fillPaint, strokePaint, realScale);
          }
        }
      }
    }
  }

  void _drawPath(
    Canvas canvas,
    List coords,
    Paint fillPaint,
    Paint strokePaint,
    double scale,
  ) {
    final path = Path();
    bool first = true;

    for (var c in coords) {
      final lon = (c[0] as num).toDouble();
      final lat = (c[1] as num).toDouble();

      final x = (lon - minLon) * scale;
      final y = (maxLat - lat) * scale;

      if (first) {
        path.moveTo(x, y);
        first = false;
      } else {
        path.lineTo(x, y);
      }
    }

    path.close();
    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, strokePaint);
  }

  @override
  bool shouldRepaint(covariant MapPainter oldDelegate) =>
      oldDelegate.features != features ||
      oldDelegate.scale != scale ||
      oldDelegate.offset != offset ||
      oldDelegate.nationalVotes != nationalVotes;
}

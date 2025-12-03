import 'package:flutter/material.dart';
import 'color_engine.dart';

// -------------------------------------------------------------
// T�oRK��YE HAR��TASI WIDGET'I
// -------------------------------------------------------------
class MapWidget extends StatelessWidget {
  final List<dynamic> features;
  final double scale;
  final Offset offset;
  final Map<String, int>? result; // SimǬlasyon sonucu
  final Map<String, double>? votes; // Oy oranlar�� (renklendirme i��in)
  final ValueChanged<ScaleUpdateDetails> onScaleUpdate;

  const MapWidget({
    required this.features,
    required this.scale,
    required this.offset,
    this.result,
    this.votes,
    required this.onScaleUpdate,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey.shade200,
      child: GestureDetector(
        onScaleUpdate: onScaleUpdate,
        child: SizedBox.expand(
          child: CustomPaint(
            painter: MapPainter(
              features: features,
              scale: scale,
              offset: offset,
              result: result,
              votes: votes,
            ),
          ),
        ),
      ),
    );
  }
}

// -------------------------------------------------------------
// T�oRK��YE HAR��TASI �Ŏ�Z��M�� (RENKLEND��R��LM���?)
// -------------------------------------------------------------
class MapPainter extends CustomPainter {
  final List<dynamic> features;
  final double scale;
  final Offset offset;
  final Map<String, int>? result;
  final Map<String, double>? votes;

  MapPainter({
    required this.features,
    required this.scale,
    required this.offset,
    this.result,
    this.votes,
  });

  // TǬrkiye'nin WGS84 s��n��rlar��
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
    final realScale = (scaleX < scaleY ? scaleX : scaleY) * 0.95;

    // Haritay�� ortala
    final mapWidth = lonRange * realScale;
    final mapHeight = latRange * realScale;
    final centerOffsetX = (size.width - mapWidth) / 2;
    final centerOffsetY = (size.height - mapHeight) / 2;

    canvas.translate(offset.dx + centerOffsetX, offset.dy + centerOffsetY);
    canvas.scale(scale);

    final strokePaint = Paint()
      ..color = Colors.blueGrey.shade800
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5 / scale;

    for (var feature in features) {
      final geom = feature["geometry"];
      if (geom == null) continue;

      // �?ehir/b��lge ad��n�� al
      final properties = feature["properties"];
      final cityName = properties?["name"] ?? properties?["NAME"] ?? "";

      // B��lge rengini hesapla
      Color fillColor = _computeRegionColor(cityName);

      final fillPaint = Paint()
        ..color = fillColor
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

  /// B��lgenin hangi parti taraf��ndan kazan��ld��Y��n�� hesapla
  Color _computeRegionColor(String cityName) {
    if ((votes == null || votes!.isEmpty) && (result == null || result!.isEmpty)) {
      return Colors.blueGrey.shade300;
    }

    if (votes != null && votes!.isNotEmpty) {
      final color = computeRegionColor(
        city: cityName,
        nationalVotes: votes!,
      );
      return color.withOpacity(color == Colors.grey ? 0.8 : 1.0);
    }

    // votes bo��sa, toplam sandalye sonucuna g��re en b��y��k parti rengini kullan
    final topParty = result!.entries
        .reduce((a, b) => a.value >= b.value ? a : b)
        .key;
    final fallback = colorForParty(topParty);
    return fallback;
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
      oldDelegate.result != result ||
      oldDelegate.votes != votes;
}

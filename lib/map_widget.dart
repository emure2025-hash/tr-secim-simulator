import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'color_engine.dart';
import 'region_calculator.dart';

// -------------------------------------------------------------
// TÜRKİYE HARİTASI WIDGET'I
// -------------------------------------------------------------
class MapWidget extends StatelessWidget {
  final List<dynamic> features;
  final double scale;
  final Offset offset;
  final Map<String, RegionResult>? regionResults; // Bölge sonuçları
  final Function(String regionId)? onRegionTap; // Tıklama callback'i
  final ValueChanged<ScaleUpdateDetails> onScaleUpdate;

  const MapWidget({
    required this.features,
    required this.scale,
    required this.offset,
    this.regionResults,
    this.onRegionTap,
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
            regionResults: regionResults,
            onRegionTap: onRegionTap,
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
  final Map<String, RegionResult>? regionResults;
  final Function(String regionId)? onRegionTap;

  MapPainter({
    required this.features,
    required this.scale,
    required this.offset,
    this.regionResults,
    this.onRegionTap,
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
      final regionId = properties?["id"] as String? ?? "";
      final geom = feature["geometry"];
      if (geom == null) continue;

      // Bölge rengini belirle
      Color regionColor = Colors.grey.shade300;
      
      if (regionResults != null && regionResults!.containsKey(regionId)) {
        final result = regionResults![regionId]!;
        regionColor = colorForParty(result.winner);
      }

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
      oldDelegate.regionResults != regionResults;

  @override
  bool? hitTest(Offset position) => true;
}

// -------------------------------------------------------------
// TIKLANABİLİR HARİTA WIDGET'I (Kullanım için alternatif)
// -------------------------------------------------------------
class InteractiveMapWidget extends StatefulWidget {
  final List<dynamic> features;
  final Map<String, RegionResult>? regionResults;
  final Function(String regionId)? onRegionTap;

  const InteractiveMapWidget({
    required this.features,
    this.regionResults,
    this.onRegionTap,
    super.key,
  });

  @override
  State<InteractiveMapWidget> createState() => _InteractiveMapWidgetState();
}

class _InteractiveMapWidgetState extends State<InteractiveMapWidget> {
  double _scale = 1.0;
  Offset _offset = Offset.zero;
  String? _hoveredRegion;

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (event) => _handlePointerDown(event),
      onPointerHover: (event) => _handlePointerHover(event),
      child: GestureDetector(
        onScaleUpdate: (details) {
          setState(() {
            _scale = (_scale * details.scale).clamp(0.5, 3.0);
            _offset = _offset + details.focalPointDelta;
          });
        },
        child: SizedBox.expand(
          child: CustomPaint(
            painter: InteractiveMapPainter(
              features: widget.features,
              scale: _scale,
              offset: _offset,
              regionResults: widget.regionResults,
              hoveredRegion: _hoveredRegion,
            ),
          ),
        ),
      ),
    );
  }

  void _handlePointerDown(PointerDownEvent event) {
    final regionId = _getRegionAtPosition(event.localPosition);
    if (regionId != null && widget.onRegionTap != null) {
      widget.onRegionTap!(regionId);
    }
  }

  void _handlePointerHover(PointerHoverEvent event) {
    final regionId = _getRegionAtPosition(event.localPosition);
    if (regionId != _hoveredRegion) {
      setState(() {
        _hoveredRegion = regionId;
      });
    }
  }

  String? _getRegionAtPosition(Offset position) {
    final size = context.size;
    if (size == null) return null;

    const double minLon = 25.0;
    const double maxLon = 45.0;
    const double minLat = 35.8;
    const double maxLat = 42.2;

    final lonRange = maxLon - minLon;
    final latRange = maxLat - minLat;

    final scaleX = size.width / lonRange;
    final scaleY = size.height / latRange;
    final realScale = (scaleX < scaleY ? scaleX : scaleY) * 1.05;

    final mapWidth = lonRange * realScale;
    final mapHeight = latRange * realScale;
    final centerOffsetX = (size.width - mapWidth) / 2;
    final centerOffsetY = (size.height - mapHeight) / 2;

    final translated = position - Offset(centerOffsetX, centerOffsetY) - _offset;
    final localPoint = translated / _scale;

    for (var feature in widget.features) {
      final properties = feature["properties"];
      final regionId = properties?["id"] as String?;
      final geom = feature["geometry"];
      if (regionId == null || geom == null) continue;

      if (_pointInGeometry(localPoint, geom, minLon, maxLat, realScale)) {
        return regionId;
      }
    }

    return null;
  }

  bool _pointInGeometry(
    Offset point,
    dynamic geom,
    double minLon,
    double maxLat,
    double scale,
  ) {
    bool contains = false;

    void testPolygon(List<dynamic> polygon) {
      for (var ring in polygon) {
        final path = Path();
        bool first = true;

        for (var c in ring) {
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

        if (path.contains(point)) {
          contains = true;
          return;
        }
      }
    }

    if (geom["type"] == "Polygon") {
      testPolygon(geom["coordinates"]);
    } else if (geom["type"] == "MultiPolygon") {
      for (var poly in geom["coordinates"]) {
        testPolygon(poly);
        if (contains) break;
      }
    }

    return contains;
  }
}

class InteractiveMapPainter extends CustomPainter {
  final List<dynamic> features;
  final double scale;
  final Offset offset;
  final Map<String, RegionResult>? regionResults;
  final String? hoveredRegion;

  InteractiveMapPainter({
    required this.features,
    required this.scale,
    required this.offset,
    this.regionResults,
    this.hoveredRegion,
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

    final mapWidth = lonRange * realScale;
    final mapHeight = latRange * realScale;
    final centerOffsetX = (size.width - mapWidth) / 2;
    final centerOffsetY = (size.height - mapHeight) / 2;

    canvas.translate(offset.dx + centerOffsetX, offset.dy + centerOffsetY);
    canvas.scale(scale);

    for (var feature in features) {
      final properties = feature["properties"];
      final regionId = properties?["id"] as String? ?? "";
      final geom = feature["geometry"];
      if (geom == null) continue;

      Color regionColor = Colors.grey.shade300;
      
      if (regionResults != null && regionResults!.containsKey(regionId)) {
        final result = regionResults![regionId]!;
        regionColor = colorForParty(result.winner);
      }

      // Hover efekti
      final isHovered = hoveredRegion == regionId;
      
      final strokePaint = Paint()
        ..color = isHovered ? Colors.black : Colors.blueGrey.shade600
        ..style = PaintingStyle.stroke
        ..strokeWidth = (isHovered ? 1.5 : 0.7) / scale;

      final fillPaint = Paint()
        ..color = isHovered 
            ? regionColor.withOpacity(0.8) 
            : regionColor
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
  bool shouldRepaint(covariant InteractiveMapPainter oldDelegate) =>
      oldDelegate.features != features ||
      oldDelegate.scale != scale ||
      oldDelegate.offset != offset ||
      oldDelegate.regionResults != regionResults ||
      oldDelegate.hoveredRegion != hoveredRegion;
}

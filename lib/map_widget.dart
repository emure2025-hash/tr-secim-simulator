import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'color_engine.dart';
import 'region_calculator.dart';
import 'alliance_calculator.dart';

// -------------------------------------------------------------
// TÜRKİYE HARİTASI WIDGET'I
// -------------------------------------------------------------
class MapWidget extends StatefulWidget {
  final List<dynamic> features;
  final double scale;
  final Offset offset;
  final Map<String, RegionResult>? regionResults;
  final Map<String, RegionAllianceResult>? regionAllianceResults;
  final bool useAllianceColors;
  final Function(String regionId)? onRegionTap;
  final ValueChanged<ScaleUpdateDetails> onScaleUpdate;

  const MapWidget({
    super.key,
    required this.features,
    required this.scale,
    required this.offset,
    this.regionResults,
    this.regionAllianceResults,
    this.useAllianceColors = false,
    this.onRegionTap,
    required this.onScaleUpdate,
  });

  @override
  State<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  final ValueNotifier<String?> hoveredProvince = ValueNotifier(null);
  DateTime? _lastHoverTime;
  Size? _geometrySize;
  List<dynamic>? _geometryFeatures;
  final List<_RegionGeometry> _regionGeometries = [];

  static const hoverThrottle = Duration(milliseconds: 40);

  void _handleHover(String? province) {
    if (province == null) {
      _clearHover();
      return;
    }

    final now = DateTime.now();
    if (_lastHoverTime != null &&
        now.difference(_lastHoverTime!) < hoverThrottle) {
      return;
    }

    _lastHoverTime = now;

    if (hoveredProvince.value != province) {
      hoveredProvince.value = province;
    }
  }

  void _clearHover() {
    if (hoveredProvince.value != null) {
      hoveredProvince.value = null;
    }
  }

  @override
  void dispose() {
    hoveredProvince.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: MouseRegion(
        onExit: (_) => _clearHover(),
        onHover: (event) {
          final regionId = _getRegionAtPosition(event.localPosition);
          _handleHover(regionId);
        },
        child: ValueListenableBuilder<String?>(
          valueListenable: hoveredProvince,
          builder: (_, hovered, __) {
            return GestureDetector(
              onScaleUpdate: widget.onScaleUpdate,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final size = Size(constraints.maxWidth, constraints.maxHeight);
                  _ensureGeometryCache(size);
                  return SizedBox.expand(
                    child: CustomPaint(
                      painter: _TurkeyMapPainter(
                        features: widget.features,
                        scale: widget.scale,
                        offset: widget.offset,
                        regionResults: widget.regionResults,
                        regionAllianceResults: widget.regionAllianceResults,
                        useAllianceColors: widget.useAllianceColors,
                        hoveredProvince: hovered,
                        onRegionTap: widget.onRegionTap,
                        regionGeometries: _regionGeometries,
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }

  String? _getRegionAtPosition(Offset position) {
    final size = context.size;
    if (size == null) return null;
    _ensureGeometryCache(size);
    _ensureGeometryCache(size);

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

    final translated =
        position - Offset(centerOffsetX, centerOffsetY) - widget.offset;
    final localPoint = translated / widget.scale;

    for (final geometry in _regionGeometries) {
      for (final path in geometry.paths) {
        if (path.contains(localPoint)) {
          return geometry.regionId;
        }
      }
    }

    return null;
  }

  void _ensureGeometryCache(Size size) {
    if (size.isEmpty) return;
    if (identical(_geometryFeatures, widget.features) &&
        _geometrySize == size &&
        _regionGeometries.isNotEmpty) {
      return;
    }

    _geometryFeatures = widget.features;
    _geometrySize = size;
    _regionGeometries.clear();

    const double minLon = 25.0;
    const double maxLon = 45.0;
    const double minLat = 35.8;
    const double maxLat = 42.2;

    final lonRange = maxLon - minLon;
    final latRange = maxLat - minLat;
    final scaleX = size.width / lonRange;
    final scaleY = size.height / latRange;
    final realScale = (scaleX < scaleY ? scaleX : scaleY) * 1.05;

    for (var feature in widget.features) {
      final properties = feature["properties"];
      final regionId = properties?["id"] as String?;
      final geom = feature["geometry"];
      if (regionId == null || geom == null) continue;

      final paths = <Path>[];

      void addPolygon(List<dynamic> polygon) {
        for (var ring in polygon) {
          final path = Path();
          bool first = true;
          for (var c in ring) {
            final lon = (c[0] as num).toDouble();
            final lat = (c[1] as num).toDouble();
            final x = (lon - minLon) * realScale;
            final y = (maxLat - lat) * realScale;
            if (first) {
              path.moveTo(x, y);
              first = false;
            } else {
              path.lineTo(x, y);
            }
          }
          path.close();
          paths.add(path);
        }
      }

      if (geom["type"] == "Polygon") {
        addPolygon(geom["coordinates"]);
      } else if (geom["type"] == "MultiPolygon") {
        for (var poly in geom["coordinates"]) {
          addPolygon(poly);
        }
      }

      if (paths.isNotEmpty) {
        _regionGeometries.add(
          _RegionGeometry(
            regionId: regionId,
            paths: paths,
          ),
        );
      }
    }
  }
}

// -------------------------------------------------------------
// TÜRKİYE HARİTASI ÇİZİMİ
// -------------------------------------------------------------
class _TurkeyMapPainter extends CustomPainter {
  final List<dynamic> features;
  final double scale;
  final Offset offset;
  final Map<String, RegionResult>? regionResults;
  final Map<String, RegionAllianceResult>? regionAllianceResults;
  final bool useAllianceColors;
  final Function(String regionId)? onRegionTap;
  final String? hoveredProvince;
  final List<_RegionGeometry>? regionGeometries;

  _TurkeyMapPainter({
    required this.features,
    required this.scale,
    required this.offset,
    this.regionResults,
    this.regionAllianceResults,
    this.useAllianceColors = false,
    this.onRegionTap,
    this.hoveredProvince,
    this.regionGeometries,
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

    final geometries = regionGeometries;
    if (geometries != null && geometries.isNotEmpty) {
      for (final geometry in geometries) {
        final regionId = geometry.regionId;
        Color regionColor = Colors.grey.shade300;
        if (useAllianceColors &&
            regionAllianceResults != null &&
            regionAllianceResults!.containsKey(regionId)) {
          final result = regionAllianceResults![regionId]!;
          final leader =
              result.leadingPartyPerAlliance[result.winnerAlliance];
          regionColor = leader != null
              ? colorForParty(leader)
              : colorForAlliance(result.winnerAlliance);
        } else if (regionResults != null &&
            regionResults!.containsKey(regionId)) {
          final result = regionResults![regionId]!;
          final leadingParty = _partyWithHighestVote(result.votes);
          if (leadingParty != null) {
            regionColor = colorForParty(leadingParty);
          }
        }

        final isHovered = hoveredProvince == regionId;

        final strokePaint = Paint()
          ..color = isHovered ? Colors.black : Colors.blueGrey.shade600
          ..style = PaintingStyle.stroke
          ..strokeWidth = (isHovered ? 1.5 : 0.7) / scale;

        final fillPaint = Paint()
          ..color = isHovered ? regionColor.withOpacity(0.8) : regionColor
          ..style = PaintingStyle.fill;

        for (final path in geometry.paths) {
          canvas.drawPath(path, fillPaint);
          canvas.drawPath(path, strokePaint);
        }
      }
      return;
    }

    for (var feature in features) {
      final properties = feature["properties"];
      final regionId = properties?["id"] as String? ?? "";
      final geom = feature["geometry"];
      if (geom == null) continue;

      // Bölge rengini belirle
      Color regionColor = Colors.grey.shade300;
      if (useAllianceColors &&
          regionAllianceResults != null &&
          regionAllianceResults!.containsKey(regionId)) {
        final result = regionAllianceResults![regionId]!;
        final leader =
            result.leadingPartyPerAlliance[result.winnerAlliance];
        regionColor = leader != null
            ? colorForParty(leader)
            : colorForAlliance(result.winnerAlliance);
      } else if (regionResults != null &&
          regionResults!.containsKey(regionId)) {
        final result = regionResults![regionId]!;
        final leadingParty = _partyWithHighestVote(result.votes);
        if (leadingParty != null) {
          regionColor = colorForParty(leadingParty);
        }
      }

      final isHovered = hoveredProvince == regionId;

      final strokePaint = Paint()
        ..color = isHovered ? Colors.black : Colors.blueGrey.shade600
        ..style = PaintingStyle.stroke
        ..strokeWidth = (isHovered ? 1.5 : 0.7) / scale;

      final fillPaint = Paint()
        ..color = isHovered ? regionColor.withOpacity(0.8) : regionColor
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
  bool shouldRepaint(covariant _TurkeyMapPainter oldDelegate) =>
      oldDelegate.features != features ||
      oldDelegate.scale != scale ||
      oldDelegate.offset != offset ||
      oldDelegate.regionResults != regionResults ||
      oldDelegate.regionAllianceResults != regionAllianceResults ||
      oldDelegate.useAllianceColors != useAllianceColors ||
      oldDelegate.hoveredProvince != hoveredProvince ||
      oldDelegate.regionGeometries != regionGeometries;

  @override
  bool? hitTest(Offset position) => true;
}

// -------------------------------------------------------------
// TIKLANABİLİR HARİTA WIDGET'I (Kullanım için alternatif)
// -------------------------------------------------------------
class InteractiveMapWidget extends StatefulWidget {
  final List<dynamic> features;
  final Map<String, RegionResult>? regionResults;
  final Map<String, RegionAllianceResult>? regionAllianceResults;
  final bool useAllianceColors;
  final Function(String regionId)? onRegionTap;
  final double? scale;
  final Offset? offset;
  final Function(double scale, Offset offset)? onTransform;

  const InteractiveMapWidget({
    required this.features,
    this.regionAllianceResults,
    this.useAllianceColors = false,
    this.scale,
    this.offset,
    this.regionResults,
    this.onTransform,
    this.onRegionTap,
    super.key,
  });

  @override
  State<InteractiveMapWidget> createState() => _InteractiveMapWidgetState();
}

class _InteractiveMapWidgetState extends State<InteractiveMapWidget> {
  late double _scale;
  late Offset _offset;
  String? _hoveredRegion;
  Offset? _pendingHoverPosition;
  bool _hoverUpdateScheduled = false;
  Size? _geometrySize;
  List<dynamic>? _geometryFeatures;
  final List<_RegionGeometry> _regionGeometries = [];
  ui.Picture? _basePicture;
  Size? _basePictureSize;
  double? _basePictureScale;
  List<dynamic>? _basePictureFeatures;
  Map<String, RegionResult>? _basePictureRegionResults;
  Map<String, RegionAllianceResult>? _basePictureRegionAllianceResults;
  bool? _basePictureUseAllianceColors;

  @override
  void initState() {
    super.initState();
    _scale = widget.scale ?? 1.0;
    _offset = widget.offset ?? Offset.zero;
  }

  @override
  Widget build(BuildContext context) {
    _scale = widget.scale ?? _scale;
    _offset = widget.offset ?? _offset;

    return Listener(
      onPointerDown: (event) => _handlePointerDown(event),
      child: MouseRegion(
        onExit: (_) {
          if (_hoveredRegion != null) {
            setState(() {
              _hoveredRegion = null;
            });
          }
        },
        onHover: (event) => _handlePointerHover(event),
        child: GestureDetector(
          onScaleUpdate: (details) {
            setState(() {
              _scale = (_scale * details.scale).clamp(0.5, 3.0);
              _offset = _offset + details.focalPointDelta;
            });
            widget.onTransform?.call(_scale, _offset);
          },
          child: LayoutBuilder(
            builder: (context, constraints) {
              final size = Size(constraints.maxWidth, constraints.maxHeight);
              _ensureGeometryCache(size);
              _ensureBasePicture(size, _scale);
              return SizedBox.expand(
                child: CustomPaint(
                  painter: InteractiveMapPainter(
                    features: widget.features,
                    scale: _scale,
                    offset: _offset,
                    regionResults: widget.regionResults,
                    regionAllianceResults: widget.regionAllianceResults,
                    useAllianceColors: widget.useAllianceColors,
                    hoveredRegion: _hoveredRegion,
                    regionGeometries: _regionGeometries,
                    basePicture: _basePicture,
                  ),
                ),
              );
            },
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
    _pendingHoverPosition = event.localPosition;
    if (_hoverUpdateScheduled) return;
    _hoverUpdateScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _hoverUpdateScheduled = false;
      if (!mounted) return;
      final position = _pendingHoverPosition;
      if (position == null) return;
      final regionId = _getRegionAtPosition(position);
      if (regionId != _hoveredRegion) {
        setState(() {
          _hoveredRegion = regionId;
        });
      }
    });
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

    for (final geometry in _regionGeometries) {
      for (final path in geometry.paths) {
        if (path.contains(localPoint)) {
          return geometry.regionId;
        }
      }
    }

    return null;
  }

  void _ensureGeometryCache(Size size) {
    if (size.isEmpty) return;
    if (identical(_geometryFeatures, widget.features) &&
        _geometrySize == size &&
        _regionGeometries.isNotEmpty) {
      return;
    }

    _geometryFeatures = widget.features;
    _geometrySize = size;
    _regionGeometries.clear();

    const double minLon = 25.0;
    const double maxLon = 45.0;
    const double minLat = 35.8;
    const double maxLat = 42.2;

    final lonRange = maxLon - minLon;
    final latRange = maxLat - minLat;
    final scaleX = size.width / lonRange;
    final scaleY = size.height / latRange;
    final realScale = (scaleX < scaleY ? scaleX : scaleY) * 1.05;

    for (var feature in widget.features) {
      final properties = feature["properties"];
      final regionId = properties?["id"] as String?;
      final geom = feature["geometry"];
      if (regionId == null || geom == null) continue;

      final paths = <Path>[];

      void addPolygon(List<dynamic> polygon) {
        for (var ring in polygon) {
          final path = Path();
          bool first = true;
          for (var c in ring) {
            final lon = (c[0] as num).toDouble();
            final lat = (c[1] as num).toDouble();
            final x = (lon - minLon) * realScale;
            final y = (maxLat - lat) * realScale;
            if (first) {
              path.moveTo(x, y);
              first = false;
            } else {
              path.lineTo(x, y);
            }
          }
          path.close();
          paths.add(path);
        }
      }

      if (geom["type"] == "Polygon") {
        addPolygon(geom["coordinates"]);
      } else if (geom["type"] == "MultiPolygon") {
        for (var poly in geom["coordinates"]) {
          addPolygon(poly);
        }
      }

      if (paths.isNotEmpty) {
        _regionGeometries.add(
          _RegionGeometry(
            regionId: regionId,
            paths: paths,
          ),
        );
      }
    }
  }

  void _ensureBasePicture(Size size, double scale) {
    if (size.isEmpty || _regionGeometries.isEmpty) return;
    if (identical(_basePictureFeatures, widget.features) &&
        _basePictureSize == size &&
        _basePictureScale == scale &&
        _basePictureRegionResults == widget.regionResults &&
        _basePictureRegionAllianceResults == widget.regionAllianceResults &&
        _basePictureUseAllianceColors == widget.useAllianceColors &&
        _basePicture != null) {
      return;
    }

    _basePictureFeatures = widget.features;
    _basePictureSize = size;
    _basePictureScale = scale;
    _basePictureRegionResults = widget.regionResults;
    _basePictureRegionAllianceResults = widget.regionAllianceResults;
    _basePictureUseAllianceColors = widget.useAllianceColors;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    for (final geometry in _regionGeometries) {
      final regionId = geometry.regionId;
      Color regionColor = Colors.grey.shade300;
      if (widget.useAllianceColors &&
          widget.regionAllianceResults != null &&
          widget.regionAllianceResults!.containsKey(regionId)) {
        final result = widget.regionAllianceResults![regionId]!;
        final leader = result.leadingPartyPerAlliance[result.winnerAlliance];
        regionColor =
            leader != null ? colorForParty(leader) : colorForAlliance(result.winnerAlliance);
      } else if (widget.regionResults != null &&
          widget.regionResults!.containsKey(regionId)) {
        final result = widget.regionResults![regionId]!;
        final leadingParty = _partyWithHighestVote(result.votes);
        if (leadingParty != null) {
          regionColor = colorForParty(leadingParty);
        }
      }

      final strokePaint = Paint()
        ..color = Colors.blueGrey.shade600
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.7 / scale;

      final fillPaint = Paint()
        ..color = regionColor
        ..style = PaintingStyle.fill;

      for (final path in geometry.paths) {
        canvas.drawPath(path, fillPaint);
        canvas.drawPath(path, strokePaint);
      }
    }

    _basePicture = recorder.endRecording();
  }
}

class InteractiveMapPainter extends CustomPainter {
  final List<dynamic> features;
  final double scale;
  final Offset offset;
  final Map<String, RegionResult>? regionResults;
  final Map<String, RegionAllianceResult>? regionAllianceResults;
  final bool useAllianceColors;
  final String? hoveredRegion;
  final List<_RegionGeometry>? regionGeometries;
  final ui.Picture? basePicture;

  InteractiveMapPainter({
    required this.features,
    required this.scale,
    required this.offset,
    this.regionResults,
    this.regionAllianceResults,
    this.useAllianceColors = false,
    this.hoveredRegion,
    this.regionGeometries,
    this.basePicture,
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

    final geometries = regionGeometries;
    if (geometries != null && geometries.isNotEmpty && basePicture != null) {
      canvas.drawPicture(basePicture!);
      if (hoveredRegion == null) return;
      _paintHoveredRegion(canvas, geometries, hoveredRegion!);
      return;
    }

    if (geometries != null && geometries.isNotEmpty) {
      for (final geometry in geometries) {
        final regionId = geometry.regionId;
        Color regionColor = Colors.grey.shade300;
        if (useAllianceColors &&
            regionAllianceResults != null &&
            regionAllianceResults!.containsKey(regionId)) {
          final result = regionAllianceResults![regionId]!;
          final leader =
              result.leadingPartyPerAlliance[result.winnerAlliance];
          regionColor = leader != null
              ? colorForParty(leader)
              : colorForAlliance(result.winnerAlliance);
        } else if (regionResults != null &&
            regionResults!.containsKey(regionId)) {
          final result = regionResults![regionId]!;
          final leadingParty = _partyWithHighestVote(result.votes);
          if (leadingParty != null) {
            regionColor = colorForParty(leadingParty);
          }
        }

        final isHovered = hoveredRegion == regionId;
        final strokePaint = Paint()
          ..color = isHovered ? Colors.black : Colors.blueGrey.shade600
          ..style = PaintingStyle.stroke
          ..strokeWidth = (isHovered ? 1.5 : 0.7) / scale;
        final fillPaint = Paint()
          ..color = isHovered ? regionColor.withOpacity(0.8) : regionColor
          ..style = PaintingStyle.fill;

        for (final path in geometry.paths) {
          canvas.drawPath(path, fillPaint);
          canvas.drawPath(path, strokePaint);
        }
      }
      return;
    }

    for (var feature in features) {
      final properties = feature["properties"];
      final regionId = properties?["id"] as String? ?? "";
      final geom = feature["geometry"];
      if (geom == null) continue;

      Color regionColor = Colors.grey.shade300;
      if (useAllianceColors &&
          regionAllianceResults != null &&
          regionAllianceResults!.containsKey(regionId)) {
        final result = regionAllianceResults![regionId]!;
        final leader =
            result.leadingPartyPerAlliance[result.winnerAlliance];
        regionColor = leader != null
            ? colorForParty(leader)
            : colorForAlliance(result.winnerAlliance);
      } else if (regionResults != null &&
          regionResults!.containsKey(regionId)) {
        final result = regionResults![regionId]!;
        final leadingParty = _partyWithHighestVote(result.votes);
        if (leadingParty != null) {
          regionColor = colorForParty(leadingParty);
        }
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
      oldDelegate.regionAllianceResults != regionAllianceResults ||
      oldDelegate.useAllianceColors != useAllianceColors ||
      oldDelegate.hoveredRegion != hoveredRegion ||
      oldDelegate.regionGeometries != regionGeometries ||
      oldDelegate.basePicture != basePicture;

  void _paintHoveredRegion(
    Canvas canvas,
    List<_RegionGeometry> geometries,
    String hoveredId,
  ) {
    _RegionGeometry? geometry;
    for (final item in geometries) {
      if (item.regionId == hoveredId) {
        geometry = item;
        break;
      }
    }
    if (geometry == null) return;

    Color regionColor = Colors.grey.shade300;
    if (useAllianceColors &&
        regionAllianceResults != null &&
        regionAllianceResults!.containsKey(hoveredId)) {
      final result = regionAllianceResults![hoveredId]!;
      final leader = result.leadingPartyPerAlliance[result.winnerAlliance];
      regionColor =
          leader != null ? colorForParty(leader) : colorForAlliance(result.winnerAlliance);
    } else if (regionResults != null &&
        regionResults!.containsKey(hoveredId)) {
      final result = regionResults![hoveredId]!;
      final leadingParty = _partyWithHighestVote(result.votes);
      if (leadingParty != null) {
        regionColor = colorForParty(leadingParty);
      }
    }

    final strokePaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5 / scale;

    final fillPaint = Paint()
      ..color = regionColor.withOpacity(0.8)
      ..style = PaintingStyle.fill;

    for (final path in geometry.paths) {
      canvas.drawPath(path, fillPaint);
      canvas.drawPath(path, strokePaint);
    }
  }
}

/// Bölgedeki en yüksek oy oranına sahip partiyi döndürür
String? _partyWithHighestVote(Map<String, double> votes) {
  if (votes.isEmpty) return null;

  String? leader;
  double maxVote = -double.infinity;

  votes.forEach((party, vote) {
    final value = vote.isFinite ? vote : 0.0;
    if (leader == null || value > maxVote) {
      leader = party;
      maxVote = value;
    }
  });

  return leader;
}

class _RegionGeometry {
  final String regionId;
  final List<Path> paths;

  const _RegionGeometry({
    required this.regionId,
    required this.paths,
  });
}


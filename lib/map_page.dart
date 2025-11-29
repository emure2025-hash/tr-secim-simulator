import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'color_engine.dart'; // → Bölgeleri parti rengine boyayan motor
import 'regions.dart'; // → Region listesi (id – city – seats)
import 'legend_widget.dart';

// Bu widget haritayı ekrana çizer
class MapPage extends StatefulWidget {
  final Map<String, int> result; // Sonuç tablosu (CHP: 168, AKP: 195… gibi)

  const MapPage({super.key, required this.result});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  Map<String, dynamic>? geoJson; // GeoJSON verisi burada saklanacak
  Rect? geoBounds; // Tüm Türkiye'nin lon/lat bounding box'ı
  dynamic selectedRegionId; // Dokunulan bölge ID’si (string veya int olabilir)

  @override
  void initState() {
    super.initState();
    _loadMap();
  }

  /// GeoJSON içindeki tüm noktaların min/max lon/lat'ini hesaplar.
  Rect computeGeoBounds(Map<String, dynamic> geo) {
    double? minX, maxX, minY, maxY;

    for (var feature in geo["features"]) {
      final geometry = feature["geometry"];
      if (geometry == null) continue;

      final type = geometry["type"];
      final coords = geometry["coordinates"];

      if (type == "Polygon") {
        for (var poly in coords) {
          for (var point in poly) {
            final lon = (point[0] as num).toDouble();
            final lat = (point[1] as num).toDouble();

            minX = (minX == null) ? lon : (lon < minX! ? lon : minX!);
            maxX = (maxX == null) ? lon : (lon > maxX! ? lon : maxX!);
            minY = (minY == null) ? lat : (lat < minY! ? lat : minY!);
            maxY = (maxY == null) ? lat : (lat > maxY! ? lat : maxY!);
          }
        }
      } else if (type == "MultiPolygon") {
        for (var group in coords) {
          for (var poly in group) {
            for (var point in poly) {
              final lon = (point[0] as num).toDouble();
              final lat = (point[1] as num).toDouble();

              minX = (minX == null) ? lon : (lon < minX! ? lon : minX!);
              maxX = (maxX == null) ? lon : (lon > maxX! ? lon : maxX!);
              minY = (minY == null) ? lat : (lat < minY! ? lat : minY!);
              maxY = (maxY == null) ? lat : (lat > maxY! ? lat : maxY!);
            }
          }
        }
      }
    }

    return Rect.fromLTRB(minX!, minY!, maxX!, maxY!);
  }

  // GeoJSON loader (sadece regions87.geojson'u yükle)
  Future<void> _loadMap() async {
    const path = 'assets/maps/regions87_all.geojson';

    try {
      final data = await rootBundle.loadString(path);

      final decoded = json.decode(data);
      if (decoded is Map<String, dynamic>) {
        setState(() {
          geoJson = decoded;
          geoBounds = computeGeoBounds(decoded);
        });

        // ignore: avoid_print
        print('Loaded geojson from $path');
      } else {
        // ignore: avoid_print
        print('ERROR: GeoJSON formatı FeatureCollection değil.');
      }
    } catch (e) {
      // ignore: avoid_print
      print('ERROR: $path yüklenemedi: $e');
      setState(() {
        geoJson = {'type': 'FeatureCollection', 'features': []};
      });
    }
  }

  /// Ekran koordinatı için lon/lat'i aynı projeksiyonla canvas'a yansıtır.
  Offset _projectPoint(double lon, double lat, Size size) {
    final bounds = geoBounds!;
    final scaleX = size.width / (bounds.right - bounds.left);
    final scaleY = size.height / (bounds.bottom - bounds.top);
    final scale = scaleX < scaleY ? scaleX : scaleY;

    final x = (lon - bounds.left) * scale;
    final y = (bounds.bottom - lat) * scale;

    final offsetX = (size.width - (bounds.width * scale)) / 2;
    final offsetY = (size.height - (bounds.height * scale)) / 2;

    return Offset(x + offsetX, y + offsetY);
  }

  @override
  Widget build(BuildContext context) {
    final hasData = geoJson != null && geoBounds != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Türkiye Haritası"),
      ),
      body: !hasData
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                LayoutBuilder(
                  builder: (context, constraints) {
                    final canvasSize = Size(
                        constraints.maxWidth, constraints.maxHeight);

                    return GestureDetector(
                      onTapUp: (details) {
                        final id = _hitTest(
                          details.localPosition,
                          canvasSize,
                        );
                        if (id != null) {
                          setState(() => selectedRegionId = id);
                        }
                      },
                      child: CustomPaint(
                        painter: TurkeyMapPainter(
                          geoJson: geoJson!,
                          selectedRegionId: selectedRegionId,
                          getColor: (regionKey) {
                            // regionKey geojson'daki props["id"] olabilir (int veya string)
                            final region = regions.firstWhere(
                              (r) =>
                                  r.id.toString() == regionKey.toString() ||
                                  r.city.toString().toLowerCase() ==
                                      regionKey.toString().toLowerCase(),
                              orElse: () => regions[0],
                            );

                            // widget.result int -> double dönüşümü
                            final nationalVotes = widget.result
                                .map((k, v) => MapEntry(k, v.toDouble()));

                            return computeRegionColor(
                              city: region.city,
                              nationalVotes: nationalVotes,
                            );
                          },
                          bounds: geoBounds!,
                        ),
                        size: canvasSize,
                      ),
                    );
                  },
                ),

                // → LEGEND BURADA
                const Positioned(
                  right: 12,
                  top: 12,
                  child: LegendWidget(),
                ),
              ],
            ),
    );
  }

  // Dokunulan noktanın hangi bölgeye ait olduğunu anlamaya çalışır
  dynamic _hitTest(Offset pos, Size canvasSize) {
    if (geoJson == null || geoBounds == null) return null;

    for (var feature in geoJson!["features"]) {
      final props = feature["properties"];
      final id = props?["id"];
      final geometry = feature["geometry"];
      if (geometry == null) continue;

      final type = geometry["type"];

      if (type == "Polygon") {
        for (var polygon in geometry["coordinates"]) {
          if (_pointInPolygon(pos, polygon, canvasSize)) return id;
        }
      } else if (type == "MultiPolygon") {
        for (var polyGroup in geometry["coordinates"]) {
          for (var polygon in polyGroup) {
            if (_pointInPolygon(pos, polygon, canvasSize)) return id;
          }
        }
      }
    }

    return null;
  }

  // Bir noktanın çokgen içinde olup olmadığını kontrol eden klasik fonksiyon.
  // Önemli: Aynı projeksiyon (_projectPoint) kullanılıyor ki çizim ve hit-test örtüşsün.
  bool _pointInPolygon(Offset pos, List poly, Size size) {
    if (geoBounds == null) return false;

    bool inside = false;

    for (int i = 0, j = poly.length - 1; i < poly.length; j = i++) {
      final lonI = (poly[i][0] as num).toDouble();
      final latI = (poly[i][1] as num).toDouble();
      final pI = _projectPoint(lonI, latI, size);
      final xi = pI.dx;
      final yi = pI.dy;

      final lonJ = (poly[j][0] as num).toDouble();
      final latJ = (poly[j][1] as num).toDouble();
      final pJ = _projectPoint(lonJ, latJ, size);
      final xj = pJ.dx;
      final yj = pJ.dy;

      final intersects = ((yi > pos.dy) != (yj > pos.dy)) &&
          (pos.dx <
              (xj - xi) * (pos.dy - yi) / ((yj - yi) + 0.000001) + xi);

      if (intersects) inside = !inside;
    }

    return inside;
  }
}

// Bu sınıf haritadaki bölgeleri çizen ressam
class TurkeyMapPainter extends CustomPainter {
  final Map<String, dynamic> geoJson;
  final dynamic selectedRegionId;
  final Color Function(dynamic regionKey) getColor;
  final Rect bounds;

  TurkeyMapPainter({
    required this.geoJson,
    required this.selectedRegionId,
    required this.getColor,
    required this.bounds,
  });

  /// Painter tarafındaki projeksiyon fonksiyonu.
  Offset projectPoint(double lon, double lat, Size size) {
    final scaleX = size.width / (bounds.right - bounds.left);
    final scaleY = size.height / (bounds.bottom - bounds.top);
    final scale = scaleX < scaleY ? scaleX : scaleY;

    final x = (lon - bounds.left) * scale;
    final y = (bounds.bottom - lat) * scale;

    final offsetX = (size.width - (bounds.width * scale)) / 2;
    final offsetY = (size.height - (bounds.height * scale)) / 2;

    return Offset(x + offsetX, y + offsetY);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.black.withOpacity(0.4)
      ..strokeWidth = 0.6;

    for (var feature in geoJson["features"]) {
      final props = feature["properties"];
      final id = props?["id"];
      final geometry = feature["geometry"];
      if (geometry == null) continue;

      final fillPaint = Paint()
        ..style = PaintingStyle.fill
        ..color =
            getColor(id).withOpacity(id == selectedRegionId ? 1.0 : 0.8);

      final type = geometry["type"];

      if (type == "Polygon") {
        for (var polygon in geometry["coordinates"]) {
          final path = _createPath(polygon, size);
          canvas.drawPath(path, fillPaint);
          canvas.drawPath(path, borderPaint);
        }
      } else if (type == "MultiPolygon") {
        for (var polyGroup in geometry["coordinates"]) {
          for (var polygon in polyGroup) {
            final path = _createPath(polygon, size);
            canvas.drawPath(path, fillPaint);
            canvas.drawPath(path, borderPaint);
          }
        }
      }
    }
  }

  Path _createPath(List polygon, Size size) {
    final path = Path();
    bool first = true;

    for (var point in polygon) {
      final lon = (point[0] as num).toDouble();
      final lat = (point[1] as num).toDouble();
      final pos = projectPoint(lon, lat, size);

      if (first) {
        path.moveTo(pos.dx, pos.dy);
        first = false;
      } else {
        path.lineTo(pos.dx, pos.dy);
      }
    }

    return path;
  }

  @override
  bool shouldRepaint(covariant TurkeyMapPainter oldDelegate) => true;
}

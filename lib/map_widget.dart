import 'package:flutter/material.dart';

// -------------------------------------------------------------
// MAP WIDGET (MainPage'de kullanılan ana harita bileşeni)
// -------------------------------------------------------------
class MapWidget extends StatelessWidget {
  final List<dynamic> features;
  final double scale;
  final Offset offset;
  final ValueChanged<ScaleUpdateDetails> onScaleUpdate; // İnteraktivite için

  const MapWidget({
    required this.features,
    required this.scale,
    required this.offset,
    required this.onScaleUpdate,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onScaleUpdate: onScaleUpdate, // MainPage'den gelen fonksiyonu kullan
      child: CustomPaint(
        painter: MapPainter(
          features: features,
          scale: scale,
          offset: offset,
        ),
        size: Size.infinite, // Mümkün olan tüm alanı kapla
      ),
    );
  }
}

// -------------------------------------------------------------
// MAP PAINTER (Haritayı çizen CustomPainter)
// -------------------------------------------------------------
class MapPainter extends CustomPainter {
  final List<dynamic> features;
  final double scale;
  final Offset offset;

  MapPainter({
    required this.features,
    required this.scale,
    required this.offset,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Ölçek ve kaydırma
    canvas.translate(offset.dx, offset.dy);
    canvas.scale(scale);

    final paint = Paint()
      ..color = Colors.blueGrey.shade400
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.6 / scale; // Zoom yapınca kalınlık değişmesin diye

    for (var feature in features) {
      final geom = feature["geometry"];
      if (geom == null) continue;

      // Her bölgeye göre farklı bir renk ataması yapılabilir (Şimdilik gri)
      final fillPaint = Paint()
        ..color = Colors.blueGrey.shade100 
        ..style = PaintingStyle.fill;
      
      // GeoJSON yapısına göre MultiPolygon ve Polygon kontrolü
      if (geom["type"] == "Polygon") {
        for (var ring in geom["coordinates"]) {
          _drawPath(canvas, ring, fillPaint, paint, size);
        }
      } else if (geom["type"] == "MultiPolygon") {
        for (var poly in geom["coordinates"]) {
          for (var ring in poly) {
            _drawPath(canvas, ring, fillPaint, paint, size);
          }
        }
      }
    }
  }

  /// Bir polygon ring çizen yardımcı fonksiyon
  void _drawPath(Canvas canvas, List coords, Paint fillPaint, Paint strokePaint, Size size) {
    final path = Path();
    bool first = true;

    // --- ORİJİNAL, SADE KOORDİNAT DÖNÜŞÜM DEĞERLERİ ---
    // Bu değerler, haritanın ekranda düzgün ve orantılı görünmesi için esastır.
    const double minLon = 26.0; // Türkiye min boylamı (Yaklaşık)
    const double maxLon = 45.0; // Türkiye max boylamı (Yaklaşık)
    const double maxLat = 42.0; // Türkiye max enlemi (Yaklaşık)
    const double minLat = 36.0; // Türkiye min enlemi (Yaklaşık)
    
    final double lonRange = maxLon - minLon;
    final double latRange = maxLat - minLat;
    const double mapScale = 40.0; // Haritanın büyüklüğünü ayarlayan sabit
    
    // Y ekseninin ters çevrilmesi için sabit (GeoJSON'da y-ekseni ters çalışır)
    const double yFlipFactor = 0.4; 

    for (var c in coords) {
      final lon = (c[0] as num).toDouble();
      final lat = (c[1] as num).toDouble();

      // WGS84 koordinatlarını (lon, lat) ekran koordinatlarına (x, y) dönüştürme
      // X = (Boylam - MinBoylam) * Ölçekleme
      // Y = (MaxEnlem - Enlem) * Ölçekleme (Y eksenini ters çevirme)
      
      // size.width ve size.height, haritanın Expanded widget'ından aldığı alana göre dinamik ölçekleme sağlar.
      final double x = (lon - minLon) * mapScale * size.width / lonRange;
      final double y = (maxLat - lat) * mapScale * size.height / latRange * yFlipFactor;
      
      if (first) {
        path.moveTo(x, y);
        first = false;
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    
    // Önce dolgu, sonra sınırları çiz
    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, strokePaint);
  }

  @override
  bool shouldRepaint(covariant MapPainter oldDelegate) {
    // Sadece özellikler, ölçek veya kaydırma değiştiyse tekrar çiz
    return oldDelegate.features != features ||
        oldDelegate.scale != scale ||
        oldDelegate.offset != offset;
  }
}
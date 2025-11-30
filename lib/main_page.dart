import 'dart:convert';
import 'package:flutter/material.dart';
import 'map_widget.dart';
import 'package:flutter/services.dart' show rootBundle;

// -------------------------------------------------------------
// ANA SAYFA — Harita + Oy Girişi + Sonuç Paneli
// -------------------------------------------------------------
class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  bool showInput = true; // Oy girişi mi? Sonuç ekranı mı?
  Map<String, int>? result;

  List features = [];
  double scale = 1.0;
  Offset offset = Offset.zero;

  @override
  void initState() {
    super.initState();
    loadGeoJson();
  }

  Future<void> loadGeoJson() async {
    String data = await rootBundle.loadString(
      "assets/maps/turkiye_87_secim_bolgesi.geojson",
    );
    final json = jsonDecode(data);

    setState(() => features = json["features"]);
  }

  // Şimdilik demo bir hesaplama
  Map<String, int> calculateParliament(Map<String, double> votes) {
    return {
      "CHP": 180,
      "AKP": 160,
      "DEM": 60,
      "MHP": 50,
      "İYİ Parti": 30,
      "Diğer": 120,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // --------------------- ÜSTTE HARİTA ---------------------
          Expanded(
            flex: 5,
            child: features.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : GestureDetector(
                    onScaleUpdate: (d) {
                      setState(() {
                        scale = d.scale;
                        offset += d.focalPointDelta;
                      });
                    },
                    child: CustomPaint(
                      painter: MapPainter(features, scale, offset, result),
                      child: Container(color: Colors.grey.shade100),
                    ),
                  ),
          ),

          // --------------------- ALTI PANEL -----------------------
          Expanded(
            flex: 4,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: showInput
                  ? VoteInputPanel(
                      onSimulate: (votes) {
                        final r = calculateParliament(votes);
                        setState(() {
                          result = r;
                          showInput = false;
                        });
                      },
                    )
                  : ResultPanel(
                      result: result!,
                      onBack: () => setState(() => showInput = true),
                    ),
            ),
          )
        ],
      ),
    );
  }
}

// -------------------------------------------------------------
// HARİTA ÇİZİCİ
// -------------------------------------------------------------
class MapPainter extends CustomPainter {
  final List features;
  final double scale;
  final Offset offset;
  final Map<String, int>? result;

  MapPainter(this.features, this.scale, this.offset, this.result);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.translate(offset.dx, offset.dy);
    canvas.scale(scale);

    for (var f in features) {
      final geom = f["geometry"];

      // Kazanan parti rengi (şimdilik tek renk)
      Color fill = Colors.white;
      if (result != null) {
        final winner = result!.entries
            .reduce((a, b) => a.value > b.value ? a : b)
            .key;
        fill = _partyColor(winner).withOpacity(0.35);
      }

      final stroke = Paint()
        ..color = Colors.blueGrey.shade600
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.5;

      final fillPaint = Paint()
        ..color = fill
        ..style = PaintingStyle.fill;

      if (geom["type"] == "Polygon") {
        for (var coords in geom["coordinates"]) {
          final path = Path();
          bool first = true;

          for (var c in coords) {
             final num x = c[0];
             final num y = c[1];

      // Lon/Lat → ekran koordinatına dönüşüm
             final double px = (x - 25) * 30.0;
             final double py = (42 - y) * 30.0;

      if (first) {
        path.moveTo(px, py);
        first = false;
      } else {
        path.lineTo(px, py);
      }
    }

          canvas.drawPath(path, fillPaint);
          canvas.drawPath(path, stroke);
        }
      }
    }
  }

  Color _partyColor(String p) {
    switch (p) {
      case "CHP": return Colors.red;
      case "AKP": return Colors.orange;
      case "MHP": return Colors.blue;
      case "İYİ Parti": return Colors.lightBlue;
      case "DEM": return Colors.green;
      default: return Colors.grey;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// -------------------------------------------------------------
// OY GİRİŞ PANELİ
// -------------------------------------------------------------
class VoteInputPanel extends StatefulWidget {
  final Function(Map<String, double>) onSimulate;

  const VoteInputPanel({required this.onSimulate});

  @override
  State<VoteInputPanel> createState() => _VoteInputPanelState();
}

class _VoteInputPanelState extends State<VoteInputPanel> {
  Map<String, double> votes = {
    "CHP": 30,
    "AKP": 28,
    "MHP": 8,
    "İYİ Parti": 7,
    "DEM": 10,
    "Diğer": 17,
  };

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        const Text("Oy Oranlarını Girin",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),

        for (var p in votes.keys)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(p),
              Slider(
                value: votes[p]!,
                min: 0,
                max: 60,
                label: votes[p]!.toStringAsFixed(1),
                onChanged: (v) => setState(() => votes[p] = v),
              ),
            ],
          ),

        ElevatedButton(
          onPressed: () => widget.onSimulate(votes),
          child: const Text("Simülasyonu Çalıştır"),
        )
      ],
    );
  }
}

// -------------------------------------------------------------
// SONUÇ PANELİ
// -------------------------------------------------------------
class ResultPanel extends StatelessWidget {
  final Map<String, int> result;
  final VoidCallback onBack;

  const ResultPanel({required this.result, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text("Milletvekili Dağılımı",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),

        Expanded(
          child: ListView(
            children: result.entries
                .map((e) => ListTile(
                      title: Text(e.key),
                      trailing: Text("${e.value} MV"),
                    ))
                .toList(),
          ),
        ),

        ElevatedButton(
          onPressed: onBack,
          child: const Text("Geri Dön"),
        ),
      ],
    );
  }
}

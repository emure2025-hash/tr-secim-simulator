import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'map_widget.dart';

// -------------------------------------------------------------
// ANA SAYFA – Harita ve Oy Girişi Birlikte Kaydırılabilir
// -------------------------------------------------------------
class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  bool showInput = true;
  Map<String, int>? result;
  List<dynamic> features = [];
  double mapScale = 1.0;
  Offset mapOffset = Offset.zero;

  @override
  void initState() {
    super.initState();
    _loadGeoJson();
  }

  Future<void> _loadGeoJson() async {
    try {
      final data = await rootBundle.loadString(
        "assets/maps/turkiye_87_secim_bolgesi.geojson",
      );
      final decoded = jsonDecode(data);

      setState(() {
        features = decoded["features"] as List<dynamic>;
      });
    } catch (e) {
      debugPrint("GeoJSON yüklenemedi: $e");
    }
  }

  /// D'Hondt metoduna göre milletvekili dağılımı
  Map<String, int> _calculateParliament(
    Map<String, double> votes,
    double threshold,
  ) {
    const totalSeats = 600;

    // Barajı geçemeyen partileri filtrele
    final eligibleVotes = Map<String, double>.fromEntries(
      votes.entries.where((e) => e.value >= threshold),
    );

    if (eligibleVotes.isEmpty) {
      return {for (final entry in votes.entries) entry.key: 0};
    }

    // Her parti için mutlak oy sayısını hesapla
    final Map<String, double> absoluteVotes = {};
    eligibleVotes.forEach((party, percent) {
      absoluteVotes[party] = percent * 10000;
    });

    // D'Hondt metodu
    final Map<String, int> seats = {for (var p in eligibleVotes.keys) p: 0};

    for (int i = 0; i < totalSeats; i++) {
      String? maxParty;
      double maxQuotient = 0;

      absoluteVotes.forEach((party, votes) {
        final quotient = votes / (seats[party]! + 1);
        if (quotient > maxQuotient) {
          maxQuotient = quotient;
          maxParty = party;
        }
      });

      if (maxParty != null) {
        seats[maxParty!] = seats[maxParty!]! + 1;
      }
    }

    // Barajı geçemeyen partilere 0 sandalye
    votes.keys.where((p) => !eligibleVotes.containsKey(p)).forEach((p) {
      seats[p] = 0;
    });

    return seats;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("TR Seçim Simülatörü"),
        centerTitle: true,
        backgroundColor: Colors.blueGrey.shade700,
        foregroundColor: Colors.white,
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: showInput
            ? VoteInputScreen(
                key: const ValueKey("input"),
                features: features,
                mapScale: mapScale,
                mapOffset: mapOffset,
                onMapUpdate: (scale, offset) {
                  setState(() {
                    mapScale = scale;
                    mapOffset = offset;
                  });
                },
                onSimulate: (votes, threshold) {
                  final r = _calculateParliament(votes, threshold);
                  setState(() {
                    result = r;
                    showInput = false;
                  });
                },
              )
            : ResultPanel(
                key: const ValueKey("result"),
                result: result ?? {},
                onBack: () {
                  setState(() {
                    showInput = true;
                    result = null;
                  });
                },
              ),
      ),
    );
  }
}

// -------------------------------------------------------------
// OY GİRİŞ EKRANI (HARİTA + PANEL BİRLİKTE)
// -------------------------------------------------------------
class VoteInputScreen extends StatefulWidget {
  final List<dynamic> features;
  final double mapScale;
  final Offset mapOffset;
  final Function(double, Offset) onMapUpdate;
  final Function(Map<String, double>, double) onSimulate;

  const VoteInputScreen({
    required this.features,
    required this.mapScale,
    required this.mapOffset,
    required this.onMapUpdate,
    required this.onSimulate,
    super.key,
  });

  @override
  State<VoteInputScreen> createState() => _VoteInputScreenState();
}

class _VoteInputScreenState extends State<VoteInputScreen> {
  Map<String, double> votes = {
    "CHP": 0.0,
    "AKP": 0.0,
    "MHP": 0.0,
    "İYİ Parti": 0.0,
    "DEM": 0.0,
    "Diğer": 0.0,
  };

  double threshold = 0.0; // Seçim barajı başlangıç değeri %0

  double get total => votes.values.fold<double>(0.0, (sum, v) => sum + v);

  void _addParty() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Yeni Parti Ekle"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: "Parti Adı",
            hintText: "örn: Yeni Parti",
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("İptal"),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty &&
                  !votes.containsKey(controller.text.trim())) {
                setState(() {
                  votes[controller.text.trim()] = 0.0;
                });
              }
              Navigator.pop(context);
            },
            child: const Text("Ekle"),
          ),
        ],
      ),
    );
  }

  void _removeParty(String party) {
    setState(() {
      votes.remove(party);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // --------------------- HARİTA BÖLÜMÜ ---------------------
          SizedBox(
            height: 350,
            child: widget.features.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : MapWidget(
                    features: widget.features,
                    scale: widget.mapScale,
                    offset: widget.mapOffset,
                    result: null,
                    onScaleUpdate: (details) {
                      widget.onMapUpdate(
                        (widget.mapScale * details.scale).clamp(0.5, 3.0),
                        widget.mapOffset + details.focalPointDelta,
                      );
                    },
                  ),
          ),

          // --------------------- OY GİRİŞ PANELI ---------------------
          Container(
            color: Colors.grey.shade100,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  "Oy Oranlarını Girin",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),

                // SEÇİM BARAJI
                Card(
                  color: Colors.amber.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Seçim Barajı",
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.amber.shade700,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                "%${threshold.toStringAsFixed(1)}",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Slider(
                          value: threshold,
                          min: 0,
                          max: 15,
                          divisions: 150,
                          label: "%${threshold.toStringAsFixed(1)}",
                          activeColor: Colors.amber.shade700,
                          onChanged: (v) => setState(() => threshold = v),
                        ),
                        Text(
                          "Barajı geçemeyen partiler milletvekili alamaz",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // PARTİLER
                for (var p in votes.keys)
                  Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  p,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              if (votes.length > 2)
                                IconButton(
                                  icon: const Icon(Icons.delete_outline,
                                      size: 20),
                                  onPressed: () => _removeParty(p),
                                  tooltip: "Partiyi Kaldır",
                                ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.blueGrey.shade700,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  "%${votes[p]!.toStringAsFixed(1)}",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Slider(
                            value: votes[p]!,
                            min: 0,
                            max: 60,
                            divisions: 600, // 0.1'lik hassasiyet
                            label: "%${votes[p]!.toStringAsFixed(1)}",
                            onChanged: (v) => setState(() => votes[p] = v),
                          ),
                        ],
                      ),
                    ),
                  ),

                // PARTİ EKLE BUTONU
                OutlinedButton.icon(
                  onPressed: _addParty,
                  icon: const Icon(Icons.add),
                  label: const Text("Yeni Parti Ekle"),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),

                const SizedBox(height: 16),

                // TOPLAM GÖSTERGESİ
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: (total - 100).abs() < 0.5
                        ? Colors.green.shade100
                        : Colors.red.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: (total - 100).abs() < 0.5
                          ? Colors.green
                          : Colors.red,
                      width: 2,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Toplam:",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "%${total.toStringAsFixed(1)}",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: (total - 100).abs() < 0.5
                              ? Colors.green.shade900
                              : Colors.red.shade900,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // SİMÜLASYON BUTONU
                ElevatedButton(
                  onPressed: (total - 100).abs() < 0.5
                      ? () => widget.onSimulate(votes, threshold)
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueGrey.shade700,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Simülasyonu Çalıştır",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// -------------------------------------------------------------
// SONUÇ PANELİ
// -------------------------------------------------------------
class ResultPanel extends StatelessWidget {
  final Map<String, int> result;
  final VoidCallback onBack;

  const ResultPanel({
    required this.result,
    required this.onBack,
    super.key,
  });

  int get totalSeats => result.values.fold<int>(0, (sum, v) => sum + v);

  @override
  Widget build(BuildContext context) {
    final sorted = result.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Container(
      color: Colors.grey.shade100,
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            const Text(
              "Milletvekili Dağılımı",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              "Toplam: $totalSeats MV",
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 16),

            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: sorted.length,
                itemBuilder: (context, index) {
                  final entry = sorted[index];
                  final percentage =
                      totalSeats > 0 ? (entry.value / totalSeats * 100) : 0.0;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Text(
                              entry.key,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  "${entry.value} MV",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                Text(
                                  "%${percentage.toStringAsFixed(1)}",
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton(
                onPressed: onBack,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueGrey.shade700,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text(
                  "Geri Dön ve Oyları Değiştir",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
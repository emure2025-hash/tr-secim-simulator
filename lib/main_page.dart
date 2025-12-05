import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'map_widget.dart';
import 'region_calculator.dart';
import 'region_detail_dialog.dart';

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
  Map<String, double> lastVotes = {};
  double lastThreshold = 0.0;
  Map<String, RegionResult>? regionResults; // Bölge sonuçları
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
      
      debugPrint("✅ GeoJSON yüklendi: ${features.length} bölge");
    } catch (e) {
      debugPrint("❌ GeoJSON yüklenemedi: $e");
    }
  }

  /// D'Hondt metoduna göre milletvekili dağılımı
  Map<String, int> _calculateParliament(
    Map<String, double> votes,
    double threshold,
  ) {
    // Bölge bazlı hesaplama yap
    final regions = calculateAllRegions(
      nationalVotes: votes,
      threshold: threshold,
    );
    
    setState(() {
      regionResults = regions;
    });
    
    // Toplam milletvekili sayısını hesapla
    final Map<String, int> totalSeats = {
      for (var party in votes.keys) party: 0
    };
    
    regions.forEach((regionId, result) {
      result.seats.forEach((party, seats) {
        totalSeats[party] = (totalSeats[party] ?? 0) + seats;
      });
    });
    
    return totalSeats;
  }

  void _handleRegionTap(String regionId) {
    if (regionResults != null && regionResults!.containsKey(regionId)) {
      showRegionDetail(context, regionResults![regionId]!);
    }
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
                    lastVotes = Map<String, double>.from(votes);
                    lastThreshold = threshold;
                    result = r;
                    showInput = false;
                  });
                },
              )
            : ResultScreen(
                key: const ValueKey("result"),
                result: result ?? {},
                features: features,
                mapScale: mapScale,
                mapOffset: mapOffset,
                votes: lastVotes,
                regionResults: regionResults,
                onRegionTap: _handleRegionTap,
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
    "IYI Parti": 0.0,
    "DEM": 0.0,
    "DIGER": 0.0,
  };

  double threshold = 0.0;

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
                    regionResults: null, // Giriş ekranında sonuç yok
                    onScaleUpdate: (details) {
                      widget.onMapUpdate(
                        (widget.mapScale * details.scale).clamp(0.5, 3.0),
                        widget.mapOffset + details.focalPointDelta,
                      );
                    },
                  ),
          ),

          // --------------------- OY GİRİŞ PANELİ ---------------------
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
                          max: 10,
                          divisions: 20,
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
                            divisions: 600,
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
// SONUÇ EKRANI (HARİTA + SONUÇLAR)
// -------------------------------------------------------------
class ResultScreen extends StatelessWidget {
  final Map<String, int> result;
  final List<dynamic> features;
  final double mapScale;
  final Offset mapOffset;
  final Map<String, double> votes;
  final Map<String, RegionResult>? regionResults;
  final Function(String)? onRegionTap;
  final VoidCallback onBack;

  const ResultScreen({
    required this.result,
    required this.features,
    required this.mapScale,
    required this.mapOffset,
    required this.votes,
    this.regionResults,
    this.onRegionTap,
    required this.onBack,
    super.key,
  });

  int get totalSeats => result.values.fold<int>(0, (sum, v) => sum + v);

  @override
  Widget build(BuildContext context) {
    final sorted = result.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return SingleChildScrollView(
      child: Column(
        children: [
          // --------------------- HARİTA BÖLÜMÜ ---------------------
          SizedBox(
            height: 350,
            child: features.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : Stack(
                    children: [
                      InteractiveMapWidget(
                        features: features,
                        regionResults: regionResults,
                        onRegionTap: onRegionTap,
                      ),
                      Positioned(
                        top: 16,
                        right: 16,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.touch_app,
                                size: 20,
                                color: Colors.blueGrey,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "Bölgelere tıklayın",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.blueGrey.shade700,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
          ),

          // --------------------- SONUÇ PANELİ ---------------------
          Container(
            color: Colors.grey.shade100,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
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

                // Sonuç listesi
                ...sorted.map((entry) {
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
                }).toList(),

                const SizedBox(height: 16),
                ElevatedButton(
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}
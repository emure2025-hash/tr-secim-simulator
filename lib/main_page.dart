import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'map_widget.dart';
import 'region_calculator.dart';
import 'region_detail_dialog.dart';
import 'alliance.dart';
import 'alliance_calculator.dart';
import 'preset_parties.dart';
import 'alliance_detail_dialog.dart';
import 'map_mode.dart';
import 'result_screen.dart';
import 'alliance_manager_screen.dart';

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
  Map<String, RegionResult>? regionResults;
  Map<String, RegionAllianceResult>? regionAllianceResults;
  List<Alliance> alliances = [];
  MapMode mapMode = MapMode.party;
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

  Map<String, int> _calculateParliament(
    Map<String, double> votes,
    double threshold,
  ) {
    final regions = calculateAllRegions(
      nationalVotes: votes,
      threshold: threshold,
      alliances: alliances,
    );

    final regionsAlliance = calculateAllRegionAlliances(
      nationalVotes: votes,
      alliances: alliances,
      threshold: threshold,
    );

    setState(() {
      regionResults = regions;
      regionAllianceResults = regionsAlliance;
    });

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
    if (mapMode == MapMode.party) {
      if (regionResults != null && regionResults!.containsKey(regionId)) {
        showRegionDetail(context, regionResults![regionId]!);
      }
    } else {
      if (regionAllianceResults != null &&
          regionAllianceResults!.containsKey(regionId)) {
        showAllianceRegionDetail(context, regionAllianceResults![regionId]!);
      }
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
                alliances: alliances,
                onAlliancesChanged: (newAlliances) {
                  setState(() {
                    alliances = newAlliances;
                  });
                },
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
                onMapUpdate: (scale, offset) {
                  setState(() {
                    mapScale = scale;
                    mapOffset = offset;
                  });
                },
                votes: lastVotes,
                regionResults: regionResults,
                regionAllianceResults: regionAllianceResults,
                alliances: alliances,
                mapMode: mapMode,
                onMapModeChanged: (mode) {
                  setState(() {
                    mapMode = mode;
                  });
                },
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

class VoteInputScreen extends StatefulWidget {
  final List<dynamic> features;
  final double mapScale;
  final Offset mapOffset;
  final List<Alliance> alliances;
  final Function(List<Alliance>) onAlliancesChanged;
  final Function(double, Offset) onMapUpdate;
  final Function(Map<String, double>, double) onSimulate;

  const VoteInputScreen({
    required this.features,
    required this.mapScale,
    required this.mapOffset,
    required this.alliances,
    required this.onAlliancesChanged,
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
  bool showPresetParties = false;

  double get total => votes.values.fold<double>(0.0, (sum, v) => sum + v);

  void _addPartyFromPreset(String partyName) {
    if (!votes.containsKey(partyName)) {
      setState(() {
        votes[partyName] = 0.0;
      });
    }
  }

  void _addCustomParty() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Özel Parti Ekle"),
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

  void _manageAlliances() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AllianceManagerScreen(
          allParties: votes.keys.toList(),
          currentAlliances: widget.alliances,
          onSave: (newAlliances) {
            widget.onAlliancesChanged(newAlliances);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(
            height: 350,
            child: widget.features.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : MapWidget(
                    features: widget.features,
                    scale: widget.mapScale,
                    offset: widget.mapOffset,
                    regionResults: null,
                    onScaleUpdate: (details) {
                      widget.onMapUpdate(
                        (widget.mapScale * details.scale).clamp(0.5, 3.0),
                        widget.mapOffset + details.focalPointDelta,
                      );
                    },
                  ),
          ),
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

                // İttifak Yönetimi Butonu
                if (widget.alliances.isNotEmpty)
                  Card(
                    color: Colors.blue.shade50,
                    child: ListTile(
                      leading: Icon(Icons.groups, color: Colors.blue.shade700),
                      title: Text(
                        "${widget.alliances.length} İttifak Tanımlı",
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      trailing: ElevatedButton.icon(
                        onPressed: _manageAlliances,
                        icon: const Icon(Icons.edit, size: 18),
                        label: const Text("Düzenle"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade700,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ),
                if (widget.alliances.isEmpty)
                  Card(
                    color: Colors.orange.shade50,
                    child: ListTile(
                      leading:
                          Icon(Icons.info_outline, color: Colors.orange.shade700),
                      title: const Text("İttifak tanımlanmadı"),
                      subtitle: const Text("Parti bazlı hesaplama yapılacak"),
                      trailing: ElevatedButton.icon(
                        onPressed: _manageAlliances,
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text("İttifak Oluştur"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange.shade700,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ),

                const SizedBox(height: 16),

                // Seçim Barajı
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
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Partiler
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
                                  icon: const Icon(Icons.delete_outline, size: 20),
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

                // Parti Ekle Butonları
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          setState(() {
                            showPresetParties = !showPresetParties;
                          });
                        },
                        icon: const Icon(Icons.list),
                        label: const Text("Hazır Partiler"),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _addCustomParty,
                        icon: const Icon(Icons.add),
                        label: const Text("Özel Parti"),
                      ),
                    ),
                  ],
                ),

                // Hazır Parti Listesi
                if (showPresetParties)
                  Card(
                    margin: const EdgeInsets.only(top: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: PresetParties.allParties
                            .where((p) => !votes.containsKey(p))
                            .map((party) => ActionChip(
                                  label: Text(party),
                                  onPressed: () => _addPartyFromPreset(party),
                                  avatar: const Icon(Icons.add, size: 16),
                                ))
                            .toList(),
                      ),
                    ),
                  ),

                const SizedBox(height: 16),

                // Toplam
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

                // Simülasyon Butonu
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

// ResultScreen ve AllianceManagerScreen için devam dosyaları gerekiyor...

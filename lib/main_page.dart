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
import 'color_engine.dart';

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
  List<String> lastPartyOrder = [];
  Map<String, RegionResult>? regionResults;
  Map<String, RegionAllianceResult>? regionAllianceResults;
  List<Alliance> alliances = [];
  MapMode mapMode = MapMode.party;
  List<dynamic> features = [];
  double mapScale = 0.94;
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
        title: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "PoliVision",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 2),
            Text(
              "Türkiye",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
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
                onSimulate: (votes, threshold, partyOrder) {
                  final r = _calculateParliament(votes, threshold);
                  setState(() {
                    lastVotes = Map<String, double>.from(votes);
                    lastThreshold = threshold;
                    lastPartyOrder = List<String>.from(partyOrder);
                    result = r;
                    mapScale = 0.94;
                    mapOffset = Offset.zero;
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
                partyOrder: lastPartyOrder,
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
  final Function(Map<String, double>, double, List<String>) onSimulate;

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
  MapMode sliderMode = MapMode.party;
  late List<String> partyOrder;
  late List<String> _allianceOrderIds;

  static const String _unalignedAllianceLabel = "İttifaksız";

  double get total => votes.values.fold<double>(0.0, (sum, v) => sum + v);

  @override
  void initState() {
    super.initState();
    partyOrder = votes.keys.toList();
    _allianceOrderIds = widget.alliances.map((alliance) => alliance.id).toList();
  }

  @override
  void didUpdateWidget(covariant VoteInputScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.alliances.isEmpty && sliderMode == MapMode.alliance) {
      setState(() {
        sliderMode = MapMode.party;
      });
    }
    _syncAllianceOrder();
  }

  void _syncAllianceOrder() {
    final currentIds = widget.alliances.map((alliance) => alliance.id).toList();
    final existing = _allianceOrderIds
        .where((id) => currentIds.contains(id))
        .toList();
    final newOnes =
        currentIds.where((id) => !existing.contains(id)).toList();
    final next = [...existing, ...newOnes];
    if (!_sameOrder(_allianceOrderIds, next)) {
      setState(() {
        _allianceOrderIds = next;
      });
    }
  }

  bool _sameOrder(List<String> left, List<String> right) {
    if (left.length != right.length) return false;
    for (int i = 0; i < left.length; i++) {
      if (left[i] != right[i]) return false;
    }
    return true;
  }

  void _addPartyFromPreset(String partyName) {
    if (!votes.containsKey(partyName)) {
      setState(() {
        votes[partyName] = 0.0;
        partyOrder.add(partyName);
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
                  partyOrder.add(controller.text.trim());
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
      partyOrder.remove(party);
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

  Widget _buildPartyLogo(String party) {
    final logoPath = logoForParty(party);
    if (logoPath == null) {
      return CircleAvatar(
        radius: 12,
        backgroundColor: colorForParty(party),
        child: Text(
          party.isNotEmpty ? party[0].toUpperCase() : "?",
          style: const TextStyle(fontSize: 12, color: Colors.white),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: Image.asset(
        logoPath,
        width: 24,
        height: 24,
        fit: BoxFit.contain,
      ),
    );
  }

  Widget _buildPartySlider(
    String party, {
    required int dragIndex,
    bool showDragHandle = false,
  }) {
    return Card(
      key: ValueKey("party-$party"),
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (showDragHandle)
                  ReorderableDragStartListener(
                    index: dragIndex,
                    child: const Padding(
                      padding: EdgeInsets.only(right: 8),
                      child: Icon(Icons.drag_handle),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _buildPartyLogo(party),
                ),
                Expanded(
                  child: Text(
                    party,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
                if (votes.length > 2)
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 20),
                    onPressed: () => _removeParty(party),
                    tooltip: "Partiyi Kaldir",
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
                    "%${votes[party]!.toStringAsFixed(1)}",
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
              value: votes[party]!,
              min: 0,
              max: 100,
              divisions: 1000,
              label: "%${votes[party]!.toStringAsFixed(1)}",
              onChanged: (v) => setState(() => votes[party] = v),
            ),
          ],
        ),
      ),
    );
  }

  Map<String, List<String>> _buildAllianceGroups() {
    final Map<String, List<String>> groups = {};
    final Set<String> assigned = {};
    final orderedParties =
        partyOrder.where((party) => votes.containsKey(party));

    for (final alliance in widget.alliances) {
      final members = orderedParties
          .where((party) => alliance.parties.contains(party))
          .toList();
      if (members.isEmpty) continue;
      groups[alliance.name] = members;
      assigned.addAll(members);
    }

    final unaligned =
        orderedParties.where((party) => !assigned.contains(party));
    if (unaligned.isNotEmpty) {
      groups[_unalignedAllianceLabel] = unaligned.toList();
    }

    return groups;
  }

  Widget _buildAllianceSection(String name, List<String> parties) {
    final totalVote = parties.fold<double>(
      0.0,
      (sum, party) => sum + (votes[party] ?? 0.0),
    );
    final headerColor = name == _unalignedAllianceLabel
        ? Colors.grey.shade700
        : colorForAllianceFromVotes(
            allianceName: name,
            parties: parties,
            votes: votes,
          );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 8, top: 8),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: headerColor.withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: headerColor.withOpacity(0.45)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  name,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: headerColor,
                  ),
                ),
              ),
              Text(
                "%${totalVote.toStringAsFixed(1)}",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: headerColor,
                ),
              ),
            ],
          ),
        ),
        ReorderableListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          buildDefaultDragHandles: false,
          itemCount: parties.length,
          onReorder: (oldIndex, newIndex) {
            setState(() {
              _reorderWithinGroup(parties, oldIndex, newIndex);
            });
          },
          itemBuilder: (context, index) {
            final party = parties[index];
            return _buildPartySlider(
              party,
              dragIndex: index,
              showDragHandle: true,
            );
          },
        ),
      ],
    );
  }

  Widget _buildAllianceSectionWithHandle(
    String name,
    List<String> parties, {
    required int dragIndex,
  }) {
    final totalVote = parties.fold<double>(
      0.0,
      (sum, party) => sum + (votes[party] ?? 0.0),
    );
    final headerColor = name == _unalignedAllianceLabel
        ? Colors.grey.shade700
        : colorForAllianceFromVotes(
            allianceName: name,
            parties: parties,
            votes: votes,
          );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 8, top: 8),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: headerColor.withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: headerColor.withOpacity(0.45)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  name,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: headerColor,
                  ),
                ),
              ),
              Text(
                "%${totalVote.toStringAsFixed(1)}",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: headerColor,
                ),
              ),
              const SizedBox(width: 8),
              ReorderableDragStartListener(
                index: dragIndex,
                child: Icon(
                  Icons.drag_handle,
                  color: headerColor.withOpacity(0.75),
                ),
              ),
            ],
          ),
        ),
        ReorderableListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          buildDefaultDragHandles: false,
          itemCount: parties.length,
          onReorder: (oldIndex, newIndex) {
            setState(() {
              _reorderWithinGroup(parties, oldIndex, newIndex);
            });
          },
          itemBuilder: (context, index) {
            final party = parties[index];
            return _buildPartySlider(
              party,
              dragIndex: index,
              showDragHandle: true,
            );
          },
        ),
      ],
    );
  }

  void _reorderAllianceSections(
    List<String> orderedIds,
    int oldIndex,
    int newIndex,
  ) {
    if (newIndex > oldIndex) newIndex -= 1;
    final moved = orderedIds.removeAt(oldIndex);
    orderedIds.insert(newIndex, moved);
    final orderedSet = orderedIds.toSet();
    var i = 0;
    _allianceOrderIds = [
      for (final id in _allianceOrderIds)
        if (orderedSet.contains(id)) orderedIds[i++] else id
    ];
  }

  void _reorderPartyList(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) newIndex -= 1;
    setState(() {
      final party = partyOrder.removeAt(oldIndex);
      partyOrder.insert(newIndex, party);
    });
  }

  void _reorderWithinGroup(
    List<String> parties,
    int oldIndex,
    int newIndex,
  ) {
    if (newIndex > oldIndex) newIndex -= 1;

    final positions = <int>[];
    for (int i = 0; i < partyOrder.length; i++) {
      if (parties.contains(partyOrder[i])) {
        positions.add(i);
      }
    }
    if (oldIndex < 0 || oldIndex >= positions.length) return;

    final moved = partyOrder.removeAt(positions[oldIndex]);

    final newPositions = <int>[];
    for (int i = 0; i < partyOrder.length; i++) {
      if (parties.contains(partyOrder[i])) {
        newPositions.add(i);
      }
    }

    final insertPos = newIndex >= newPositions.length
        ? (newPositions.isEmpty ? partyOrder.length : newPositions.last + 1)
        : newPositions[newIndex];
    partyOrder.insert(insertPos, moved);
  }

  @override
  Widget build(BuildContext context) {
    final allianceGroups = _buildAllianceGroups();
    final allianceById = {
      for (final alliance in widget.alliances) alliance.id: alliance
    };
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
                if (widget.alliances.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: SegmentedButton<MapMode>(
                        segments: const [
                          ButtonSegment(
                            value: MapMode.party,
                            label: Text("Parti"),
                            icon: Icon(Icons.flag),
                          ),
                          ButtonSegment(
                            value: MapMode.alliance,
                            label: Text("İttifak"),
                            icon: Icon(Icons.groups),
                          ),
                        ],
                        selected: {sliderMode},
                        onSelectionChanged: (set) {
                          if (set.isEmpty) return;
                          setState(() {
                            sliderMode = set.first;
                          });
                        },
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.resolveWith((states) {
                            if (states.contains(MaterialState.selected)) {
                              return Colors.blueGrey.shade700;
                            }
                            return Colors.blueGrey.shade100;
                          }),
                          foregroundColor:
                              MaterialStateProperty.all(Colors.white),
                        ),
                      ),
                    ),
                  ),
                if (sliderMode == MapMode.party)
                  ReorderableListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    buildDefaultDragHandles: false,
                    itemCount: partyOrder.length,
                    onReorder: _reorderPartyList,
                    itemBuilder: (context, index) {
                      final party = partyOrder[index];
                      return _buildPartySlider(
                        party,
                        dragIndex: index,
                        showDragHandle: true,
                      );
                    },
                  ),
                if (sliderMode == MapMode.alliance)
                  Builder(
                    builder: (context) {
                      final orderedAllianceIds = _allianceOrderIds
                          .where((id) =>
                              allianceById[id] != null &&
                              allianceGroups
                                  .containsKey(allianceById[id]!.name))
                          .toList();
                      return Column(
                        children: [
                          ReorderableListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            buildDefaultDragHandles: false,
                            itemCount: orderedAllianceIds.length,
                            onReorder: (oldIndex, newIndex) {
                              setState(() {
                                _reorderAllianceSections(
                                  List<String>.from(orderedAllianceIds),
                                  oldIndex,
                                  newIndex,
                                );
                              });
                            },
                            itemBuilder: (context, index) {
                              final alliance =
                                  allianceById[orderedAllianceIds[index]]!;
                              final parties =
                                  allianceGroups[alliance.name] ?? const [];
                              return Container(
                                key: ValueKey("alliance-${alliance.id}"),
                                child: _buildAllianceSectionWithHandle(
                                  alliance.name,
                                  parties,
                                  dragIndex: index,
                                ),
                              );
                            },
                          ),
                          if (allianceGroups
                              .containsKey(_unalignedAllianceLabel))
                            _buildAllianceSection(
                              _unalignedAllianceLabel,
                              allianceGroups[_unalignedAllianceLabel]!,
                            ),
                        ],
                      );
                    },
                  ),

                // Parti Ekle Butonları
                OutlinedButton.icon(
                  onPressed: () {
                    setState(() {
                      showPresetParties = !showPresetParties;
                    });
                  },
                  icon: const Icon(Icons.list),
                  label: const Text("Hazir Partiler"),
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
                                  label: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      _buildPartyLogo(party),
                                      const SizedBox(width: 4),
                                      Text(party),
                                    ],
                                  ),
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
                      ? () => widget.onSimulate(votes, threshold, partyOrder)
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

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
  double inputTotal = 0.0;
  double inputThreshold = 0.0;
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

      debugPrint("ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã¢â‚¬Â¦ÃƒÂ¢Ã¢â€šÂ¬Ã…â€œÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚Â¦ GeoJSON yÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¼klendi: ${features.length} bÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¶lge");
    } catch (e) {
      debugPrint("ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚ÂÃƒÆ’Ã¢â‚¬Â¦ÃƒÂ¢Ã¢â€šÂ¬Ã¢â€Â¢ GeoJSON yÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¼klenemedi: $e");
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

  Widget _statusChip(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(left: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0x1AFFFFFF),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0x3300E5FF)),
      ),
      child: Text(
        '$label: $value',
        style: const TextStyle(
          fontSize: 11,
          color: Colors.white70,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 60,
        leadingWidth: 150,
        leading: Padding(
          padding: const EdgeInsets.only(left: 14),
          child: Row(
            children: [
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF00E5FF), Color(0xFF9D4DFF)],
                  ),
                  boxShadow: const [
                    BoxShadow(color: Color(0x5500E5FF), blurRadius: 10),
                  ],
                ),
                child: const Icon(Icons.hub, size: 16, color: Colors.white),
              ),
              const SizedBox(width: 8),
              const Text(
                'PoliVision',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
              ),
            ],
          ),
        ),
        centerTitle: true,
        title: const Text(
          'Simulasyon Laboratuvari',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
        ),
        backgroundColor: Colors.black.withOpacity(0.35),
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: Colors.white,
        actions: showInput
            ? [
                _statusChip('Baraj', '%${inputThreshold.toStringAsFixed(1)}'),
                _statusChip(
                  'Ittifak',
                  alliances.isEmpty ? 'Yok' : '${alliances.length}',
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: _statusChip(
                    'Toplam',
                    '%${inputTotal.toStringAsFixed(1)}',
                  ),
                ),
              ]
            : null,
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: showInput
            ? VoteInputScreen(
                key: const ValueKey('input'),
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
                onStatusChanged: (total, threshold) {
                  if ((inputTotal - total).abs() < 0.01 &&
                      (inputThreshold - threshold).abs() < 0.01) {
                    return;
                  }
                  setState(() {
                    inputTotal = total;
                    inputThreshold = threshold;
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
                key: const ValueKey('result'),
                result: result ?? {},
                features: features,
                mapScale: mapScale,
                mapOffset: mapOffset,
                threshold: lastThreshold,
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
  final Function(double total, double threshold) onStatusChanged;
  final Function(Map<String, double>, double, List<String>) onSimulate;

  const VoteInputScreen({
    required this.features,
    required this.mapScale,
    required this.mapOffset,
    required this.alliances,
    required this.onAlliancesChanged,
    required this.onMapUpdate,
    required this.onStatusChanged,
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
  MapMode sliderMode = MapMode.party;
  String? _hoveredParty;
  bool _showAllianceEditor = false;
  late List<String> partyOrder;
  late List<String> _allianceOrderIds;
  static const List<String> _preferredPartyOrder = [
    "CHP",
    "AKP",
    "DEM",
    "MHP",
    "IYI Parti",
    "DIGER",
  ];

  static const String _unalignedAllianceLabel = "ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã‚ÂÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â°ttifaksÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã‚ÂÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â±z";

  double get total => votes.values.fold<double>(0.0, (sum, v) => sum + v);

  String _normalizePartyName(String party) {
    final normalized = party.trim().toUpperCase();
    if (normalized == "IYIP" || normalized == "IYI" || normalized == "IYI PARTI") {
      return "IYI Parti";
    }
    if (normalized == "DIGER" || normalized == "DİĞER") return "DIGER";
    return party;
  }

  int _partyRank(String party) {
    final normalized = _normalizePartyName(party);
    final idx = _preferredPartyOrder.indexOf(normalized);
    if (idx >= 0) return idx;
    final presetIdx = PresetParties.allParties.indexWhere(
      (p) => p.toUpperCase() == normalized.toUpperCase(),
    );
    if (presetIdx >= 0) return 10 + presetIdx;
    final dynamicRank = partyOrder.indexOf(party);
    final safeRank = dynamicRank < 0 ? partyOrder.length : dynamicRank;
    return 1000 + safeRank;
  }

  List<String> _applyDefaultPartyOrder(Iterable<String> names) {
    final seen = <String>{};
    final list = <String>[];
    for (final raw in names) {
      final normalized = _normalizePartyName(raw);
      if (seen.add(normalized)) {
        list.add(normalized);
      }
    }
    list.sort((a, b) => _partyRank(a).compareTo(_partyRank(b)));
    return list;
  }

  void _insertPartyInDefaultOrder(String rawParty) {
    final party = _normalizePartyName(rawParty);
    if (votes.containsKey(party)) return;
    votes[party] = 0.0;
    partyOrder = _applyDefaultPartyOrder([...partyOrder, party]);
  }

  @override
  void initState() {
    super.initState();
    partyOrder = _applyDefaultPartyOrder(votes.keys);
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
    setState(() {
      _insertPartyInDefaultOrder(partyName);
    });
  }

  void _addCustomParty() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬ÃƒÂ¢Ã¢â€šÂ¬Ã…â€œzel Parti Ekle"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: "Parti AdÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã‚ÂÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â±",
            hintText: "ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¶rn: Yeni Parti",
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã‚ÂÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â°ptal"),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty &&
                  !votes.containsKey(controller.text.trim())) {
                setState(() {
                  _insertPartyInDefaultOrder(controller.text.trim());
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

  void _editPartyValue(String party) {
    final controller = TextEditingController(
      text: votes[party]!.toStringAsFixed(1),
    );
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$party Oy Yuzdesi'),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: 'Yuzde',
            hintText: '0-100',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Iptal'),
          ),
          ElevatedButton(
            onPressed: () {
              final parsed = double.tryParse(
                controller.text.trim().replaceAll(',', '.'),
              );
              if (parsed != null) {
                setState(() {
                  votes[party] = parsed.clamp(0.0, 100.0);
                });
              }
              Navigator.pop(context);
            },
            child: const Text('Kaydet'),
          ),
        ],
      ),
    );
  }

  void _manageAlliances() {
    setState(() {
      _showAllianceEditor = !_showAllianceEditor;
    });
  }

  List<String> _allAllianceCandidates() {
    final set = <String>{};
    for (final p in partyOrder) {
      set.add(_normalizePartyName(p));
    }
    for (final p in votes.keys) {
      set.add(_normalizePartyName(p));
    }
    for (final p in PresetParties.allParties) {
      set.add(_normalizePartyName(p));
    }
    set.add("DIGER");
    final list = set.toList();
    list.sort((a, b) => _partyRank(a).compareTo(_partyRank(b)));
    return list;
  }

  List<String> _availableCandidatesForAlliance(Alliance alliance) {
    final usedByOthers = <String>{};
    for (final a in widget.alliances) {
      if (a.id == alliance.id) continue;
      usedByOthers.addAll(a.parties.map(_normalizePartyName));
    }
    return _allAllianceCandidates()
        .where((p) => !usedByOthers.contains(_normalizePartyName(p)))
        .toList();
  }

  void _createAllianceInline() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Yeni Ittifak"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: "Ittifak Adi",
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Iptal"),
          ),
          ElevatedButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                final next = [
                  ...widget.alliances,
                  Alliance(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    name: name,
                    parties: const [],
                  ),
                ];
                widget.onAlliancesChanged(next);
                _syncAllianceOrder();
              }
              Navigator.pop(context);
            },
            child: const Text("Olustur"),
          ),
        ],
      ),
    );
  }

  void _deleteAllianceInline(Alliance alliance) {
    final next = widget.alliances.where((a) => a.id != alliance.id).toList();
    widget.onAlliancesChanged(next);
    _syncAllianceOrder();
  }

  void _addPartyToAllianceInline(Alliance alliance, String rawParty) {
    final party = _normalizePartyName(rawParty);
    if (!votes.containsKey(party)) {
      setState(() {
        _insertPartyInDefaultOrder(party);
      });
    }
    final next = widget.alliances.map((a) {
      if (a.id != alliance.id) return a;
      if (a.parties.contains(party)) return a;
      return a.copyWith(parties: [...a.parties, party]);
    }).toList();
    widget.onAlliancesChanged(next);
    _syncAllianceOrder();
  }

  void _removePartyFromAllianceInline(Alliance alliance, String party) {
    final next = widget.alliances.map((a) {
      if (a.id != alliance.id) return a;
      final updated = List<String>.from(a.parties)..remove(party);
      return a.copyWith(parties: updated);
    }).toList();
    widget.onAlliancesChanged(next);
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
    final value = votes[party]!;
    final isHovered = _hoveredParty == party;

    return MouseRegion(
      key: ValueKey("party-$party"),
      onEnter: (_) => setState(() => _hoveredParty = party),
      onExit: (_) => setState(() => _hoveredParty = null),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        margin: EdgeInsets.only(
          bottom: 10,
          top: isHovered ? 0 : 2,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0x80151B2F),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isHovered
                ? const Color(0xAA00E5FF)
                : const Color(0x3300E5FF),
          ),
          boxShadow: [
            BoxShadow(
              color: isHovered
                  ? const Color(0x3300E5FF)
                  : const Color(0x11000000),
              blurRadius: isHovered ? 16 : 8,
              offset: Offset(0, isHovered ? 6 : 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (showDragHandle)
              ReorderableDragStartListener(
                index: dragIndex,
                child: const Padding(
                  padding: EdgeInsets.only(right: 6),
                  child: Icon(Icons.drag_handle, size: 18, color: Colors.white54),
                ),
              ),
            SizedBox(
              width: 124,
              child: Row(
                children: [
                  _buildPartyLogo(party),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      party,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  if (votes.length > 2)
                    IconButton(
                      icon: const Icon(Icons.close, size: 16),
                      splashRadius: 16,
                      onPressed: () => _removeParty(party),
                      tooltip: "Partiyi Kaldir",
                    ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: const Color(0xFF00E5FF),
                  inactiveTrackColor: const Color(0x2A00E5FF),
                  thumbColor: const Color(0xFF00E5FF),
                  overlayColor: const Color(0x3000E5FF),
                  trackHeight: 4,
                ),
                child: Slider(
                  value: value,
                  min: 0,
                  max: 100,
                  divisions: 1000,
                  label: "%${value.toStringAsFixed(1)}",
                  onChanged: (v) => setState(() => votes[party] = v),
                ),
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 80,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  InkWell(
                    onTap: () => _editPartyValue(party),
                    borderRadius: BorderRadius.circular(999),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0x2A00E5FF),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: const Color(0xAA00E5FF)),
                      ),
                      child: _AnimatedPercentText(value: value),
                    ),
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      minHeight: 4,
                      value: value / 100,
                      backgroundColor: const Color(0x1AFFFFFF),
                      color: const Color(0xFF9D4DFF),
                    ),
                  ),
                ],
              ),
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
    final isReady = (total - 100).abs() < 0.5;
    final isWide = MediaQuery.of(context).size.width >= 980;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      widget.onStatusChanged(total, threshold);
    });

    final controlsPanel = _buildControlsPanel(
      allianceGroups: allianceGroups,
      allianceById: allianceById,
    );

    final summaryPanel = _buildLiveSummaryPanel(isReady: isReady);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 22),
      child: isWide
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 62, child: controlsPanel),
                const SizedBox(width: 14),
                Expanded(flex: 38, child: summaryPanel),
              ],
            )
          : Column(
              children: [
                summaryPanel,
                const SizedBox(height: 14),
                controlsPanel,
              ],
            ),
    );
  }

  Widget _buildControlsPanel({
    required Map<String, List<String>> allianceGroups,
    required Map<String, Alliance> allianceById,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0x80161D35), Color(0x66221A40)],
        ),
        border: Border.all(color: const Color(0x3300E5FF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Parti Kartlari',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.groups, color: Color(0xFF00E5FF)),
              title: Text(
                widget.alliances.isEmpty
                    ? 'Ittifak: Yok'
                    : '${widget.alliances.length} Ittifak tanimli',
              ),
              trailing: Wrap(
                spacing: 8,
                children: [
                  IconButton(
                    tooltip: 'Yeni Ittifak',
                    onPressed: _createAllianceInline,
                    icon: const Icon(Icons.add),
                  ),
                  ElevatedButton.icon(
                    onPressed: _manageAlliances,
                    icon: Icon(
                      _showAllianceEditor ? Icons.close : Icons.edit,
                      size: 16,
                    ),
                    label: Text(_showAllianceEditor ? 'Kapat' : 'Duzenle'),
                  ),
                ],
              ),
            ),
          ),
          if (_showAllianceEditor) ...[
            const SizedBox(height: 8),
            _buildInlineAllianceEditor(),
          ],
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Secim Baraji',
                          style: TextStyle(fontWeight: FontWeight.w600)),
                      Text(
                        '%${threshold.toStringAsFixed(1)}',
                        style: const TextStyle(
                          color: Color(0xFF00E5FF),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  Slider(
                    value: threshold,
                    min: 0,
                    max: 10,
                    divisions: 20,
                    label: '%${threshold.toStringAsFixed(1)}',
                    onChanged: (v) => setState(() => threshold = v),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          if (widget.alliances.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Align(
                alignment: Alignment.centerRight,
                child: SegmentedButton<MapMode>(
                  segments: const [
                    ButtonSegment(value: MapMode.party, label: Text('Parti'), icon: Icon(Icons.flag)),
                    ButtonSegment(value: MapMode.alliance, label: Text('Ittifak'), icon: Icon(Icons.groups)),
                  ],
                  selected: {sliderMode},
                  onSelectionChanged: (set) {
                    if (set.isEmpty) return;
                    setState(() {
                      sliderMode = set.first;
                    });
                  },
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
                        allianceGroups.containsKey(allianceById[id]!.name))
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
                        final alliance = allianceById[orderedAllianceIds[index]]!;
                        final parties = allianceGroups[alliance.name] ?? const [];
                        return Container(
                          key: ValueKey('alliance-${alliance.id}'),
                          child: _buildAllianceSectionWithHandle(
                            alliance.name,
                            parties,
                            dragIndex: index,
                          ),
                        );
                      },
                    ),
                    if (allianceGroups.containsKey(_unalignedAllianceLabel))
                      _buildAllianceSection(
                        _unalignedAllianceLabel,
                        allianceGroups[_unalignedAllianceLabel]!,
                      ),
                  ],
                );
              },
            ),
          const SizedBox(height: 10),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Hazir Partiler',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: (() {
                      final remaining = PresetParties.allParties
                          .where((p) => !votes.containsKey(_normalizePartyName(p)))
                          .toList();
                      remaining.sort(
                        (a, b) => _partyRank(a).compareTo(_partyRank(b)),
                      );
                      return remaining
                          .map(
                            (party) => ActionChip(
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
                            ),
                          )
                          .toList();
                    })(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAlliancePartyPicker(Alliance alliance) {
    final candidates = _availableCandidatesForAlliance(alliance);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${alliance.name} - Parti Ekle'),
        content: SizedBox(
          width: 420,
          child: candidates.isEmpty
              ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text('Eklenebilir parti kalmadi.'),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: candidates.length,
                  itemBuilder: (context, index) {
                    final party = candidates[index];
                    final inVoteList = votes.containsKey(party);
                    return ListTile(
                      leading: _buildPartyLogo(party),
                      title: Text(party),
                      subtitle: inVoteList
                          ? null
                          : const Text(
                              'Hazir partilerden eklenecek',
                              style: TextStyle(fontSize: 11),
                            ),
                      onTap: () {
                        _addPartyToAllianceInline(alliance, party);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kapat'),
          ),
        ],
      ),
    );
  }

  Widget _buildInlineAllianceEditor() {
    final alliances = widget.alliances;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: const Color(0x2A10192A),
        border: Border.all(color: const Color(0x3300E5FF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Ittifak Duzenleyici',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          if (alliances.isEmpty)
            const Text(
              'Henuz ittifak yok. "Yeni Ittifak" ile olusturabilirsin.',
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ...alliances.map((alliance) {
            return Card(
              margin: const EdgeInsets.only(top: 8),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            alliance.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        IconButton(
                          tooltip: 'Ittifaki Sil',
                          onPressed: () => _deleteAllianceInline(alliance),
                          icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                        ),
                      ],
                    ),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: alliance.parties
                          .map((party) => InputChip(
                                avatar: _buildPartyLogo(party),
                                label: Text(party),
                                onDeleted: () =>
                                    _removePartyFromAllianceInline(alliance, party),
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 6),
                    OutlinedButton.icon(
                      onPressed: () => _showAlliancePartyPicker(alliance),
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text('Parti Ekle'),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildLiveSummaryPanel({required bool isReady}) {
    final sortedByVote = votes.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final belowThreshold = sortedByVote
        .where((e) => e.value > 0 && e.value < threshold)
        .toList();
    final topTwo = sortedByVote.take(2).toList();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0x801C243E), Color(0x6621163D)],
        ),
        border: Border.all(color: const Color(0x4D9D4DFF)),
        boxShadow: const [BoxShadow(color: Color(0x229D4DFF), blurRadius: 18)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Canli Ozet',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _miniMetric('Baraj', '%${threshold.toStringAsFixed(1)}')),
              const SizedBox(width: 8),
              Expanded(
                child: _miniMetric(
                  'Ittifak',
                  widget.alliances.isEmpty ? 'Yok' : '${widget.alliances.length}',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(child: _miniMetric('Toplam', '%${total.toStringAsFixed(1)}')),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Baraj alti',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: belowThreshold.isEmpty
                ? [
                    const Chip(
                      label: Text('Baraj alti parti yok'),
                    ),
                  ]
                : belowThreshold
                    .map(
                      (entry) => Chip(
                        avatar: _buildPartyLogo(entry.key),
                        label: Text('${entry.key}  %${entry.value.toStringAsFixed(1)}'),
                      ),
                    )
                    .toList(),
          ),
          const SizedBox(height: 12),
          const Text(
            'En buyuk 2 parti',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          ...topTwo.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            return Container(
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: const Color(0x1AFFFFFF),
                border: Border.all(color: const Color(0x3300E5FF)),
              ),
              child: Row(
                children: [
                  Text(
                    '#${index + 1}',
                    style: const TextStyle(
                      color: Color(0xFF00E5FF),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildPartyLogo(item.key),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item.key,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  Text(
                    '%${item.value.toStringAsFixed(1)}',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 12),
          Container(
            height: 260,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0x5500E5FF)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
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
          ),
          const SizedBox(height: 12),
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: isReady ? const Color(0x1A00E5FF) : const Color(0x1AFF3E8E),
              border: Border.all(
                color: isReady ? const Color(0xAA00E5FF) : const Color(0xAAFF3E8E),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  isReady ? Icons.verified : Icons.warning_amber_rounded,
                  color: isReady ? const Color(0xFF00E5FF) : const Color(0xFFFF3E8E),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    isReady ? 'Simulasyon icin hazir.' : 'Toplam oy %100 olmali.',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              gradient: const LinearGradient(
                colors: [Color(0xFF00E5FF), Color(0xFF9D4DFF)],
              ),
              boxShadow: [
                BoxShadow(
                  color: isReady ? const Color(0x6600E5FF) : const Color(0x33FFFFFF),
                  blurRadius: 18,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: isReady
                  ? () => widget.onSimulate(votes, threshold, partyOrder)
                  : null,
              style: ElevatedButton.styleFrom(
                elevation: 0,
                shadowColor: Colors.transparent,
                foregroundColor: Colors.white,
                backgroundColor: Colors.transparent,
                disabledBackgroundColor: Colors.transparent,
                padding: const EdgeInsets.symmetric(vertical: 17),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text('Simulasyonu Calistir',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniMetric(String title, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 9),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: const Color(0x1600E5FF),
        border: Border.all(color: const Color(0x4400E5FF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 11, color: Colors.white70)),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF00E5FF),
            ),
          ),
        ],
      ),
    );
  }
}


class _AnimatedPercentText extends StatefulWidget {
  final double value;

  const _AnimatedPercentText({required this.value});

  @override
  State<_AnimatedPercentText> createState() => _AnimatedPercentTextState();
}

class _AnimatedPercentTextState extends State<_AnimatedPercentText> {
  late double _oldValue;

  @override
  void initState() {
    super.initState();
    _oldValue = widget.value;
  }

  @override
  void didUpdateWidget(covariant _AnimatedPercentText oldWidget) {
    super.didUpdateWidget(oldWidget);
    _oldValue = oldWidget.value;
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: _oldValue, end: widget.value),
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      builder: (context, value, _) {
        return Text(
          '%${value.toStringAsFixed(1)}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        );
      },
    );
  }
}
// ResultScreen ve AllianceManagerScreen iÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â§in devam dosyalarÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã‚ÂÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â± gerekiyor...

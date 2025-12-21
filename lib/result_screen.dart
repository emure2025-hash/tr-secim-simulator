import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import 'alliance.dart';
import 'alliance_calculator.dart';
import 'color_engine.dart';
import 'map_mode.dart';
import 'map_widget.dart';
import 'region_calculator.dart';
import 'seat_distribution_widget.dart';

class _VoteSummary {
  final String label;
  final double votePercent;
  final int seats;
  final Color color;
  final List<String> parties;

  const _VoteSummary({
    required this.label,
    required this.votePercent,
    required this.seats,
    required this.color,
    this.parties = const [],
  });
}

class ResultScreen extends StatefulWidget {
  final Map<String, int> result;
  final List<dynamic> features;
  final double mapScale;
  final Offset mapOffset;
  final Map<String, double> votes;
  final List<String> partyOrder;
  final Map<String, RegionResult>? regionResults;
  final Map<String, RegionAllianceResult>? regionAllianceResults;
  final List<Alliance> alliances;
  final MapMode mapMode;
  final ValueChanged<MapMode> onMapModeChanged;
  final Function(String regionId) onRegionTap;
  final VoidCallback onBack;
  final Function(double scale, Offset offset)? onMapUpdate;

  const ResultScreen({
    super.key,
    required this.result,
    required this.features,
    required this.mapScale,
    required this.mapOffset,
    required this.votes,
    required this.partyOrder,
    required this.regionResults,
    required this.regionAllianceResults,
    required this.alliances,
    required this.mapMode,
    required this.onMapModeChanged,
    required this.onRegionTap,
    required this.onBack,
    this.onMapUpdate,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  late double _mapScale;
  late Offset _mapOffset;
  MapMode _sliderMode = MapMode.party;

  @override
  void initState() {
    super.initState();
    _mapScale = widget.mapScale;
    _mapOffset = widget.mapOffset;
  }

  @override
  void didUpdateWidget(covariant ResultScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.alliances.isEmpty && _sliderMode == MapMode.alliance) {
      setState(() {
        _sliderMode = MapMode.party;
      });
    }
  }

  void _handleMapUpdate(double scale, Offset offset) {
    setState(() {
      _mapScale = scale;
      _mapOffset = offset;
    });
    widget.onMapUpdate?.call(scale, offset);
  }

  String _initials(String name) {
    final trimmed = name.trim();
    if (trimmed.length <= 2) return trimmed.toUpperCase();
    return trimmed.substring(0, 2).toUpperCase();
  }

  Widget _buildPartyLogo(String label, Color fallbackColor) {
    final logoPath = logoForParty(label);
    if (logoPath == null) {
      return CircleAvatar(
        backgroundColor: fallbackColor,
        child: Text(
          _initials(label),
          style: const TextStyle(color: Colors.white),
        ),
      );
    }

    return CircleAvatar(
      backgroundColor: Colors.white,
      child: ClipOval(
        child: Image.asset(
          logoPath,
          width: 28,
          height: 28,
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  Widget _buildAllianceLogos(List<String> parties, Color fallbackColor) {
    final members = parties.isNotEmpty ? parties : const <String>[];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: members.map((party) {
          final logoPath = logoForParty(party);
          if (logoPath == null) {
            return Padding(
              padding: const EdgeInsets.only(right: 4),
              child: CircleAvatar(
                radius: 10,
                backgroundColor: fallbackColor,
                child: Text(
                  _initials(party),
                  style: const TextStyle(fontSize: 10, color: Colors.white),
                ),
              ),
            );
          }
          return Padding(
            padding: const EdgeInsets.only(right: 4),
            child: CircleAvatar(
              radius: 10,
              backgroundColor: Colors.white,
              child: ClipOval(
                child: Image.asset(
                  logoPath,
                  width: 20,
                  height: 20,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  List<String> _orderedParties() {
    final ordered = <String>[];
    final seen = <String>{};

    for (final party in widget.partyOrder) {
      if (widget.votes.containsKey(party) && seen.add(party)) {
        ordered.add(party);
      }
    }

    for (final party in widget.votes.keys) {
      if (seen.add(party)) {
        ordered.add(party);
      }
    }

    return ordered;
  }

  List<_VoteSummary> _buildPartySummaries() {
    final orderedParties = _orderedParties();
    final summaries = orderedParties
        .map(
          (party) => _VoteSummary(
            label: party,
            votePercent: widget.votes[party] ?? 0.0,
            seats: widget.result[party] ?? 0,
            color: colorForParty(party),
            parties: [party],
          ),
        )
        .toList();
    summaries.sort((a, b) => b.votePercent.compareTo(a.votePercent));
    return summaries;
  }

  List<_VoteSummary> _buildAllianceSummaries() {
    final orderedParties = _orderedParties();
    final Map<String, List<String>> allianceGroups = {};
    final Set<String> assigned = {};

    for (final alliance in widget.alliances) {
      final members = orderedParties
          .where((party) => alliance.parties.contains(party))
          .toList();
      if (members.isEmpty) continue;
      allianceGroups[alliance.name] = members;
      assigned.addAll(members);
    }

    final summaries = <_VoteSummary>[];
    allianceGroups.forEach((name, parties) {
      double voteSum = 0.0;
      int seatSum = 0;
      for (final party in parties) {
        voteSum += widget.votes[party] ?? 0.0;
        seatSum += widget.result[party] ?? 0;
      }
      summaries.add(
        _VoteSummary(
          label: name,
          votePercent: voteSum,
          seats: seatSum,
          color: colorForAllianceFromVotes(
            allianceName: name,
            parties: parties,
            votes: widget.votes,
          ),
          parties: parties,
        ),
      );
    });

    final unalignedParties =
        orderedParties.where((party) => !assigned.contains(party));
    for (final party in unalignedParties) {
      summaries.add(
        _VoteSummary(
          label: party,
          votePercent: widget.votes[party] ?? 0.0,
          seats: widget.result[party] ?? 0,
          color: colorForParty(party),
          parties: [party],
        ),
      );
    }

    summaries.sort((a, b) => b.votePercent.compareTo(a.votePercent));
    return summaries;
  }

  Map<String, int> _buildSeatMapFromSummaries(List<_VoteSummary> summaries) {
    return {for (final summary in summaries) summary.label: summary.seats};
  }

  Map<String, Color> _buildColorMapFromSummaries(List<_VoteSummary> summaries) {
    return {for (final summary in summaries) summary.label: summary.color};
  }

  @override
  Widget build(BuildContext context) {
    final totalSeats = widget.result.values.fold<int>(0, (a, b) => a + b);
    final sliderSummaries = _sliderMode == MapMode.alliance
        ? _buildAllianceSummaries()
        : _buildPartySummaries();
    final seatMap = _buildSeatMapFromSummaries(sliderSummaries);
    final seatColorMap = _buildColorMapFromSummaries(sliderSummaries);
    final pieSections = sliderSummaries.map((summary) {
      final seatShare =
          totalSeats == 0 ? 0 : (summary.seats / totalSeats * 100);
      return PieChartSectionData(
        color: summary.color,
        value: summary.seats.toDouble(),
        title: "${seatShare.toStringAsFixed(1)}%",
        titleStyle: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
        radius: 55,
      );
    }).toList();

    final bool canShowAlliance = widget.alliances.isNotEmpty &&
        (widget.regionAllianceResults?.isNotEmpty ?? false);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Simulasyon Sonuclari"),
        backgroundColor: Colors.blueGrey.shade700,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onBack,
        ),
        actions: [
          if (canShowAlliance)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: SegmentedButton<MapMode>(
                segments: const [
                  ButtonSegment(
                    value: MapMode.party,
                    label: Text("Parti"),
                    icon: Icon(Icons.flag),
                  ),
                  ButtonSegment(
                    value: MapMode.alliance,
                    label: Text("Ittifak"),
                    icon: Icon(Icons.groups),
                  ),
                ],
                selected: {widget.mapMode},
                onSelectionChanged: (set) {
                  if (set.isNotEmpty) widget.onMapModeChanged(set.first);
                  setState(() {});
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.resolveWith((states) {
                    if (states.contains(MaterialState.selected)) {
                      return Colors.blueGrey.shade700;
                    }
                    return Colors.blueGrey.shade100;
                  }),
                  foregroundColor: MaterialStateProperty.all(Colors.white),
                ),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: 360,
              child: widget.features.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : InteractiveMapWidget(
                      features: widget.features,
                      regionResults:
                          widget.mapMode == MapMode.party ? widget.regionResults : null,
                      regionAllianceResults: widget.mapMode == MapMode.alliance
                          ? widget.regionAllianceResults
                          : null,
                      useAllianceColors: widget.mapMode == MapMode.alliance,
                      onRegionTap: widget.onRegionTap,
                      scale: _mapScale,
                      offset: _mapOffset,
                      onTransform: _handleMapUpdate,
                    ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: SizedBox(
                height: 320,
                child: Column(
                  children: [
                    if (widget.alliances.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
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
                                label: Text("Ittifak"),
                                icon: Icon(Icons.groups),
                              ),
                            ],
                            selected: {_sliderMode},
                            onSelectionChanged: (set) {
                              if (set.isEmpty) return;
                              setState(() {
                                _sliderMode = set.first;
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
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(
                            child: Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "Koltuk Dagilimi (Pie)",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Expanded(
                                      child: PieChart(
                                        PieChartData(
                                          sections: pieSections,
                                          sectionsSpace: 2,
                                          centerSpaceRadius: 36,
                                          borderData: FlBorderData(show: false),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: SeatDistributionWidget(
                                  seatsByParty: seatMap,
                                  partyColors: seatColorMap,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    "Toplam Sandalye: $totalSeats",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (widget.alliances.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8, bottom: 12),
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
                              label: Text("Ittifak"),
                              icon: Icon(Icons.groups),
                            ),
                          ],
                          selected: {_sliderMode},
                          onSelectionChanged: (set) {
                            if (set.isEmpty) return;
                            setState(() {
                              _sliderMode = set.first;
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
                  const SizedBox(height: 12),
                  ...sliderSummaries.map((summary) {
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: _sliderMode == MapMode.alliance ? 120 : 40,
                              child: _sliderMode == MapMode.alliance
                                  ? _buildAllianceLogos(
                                      summary.parties,
                                      summary.color,
                                    )
                                  : _buildPartyLogo(
                                      summary.label,
                                      summary.color,
                                    ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    summary.label,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  LinearProgressIndicator(
                                    value: summary.votePercent / 100,
                                    backgroundColor: Colors.grey.shade200,
                                    color: summary.color,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  "${summary.votePercent.toStringAsFixed(1)}%",
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text("${summary.seats} MV"),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

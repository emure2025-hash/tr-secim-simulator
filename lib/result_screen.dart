import 'package:flutter/material.dart';

import 'alliance.dart';
import 'alliance_calculator.dart';
import 'color_engine.dart';
import 'map_mode.dart';
import 'map_widget.dart';
import 'region_calculator.dart';

class ResultScreen extends StatefulWidget {
  final Map<String, int> result;
  final List<dynamic> features;
  final double mapScale;
  final Offset mapOffset;
  final Map<String, double> votes;
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

  @override
  void initState() {
    super.initState();
    _mapScale = widget.mapScale;
    _mapOffset = widget.mapOffset;
  }

  void _handleMapUpdate(double scale, Offset offset) {
    setState(() {
      _mapScale = scale;
      _mapOffset = offset;
    });
    widget.onMapUpdate?.call(scale, offset);
  }

  @override
  Widget build(BuildContext context) {
    final totalSeats = widget.result.values.fold<int>(0, (a, b) => a + b);
    final sortedResults = widget.result.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final bool canShowAlliance = widget.alliances.isNotEmpty &&
        (widget.regionAllianceResults?.isNotEmpty ?? false);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Simülasyon Sonuçları"),
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
                    label: Text("İttifak"),
                    icon: Icon(Icons.groups),
                  ),
                ],
                selected: {widget.mapMode},
                onSelectionChanged: (set) {
                  if (set.isNotEmpty) widget.onMapModeChanged(set.first);
                  setState(() {}); // rebuild for local state
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
                  const SizedBox(height: 12),
                  ...sortedResults.map((entry) {
                    final percent = totalSeats == 0
                        ? 0
                        : (entry.value / totalSeats * 100);
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: colorForParty(entry.key),
                          child: Text(
                            entry.key.substring(0, 2).toUpperCase(),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        title: Text(
                          entry.key,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: LinearProgressIndicator(
                          value: percent / 100,
                          backgroundColor: Colors.grey.shade200,
                          color: colorForParty(entry.key),
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              "${entry.value} MV",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text("%${percent.toStringAsFixed(1)}"),
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

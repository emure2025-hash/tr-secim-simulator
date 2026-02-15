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

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _VoteSummary &&
          label == other.label &&
          votePercent == other.votePercent &&
          seats == other.seats &&
          color == other.color;

  @override
  int get hashCode => Object.hash(label, votePercent, seats, color);
}

class _PieLegendEntry {
  final String label;
  final double percent;
  final Color color;
  final List<String> parties;

  const _PieLegendEntry({
    required this.label,
    required this.percent,
    required this.color,
    required this.parties,
  });
}

class ResultScreen extends StatefulWidget {
  final Map<String, int> result;
  final List<dynamic> features;
  final double mapScale;
  final Offset mapOffset;
  final double threshold;
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
    required this.threshold,
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
  String? _selectedPieLabel;
  String? _hoveredPanel;
  
  // Cache iÃ§in
  List<_VoteSummary>? _cachedPartySummaries;
  List<_VoteSummary>? _cachedAllianceSummaries;
  Map<String, int>? _cachedSeatMap;
  Map<String, Color>? _cachedColorMap;
  List<PieChartSectionData>? _cachedPieSections;

  @override
  void initState() {
    super.initState();
    _mapScale = widget.mapScale;
    _mapOffset = widget.mapOffset;
  }

  @override
  void didUpdateWidget(covariant ResultScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Cache invalidation
    if (oldWidget.result != widget.result ||
        oldWidget.votes != widget.votes ||
        oldWidget.alliances != widget.alliances) {
      _cachedPartySummaries = null;
      _cachedAllianceSummaries = null;
      _cachedSeatMap = null;
      _cachedColorMap = null;
      _cachedPieSections = null;
      _selectedPieLabel = null;
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

  Widget _buildAllianceLogos(
    List<String> parties,
    Color fallbackColor, {
    bool highlighted = false,
  }) {
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
                radius: highlighted ? 12 : 10,
                backgroundColor: fallbackColor,
                child: Text(
                  _initials(party),
                  style: TextStyle(
                    fontSize: highlighted ? 11 : 10,
                    color: Colors.white,
                  ),
                ),
              ),
            );
          }
          return Padding(
            padding: const EdgeInsets.only(right: 4),
            child: Container(
              padding: highlighted ? const EdgeInsets.all(1) : EdgeInsets.zero,
              decoration: highlighted
                  ? BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: fallbackColor, width: 1.4),
                    )
                  : null,
              child: CircleAvatar(
                radius: highlighted ? 12 : 10,
                backgroundColor: Colors.white,
                child: ClipOval(
                  child: Image.asset(
                    logoPath,
                    width: highlighted ? 22 : 20,
                    height: highlighted ? 22 : 20,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildLegendLogo(
    String label,
    Color fallbackColor, {
    bool highlighted = false,
  }) {
    final logoPath = logoForParty(label);
    if (logoPath == null) {
      return CircleAvatar(
        radius: highlighted ? 10 : 8,
        backgroundColor: fallbackColor,
        child: Text(
          _initials(label),
          style: TextStyle(
            fontSize: highlighted ? 10 : 9,
            color: Colors.white,
          ),
        ),
      );
    }

    final avatar = CircleAvatar(
      radius: highlighted ? 10 : 8,
      backgroundColor: Colors.white,
      child: ClipOval(
        child: Image.asset(
          logoPath,
          width: highlighted ? 18 : 16,
          height: highlighted ? 18 : 16,
          fit: BoxFit.contain,
        ),
      ),
    );
    if (!highlighted) return avatar;
    return Container(
      padding: const EdgeInsets.all(1),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: fallbackColor, width: 1.3),
      ),
      child: avatar,
    );
  }

  Widget _buildPieLegend(
    List<_PieLegendEntry> entries, {
    String? highlightedLabel,
  }) {
    if (entries.isEmpty) {
      return const Center(
        child: Text(
          "Veri yok",
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return ListView.separated(
      itemCount: entries.length,
      separatorBuilder: (_, __) => const SizedBox(height: 6),
      itemBuilder: (context, index) {
        final entry = entries[index];
        final hasAllianceLogos = entry.parties.length > 1;
        final isHighlighted = entry.label == highlightedLabel;
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedPieLabel = isHighlighted ? null : entry.label;
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            decoration: BoxDecoration(
              color: isHighlighted
                  ? entry.color.withOpacity(0.12)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isHighlighted
                    ? entry.color.withOpacity(0.85)
                    : Colors.transparent,
                width: isHighlighted ? 1.4 : 1,
              ),
            ),
            child: Row(
              children: [
                if (hasAllianceLogos)
                  SizedBox(
                    width: 44,
                    child: _buildAllianceLogos(
                      entry.parties,
                      entry.color,
                      highlighted: isHighlighted,
                    ),
                  )
                else
                  _buildLegendLogo(
                    entry.label,
                    entry.color,
                    highlighted: isHighlighted,
                  ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    entry.label,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isHighlighted ? entry.color : Colors.white70,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  "${entry.percent.toStringAsFixed(1)}%",
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        );
      },
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
    if (_cachedPartySummaries != null) return _cachedPartySummaries!;
    
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
    
    _cachedPartySummaries = summaries;
    return summaries;
  }

  List<_VoteSummary> _buildAllianceSummaries() {
    if (_cachedAllianceSummaries != null) return _cachedAllianceSummaries!;
    
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
    
    _cachedAllianceSummaries = summaries;
    return summaries;
  }

  Map<String, int> _buildSeatMapFromSummaries(List<_VoteSummary> summaries) {
    return {for (final summary in summaries) summary.label: summary.seats};
  }

  Map<String, Color> _buildColorMapFromSummaries(List<_VoteSummary> summaries) {
    return {for (final summary in summaries) summary.label: summary.color};
  }

  List<PieChartSectionData> _buildPieSections(
    List<_VoteSummary> summaries,
    int totalSeats,
    String? highlightedLabel,
  ) {
    return summaries.asMap().entries.map((entry) {
      final summary = entry.value;
      final seatShare = totalSeats == 0 ? 0 : (summary.seats / totalSeats * 100);
      final isHovered = summary.label == highlightedLabel;
      
      return PieChartSectionData(
        color: summary.color,
        value: summary.seats.toDouble(),
        title: "${seatShare.toStringAsFixed(1)}%",
        titleStyle: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
        radius: isHovered ? 60 : 55, // Hover'da bÃ¼yÃ¼t
        titlePositionPercentageOffset: isHovered ? 0.65 : 0.6,
      );
    }).toList();
  }

  Widget _buildNeonStatCard({
    required String title,
    required String value,
    String? subtitle,
    Color accent = const Color(0xFF00E5FF),
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 11,
              color: Colors.white60,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              color: accent,
              fontWeight: FontWeight.w700,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Container(
            height: 2,
            decoration: BoxDecoration(
              color: accent.withOpacity(0.75),
              borderRadius: BorderRadius.circular(999),
              boxShadow: [
                BoxShadow(
                  color: accent.withOpacity(0.45),
                  blurRadius: 8,
                ),
              ],
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 10,
                color: Colors.white54,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSmoothPanel({
    required String id,
    required Widget child,
  }) {
    final hovered = _hoveredPanel == id;
    return MouseRegion(
      onEnter: (_) => setState(() => _hoveredPanel = id),
      onExit: (_) => setState(() => _hoveredPanel = null),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 170),
        curve: Curves.easeOut,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: hovered
              ? const Color(0x1CFFFFFF)
              : const Color(0x12000000),
          border: Border.all(
            color: hovered
                ? const Color(0x4000E5FF)
                : const Color(0x2200E5FF),
            width: hovered ? 1.0 : 0.6,
          ),
          boxShadow: [
            BoxShadow(
              color: hovered
                  ? const Color(0x2200E5FF)
                  : const Color(0x12000000),
              blurRadius: hovered ? 12 : 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalSeats = widget.result.values.fold<int>(0, (a, b) => a + b);
    final bool canShowAlliance = widget.alliances.isNotEmpty &&
        (widget.regionAllianceResults?.isNotEmpty ?? false);
    final activeMode = canShowAlliance ? widget.mapMode : MapMode.party;

    final sliderSummaries = activeMode == MapMode.alliance
        ? _buildAllianceSummaries()
        : _buildPartySummaries();
    final activePieLabel = _selectedPieLabel;
    final seatMap = _buildSeatMapFromSummaries(sliderSummaries);
    final seatColorMap = _buildColorMapFromSummaries(sliderSummaries);
    final pieSections =
        _buildPieSections(sliderSummaries, totalSeats, activePieLabel);
    final pieLegendEntries = sliderSummaries
        .where((summary) => summary.seats > 0)
        .map((summary) {
          final seatShare =
              totalSeats == 0 ? 0.0 : (summary.seats / totalSeats * 100);
          return _PieLegendEntry(
            label: summary.label,
            percent: seatShare,
            color: summary.color,
            parties: summary.parties,
          );
        })
        .toList();

    final topLeader = sliderSummaries.isEmpty ? null : sliderSummaries.first;
    final majorityThreshold = (totalSeats ~/ 2) + 1;
    final leaderSeats = topLeader?.seats ?? 0;
    final hasMajority = leaderSeats >= majorityThreshold;
    final belowThresholdCount = widget.votes.entries
        .where((e) => e.value > 0 && e.value < widget.threshold)
        .length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Simulasyon Sonuclari'),
        backgroundColor: Colors.black.withOpacity(0.35),
        elevation: 0,
        scrolledUnderElevation: 0,
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
                    label: Text('Parti'),
                    icon: Icon(Icons.flag),
                  ),
                  ButtonSegment(
                    value: MapMode.alliance,
                    label: Text('Ittifak'),
                    icon: Icon(Icons.groups),
                  ),
                ],
                selected: {widget.mapMode},
                onSelectionChanged: (set) {
                  if (set.isNotEmpty) {
                    widget.onMapModeChanged(set.first);
                    setState(() {});
                  }
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.resolveWith((states) {
                    if (states.contains(MaterialState.selected)) {
                      return const Color(0x3300E5FF);
                    }
                    return const Color(0x1AFFFFFF);
                  }),
                  foregroundColor: MaterialStateProperty.resolveWith((states) {
                    if (states.contains(MaterialState.selected)) {
                      return const Color(0xFF00E5FF);
                    }
                    return Colors.white70;
                  }),
                ),
              ),
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
        child: Column(
          children: [
            Expanded(
              flex: 58,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth >= 1120;

                  final pieCard = _buildSmoothPanel(
                    id: 'pie',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                          const Text(
                            'Yuzdesel koltuk dagilimi',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Expanded(
                            child: LayoutBuilder(
                              builder: (context, inner) {
                                final chart = PieChart(
                                  PieChartData(
                                    sections: pieSections,
                                    sectionsSpace: 2,
                                    centerSpaceRadius: 36,
                                    borderData: FlBorderData(show: false),
                                    pieTouchData: PieTouchData(enabled: false),
                                  ),
                                  swapAnimationDuration:
                                      const Duration(milliseconds: 150),
                                  swapAnimationCurve: Curves.easeOut,
                                );

                                if (inner.maxWidth < 260) {
                                  return Column(
                                    children: [
                                      SizedBox(
                                        height: 120,
                                        child: _buildPieLegend(
                                          pieLegendEntries,
                                          highlightedLabel: activePieLabel,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Expanded(child: chart),
                                    ],
                                  );
                                }

                                return Row(
                                  children: [
                                    SizedBox(
                                      width: 140,
                                      child: _buildPieLegend(
                                        pieLegendEntries,
                                        highlightedLabel: activePieLabel,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(child: chart),
                                  ],
                                );
                              },
                            ),
                          ),
                        ],
                    ),
                  );

                  final mapPanel = _buildSmoothPanel(
                    id: 'map',
                    child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _buildNeonStatCard(
                                  title: 'Toplam MV',
                                  value: '$totalSeats',
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _buildNeonStatCard(
                                  title: activeMode == MapMode.alliance
                                      ? '1. Ittifak'
                                      : '1. Parti',
                                  value: topLeader?.label ?? '-',
                                  subtitle: '${topLeader?.seats ?? 0} MV',
                                  accent: const Color(0xFF9D4DFF),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _buildNeonStatCard(
                                  title: 'Cogunluk Durumu',
                                  value: hasMajority
                                      ? '$leaderSeats MV (Var)'
                                      : '$leaderSeats MV (Yok)',
                                  subtitle: 'Esik: $majorityThreshold MV',
                                  accent: hasMajority
                                      ? const Color(0xFF00E5FF)
                                      : const Color(0xFFFF4D8D),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _buildNeonStatCard(
                                  title: 'Baraj Bilgisi',
                                  value: '%${widget.threshold.toStringAsFixed(1)}',
                                  subtitle: 'Baraj alti: $belowThresholdCount',
                                  accent: const Color(0xFF4DD8FF),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Expanded(
                            child: RepaintBoundary(
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: widget.features.isEmpty
                                      ? const Center(
                                          child: CircularProgressIndicator(),
                                        )
                                      : InteractiveMapWidget(
                                          features: widget.features,
                                          regionResults:
                                              activeMode == MapMode.party
                                                  ? widget.regionResults
                                                  : null,
                                          regionAllianceResults:
                                              activeMode == MapMode.alliance
                                                  ? widget.regionAllianceResults
                                                  : null,
                                          useAllianceColors:
                                              activeMode == MapMode.alliance,
                                          onRegionTap: widget.onRegionTap,
                                          scale: _mapScale,
                                          offset: _mapOffset,
                                          onTransform: _handleMapUpdate,
                                        ),
                                ),
                              ),
                            ),
                          ),
                        ],
                    ),
                  );

                  final semiCircleCard = _buildSmoothPanel(
                    id: 'semi',
                    child: SeatDistributionWidget(
                      key: ValueKey('$activeMode-${seatMap.length}'),
                      seatsByParty: seatMap,
                      partyColors: seatColorMap,
                      markerThresholds: const [301, 360, 400],
                    ),
                  );

                  if (isWide) {
                    return Row(
                      children: [
                        Expanded(flex: 10, child: pieCard),
                        const SizedBox(width: 12),
                        Expanded(flex: 16, child: mapPanel),
                        const SizedBox(width: 12),
                        Expanded(flex: 12, child: semiCircleCard),
                      ],
                    );
                  }

                  return Column(
                    children: [
                      Expanded(flex: 48, child: mapPanel),
                      const SizedBox(height: 10),
                      Expanded(
                        flex: 52,
                        child: Row(
                          children: [
                            Expanded(child: pieCard),
                            const SizedBox(width: 10),
                            Expanded(child: semiCircleCard),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              flex: 42,
              child: _buildSmoothPanel(
                id: 'detail',
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Detayli Sonuclar (${activeMode == MapMode.alliance ? 'Ittifak' : 'Parti'})',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: ListView.separated(
                          itemCount: sliderSummaries.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 8),
                          itemBuilder: (context, i) {
                            final summary = sliderSummaries[i];
                            return Container(
                              key: ValueKey('${summary.label}-${summary.seats}'),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: const Color(0x1400E5FF),
                                border: Border.all(
                                  color: const Color(0x3300E5FF),
                                ),
                              ),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: activeMode == MapMode.alliance ? 120 : 40,
                                    child: activeMode == MapMode.alliance
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
                                          backgroundColor:
                                              Colors.white.withOpacity(0.08),
                                          color: summary.color,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        '${summary.votePercent.toStringAsFixed(1)}%',
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      Text('${summary.seats} MV'),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}





import 'package:flutter/material.dart';
import 'alliance_calculator.dart';
import 'color_engine.dart';

/// İttifak bazlı bölge detay dialogu
class AllianceRegionDetailDialog extends StatelessWidget {
  final RegionAllianceResult result;

  const AllianceRegionDetailDialog({
    super.key,
    required this.result,
  });

  Widget _buildPartyLogo(String party, {double size = 12}) {
    final logoPath = logoForParty(party);
    if (logoPath == null) {
      return CircleAvatar(
        radius: size / 2,
        backgroundColor: colorForParty(party),
        child: Text(
          party.isNotEmpty ? party[0].toUpperCase() : "?",
          style: TextStyle(fontSize: size / 1.5, color: Colors.white),
        ),
      );
    }

    return ClipOval(
      child: Image.asset(
        logoPath,
        width: size,
        height: size,
        fit: BoxFit.contain,
      ),
    );
  }

  Widget _buildAllianceLeaderLogo(String allianceName) {
    final leader = result.leadingPartyPerAlliance[allianceName];
    if (leader != null) {
      return _buildPartyLogo(leader, size: 24);
    }
    return CircleAvatar(
      radius: 12,
      backgroundColor: colorForAlliance(allianceName),
      child: Text(
        allianceName.isNotEmpty ? allianceName[0].toUpperCase() : "?",
        style: const TextStyle(fontSize: 12, color: Colors.white),
      ),
    );
  }

  Widget _buildAllianceLogos(Iterable<String> parties) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: parties.map(_buildPartyLogo).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final region = result.region;
    final sortedAlliances = result.allianceSeats.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    Color allianceColor(String allianceName) {
      final leading = result.leadingPartyPerAlliance[allianceName];
      return leading != null
          ? colorForParty(leading)
          : colorForAlliance(allianceName);
    }

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Başlık
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: allianceColor(result.winnerAlliance),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          region.name,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "${region.seats} Milletvekili",
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // İçerik
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Kazanan İttifak
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: allianceColor(result.winnerAlliance)
                            .withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: allianceColor(result.winnerAlliance),
                          width: 2,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.emoji_events,
                            color: allianceColor(result.winnerAlliance),
                            size: 32,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Kazanan İttifak",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                                Text(
                                  result.winnerAlliance,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // İttifak Dağılımı
                    const Text(
                      "İttifak Milletvekili Dağılımı",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),

                    ...sortedAlliances.map((entry) {
                      if (entry.value == 0) return const SizedBox.shrink();

                      final allianceName = entry.key;
                      final seats = entry.value;
                      final partySeats =
                          result.partySeatsInAlliance[allianceName] ?? {};

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // İttifak Başlığı
                              Row(
                                children: [
                                  _buildAllianceLeaderLogo(allianceName),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          allianceName,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        if (partySeats.isNotEmpty) ...[
                                          const SizedBox(height: 6),
                                          _buildAllianceLogos(
                                            partySeats.keys,
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: allianceColor(allianceName),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      "$seats MV",
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              // İttifak içindeki partiler
                              if (partySeats.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade50,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Column(
                                    children: partySeats.entries.map((party) {
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 4),
                                        child: Row(
                                          children: [
                                            _buildPartyLogo(party.key),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                party.key,
                                                style: const TextStyle(
                                                    fontSize: 13),
                                              ),
                                            ),
                                            Text(
                                              "${party.value} MV",
                                              style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.grey.shade700,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    }).toList(),

                    const SizedBox(height: 24),

                    // Oy Oranları
                    const Text(
                      "İttifak Oy Oranları",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),

                    ...result.allianceVotes.entries.map((entry) {
                      final allianceName = entry.key;
                      final allianceParties =
                          result.partySeatsInAlliance[allianceName]?.keys ?? [];

                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              _buildAllianceLeaderLogo(allianceName),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      allianceName,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    if (allianceParties.isNotEmpty) ...[
                                      const SizedBox(height: 6),
                                      _buildAllianceLogos(allianceParties),
                                    ],
                                    const SizedBox(height: 4),
                                    LinearProgressIndicator(
                                      value: entry.value / 100,
                                      backgroundColor: Colors.grey.shade200,
                                      color: allianceColor(allianceName),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                "%${entry.value.toStringAsFixed(1)}",
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
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

/// Dialog'u göstermek için yardımcı fonksiyon
void showAllianceRegionDetail(BuildContext context, RegionAllianceResult result) {
  showDialog(
    context: context,
    builder: (context) => AllianceRegionDetailDialog(result: result),
  );
}

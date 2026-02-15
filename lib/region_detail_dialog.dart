import 'package:flutter/material.dart';

import 'color_engine.dart';
import 'region_calculator.dart';

/// Secim bolgesi detaylarini gosteren dialog
class RegionDetailDialog extends StatelessWidget {
  final RegionResult result;

  const RegionDetailDialog({
    super.key,
    required this.result,
  });

  static const Color _panelBg = Color(0xFF090F1F);
  static const Color _surfaceBg = Color(0xFF101A31);
  static const Color _borderColor = Color(0x331BCDFF);
  static const Color _textPrimary = Color(0xFFF4F8FF);
  static const Color _textSecondary = Color(0xFF9CB3D6);

  Widget _buildPartyLogo(String party) {
    final logoPath = logoForParty(party);
    if (logoPath == null) {
      return CircleAvatar(
        radius: 14,
        backgroundColor: colorForParty(party),
        child: Text(
          party.isNotEmpty ? party[0].toUpperCase() : '?',
          style: const TextStyle(fontSize: 12, color: Colors.white),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: Image.asset(
        logoPath,
        width: 28,
        height: 28,
        fit: BoxFit.contain,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final region = result.region;
    final sortedSeats = result.seats.entries.toList()
      ..sort((a, b) {
        final voteA = result.votes[a.key] ?? 0;
        final voteB = result.votes[b.key] ?? 0;
        final voteCompare = voteB.compareTo(voteA);
        if (voteCompare != 0) return voteCompare;
        if (a.value == b.value) {
          if (a.key == result.winner && b.key != result.winner) return -1;
          if (b.key == result.winner && a.key != result.winner) return 1;
        }
        return b.value.compareTo(a.value);
      });

    final sortedVotes = result.votes.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Dialog(
      backgroundColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 560),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0A1022), _panelBg],
          ),
          border: Border.all(color: _borderColor),
          boxShadow: const [
            BoxShadow(
              color: Color(0x401BCDFF),
              blurRadius: 22,
              spreadRadius: -12,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colorForParty(result.winner),
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
                            color: _textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${region.seats} Milletvekili',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFFE3EEFF),
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
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: colorForParty(result.winner).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: colorForParty(result.winner),
                          width: 1.6,
                        ),
                      ),
                      child: Row(
                        children: [
                          _buildPartyLogo(result.winner),
                          const SizedBox(width: 12),
                          Icon(
                            Icons.emoji_events,
                            color: colorForParty(result.winner),
                            size: 32,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Kazanan Parti',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: _textSecondary,
                                  ),
                                ),
                                Text(
                                  result.winner,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: _textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Milletvekili Dagilimi',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: _textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...sortedSeats.map((entry) {
                      if (entry.value == 0) return const SizedBox.shrink();

                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: _surfaceBg,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: _borderColor),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              _buildPartyLogo(entry.key),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  entry.key,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: _textPrimary,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: colorForParty(entry.key),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  '${entry.value} MV',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: 24),
                    const Text(
                      'Oy Oranlari',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: _textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...sortedVotes.map((entry) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: _surfaceBg,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: _borderColor),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              _buildPartyLogo(entry.key),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      entry.key,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: _textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    LinearProgressIndicator(
                                      value: entry.value / 100,
                                      backgroundColor: const Color(0x1FFFFFFF),
                                      color: colorForParty(entry.key),
                                      minHeight: 6,
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                '%${entry.value.toStringAsFixed(1)}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: _textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
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

/// Dialog'u gostermek icin yardimci fonksiyon
void showRegionDetail(BuildContext context, RegionResult result) {
  showDialog(
    context: context,
    builder: (context) => RegionDetailDialog(result: result),
  );
}

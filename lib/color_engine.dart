import 'package:flutter/material.dart';
import 'strengths.dart';

/// Partilerin renkleri (temiz isimlerle)
final Map<String, Color> partyColors = {
  "CHP": const Color(0xFFC00000),
  "AKP": const Color(0xFFFF7A00),
  "MHP": const Color(0xFF8B4513),
  "İYİ Parti": const Color(0xFF00C8C8),
  "IYI Parti": const Color(0xFF00C8C8),
  "IYI": const Color(0xFF00C8C8),
  "DEM": const Color(0xFF6A0DAD),
  "HDP/DEM": const Color(0xFF6A0DAD),
  "Diğer": Colors.grey,
  "DIGER": Colors.grey,
};

Color colorForParty(String party) {
  final known = partyColors[party];
  if (known != null) return known;
  final hash = party.hashCode & 0xFFFFFF;
  final hue = (hash % 360).toDouble();
  return HSLColor.fromAHSL(1, hue, 0.55, 0.55).toColor();
}

/// Şehir bazlı renklendirme (strengths.dart haritaları kullanılır)
Color computeRegionColor({
  required String city,
  required Map<String, double> nationalVotes,
}) {
  if (nationalVotes.isEmpty) return Colors.grey.shade300;

  final Map<String, double> weighted = {};

  nationalVotes.forEach((party, nationalVote) {
    double strength = 1.0;
    switch (party) {
      case 'CHP':
        strength = strengthFromMap(chpStrength, city);
        break;
      case 'AKP':
        strength = strengthFromMap(akpStrength, city);
        break;
      case 'MHP':
        strength = strengthFromMap(mhpStrength, city);
        break;
      case 'İYİ Parti':
      case 'IYI Parti':
      case 'IYI':
        strength = strengthFromMap(iyiStrength, city);
        break;
      case 'HDP/DEM':
      case 'DEM':
      case 'HDP':
        strength = strengthFromMap(demStrength, city);
        break;
      case 'Diğer':
      case 'DIGER':
        strength = strengthFromMap(otherStrength, city);
        break;
      default:
        strength = strengthFromMap(otherStrength, city);
    }

    final value = (nationalVote.isFinite ? nationalVote : 0.0) *
        (strength.isFinite ? strength : 1.0);
    weighted[party] = value;
  });

  if (weighted.isEmpty) return Colors.grey.shade300;

  final winner = weighted.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  return colorForParty(winner);
}


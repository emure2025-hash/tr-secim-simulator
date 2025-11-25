import 'package:flutter/material.dart';
import 'strengths.dart';

/// Partilerin renkleri
final Map<String, Color> partyColors = {
  "CHP": const Color(0xFFC00000),       // koyu kırmızı
  "AKP": const Color(0xFFFF7A00),       // koyu turuncu
  "MHP": const Color(0xFF8B4513),       // kahverengi
  "İYİ Parti": const Color(0xFF00C8C8), // turkuaz
  "HDP/DEM": const Color(0xFF6A0DAD),   // mor
  "Diğer": Colors.grey,
};

/// Bir bölgenin hangi parti tarafından kazanıldığını hesaplar
Color computeRegionColor({
  required String city,
  required Map<String, double> nationalVotes,
}) {
  if (nationalVotes.isEmpty) return Colors.grey;

  final Map<String, double> regional = {};

  nationalVotes.forEach((party, nationalVote) {
    double strength = 1.0;

    // parti isimlendirmelerinin farklı varyantlarını da kontrol ediyoruz
    switch (party) {
      case 'CHP':
        strength = chpStrength[city] ?? 1.0;
        break;
      case 'AKP':
        strength = akpStrength[city] ?? 1.0;
        break;
      case 'MHP':
        strength = mhpStrength[city] ?? 1.0;
        break;
      case 'İYİ Parti':
      case 'IYI':
      case 'IYI Parti':
      case 'İYİ':
        strength = iyiStrength[city] ?? 1.0;
        break;
      case 'HDP/DEM':
      case 'DEM':
      case 'HDP':
        strength = demStrength[city] ?? 1.0;
        break;
      case 'Diğer':
      case 'DIGER':
        strength = otherStrength[city] ?? 1.0;
        break;
      default:
        strength = 1.0;
    }

    final value = (nationalVote.isFinite ? nationalVote : 0.0) * (strength.isFinite ? strength : 1.0);
    regional[party] = value;
  });

  if (regional.isEmpty) return Colors.grey;

  final winnerEntry = regional.entries.reduce((a, b) => a.value > b.value ? a : b);
  final winner = winnerEntry.key;

  return partyColors[winner] ?? Colors.grey;
}

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
  "HDP": const Color(0xFF6A0DAD),
  
  // Yeni Partiler
  "Yeniden Refah": const Color(0xFF2E7D32), // Yeşil
  "Zafer": const Color(0xFF8B0000), // Bordo
  "HÜDAPAR": const Color(0xFF1B5E20), // Koyu Yeşil
  "Büyük Birlik": const Color(0xFFE91E63), // Pembe
  "EMEP": const Color(0xFFD32F2F), // Kırmızı
  "TİP": const Color(0xFFC62828), // Koyu Kırmızı
  "SOL": const Color(0xFF1976D2), // Mavi
  "Anahtar": const Color(0xFFFFA726), // Turuncu
  "Gelecek": const Color(0xFF5E35B1), // Mor
  "Deva": const Color(0xFF0097A7), // Turkuaz
  
  "Diğer": Colors.grey,
  "DIGER": Colors.grey,
};

/// İttifak renkleri
final Map<String, Color> allianceColors = {
  "İttifak 1": const Color(0xFF1976D2),
  "İttifak 2": const Color(0xFFD32F2F),
  "İttifak 3": const Color(0xFF388E3C),
  "İttifak 4": const Color(0xFFF57C00),
  "İttifak 5": const Color(0xFF7B1FA2),
  "İttifak 6": const Color(0xFF00796B),
};

Color colorForParty(String party) {
  final known = partyColors[party];
  if (known != null) return known;
  final hash = party.hashCode & 0xFFFFFF;
  final hue = (hash % 360).toDouble();
  return HSLColor.fromAHSL(1, hue, 0.55, 0.55).toColor();
}

Color colorForAlliance(String allianceName) {
  final known = allianceColors[allianceName];
  if (known != null) return known;
  final hash = allianceName.hashCode & 0xFFFFFF;
  final hue = (hash % 360).toDouble();
  return HSLColor.fromAHSL(1, hue, 0.6, 0.5).toColor();
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
      case 'Yeniden Refah':
        strength = strengthFromMap(yenidenRefahStrength, city);
        break;
      case 'Zafer':
        strength = strengthFromMap(zaferStrength, city);
        break;
      case 'HÜDAPAR':
        strength = strengthFromMap(hudaparStrength, city);
        break;
      case 'Büyük Birlik':
        strength = strengthFromMap(buyukBirlikStrength, city);
        break;
      case 'EMEP':
      case 'TİP':
      case 'SOL':
      case 'Anahtar':
      case 'Gelecek':
      case 'Deva':
        strength = strengthFromMap(otherStrength, city);
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
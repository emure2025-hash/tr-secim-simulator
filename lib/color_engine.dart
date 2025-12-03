import 'package:flutter/material.dart';
import 'strengths.dart';

/// Partilerin renkleri
final Map<String, Color> partyColors = {
  "CHP": const Color(0xFFC00000),       // koyu k��rm��z��
  "AKP": const Color(0xFFFF7A00),       // koyu turuncu
  "MHP": const Color(0xFF8B4513),       // kahverengi
  "��Y�� Parti": const Color(0xFF00C8C8), // turkuaz
  "IYI": const Color(0xFF00C8C8),       // turkuaz - fallback
  "IYI Parti": const Color(0xFF00C8C8), // turkuaz - fallback
  "DEM": const Color(0xFF6A0DAD),       // mor
  "HDP/DEM": const Color(0xFF6A0DAD),   // mor
  "Di�Yer": Colors.grey,
};

Color colorForParty(String party) {
  final known = partyColors[party];
  if (known != null) return known;
  // Deterministic renk: parti ad��ndan h�� hesaplay��p renge ��evir
  final hash = party.hashCode & 0xFFFFFF;
  final hue = (hash % 360).toDouble();
  return HSLColor.fromAHSL(1, hue, 0.55, 0.55).toColor();
}

/// strengths.dart yap��s��na birebir uyan basit kazanan hesab��
Color computeRegionColor({
  required String city,
  required Map<String, double> nationalVotes, // kullan��lm��yor ama parametre dursun
}) {
  // �?ehir ad��n�� normalize et
  // ignore: unused_local_variable
  final c = city.toLowerCase();

  // �?ehir i��in tǬm parti strengthlerini oku
  final strengths = {
    "CHP": PartyStrengths.chp[city] ?? 0,
    "AKP": PartyStrengths.akp[city] ?? 0,
    "MHP": PartyStrengths.mhp[city] ?? 0,
    "IYI": PartyStrengths.iyi[city] ?? 0,
    "DEM": PartyStrengths.dem[city] ?? 0,
    "DIGER": PartyStrengths.diger[city] ?? 0,
  };

  // En gǬ��l�� partiyi bul
  final winnerEntry =
      strengths.entries.reduce((a, b) => a.value > b.value ? a : b);

  final winner = winnerEntry.key;

  // Rengi d��nd��r
  return colorForParty(winner);
}

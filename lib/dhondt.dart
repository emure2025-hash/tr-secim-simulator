import 'regions.dart';

/// D'Hondt dağılım sonucu geri döner.
/// parties = {"CHP": 34.0, "AKP": 27.0, ...}
/// threshold = ulusal baraj (%)
Map<String, int> calculateDhondt(Map<String, double> parties, double threshold) {
  // 1) Ulusal barajı geçemeyen partileri ele
  final eligible = parties.entries
      .where((e) => e.value >= threshold)
      .map((e) => e.key)
      .toSet();

  // MV dağılımlarının tutulacağı ana tablo
  final Map<String, int> totalSeats = {
    for (var key in parties.keys) key: 0
  };

  // 87 bölgeyi tek tek işle
  for (final region in regions) {
    // Bölgedeki geçerli partileri filtrele
    final regionVotes = {
      for (final p in eligible) p: parties[p]!
    };

    // D'Hondt puanları tablosu
    final List<MapEntry<String, double>> scores = [];

    // Her parti için bölme değerlerini hesapla
    regionVotes.forEach((party, vote) {
      for (int d = 1; d <= region.seats; d++) {
        scores.add(MapEntry(party, vote / d));
      }
    });

    // Tüm bölme değerlerini sırala
    scores.sort((a, b) => b.value.compareTo(a.value));

    // İlk N (bölge sandalyeleri kadar) partiye sandalyeleri dağıt
    for (int i = 0; i < region.seats; i++) {
      final winner = scores[i].key;
      totalSeats[winner] = totalSeats[winner]! + 1;
    }
  }

  return totalSeats;
}

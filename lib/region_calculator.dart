import 'region.dart';
import 'regions.dart';
import 'strengths.dart';

/// Tek bir bölge için D'Hondt hesaplaması yapar
class RegionResult {
  final Region region;
  final Map<String, int> seats; // Parti -> Milletvekili sayısı
  final Map<String, double> votes; // Parti -> Oy oranı (%)
  final String winner; // En yuksek oy oranina sahip parti
  
  RegionResult({
    required this.region,
    required this.seats,
    required this.votes,
    required this.winner,
  });
}

/// Tek bir seçim bölgesi için sonuç hesaplar
RegionResult calculateRegionResult({
  required Region region,
  required Map<String, double> nationalVotes,
  required double threshold,
}) {
  // 1) Bölgesel oy oranlarını hesapla (ulusal oy * bölgesel güç)
  final Map<String, double> regionalVotes = {};
  final strengthKey = strengthKeyForRegion(region.city, region.name, regionId: region.id);
  
  nationalVotes.forEach((party, nationalVote) {
    double strength = 1.0;
    
    switch (party) {
      case 'CHP':
        strength = strengthFromMap(chpStrength, strengthKey);
        break;
      case 'AKP':
        strength = strengthFromMap(akpStrength, strengthKey);
        break;
      case 'MHP':
        strength = strengthFromMap(mhpStrength, strengthKey);
        break;
      case 'İYİ Parti':
      case 'IYI Parti':
      case 'IYI':
        strength = strengthFromMap(iyiStrength, strengthKey);
        break;
      case 'HDP/DEM':
      case 'DEM':
      case 'HDP':
        strength = strengthFromMap(demStrength, strengthKey);
        break;
      case 'Diğer':
      case 'DIGER':
        strength = strengthFromMap(otherStrength, strengthKey);
        break;
      default:
        strength = strengthFromMap(otherStrength, strengthKey);
    }
    
    regionalVotes[party] = (nationalVote * strength).clamp(0.0, 100.0);
  });
  
  // 2) Normalize et (toplamı 100 yap)
  final total = regionalVotes.values.fold<double>(0.0, (sum, v) => sum + v);
  if (total > 0) {
    regionalVotes.forEach((key, value) {
      regionalVotes[key] = (value / total) * 100.0;
    });
  }
  
  // 3) Barajı geçen partileri filtrele
  final eligible = regionalVotes.entries
      .where((e) => e.value >= threshold)
      .map((e) => MapEntry(e.key, e.value))
      .toList();
  
  // 4) D'Hondt ile sandalye dağılımı
  final Map<String, int> seats = {
    for (var key in regionalVotes.keys) key: 0
  };
  
  if (eligible.isNotEmpty) {
    final List<MapEntry<String, double>> scores = [];
    
    for (final entry in eligible) {
      for (int d = 1; d <= region.seats; d++) {
        scores.add(MapEntry(entry.key, entry.value / d));
      }
    }
    
    scores.sort((a, b) => b.value.compareTo(a.value));
    
    for (int i = 0; i < region.seats; i++) {
      final winner = scores[i].key;
      seats[winner] = seats[winner]! + 1;
    }
  }
  
  // 5) Kazanan parti (en yuksek oy orani alan)
  String winner = 'Yok';
  double maxVote = -double.infinity;
  
  regionalVotes.forEach((party, vote) {
    final value = vote.isFinite ? vote : 0.0;
    if (value > maxVote) {
      maxVote = value;
      winner = party;
    }
  });
  
  return RegionResult(
    region: region,
    seats: seats,
    votes: regionalVotes,
    winner: winner,
  );
}

/// Tüm bölgeler için sonuçları hesaplar
Map<String, RegionResult> calculateAllRegions({
  required Map<String, double> nationalVotes,
  required double threshold,
}) {
  final Map<String, RegionResult> results = {};
  
  for (final region in regions) {
    results[region.id] = calculateRegionResult(
      region: region,
      nationalVotes: nationalVotes,
      threshold: threshold,
    );
  }
  
  return results;
}

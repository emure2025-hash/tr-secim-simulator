import 'alliance.dart';
import 'region.dart';
import 'regions.dart';
import 'strengths.dart';

/// Tek bir bolge icin D'Hondt hesaplamasini yapar.
class RegionResult {
  final Region region;
  final Map<String, int> seats; // Parti -> Milletvekili sayisi
  final Map<String, double> votes; // Parti -> Oy orani (%)
  final String winner; // En yuksek oy oranina sahip parti

  RegionResult({
    required this.region,
    required this.seats,
    required this.votes,
    required this.winner,
  });
}

/// Tek bir secim bolgesi icin sonucu hesaplar.
RegionResult calculateRegionResult({
  required Region region,
  required Map<String, double> nationalVotes,
  required double threshold,
  List<Alliance> alliances = const [],
}) {
  // 1) Bolgesel oy oranlarini hesapla (ulusal oy * bolgesel guc)
  final Map<String, double> regionalVotes = {};
  final strengthKey =
      strengthKeyForRegion(region.city, region.name, regionId: region.id);

  nationalVotes.forEach((party, nationalVote) {
    final strength = _getPartyStrength(party, strengthKey);
    regionalVotes[party] = (nationalVote * strength).clamp(0.0, 100.0);
  });

  // 2) Normalize et (toplami 100 yap)
  final total = regionalVotes.values.fold<double>(0.0, (sum, v) => sum + v);
  if (total > 0) {
    regionalVotes.forEach((key, value) {
      regionalVotes[key] = (value / total) * 100.0;
    });
  }

  // 3) Ittifaklari olustur (sadece tanimli ittifaklar)
  final Map<String, List<String>> allianceMap = {};

  for (final alliance in alliances) {
    allianceMap[alliance.name] = alliance.parties;
  }

  // 4) Ittifak oylarini hesapla (ulusal ve bolgesel)
  final Map<String, double> allianceRegionalVotes = {};
  final Map<String, double> allianceNationalVotes = {};
  allianceMap.forEach((allianceName, parties) {
    double regionalTotal = 0;
    double nationalTotal = 0;
    for (final party in parties) {
      regionalTotal += regionalVotes[party] ?? 0;
      nationalTotal += nationalVotes[party] ?? 0;
    }
    allianceRegionalVotes[allianceName] = regionalTotal;
    allianceNationalVotes[allianceName] = nationalTotal;
  });

  // 5) Baraj kurali (ulusal baraj esas, bolgesel baraj ek kosul):
  // - Ittifak disindaki partiler ulusal+bolgesel baraji gecmeli.
  // - Ittifak icindeki partiler icin baraj ittifaka uygulanir.
  final Map<String, String> partyAlliance = {};
  allianceMap.forEach((allianceName, parties) {
    for (final party in parties) {
      partyAlliance[party] = allianceName;
    }
  });

  final eligibleParties = regionalVotes.entries.where((entry) {
    final partyRegionalVote = entry.value;
    final partyNationalVote = nationalVotes[entry.key] ?? 0;
    final allianceName = partyAlliance[entry.key];
    if (allianceName == null) {
      return partyNationalVote >= threshold && partyRegionalVote >= threshold;
    }
    return (allianceNationalVotes[allianceName] ?? 0) >= threshold &&
        (allianceRegionalVotes[allianceName] ?? 0) >= threshold;
  }).toList();

  // 6) D'Hondt ile sandalye dagilimi (parti bazinda)
  final Map<String, int> seats = {
    for (var key in regionalVotes.keys) key: 0
  };

  if (eligibleParties.isNotEmpty) {
    final List<MapEntry<String, double>> scores = [];

    for (final entry in eligibleParties) {
      for (int d = 1; d <= region.seats; d++) {
        scores.add(MapEntry(entry.key, entry.value / d));
      }
    }

    scores.sort((a, b) => b.value.compareTo(a.value));

    for (int i = 0; i < region.seats && i < scores.length; i++) {
      final winner = scores[i].key;
      seats[winner] = seats[winner]! + 1;
    }
  }

  // 7) Kazanan parti (en yuksek oy oranini alan)
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

/// Tum bolgeler icin sonuclari hesaplar
Map<String, RegionResult> calculateAllRegions({
  required Map<String, double> nationalVotes,
  required double threshold,
  List<Alliance> alliances = const [],
}) {
  final Map<String, RegionResult> results = {};

  for (final region in regions) {
    results[region.id] = calculateRegionResult(
      region: region,
      nationalVotes: nationalVotes,
      threshold: threshold,
      alliances: alliances,
    );
  }

  return results;
}

double _getPartyStrength(String party, String strengthKey) {
  switch (party) {
    case 'CHP':
      return strengthFromMap(chpStrength, strengthKey);
    case 'AKP':
      return strengthFromMap(akpStrength, strengthKey);
    case 'MHP':
      return strengthFromMap(mhpStrength, strengthKey);
    case 'IYI Parti':
    case 'IYI':
      return strengthFromMap(iyiStrength, strengthKey);
    case 'HDP/DEM':
    case 'DEM':
    case 'HDP':
      return strengthFromMap(demStrength, strengthKey);
    case 'Yeniden Refah':
      return strengthFromMap(yenidenRefahStrength, strengthKey);
    case 'Zafer':
      return strengthFromMap(zaferStrength, strengthKey);
    case 'HUDAPAR':
    case 'HCoDAPAR':
    case 'HÇoDAPAR':
      return strengthFromMap(hudaparStrength, strengthKey);
    case 'Buyuk Birlik':
    case 'Büyük Birlik':
      return strengthFromMap(buyukBirlikStrength, strengthKey);
    case 'Diger':
    case 'Diğer':
    case 'DIGER':
      return strengthFromMap(otherStrength, strengthKey);
    default:
      return strengthFromMap(otherStrength, strengthKey);
  }
}

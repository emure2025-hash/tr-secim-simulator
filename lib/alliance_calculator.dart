import 'alliance.dart';
import 'region.dart';
import 'regions.dart';
import 'strengths.dart';

/// Bölge bazında ittifak sonucu
class RegionAllianceResult {
  final Region region;
  final Map<String, int> allianceSeats; // İttifak -> Sandalye
  final Map<String, double> allianceVotes; // İttifak -> Oy %
  final String winnerAlliance;
  final Map<String, Map<String, int>> partySeatsInAlliance; // İttifak -> Parti -> Sandalye

  RegionAllianceResult({
    required this.region,
    required this.allianceSeats,
    required this.allianceVotes,
    required this.winnerAlliance,
    required this.partySeatsInAlliance,
  });
}

/// Tek bir bölge için ittifak bazlı D'Hondt hesaplaması
RegionAllianceResult calculateRegionAllianceResult({
  required Region region,
  required Map<String, double> nationalVotes,
  required List<Alliance> alliances,
  required double threshold,
}) {
  // 1) Bölgesel oy oranlarını hesapla (her parti için)
  final Map<String, double> regionalVotes = {};

  final strengthKey = strengthKeyForRegion(region.city, region.name, regionId: region.id);
  nationalVotes.forEach((party, nationalVote) {
    double strength = _getPartyStrength(party, strengthKey);
    regionalVotes[party] = (nationalVote * strength).clamp(0.0, 100.0);
  });

  // 2) Normalize et
  final total = regionalVotes.values.fold<double>(0.0, (sum, v) => sum + v);
  if (total > 0) {
    regionalVotes.forEach((key, value) {
      regionalVotes[key] = (value / total) * 100.0;
    });
  }

  // 3) İttifakları oluştur
  final Map<String, List<String>> allianceMap = {};
  final Set<String> partiesInAlliance = {};

  for (final alliance in alliances) {
    allianceMap[alliance.name] = alliance.parties;
    partiesInAlliance.addAll(alliance.parties);
  }

  // İttifaksız partileri tek başına ittifak olarak ekle
  for (final party in regionalVotes.keys) {
    if (!partiesInAlliance.contains(party)) {
      allianceMap[party] = [party];
    }
  }

  // 4) İttifak bazında toplam oyları hesapla
  final Map<String, double> allianceVotes = {};
  allianceMap.forEach((allianceName, parties) {
    double totalVote = 0;
    for (final party in parties) {
      totalVote += regionalVotes[party] ?? 0;
    }
    allianceVotes[allianceName] = totalVote;
  });

  // 5) Barajı geçen ittifakları filtrele
  final eligible = allianceVotes.entries
      .where((e) => e.value >= threshold)
      .toList();

  // 6) D'Hondt ile sandalye dağılımı (ittifak bazında)
  final Map<String, int> allianceSeats = {
    for (var key in allianceVotes.keys) key: 0
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
      allianceSeats[winner] = allianceSeats[winner]! + 1;
    }
  }

  // 7) Her ittifak içinde partilere sandalye dağıt (ittifakın aldığı sandalyeleri parti oylarına göre dağıt)
  final Map<String, Map<String, int>> partySeatsInAlliance = {};

  allianceSeats.forEach((allianceName, seats) {
    if (seats == 0) return;

    final parties = allianceMap[allianceName]!;
    final partySeatsMap = <String, int>{};

    if (parties.length == 1) {
      // Tek partili ittifak
      partySeatsMap[parties[0]] = seats;
    } else {
      // Çok partili ittifak - D'Hondt ile dağıt
      final partyVotesInAlliance = <String, double>{};
      for (final party in parties) {
        partyVotesInAlliance[party] = regionalVotes[party] ?? 0;
      }

      // İttifak içinde D'Hondt
      final scores = <MapEntry<String, double>>[];
      for (final party in parties) {
        for (int d = 1; d <= seats; d++) {
          scores.add(MapEntry(party, (partyVotesInAlliance[party] ?? 0) / d));
        }
      }

      scores.sort((a, b) => b.value.compareTo(a.value));

      for (final party in parties) {
        partySeatsMap[party] = 0;
      }

      for (int i = 0; i < seats; i++) {
        final winner = scores[i].key;
        partySeatsMap[winner] = partySeatsMap[winner]! + 1;
      }
    }

    partySeatsInAlliance[allianceName] = partySeatsMap;
  });

  // 8) Kazanan ittifak (en yuksek oy orani alan)
  String winnerAlliance = 'Yok';
  double maxVote = -double.infinity;

  allianceVotes.forEach((alliance, vote) {
    final value = vote.isFinite ? vote : 0.0;
    if (value > maxVote) {
      maxVote = value;
      winnerAlliance = alliance;
    }
  });

  return RegionAllianceResult(
    region: region,
    allianceSeats: allianceSeats,
    allianceVotes: allianceVotes,
    winnerAlliance: winnerAlliance,
    partySeatsInAlliance: partySeatsInAlliance,
  );
}

/// Tüm bölgeler için ittifak sonuçlarını hesapla
Map<String, RegionAllianceResult> calculateAllRegionAlliances({
  required Map<String, double> nationalVotes,
  required List<Alliance> alliances,
  required double threshold,
}) {
  final Map<String, RegionAllianceResult> results = {};

  for (final region in regions) {
    results[region.id] = calculateRegionAllianceResult(
      region: region,
      nationalVotes: nationalVotes,
      alliances: alliances,
      threshold: threshold,
    );
  }

  return results;
}

/// Toplam ittifak sonuçlarını hesapla
Map<String, AllianceResult> calculateTotalAllianceResults(
  Map<String, RegionAllianceResult> regionResults,
) {
  final Map<String, int> totalAllianceSeats = {};
  final Map<String, Map<String, int>> totalPartySeatsInAlliance = {};

  // Her bölgedeki sonuçları topla
  regionResults.forEach((regionId, result) {
    result.allianceSeats.forEach((alliance, seats) {
      totalAllianceSeats[alliance] = (totalAllianceSeats[alliance] ?? 0) + seats;
    });

    result.partySeatsInAlliance.forEach((alliance, partySeats) {
      if (!totalPartySeatsInAlliance.containsKey(alliance)) {
        totalPartySeatsInAlliance[alliance] = {};
      }

      partySeats.forEach((party, seats) {
        totalPartySeatsInAlliance[alliance]![party] =
            (totalPartySeatsInAlliance[alliance]![party] ?? 0) + seats;
      });
    });
  });

  // AllianceResult'ları oluştur
  final Map<String, AllianceResult> results = {};

  totalAllianceSeats.forEach((alliance, totalSeats) {
    results[alliance] = AllianceResult(
      allianceName: alliance,
      totalSeats: totalSeats,
      partySeats: totalPartySeatsInAlliance[alliance] ?? {},
      totalVotePercent: 0, // Bunu ayrıca hesaplayabiliriz
    );
  });

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
    case 'İYİ Parti':
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
    case 'HÜDAPAR':
      return strengthFromMap(hudaparStrength, strengthKey);
    case 'Büyük Birlik':
      return strengthFromMap(buyukBirlikStrength, strengthKey);
    default:
      return strengthFromMap(otherStrength, strengthKey);
  }
}

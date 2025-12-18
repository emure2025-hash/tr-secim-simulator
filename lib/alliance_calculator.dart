import 'alliance.dart';
import 'region.dart';
import 'regions.dart';
import 'region_calculator.dart';

/// Bolge bazinda ittifak sonucu
class RegionAllianceResult {
  final Region region;
  final Map<String, int> allianceSeats; // Ittifak -> Sandalye
  final Map<String, double> allianceVotes; // Ittifak -> Oy %
  final String winnerAlliance;
  final Map<String, Map<String, int>> partySeatsInAlliance; // Ittifak -> Parti -> Sandalye
  final Map<String, String> leadingPartyPerAlliance; // Ittifak -> En yuksek oy alan parti

  RegionAllianceResult({
    required this.region,
    required this.allianceSeats,
    required this.allianceVotes,
    required this.winnerAlliance,
    required this.partySeatsInAlliance,
    required this.leadingPartyPerAlliance,
  });
}

/// Tek bir bolge icin ittifak sonuclarini parti bazli D'Hondt'tan ureterek hesaplar.
RegionAllianceResult calculateRegionAllianceResult({
  required Region region,
  required Map<String, double> nationalVotes,
  required List<Alliance> alliances,
  required double threshold,
}) {
  // Parti bazli D'Hondt ve baraj: once parti sonucu hesapla
  final regionResult = calculateRegionResult(
    region: region,
    nationalVotes: nationalVotes,
    threshold: threshold,
    alliances: alliances,
  );

  // Ittifak haritasi
  final Map<String, List<String>> allianceMap = {};
  final Set<String> partiesInAlliance = {};

  for (final alliance in alliances) {
    allianceMap[alliance.name] = alliance.parties;
    partiesInAlliance.addAll(alliance.parties);
  }

  for (final party in regionResult.votes.keys) {
    if (!partiesInAlliance.contains(party)) {
      allianceMap[party] = [party];
    }
  }

  // Ittifak oylarini hesapla
  final Map<String, double> allianceVotes = {};
  allianceMap.forEach((allianceName, parties) {
    double totalVote = 0;
    for (final party in parties) {
      totalVote += regionResult.votes[party] ?? 0;
    }
    allianceVotes[allianceName] = totalVote;
  });

  // Parti sandalyelerini ittifaka grupla
  final Map<String, int> allianceSeats = {};
  final Map<String, Map<String, int>> partySeatsInAlliance = {};
  final Map<String, String> leadingPartyPerAlliance = {};

  allianceMap.forEach((allianceName, parties) {
    int seatSum = 0;
    final partySeats = <String, int>{};
    String? leadingParty;
    double maxVoteInAlliance = -double.infinity;

    for (final party in parties) {
      final seatCount = regionResult.seats[party] ?? 0;
      partySeats[party] = seatCount;
      seatSum += seatCount;

      final voteShare = nationalVotes[party] ?? 0; // Ulusal oy oranŽñ kullan
      if (leadingParty == null || voteShare > maxVoteInAlliance) {
        leadingParty = party;
        maxVoteInAlliance = voteShare;
      }
    }

    allianceSeats[allianceName] = seatSum;
    partySeatsInAlliance[allianceName] = partySeats;

    if (leadingParty != null) {
      leadingPartyPerAlliance[allianceName] = leadingParty;
    }
  });

  // Kazanan ittifak (en yuksek oy)
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
    leadingPartyPerAlliance: leadingPartyPerAlliance,
  );
}

/// Tum bolgeler icin ittifak sonuclarini hesapla
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

/// Toplam ittifak sonuclarini hesapla
Map<String, AllianceResult> calculateTotalAllianceResults(
  Map<String, RegionAllianceResult> regionResults,
) {
  final Map<String, int> totalAllianceSeats = {};
  final Map<String, Map<String, int>> totalPartySeatsInAlliance = {};

  regionResults.forEach((regionId, result) {
    result.allianceSeats.forEach((alliance, seats) {
      totalAllianceSeats[alliance] = (totalAllianceSeats[alliance] ?? 0) + seats;
    });

    result.partySeatsInAlliance.forEach((alliance, partySeats) {
      totalPartySeatsInAlliance.putIfAbsent(alliance, () => {});
      partySeats.forEach((party, seats) {
        totalPartySeatsInAlliance[alliance]![party] =
            (totalPartySeatsInAlliance[alliance]![party] ?? 0) + seats;
      });
    });
  });

  final Map<String, AllianceResult> results = {};

  totalAllianceSeats.forEach((alliance, totalSeats) {
    results[alliance] = AllianceResult(
      allianceName: alliance,
      totalSeats: totalSeats,
      partySeats: totalPartySeatsInAlliance[alliance] ?? {},
      totalVotePercent: 0,
    );
  });

  return results;
}

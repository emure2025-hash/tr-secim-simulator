class Alliance {
  final String id;
  final String name;
  final List<String> parties;

  Alliance({
    required this.id,
    required this.name,
    required this.parties,
  });

  Alliance copyWith({
    String? id,
    String? name,
    List<String>? parties,
  }) {
    return Alliance(
      id: id ?? this.id,
      name: name ?? this.name,
      parties: parties ?? List.from(this.parties),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'parties': parties,
      };

  factory Alliance.fromJson(Map<String, dynamic> json) => Alliance(
        id: json['id'] as String,
        name: json['name'] as String,
        parties: (json['parties'] as List).cast<String>(),
      );
}

/// İttifak sonucu
class AllianceResult {
  final String allianceName;
  final int totalSeats;
  final Map<String, int> partySeats; // İttifak içindeki partilerin sandalyeleri
  final double totalVotePercent;

  AllianceResult({
    required this.allianceName,
    required this.totalSeats,
    required this.partySeats,
    required this.totalVotePercent,
  });
}
class FixtureData {
  final int fixtureId;
  final String homeClubName;
  final String awayClubName;
  final int homeClubRank;
  final int awayClubRank;
  final String homeClubLogoPath;
  final String awayClubLogoPath;
  final int? homeTeamScore;
  final int? awayTeamScore;

  FixtureData({
    required this.fixtureId,
    required this.homeClubName,
    required this.awayClubName,
    required this.homeClubRank,
    required this.awayClubRank,
    required this.homeClubLogoPath,
    required this.awayClubLogoPath,
    required this.homeTeamScore,
    required this.awayTeamScore,
  });

  factory FixtureData.fromJson(Map<String, dynamic> json) {
    return FixtureData(
      fixtureId: json['fixtureId'],
      homeClubName: json['homeClubName'],
      awayClubName: json['awayClubName'],
      homeClubRank: json['homeClubRank'],
      awayClubRank: json['awayClubRank'],
      homeClubLogoPath: json['homeClubLogoPath'],
      awayClubLogoPath: json['awayClubLogoPath'],
      homeTeamScore: json['homeTeamScore'],
      awayTeamScore: json['awayTeamScore'],
    );
  }

}

import 'package:flutter/material.dart';

import 'fixtureModel.dart';

class FixtureList extends StatelessWidget {
  final List<FixtureData> fixtures;
  final void Function(FixtureData) onFixtureTap;

  FixtureList({
    required this.fixtures,
    required this.onFixtureTap,
  });

  @override
  Widget build(BuildContext context) {

    return SingleChildScrollView(
      child: Column(
        children: [
          for (int index = 0; index < fixtures.length; index++)
            buildFixtureItem(fixtures[index]),
        ],
      ),
    );
  }

  Widget buildFixtureItem(FixtureData fixture) {
    String scoreText = ' - ';
    if(fixture.homeTeamScore!=null|| fixture.awayTeamScore!= null){
      scoreText = '${fixture.homeTeamScore} - ${fixture.awayTeamScore}';
    }
    return GestureDetector(
      onTap: () => onFixtureTap(fixture),
      child: Container(
        child: ListTile(
          leading: CircleAvatar(
            radius: 20,
            backgroundImage: NetworkImage(fixture.homeClubLogoPath),
          ),
          title: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FittedBox(
                    child: Text(
                      fixture.homeClubName,
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  ),
                  FittedBox(
                    child: Text(
                      "State: ${fixture.homeClubRank}",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              SizedBox(width: 8),
              FittedBox(
                child: Text(
                  scoreText,
                  style: TextStyle(fontSize: 18),
                ),
              ),
              SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FittedBox(
                    child: Text(
                      fixture.awayClubName,
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  ),
                  FittedBox(
                    child: Text(
                      "Rank: ${fixture.awayClubRank}",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
          trailing: CircleAvatar(
            radius: 20,
            backgroundImage: NetworkImage(fixture.awayClubLogoPath),
          ),
        ),
      ),
    );
  }
}
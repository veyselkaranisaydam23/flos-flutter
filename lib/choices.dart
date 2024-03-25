import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'general_overview_page_organizer.dart';

class ListChoice extends StatefulWidget {
  final ValueChanged<ListType> onListTypeChanged;

  const ListChoice({Key? key, required this.onListTypeChanged})
      : super(key: key);

  @override
  State<ListChoice> createState() => _ListChoiceState();
}

class _ListChoiceState extends State<ListChoice> {
  ListType listType = ListType.prize;

  @override
  Widget build(BuildContext context) {
    return ToggleButtons(
      children: const <Widget>[
        Text('   By Prize   ',style: TextStyle(fontSize: 19),),
        Text('   By Team Count   ',style: TextStyle(fontSize: 19),),
      ],
      isSelected: <bool>[
        listType == ListType.prize,
        listType == ListType.teamCount,
      ],
      onPressed: (int index) {
        if (mounted) {
          setState(() {
            listType = index == 0 ? ListType.prize : ListType.teamCount;
            widget.onListTypeChanged(listType);
          });
        }
      },
    );
  }
}

class FixtureChoice extends StatefulWidget {
  final ValueChanged<FixtureType> onFixtureTypeChanged;

  const FixtureChoice({Key? key, required this.onFixtureTypeChanged})
      : super(key: key);

  @override
  State<FixtureChoice> createState() => _FixtureChoiceState();
}

class _FixtureChoiceState extends State<FixtureChoice> {
  FixtureType fixtureType = FixtureType.date;

  @override
  Widget build(BuildContext context) {
    return ToggleButtons(
      children: const <Widget>[
        Text('   By Date   ',style: TextStyle(fontSize: 19),),
        Text('   By Popularity   ',style: TextStyle(fontSize: 19),),
      ],
      isSelected: <bool>[
        fixtureType == FixtureType.date,
        fixtureType == FixtureType.popularity,
      ],
      onPressed: (int index) {
        if (mounted) {
          setState(() {
            fixtureType = index == 0 ? FixtureType.date : FixtureType.popularity;
            widget.onFixtureTypeChanged(fixtureType);
          });
        }
      },
    );
  }
}

class ClubChoice extends StatefulWidget {
  final ValueChanged<ClubType> onClubTypeChanged;

  const ClubChoice({Key? key, required this.onClubTypeChanged})
      : super(key: key);

  @override
  State<ClubChoice> createState() => _ClubChoiceState();
}

class _ClubChoiceState extends State<ClubChoice> {
  ClubType clubType = ClubType.points;

  @override
  Widget build(BuildContext context) {
    return ToggleButtons(
      children: const <Widget>[
        Text('   By Points   ', style: TextStyle(fontSize: 19)),
        Text('   By Goals   ', style: TextStyle(fontSize: 19)),
      ],
      isSelected: <bool>[
        clubType == ClubType.points,
        clubType == ClubType.goals,
      ],
      onPressed: (int index) {
        if (mounted) {
          setState(() {
            clubType = index == 0 ? ClubType.points : ClubType.goals;
            widget.onClubTypeChanged(clubType);
          });
        }
      },
    );
  }
}

class PerformanceChoice extends StatefulWidget {
  final ValueChanged<PerformanceType> onPerformanceTypeChanged;

  const PerformanceChoice({Key? key, required this.onPerformanceTypeChanged})
      : super(key: key);

  @override
  State<PerformanceChoice> createState() => _PerformanceChoiceState();
}

class _PerformanceChoiceState extends State<PerformanceChoice> {
  PerformanceType performanceType = PerformanceType.goals;

  @override
  Widget build(BuildContext context) {
    return ToggleButtons(
      children: const <Widget>[
        Text('   By Goals   ', style: TextStyle(fontSize: 19)),
        Text('   By Assists   ', style: TextStyle(fontSize: 19)),
      ],
      isSelected: <bool>[
        performanceType == PerformanceType.goals,
        performanceType == PerformanceType.assists,
      ],
      onPressed: (int index) {
        if (mounted) {
          setState(() {
            performanceType =
            index == 0 ? PerformanceType.goals : PerformanceType.assists;
            widget.onPerformanceTypeChanged(performanceType);
          });
        }
      },
    );
  }
}
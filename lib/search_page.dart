import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:collection/collection.dart';
import 'package:league_for_enjoy/constant.dart';
import 'package:league_for_enjoy/player_detail_page.dart';
import 'package:league_for_enjoy/referee_detail_page.dart';
import 'package:league_for_enjoy/venue_detail_page.dart';

import 'club_detail_page.dart';
import 'league_detail_page.dart';

class SearchPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Search App',
      home: FutureBuilder<Map<String, dynamic>>(
        future: fetchData('e'),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            return NewSearchPage(apiResponse: snapshot.data!);
          }
        },
      ),
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.green,
      ),
    );
  }
}

class NewSearchPage extends StatefulWidget {
  final Map<String, dynamic> apiResponse;

  const NewSearchPage({Key? key, required this.apiResponse}) : super(key: key);

  @override
  _NewSearchPageState createState() => _NewSearchPageState();
}

class _NewSearchPageState extends State<NewSearchPage> {
  TextEditingController _searchController = TextEditingController();
  List<League> leagues = [];
  List<Club> clubs = [];
  List<Player> players = [];
  List<Referee> referees = [];
  List<Venue> venues = [];

  List<String> selectedFilters = ['Leagues', 'Clubs', 'Players', 'Referees', 'Venues'];
  late Map<String, List<SearchableItem>> groupedItems;
  List<String> groupTitles = [];

  void _filterItems() {
    String query = _searchController.text;
    fetchData(query).then((result) {
      setState(() {
        _parseApiResponse(result);
        _groupItems();
      });
    });
  }

  void _toggleFilter(String filter) {
    setState(() {
      if (selectedFilters.contains(filter)) {
        selectedFilters.remove(filter);
      } else {
        selectedFilters.add(filter);
      }
    });
  }

  void _groupItems() {
    groupedItems = groupBy(
      [
        ...leagues.map((league) => SearchableItem.fromLeague(league)),
        ...clubs.map((club) => SearchableItem.fromClub(club)),
        ...players.map((player) => SearchableItem.fromPlayer(player)),
        ...referees.map((referee) => SearchableItem.fromReferee(referee)),
        ...venues.map((venue) => SearchableItem.fromVenue(venue)),
      ],
          (SearchableItem item) => item.type,
    );

    _updateFilteredList();
  }

  void _updateFilteredList() {
    String query = _searchController.text.toLowerCase();
    if (query.isNotEmpty) {
      List<SearchableItem> filteredList = groupedItems.values
          .expand((list) => list)
          .where((item) =>
      selectedFilters.contains(item.type) &&
          (item.name.toLowerCase().contains(query) ||
              item.description.toLowerCase().contains(query)))
          .toList();

      List<String> filteredTitles = filteredList.map((item) => item.type).toSet().toList();

      groupTitles = filteredTitles;
    } else {
      groupTitles.clear();
    }
  }

  void _parseApiResponse(Map<String, dynamic> result) {
    leagues.clear();
    clubs.clear();
    players.clear();
    referees.clear();
    venues.clear();

    for (var leagueData in result['data']['leagues']) {
      leagues.add(League.fromJson(leagueData));
    }

    for (var clubData in result['data']['clubs']) {
      clubs.add(Club.fromJson(clubData));
    }

    for (var playerData in result['data']['players']) {
      players.add(Player.fromJson(playerData));
    }

    for (var refereeData in result['data']['referees']) {
      referees.add(Referee.fromJson(refereeData));
    }

    for (var venueData in result['data']['venues']) {
      venues.add(Venue.fromJson(venueData));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: <Widget>[
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    labelText: 'Search Items',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: _filterItems,
                child: Text('Search'),
              ),
            ],
          ),
          SizedBox(height: 16.0),
          Wrap(
            spacing: 8.0,
            children: [
              for (String filter in ['Leagues', 'Clubs', 'Players', 'Referees', 'Venues'])
                FilterChip(
                  label: Text(filter),
                  selected: selectedFilters.contains(filter),
                  onSelected: (_) => _toggleFilter(filter),
                ),
            ],
          ),
          SizedBox(height: 16.0),
          Expanded(
            child: ListView.builder(
              itemCount: groupTitles.length,
              itemBuilder: (BuildContext context, int index) {
                String groupTitle = groupTitles[index];
                List<SearchableItem> items = groupedItems[groupTitle] ?? [];

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'SEARCH RESULTS FOR $groupTitle',
                        style: TextStyle(fontWeight: FontWeight.bold,color: Colors.black,fontFamily: GoogleFonts.acme().fontFamily,),
                      ),
                    ),
                    for (SearchableItem item in items)
                      GestureDetector(
                        onTap: () {
                          _navigateToDetailPage(context, item);
                          print('Item Id: ${item.id}');
                        },
                        child: Card(
                          child: ListTile(
                            leading: Image.network(item.logoPath),
                            title: Text(item.name),
                            subtitle: Text('Description: ${item.description}'),
                            trailing: IconButton(
                              icon: Icon(Icons.arrow_right_sharp),
                              onPressed: () {
                                _navigateToDetailPage(context, item);
                              },
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Function to navigate to the detail page based on the item type
  void _navigateToDetailPage(BuildContext context, SearchableItem item) {
    switch (item.type) {
      case 'Leagues':
      // Navigate to LeagueDetailPage with the leagueId
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LeagueDetailPage(leagueId: item.id),
          ),
        );
        break;
      case 'Clubs':
      // Navigate to ClubDetailPage with the clubId
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ClubDetailPage(clubId: item.id),
          ),
        );
        break;
      case 'Venues':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VenueDetailPage(venueId: item.id),
          ),
        );
        break;
      case 'Referees':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RefereeDetailPage(refereeId: item.id),
          ),
        );
        break;
      case 'Players':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PlayerDetailPage(playerId: item.id),
          ),
        );
        break;

    // Add cases for other types (Players, Referees, Venues) similarly
      default:
        print('Unknown type: ${item.type}');
        break;
    }
  }
}

class SearchableItem {
  final String type;
  final int id; // Add an id field
  final String name;
  final String description;
  final String logoPath;

  SearchableItem({
    required this.type,
    required this.id,
    required this.name,
    required this.description,
    required this.logoPath,
  });

  factory SearchableItem.fromLeague(League league) {
    return SearchableItem(
      type: 'Leagues',
      id: league.leagueId,
      name: league.name,
      description: league.description,
      logoPath: league.logoPath,
    );
  }

  factory SearchableItem.fromClub(Club club) {
    return SearchableItem(
      type: 'Clubs',
      id: club.clubId,
      name: club.name,
      description: club.description,
      logoPath: club.logoPath,
    );
  }

  factory SearchableItem.fromPlayer(Player player) {
    return SearchableItem(
      type: 'Players',
      id: player.playerId,
      name: player.fullName,
      description: player.biography,
      logoPath: player.imgPath,
    );
  }

  factory SearchableItem.fromReferee(Referee referee) {
    return SearchableItem(
      type: 'Referees',
      id: referee.refereeId,
      name: referee.fullName,
      description: 'License Type: ${referee.licenseType}',
      logoPath: referee.imgPath,
    );
  }

  factory SearchableItem.fromVenue(Venue venue) {
    return SearchableItem(
      type: 'Venues',
      id: venue.venueId,
      name: venue.name,
      description: 'Capacity: ${venue.capacity}',
      logoPath: venue.imgPath,
    );
  }
}

class League {
  final int leagueId;
  final String name;
  final String state;
  final int prize;
  final String email;
  final String description;
  final String logoPath;

  League({
    required this.leagueId,
    required this.name,
    required this.state,
    required this.prize,
    required this.email,
    required this.description,
    required this.logoPath,
  });

  factory League.fromJson(Map<String, dynamic> json) {
    return League(
      leagueId: json['leagueId'],
      name: json['name'],
      state: json['state'],
      prize: json['prize'],
      email: json['email'],
      description: json['description'],
      logoPath: json['logoPath'],
    );
  }
}

class Club {
  final int clubId;
  final String name;
  final String state;
  final int playerCount;
  final int cupCount;
  final String email;
  final String description;
  final String logoPath;

  Club({
    required this.clubId,
    required this.name,
    required this.state,
    required this.playerCount,
    required this.cupCount,
    required this.email,
    required this.description,
    required this.logoPath,
  });

  factory Club.fromJson(Map<String, dynamic> json) {
    return Club(
      clubId: json['clubId'],
      name: json['name'],
      state: json['state'],
      playerCount: json['playerCount'],
      cupCount: json['cupCount'],
      email: json['email'],
      description: json['description'],
      logoPath: json['logoPath'],
    );
  }
}

class Player {
  final int playerId;
  final String? clubName;
  final String fullName;
  final String state;
  final int age;
  final int goals;
  final int assists;
  final String email;
  final String biography;
  final String imgPath;

  Player({
    required this.playerId,
    required this.clubName,
    required this.fullName,
    required this.state,
    required this.age,
    required this.goals,
    required this.assists,
    required this.email,
    required this.biography,
    required this.imgPath,
  });

  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(
      playerId: json['playerId'],
      clubName: json['clubName'],
      fullName: json['fullName'],
      state: json['state'],
      age: json['age'],
      goals: json['goals'],
      assists: json['assists'],
      email: json['email'],
      biography: json['biography'],
      imgPath: json['imgPath'],
    );
  }
}

class Referee {
  final int refereeId;
  final String fullName;
  final int age;
  final String licenseType;
  final String email;
  final String imgPath;

  Referee({
    required this.refereeId,
    required this.fullName,
    required this.age,
    required this.licenseType,
    required this.email,
    required this.imgPath,
  });

  factory Referee.fromJson(Map<String, dynamic> json) {
    return Referee(
      refereeId: json['refereeId'],
      fullName: json['fullName'],
      age: json['age'],
      licenseType: json['licenseType'],
      email: json['email'],
      imgPath: json['imgPath'],
    );
  }
}

class Venue {
  final int venueId;
  final String name;
  final int capacity;
  final int capacityRank;
  final String email;
  final String address;
  final String imgPath;

  Venue({
    required this.venueId,
    required this.name,
    required this.capacity,
    required this.capacityRank,
    required this.email,
    required this.address,
    required this.imgPath,
  });

  factory Venue.fromJson(Map<String, dynamic> json) {
    return Venue(
      venueId: json['venueId'],
      name: json['name'],
      capacity: json['capacity'],
      capacityRank: json['capacityRank'],
      email: json['email'],
      address: json['address'],
      imgPath: json['imgPath'],
    );
  }
}

Future<Map<String, dynamic>> fetchData(String searchQuery) async {
  final apiUrl = '${apiBase}/api/search?q=$searchQuery';
  print('API URL: $apiUrl');
  final response = await http.get(Uri.parse(apiUrl));

  if (response.statusCode == 200 || response.statusCode==201) {
    return json.decode(response.body);
  } else {
    print('HTTP Error: ${response.statusCode}');
    print('Response Body: ${response.body}');
    throw Exception('Failed to load data');
  }
}

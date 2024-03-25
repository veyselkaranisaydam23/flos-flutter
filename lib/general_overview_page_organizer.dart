import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:league_for_enjoy/club_detail_page.dart';
import 'package:league_for_enjoy/league_detail_page.dart';
import 'package:league_for_enjoy/my_fixtures.dart';
import 'package:league_for_enjoy/my_leagues.dart';
import 'package:league_for_enjoy/search_page.dart';

import 'choices.dart';
import 'customListTiles.dart';

void main() {
  runApp(const GeneralOverviewPageOrganizer());
}

class GeneralOverviewPageOrganizer extends StatelessWidget {
  const GeneralOverviewPageOrganizer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.green,
        fontFamily: GoogleFonts.roboto().fontFamily,
      ),
      home: const NavigationExample(),
    );
  }
}

class NavigationExample extends StatefulWidget {
  const NavigationExample({Key? key}) : super(key: key);

  @override
  State<NavigationExample> createState() => _NavigationExampleState();
}

enum ListType { prize, teamCount }
enum FixtureType { date, popularity }
enum ClubType { points, goals }
enum PerformanceType { goals, assists }

class _NavigationExampleState extends State<NavigationExample> {
  int currentPageIndex = 0;
  ListType listType = ListType.prize;
  FixtureType fixtureType = FixtureType.date;
  ClubType clubType = ClubType.points;
  PerformanceType performanceType = PerformanceType.goals;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'FLOS',
          style: TextStyle(
            fontFamily: GoogleFonts.audiowide().fontFamily,
            fontSize: 45,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.person, size: 45,),
            onPressed: () {
              // Add your button action here
            },
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        indicatorColor: Colors.green,
        selectedIndex: currentPageIndex,
        destinations: const <Widget>[
          NavigationDestination(
            selectedIcon: Icon(Icons.travel_explore),
            icon: Icon(Icons.travel_explore_outlined),
            label: 'Explore',
          ),
          NavigationDestination(
            icon: Badge(child: Icon(Icons.search_sharp)),
            label: 'Search',
          ),
          NavigationDestination(
            icon: Badge(
              child: Icon(Icons.sports_soccer_sharp),
            ),
            label: 'Leagues',
          ),
          NavigationDestination(
            icon: Badge(
              child: Icon(Icons.calendar_month_sharp),
            ),
            label: 'Fixtures',
          ),
        ],
      ),
      body: <Widget>[
        /// Explore page
        Card(
          shadowColor: Colors.transparent,
          margin: const EdgeInsets.all(8.0),
          child: SizedBox.expand(
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 50,),

                    // Slidable Image Gallery
                    Container(
                      color: Colors.white,
                      height: 230,
                      child: SlidableImageGallery(),
                    ),

                    // Short Container with Text and Button
                    Container(
                      color: Colors.white,
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              const Text('TOP LEAGUES', style: TextStyle(fontSize: 25),),
                              Spacer(),
                              IconButton(
                                onPressed: () {
                                  // Button Action
                                },
                                icon: const Icon(Icons.arrow_circle_right_outlined, size: 35,),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Segmented Buttons for Prize and Team Count
                    Container(
                      color: Colors.white,
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildListSegmentedButtons(),
                        ],
                      ),
                    ),


                    Container(
                      child: _buildLeagueContent(), // Use ListView.builder if your content is dynamic
                    ),

                    Container(
                      color: Colors.white,
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              const Text('TOP FIXTURES', style: TextStyle(fontSize: 25),),
                              Spacer(),
                              IconButton(
                                onPressed: () {
                                  // Button Action
                                },
                                icon: const Icon(Icons.arrow_circle_right_outlined, size: 35,),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    Container(
                      color: Colors.white,
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildFixtureSegmentedButtons(),
                        ],
                      ),
                    ),

                    Container(
                      child: _buildFixtureContent(), // Use ListView.builder if your content is dynamic
                    ),

                    Container(
                      color: Colors.white,
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              const Text('TOP CLUBS', style: TextStyle(fontSize: 25),),
                              Spacer(),
                              IconButton(
                                onPressed: () {
                                  // Button Action
                                },
                                icon: const Icon(Icons.arrow_circle_right_outlined, size: 35,),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Segmented Buttons for Prize and Team Count
                    Container(
                      color: Colors.white,
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildClubSegmentedButtons(),
                        ],
                      ),
                    ),


                    Container(
                      child: _buildClubContent(), // Use ListView.builder if your content is dynamic
                    ),

                    Container(
                      color: Colors.white,
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              const Text('TOP PERFORMANCES', style: TextStyle(fontSize: 25,),),
                              Spacer(),

                            ],
                          ),
                        ],
                      ),
                    ),

                    // Segmented Buttons for Prize and Team Count
                    Container(
                      color: Colors.white,
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildPerformanceSegmentedButtons(),
                        ],
                      ),
                    ),


                    Container(
                      child: _buildPerformancesContent(), // Use ListView.builder if your content is dynamic
                    ),

                  ],
                ),
              ),
            ),
          ),
        ),

        /// Search page
        SearchPage(),
        /// League page
        MyLeagues(),
        /// Fixture page
        MyFixtures(),
      ][currentPageIndex],
    );
  }

  Widget _buildListSegmentedButtons() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(9.0),
      child: ListChoice(
        onListTypeChanged: (type) {
          if (mounted) {
            setState(() {
              listType = type;
            });
          }
        },
      ),
    );
  }

  Widget _buildFixtureSegmentedButtons() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(9.0),
      child: FixtureChoice(
        onFixtureTypeChanged: (type) {
          if (mounted) {
            setState(() {
              fixtureType = type;
            });
          }
        },
      ),
    );
  }

  Widget _buildClubSegmentedButtons() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(9.0),
      child: ClubChoice(
        onClubTypeChanged: (type) {
          if (mounted) {
            setState(() {
              clubType = type;
            });
          }
        },
      ),
    );
  }

  Widget _buildPerformanceSegmentedButtons() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(9.0),
      child: PerformanceChoice(
        onPerformanceTypeChanged: (type) {
          if (mounted) {
            setState(() {
              performanceType = type;
            });
          }
        },
      ),
    );
  }

  Widget _buildLeagueContent() {
    switch (listType) {
      case ListType.prize:
        return _buildPrizeContent();
      case ListType.teamCount:
        return _buildTeamCountContent();
      default:
        return Container(); // You can return a default widget or an empty container
    }
  }

  Widget _buildPrizeContent() {
    return SingleChildScrollView(
      child: Column(
        children: [
          CustomListTileWithLeagues(
            photo: AssetImage('photos/ts_lig.jpg'),
            title: 'In Progress',
            subtitle: 'Trendyol Super Lig',
            additionalText: '32.000.000',
            onPressed: () {
              // Your button onPressed action
            },
          ),
          CustomListTileWithLeagues(
            photo: AssetImage('photos/t1_lig.png'),
            title: 'Not Started',
            subtitle: 'Trendyol 1. Lig',
            additionalText: '20.000.000',
            onPressed: () {
              // Your button onPressed action
            },
          ),
          CustomListTileWithLeagues(
            photo: AssetImage('photos/TFF2.jpg'),
            title: 'In Progress',
            subtitle: 'Tff 2. Lig',
            additionalText: '15.000.000',
            onPressed: () {
              // Your button onPressed action
            },
          ),
          CustomListTileWithLeagues(
            photo: AssetImage('photos/TFF3Lig.png'),
            title: 'Not Started',
            subtitle: 'Tff 3. Lig',
            additionalText: '10.000.000',
            onPressed: () {
              // Your button onPressed action
            },
          ),
          CustomListTileWithLeagues(
            photo: AssetImage('photos/U12_izmir.jpg'),
            title: 'Not Started',
            subtitle: 'İzmir U12 Lig',
            additionalText: '2.000.000',
            onPressed: () {
              // Your button onPressed action
            },
          ),


        ],
      ),
    );
  }

  Widget _buildTeamCountContent() {
    return SingleChildScrollView(
      child: Column(
        children: [
          CustomListTileWithLeagues(
            photo: AssetImage('photos/t1_lig.png'),
            title: 'Not Started',
            subtitle: 'Trendyol 1. Lig',
            additionalText: '30 Teams',
            onPressed: () {
              // Your button onPressed action
            },
          ),
          // Add new items here
          CustomListTileWithLeagues(
            photo: AssetImage('photos/TFF2.jpg'),
            title: 'In Progress',
            subtitle: 'Tff 2. Lig',
            additionalText: '25 Teams',
            onPressed: () {
              // Your button onPressed action
            },
          ),

          CustomListTileWithLeagues(
            photo: AssetImage('photos/TFF3Lig.png'),
            title: 'Not Started',
            subtitle: 'Tff 3. Lig',
            additionalText: '22 Teams',
            onPressed: () {

            },
          ),

          CustomListTileWithLeagues(
            photo: AssetImage('photos/U12_izmir.jpg'),
            title: 'Not Started',
            subtitle: 'İzmir U12 Lig',
            additionalText: '20 Teams',
            onPressed: () {
              // Your button onPressed action
            },
          ),
          CustomListTileWithLeagues(
            photo: AssetImage('photos/ts_lig.jpg'),
            title: 'In Progress',
            subtitle: 'Trendyol Super Lig',
            additionalText: '18 Teams',
            onPressed: () {
              // Your button onPressed action
            },
          ),

        ],
      ),
    );
  }


  Widget _buildFixtureContent() {
    switch (fixtureType) {
      case FixtureType.date:
        return _buildDateFixtureContent();
      case FixtureType.popularity:
        return _buildPopularityFixtureContent();
      default:
        return Container(); // You can return a default widget or an empty container
    }
  }

  Widget _buildDateFixtureContent() {
    return SingleChildScrollView(
      child: Column(
        children: [
          CustomListTileWithScores(
            photo1: AssetImage('photos/fb_logo.png'),
            team1: 'Fenerbahçe',
            subtitle1: '1st Place',
            score1: 2,
            score2: 1,
            team2: 'Galatasaray',
            subtitle2: '3rd Place',
            photo2: AssetImage('photos/gs_logo.png'),
          ),
          CustomListTileWithScores(
            photo1: AssetImage('photos/bjk_logo.png'),
            team1: 'Beşiktaş',
            subtitle1: '2nd Place',
            score1: 0,
            score2: 3,
            team2: 'Trabzonspor',
            subtitle2: '4th Place',
            photo2: AssetImage('photos/ts_logo.png'),
          ),
          // Add new items here

          CustomListTileWithScores(
            photo1: AssetImage('photos/ahlat_logo.jpeg'),
            team1: 'Ahlatspor',
            subtitle1: '7th Place',
            score1: 3,
            score2: 2,
            team2: 'Siirtspor',
            subtitle2: '8th Place',
            photo2: AssetImage('photos/siirtspor_logo.png'),
          ),

          CustomListTileWithScores(
            photo1: AssetImage('photos/elazigspor_logo.png'),
            team1: 'Elazığspor',
            subtitle1: '5th Place',
            score1: 1,
            score2: 1,
            team2: 'Sivasspor',
            subtitle2: '6th Place',
            photo2: AssetImage('photos/sivasspor_logo.png'),
          ),

          CustomListTileWithScores(
            photo1: AssetImage('photos/bursaspor_logo.png'),
            team1: 'Bursaspor',
            subtitle1: '9th Place',
            score1: 2,
            score2: 0,
            team2: 'Gaziantepspor',
            subtitle2: '10th Place',
            photo2: AssetImage('photos/gaziantep_logo.png'),
          ),
        ],
      ),
    );
  }

  Widget _buildPopularityFixtureContent() {
    return SingleChildScrollView(
      child: Column(
        children: [
          CustomListTileWithScores(
            photo1: AssetImage('photos/bjk_logo.png'),
            team1: 'Beşiktaş',
            subtitle1: '2nd Place',
            score1: 0,
            score2: 3,
            team2: 'Trabzonspor',
            subtitle2: '4th Place',
            photo2: AssetImage('photos/ts_logo.png'),
          ),
          CustomListTileWithScores(
            photo1: AssetImage('photos/fb_logo.png'),
            team1: 'Fenerbahçe',
            subtitle1: '1st Place',
            score1: 2,
            score2: 1,
            team2: 'Galatasaray',
            subtitle2: '3rd Place',
            photo2: AssetImage('photos/gs_logo.png'),
          ),
          // Add new items here
          CustomListTileWithScores(
            photo1: AssetImage('photos/bursaspor_logo.png'),
            team1: 'Bursaspor',
            subtitle1: '9th Place',
            score1: 2,
            score2: 0,
            team2: 'Gaziantepspor',
            subtitle2: '10th Place',
            photo2: AssetImage('photos/gaziantep_logo.png'),
          ),
          CustomListTileWithScores(
            photo1: AssetImage('photos/ahlat_logo.jpeg'),
            team1: 'Ahlatspor',
            subtitle1: '7th Place',
            score1: 3,
            score2: 2,
            team2: 'Siirtspor',
            subtitle2: '8th Place',
            photo2: AssetImage('photos/siirtspor_logo.png'),
          ),
          CustomListTileWithScores(
            photo1: AssetImage('photos/elazigspor_logo.png'),
            team1: 'Elazığspor',
            subtitle1: '5th Place',
            score1: 1,
            score2: 1,
            team2: 'Sivasspor',
            subtitle2: '6th Place',
            photo2: AssetImage('photos/sivasspor_logo.png'),
          ),
        ],
      ),
    );
  }



  Widget _buildClubContent() {
    switch (clubType) {
      case ClubType.points:
        return _buildPointsClubContent();
      case ClubType.goals:
        return _buildGoalsClubContent();
      default:
        return Container(); // You can return a default widget or an empty container
    }
  }

  Widget _buildPointsClubContent() {
    return SingleChildScrollView(
      child: Column(
        children: [
          CustomListTileWithLeagues(
            photo: AssetImage('photos/fb_logo.png'),
            title: 'Fenerbahçe',
            subtitle: '1st Place',
            additionalText: '50 Points',
            onPressed: () {
              // Your button onPressed action
            },
          ),
          CustomListTileWithLeagues(
            photo: AssetImage('photos/gs_logo.png'),
            title: 'Galatasaray',
            subtitle: '2nd Place',
            additionalText: '48 Points',
            onPressed: () {
              // Your button onPressed action
            },
          ),
          CustomListTileWithLeagues(
            photo: AssetImage('photos/bjk_logo.png'),
            title: 'Beşiktaş',
            subtitle: '3rd Place',
            additionalText: '43 Points',
            onPressed: () {
              // Your button onPressed action
            },
          ),
          CustomListTileWithLeagues(
            photo: AssetImage('photos/ts_logo.png'),
            title: 'Trabzonspor',
            subtitle: '4th Place',
            additionalText: '40 Points',
            onPressed: () {
              // Your button onPressed action
            },
          ),
          CustomListTileWithLeagues(
            photo: AssetImage('photos/elazigspor_logo.png'),
            title: 'Elazığspor',
            subtitle: '5th Place',
            additionalText: '38 Points',
            onPressed: () {
              // Your button onPressed action
            },
          ),


        ],
      ),
    );
  }

  Widget _buildGoalsClubContent() {
    return SingleChildScrollView(
      child: Column(
        children: [
          CustomListTileWithLeagues(
            photo: AssetImage('photos/gs_logo.png'),
            title: 'Galatasaray',
            subtitle: '2nd Place',
            additionalText: '50 Goals',
            onPressed: () {
              // Your button onPressed action
            },
          ),
          CustomListTileWithLeagues(
            photo: AssetImage('photos/fb_logo.png'),
            title: 'Fenerbahçe',
            subtitle: '1st Place',
            additionalText: '48 Goals',
            onPressed: () {
              // Your button onPressed action
            },
          ),
          // Add new items here
          CustomListTileWithLeagues(
            photo: AssetImage('photos/ts_logo.png'),
            title: 'Trabzonspor',
            subtitle: '4th Place',
            additionalText: '32 Goals',
            onPressed: () {
              // Your button onPressed action
            },
          ),
          CustomListTileWithLeagues(
            photo: AssetImage('photos/bjk_logo.png'),
            title: 'Beşiktaş',
            subtitle: '3rd Place',
            additionalText: '29 Goals',
            onPressed: () {
              // Your button onPressed action
            },
          ),
          CustomListTileWithLeagues(
            photo: AssetImage('photos/sivasspor_logo.png'),
            title: 'Sivasspor',
            subtitle: '6th Place',
            additionalText: '26 Goals',
            onPressed: () {
              // Your button onPressed action
            },
          ),
        ],
      ),
    );
  }


  Widget _buildPerformancesContent() {
    switch (performanceType) {
      case PerformanceType.goals:
        return _buildGoalsPerformancesContent();
      case PerformanceType.assists:
        return _buildAssistsPerformancesContent();
      default:
        return Container(); // You can return a default widget or an empty container
    }
  }

  Widget _buildGoalsPerformancesContent() {
    return SingleChildScrollView(
      child: Column(
        children: [
          CustomListTileWithLeagues(
            photo: NetworkImage('https://i.goalzz.com/?i=o%2fp%2f160%2f843%2femirhan-cakir-1.png'),
            title: 'Emirhan Çakır',
            subtitle: 'Pazarspor FK',
            additionalText: '30 Goals',
            onPressed: () {
              // Your button onPressed action
            },
          ),
          CustomListTileWithLeagues(
            photo: NetworkImage('https://i.goalzz.com/?i=o%2fp%2f137%2f228%2fabdulkadir-omur-1.png'),
            title: 'Abdulkadir Ömür',
            subtitle: 'Trabzon Kanuni FK',
            additionalText: '25 Goals',
            onPressed: () {
              // Your button onPressed action
            },
          ),
          // Add new items here
          CustomListTileWithLeagues(
            photo: NetworkImage('https://i.goalzz.com/?i=o%2fp%2f162%2f358%2firfan-basaran-1.jpg'),
            title: 'İrfan Başaran',
            subtitle: 'Pazarspor FK',
            additionalText: '20 Goals',
            onPressed: () {
              // Your button onPressed action
            },
          ),
          CustomListTileWithLeagues(
            photo: NetworkImage('https://i.goalzz.com/?i=o%2fp%2f160%2f254%2fali-eren-iyican-1.png'),
            title: 'Ali Eren İyican',
            subtitle: 'Araklıspor',
            additionalText: '15 Goals',
            onPressed: () {
              // Your button onPressed action
            },
          ),
          CustomListTileWithLeagues(
            photo: NetworkImage('https://i.goalzz.com/?i=o%2fp%2f148%2f653%2fmert-cetin-1.png'),
            title: 'Mert Çetin',
            subtitle: 'Galatasaray UA',
            additionalText: '10 Goals',
            onPressed: () {
              // Your button onPressed action
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAssistsPerformancesContent() {
    return SingleChildScrollView(
      child: Column(
        children: [
          CustomListTileWithLeagues(
            photo: NetworkImage('https://i.goalzz.com/?i=o%2fp%2f90%2f351%2fabdulkadir-kayali-1.png'),
            title: 'Abdulkadir Kayalı',
            subtitle: 'Aydınspor FK',
            additionalText: '15 Assists',
            onPressed: () {
              // Your button onPressed action
            },
          ),
          CustomListTileWithLeagues(
            photo: NetworkImage('https://i.goalzz.com/?i=o%2fp%2f90%2f810%2fsalih-ucan-1.png'),
            title: 'Salih Uçan',
            subtitle: 'Bağcılar SK',
            additionalText: '12 Assists',
            onPressed: () {
              // Your button onPressed action
            },
          ),
          // Add new items here
          CustomListTileWithLeagues(
            photo: NetworkImage('https://i.goalzz.com/?i=o%2fp%2f160%2f88%2fahmet-hakan-demirli-1.png'),
            title: 'Ahmet Demirli',
            subtitle: 'Çayırova Spor',
            additionalText: '10 Assists',
            onPressed: () {
              // Your button onPressed action
            },
          ),
          CustomListTileWithLeagues(
            photo: NetworkImage('https://i.goalzz.com/?i=o%2fp%2f173%2f326%2fburak-yilmaz-1.png'),
            title: 'Burak Yılmaz',
            subtitle: 'Ödemişspor FK',
            additionalText: '8 Assists',
            onPressed: () {
              // Your button onPressed action
            },
          ),
          CustomListTileWithLeagues(
            photo: NetworkImage('https://i.goalzz.com/?i=teams%2fgermany%2fdortmund%2femre_mor.jpg'),
            title: 'Emre Mor',
            subtitle: 'Soma Spor FK',
            additionalText: '5 Assists',
            onPressed: () {
              // Your button onPressed action
            },
          ),
        ],
      ),
    );
  }


}

class SlidableImageGallery extends StatelessWidget {
  final List<String> assetPaths = [
    'photos/1.jpg',
    'photos/2.jpg',
    'photos/3.jpg',
    // Add more asset paths as needed
  ];

  final List<String> imageDescriptions = [
    'Computer engineering came first in the group in the university league',
    'New league excitement in Cemil Şeboy',
    'Critical words about the match from the famous football commentator',
    // Add more descriptions as needed
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CarouselSlider(
          options: CarouselOptions(
            height: 200.0, // Adjust height as needed
            enlargeCenterPage: true,
            autoPlay: true,
          ),
          items: assetPaths.asMap().entries.map((entry) {
            final int index = entry.key;
            final String assetPath = entry.value;
            final String description = imageDescriptions[index];

            return Builder(
              builder: (BuildContext context) {
                return Container(
                  width: MediaQuery.of(context).size.width,
                  margin: EdgeInsets.symmetric(horizontal: 5.0),
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.asset(
                        assetPath,
                        fit: BoxFit.cover,
                        alignment: Alignment.center,
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          padding: EdgeInsets.all(8.0),
                          color: Colors.black.withOpacity(0.5),
                          child: Text(
                            description,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16.0,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          }).toList(),
        ),
        SizedBox(height: 10),
      ],
    );
  }
}
import 'package:flutter/material.dart';

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:league_for_enjoy/constant.dart';
import 'package:league_for_enjoy/edit_my_league.dart';
import 'package:league_for_enjoy/search_page.dart';
import 'package:league_for_enjoy/show_dialog.dart';
import 'package:league_for_enjoy/token_service.dart';


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

class MyLeagues extends StatefulWidget {
  @override
  _MyLeaguesState createState() => _MyLeaguesState();
}

class _MyLeaguesState extends State<MyLeagues> {
  late List<League> leagues = []; // Initialize with an empty list
  final TokenService _tokenService = TokenService(); // Declare and initialize _authService

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      final token = await _tokenService.getToken();
      print(token);
      final headers = {'Authorization': 'Bearer $token'};
      final response = await http.get(
        Uri.parse('${apiBase}/api/my/leagues'),
        headers: headers,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final List<dynamic> data = json.decode(response.body)['data'];
        setState(() {
          leagues = data.map((item) => League.fromJson(item)).toList();
        });
        print(data);
      } else {
        final Map<String, dynamic> responseData = json.decode(response.body);
        print("false ${responseData['httpStatus']['message']}");
        print(response.statusCode);
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
  }


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.green,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text("My Leagues"),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            _showAddLeagueDialog(context);
          },
          child: Icon(Icons.add),
        ),
        body: leagues != null
            ? ListView.builder(
          itemCount: leagues.length,
          itemBuilder: (BuildContext context, int index) {
            League league = leagues[index];
            Color backgroundColor;

            switch (league.state.toLowerCase()) {
              case 'not started':
                backgroundColor = Colors.grey;
                break;
              case 'in progress':
                backgroundColor = Colors.green;
                break;
              case 'finished':
                backgroundColor = Colors.red;
                break;
              default:
                backgroundColor = Colors.white;
                break;
            }

            return Container(
              color: backgroundColor,
              padding: EdgeInsets.all(8.0),
              child: ListTile(
                leading: Image.network(league.logoPath),
                title: Text(league.name),
                subtitle: Text("Prize: ${league.prize}"),
                trailing: PopupMenuButton<String>(
                  itemBuilder: (BuildContext context) =>
                      ['Delete', 'Edit', 'Info','Start']
                          .map((String choice) =>
                          PopupMenuItem<String>(
                            value: choice,
                            enabled: choice != 'Edit' ||
                                (league.state.toLowerCase() != 'in progress' && league.state.toLowerCase() != 'finished'),
                            child: Text(choice),
                          ))
                          .toList(),
                  onSelected: (String choice) {
                    if (choice == 'Edit') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => EditMyLeaguePage(leagueId: league.leagueId,)),
                      );
                    }

                    if (choice == 'Start') {
                      startLeague(league.leagueId);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => MyLeagues()),
                      );
                    }

                    if(choice == 'Delete' && league.state.toLowerCase() == 'not started')
                      {
                        deleteLeague(league.leagueId);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => MyLeagues()),
                        );
                      }

                  },
                ),

              ),
            );
          },
        )
            : Center(child: CircularProgressIndicator()),
      ),
    );
  }

  Future<void> startLeague(int leagueId) async {
    try {
      final String apiUrl = '${apiBase}/api/my/leagues/${leagueId}/start'; // Replace with your API endpoint
      final token = await _tokenService.getToken();
      final http.Response response = await http.put(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Handle successful update
        print('League Generated successfully');
      } else {
        print('Failed to update data. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      // Handle exceptions
      print('Error during update: $e');
    }
  }

  Future<void> deleteLeague(int leagueId) async {
    try {
      final String apiUrl = '${apiBase}/api/my/leagues/${leagueId}'; // Replace with your API endpoint
      final token = await _tokenService.getToken();
      final http.Response response = await http.delete(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        // Handle successful update
        print('League Generated successfully');
      } else {
        print('Failed to update data. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      // Handle exceptions
      print('Error during update: $e');
    }
  }


  void _showAddLeagueDialog(BuildContext context) {
    TextEditingController nameController = TextEditingController();
    TextEditingController prizeController = TextEditingController();
    TextEditingController descriptionController = TextEditingController();
    int selectedPhotoIndex = 0; // Initial selection

    List<String> photoOptions = [
      "https://upload.wikimedia.org/wikipedia/commons/thumb/4/4f/S%C3%BCper_Lig_logo.svg/2160px-S%C3%BCper_Lig_logo.svg.png",
      "https://upload.wikimedia.org/wikipedia/tr/archive/e/ec/20160909224558%21TFF_1.Lig_logo.png",
      "https://upload.wikimedia.org/wikipedia/tr/archive/7/73/20190926214849%21BAL_Logo.jpg",
      "https://www.tff.org/Resources/TFF/Auto/17e9e30b8160462a86cc3dd890514cea.jpg",
      "https://upload.wikimedia.org/wikipedia/tr/archive/4/47/20200909222954%21TFF3_kopya.png",
    ];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text("Add New League"),
              content: Column(
                children: [
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(labelText: "Name"),
                  ),
                  TextField(
                    controller: prizeController,
                    decoration: InputDecoration(labelText: "Prize"),
                  ),
                  TextField(
                    controller: descriptionController,
                    decoration: InputDecoration(labelText: "Description"),
                  ),
                  DropdownButton<int>(
                    value: selectedPhotoIndex,
                    hint: Text("Select a Photo"),
                    onChanged: (int? index) {
                      if (index != null) {
                        setState(() {
                          selectedPhotoIndex = index;
                        });
                      }
                    },
                    items: photoOptions.asMap().entries.map((MapEntry<int, String> entry) {
                      return DropdownMenuItem<int>(
                        value: entry.key,
                        child: Image.network(
                          entry.value,
                          width: 100,
                          height: 100,
                        ),
                      );
                    }).toList(),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          final String name = nameController.text;
                          final int prize = int.tryParse(prizeController.text) ?? 0;
                          final String description = descriptionController.text;
                          final String logoPath = photoOptions[selectedPhotoIndex];
                          final token = await _tokenService.getToken();

                          try {
                            Map<String, String> headers = {
                              "Content-Type": "application/json",
                              'Authorization': 'Bearer $token'
                            };

                            String jsonData = jsonEncode({
                              "name": name,
                              "prize": prize,
                              "description": description,
                              "logoPath": logoPath,
                            });

                            final response = await http.post(
                              Uri.parse('${apiBase}/api/my/leagues'),
                              headers: headers,
                              body: jsonData,
                            );

                            if (response.statusCode == 201 || response.statusCode == 200) {
                              Navigator.of(context).pop();
                              ShowDialog.showResponseDialog(context, response.statusCode, 'Sign up successful', []);
                              fetchData();
                            } else {
                              final Map<String, dynamic> responseData = json.decode(response.body);
                              ShowDialog.showResponseDialog(context,response.statusCode, responseData['httpStatus']['message'], responseData['clientErrors']);
                              print(response.statusCode);
                            }
                          } catch (e) {
                            print('Error sending data to API: $e');
                          }
                        },
                        child: Text("OK"),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text("BACK"),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

}
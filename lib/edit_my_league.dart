import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:league_for_enjoy/my_leagues.dart';
import 'package:league_for_enjoy/show_dialog.dart';
import 'package:league_for_enjoy/token_service.dart';

import 'constant.dart';

class EditMyLeaguePage extends StatefulWidget {
  final int? leagueId;

  const EditMyLeaguePage({Key? key, required this.leagueId}) : super(key: key);

  @override
  _EditMyLeaguePageState createState() => _EditMyLeaguePageState();
}

class _EditMyLeaguePageState extends State<EditMyLeaguePage> {
  final TokenService _tokenService = TokenService();
  List<dynamic> clubs = [];
  late String? name = '';
  late int? prize = 0;
  late String? state = '';
  late String? email = '';
  late String? description = '';
  late String? photo = '';
  late List<dynamic> availableClubsData = [];

  Future fetchAvailableClubs() async {
    final response = await http.get(Uri.parse('${apiBase}/api/available/clubs'));

    if (response.statusCode == 200 || response.statusCode == 201) {
      final Map<String, dynamic> data = json.decode(response.body);
      setState(() {
        availableClubsData = List<Map<String, dynamic>>.from(data['data'] ?? []);
      });
    } else {
      final Map<String, dynamic> responseData = json.decode(response.body);
      ShowDialog.showResponseDialog(
        context,
        response.statusCode,
        responseData['httpStatus']['message'],
        responseData['clientErrors'],
      );
    }
  }

  Future fetchLeagueClubs() async {
    final token = await _tokenService.getToken();
    final headers = {'Authorization': 'Bearer $token'};
    final response = await http.get(
      Uri.parse('${apiBase}/api/my/leagues/${widget.leagueId}/clubs'),
      headers: headers,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final Map<String, dynamic> data = json.decode(response.body);

      setState(() {
        clubs = data['clubs'];
      });
    } else {
      final Map<String, dynamic> responseData = json.decode(response.body);
      ShowDialog.showResponseDialog(
        context,
        response.statusCode,
        responseData['httpStatus']['message'],
        responseData['clientErrors'],
      );
    }
  }

  Future addClubToLeague(int? clubId) async {
    final token = await _tokenService.getToken();

    try {
      Map<String, String> headers = {
        "Content-Type": "application/json",
        'Authorization': 'Bearer $token'
      };

      String jsonData = jsonEncode({
        "clubId": clubId,
      });

      final response = await http.post(
        Uri.parse('${apiBase}/api/my/leagues/${widget.leagueId}/clubs'),
        headers: headers,
        body: jsonData,
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        Navigator.of(context).pop();
        ShowDialog.showResponseDialog(context, response.statusCode, 'Sign up successful', []);
        fetchLeagueClubs();
      } else {
        final Map<String, dynamic> responseData = json.decode(response.body);
        ShowDialog.showResponseDialog(
          context,
          response.statusCode,
          responseData['httpStatus']['message'],
          responseData['clientErrors'],
        );
        print(response.statusCode);
      }
    } catch (e) {
      print('Error sending data to API: $e');
    }
  }

  Future fetchData() async {
    print(widget.leagueId);
    final response = await http.get(Uri.parse('${apiBase}/api/leagues/${widget.leagueId}'));

    if (response.statusCode == 200 || response.statusCode == 201) {
      final Map<String, dynamic> data = json.decode(response.body);

      final Map<String, dynamic> leagueData = data['data'];
      setState(() {
        name = leagueData['name'];
        description = leagueData['description'];
        prize = leagueData['prize'];
        state = leagueData['state'];
        email = leagueData['email'];
        photo = leagueData['logoPath'];
        clubs = leagueData['clubs'];
      });

      print('Description: $description');
      print('Prize: $prize');
      print('name: $name');
      print('state: $state');
      print('email: $email');
      print('photo: $photo');
      print(clubs);
    } else {
      final Map<String, dynamic> responseData = json.decode(response.body);
      ShowDialog.showResponseDialog(
        context,
        response.statusCode,
        responseData['httpStatus']['message'],
        responseData['clientErrors'],
      );
      print('Error: ${response.statusCode}');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchAvailableClubs();
    fetchData();
    fetchLeagueClubs();
  }

  void _showAvailableClubsDialog(BuildContext context) {
    fetchAvailableClubs();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Available Clubs'),
          content: Container(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              physics: AlwaysScrollableScrollPhysics(),
              itemCount: availableClubsData.length,
              itemBuilder: (context, index) {
                final club = availableClubsData[index];
                return Card(
                  margin: EdgeInsets.all(10.0),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(club['logoPath']),
                      radius: 30.0,
                    ),
                    title: Text(club['name'] ?? 'N/A'),
                    subtitle: Text('Player Count ${club['playerCount']}'),
                    trailing: IconButton(
                      icon: Icon(Icons.add),
                      onPressed: () {
                        addClubToLeague(club['clubId']);
                        Navigator.pop(context);
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit League'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(16),
              child: Container(
                padding: EdgeInsets.all(20.0),
                color: Colors.green[100]?.withOpacity(0.9),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: NetworkImage(photo!),
                      radius: 50.0,
                    ),
                    SizedBox(width: 25.0),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name ?? '',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 8.0),
                          Row(
                            children: [
                              Icon(Icons.attach_money, color: Colors.black, size: 30),
                              SizedBox(width: 8.0),
                              Flexible(
                                child: Text(
                                  'Prize: $prize',
                                  style: TextStyle(fontSize: 16.0, color: Colors.black),
                                ),
                              ),
                            ],
                          ),
                          Divider(),
                          Row(
                            children: [
                              Icon(Icons.check_circle, color: Colors.black, size: 30),
                              SizedBox(width: 8.0),
                              Flexible(
                                child: Text(
                                  'Status: $state',
                                  style: TextStyle(fontSize: 16.0, color: Colors.black),
                                ),
                              ),
                            ],
                          ),
                          Divider(),
                          Row(
                            children: [
                              Icon(Icons.mail, color: Colors.black, size: 30),
                              SizedBox(width: 8.0),
                              Flexible(
                                child: Text(
                                  'Contact: $email',
                                  style: TextStyle(fontSize: 16.0, color: Colors.black),
                                ),
                              ),
                            ],
                          ),
                          Divider(),
                          Row(
                            children: [
                              Icon(Icons.info, color: Colors.black, size: 30),
                              SizedBox(width: 8.0),
                              Flexible(
                                child: Text(
                                  description ?? '',
                                  style: TextStyle(fontSize: 16.0, color: Colors.black),
                                ),
                              ),
                            ],
                          ),
                          Divider(),
                          Row(
                            children: [
                              ElevatedButton(onPressed: fetchData, child: Text('Press')),
                            ],
                          ),
                          Divider(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: clubs.length,
              itemBuilder: (context, index) {
                final club = clubs[index];
                return Card(
                  margin: EdgeInsets.all(10.0),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(club['logoPath']),
                      radius: 30.0,
                    ),
                    title: Text('${club['name']}'),
                    subtitle: Text('Player Count ${club['playerCount']}'),
                    trailing: IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        _showDeleteDialog(index);
                      },
                    ),
                  ),
                );
              },
            ),
            ElevatedButton(
              onPressed: () => _showAvailableClubsDialog(context),
              child: Text('+ Add Club'),
            ),
          ],
        ),
      ),
    );
  }

  _showDeleteDialog(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Club'),
          content: Text('Are you sure you want to delete this club?'),
          actions: [
            TextButton(
              onPressed: () async {
                try {
                  final token = await _tokenService.getToken();
                  Map<String, String> headers = {
                    'Authorization': 'Bearer $token'
                  };
                  final response = await http.delete(Uri.parse('${apiBase}/api/my/leagues/${widget.leagueId}/clubs/${clubs[index]['clubId']}'),headers: headers);

                  if (response.statusCode == 200 || response.statusCode == 201 || response.statusCode == 204) {
                    print('Item deleted successfully');
                  } else {
                    print('Failed to delete item. Status code: ${response.statusCode}');
                    print('Response body: ${response.body}');
                  }
                } catch (e) {
                  print('Error deleting item: $e');
                }
                fetchData();
                Navigator.pop(context);
              },
              child: Text('Yes'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('No'),
            ),
          ],
        );
      },
    );
  }
}

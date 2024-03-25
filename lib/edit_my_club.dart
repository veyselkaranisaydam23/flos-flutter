import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:league_for_enjoy/show_dialog.dart';
import 'package:league_for_enjoy/token_service.dart';

import 'constant.dart';

class EditMyClubPage extends StatefulWidget {

  const EditMyClubPage({Key? key}) : super(key: key);

  @override
  _EditMyClubPageState createState() => _EditMyClubPageState();
}

class _EditMyClubPageState extends State<EditMyClubPage> {
  final TokenService _tokenService = TokenService();
  List<dynamic> players = [];
  late String? leagueName = '';
  late String? name = '';
  late String? state = '';
  late int? playerCount = 0;
  late int? cupCount = 0;
  late String? email = '';
  late String? description = '';
  late String? photo = '';
  late List<Map<String, dynamic>> availablePlayersData = [];

  Future fetchAvailablePlayers() async {
    final response = await http.get(Uri.parse('${apiBase}/api/available/players'));

    if (response.statusCode == 200 || response.statusCode == 201) {
      final Map<String, dynamic> data = json.decode(response.body);
      setState(() {
        availablePlayersData = List<Map<String, dynamic>>.from(data['data'] ?? []);
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


  Future addPlayerToClub(int? playerId) async {
    final token = await _tokenService.getToken();

    try {
      Map<String, String> headers = {
        "Content-Type": "application/json",
        'Authorization': 'Bearer $token'
      };

      String jsonData = jsonEncode({
        "playerId": playerId,
      });

      final response = await http.post(
        Uri.parse('${apiBase}/api/my/club/players'),
        headers: headers,
        body: jsonData,
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        Navigator.of(context).pop();
        ShowDialog.showResponseDialog(context, response.statusCode, 'Sign up successful', []);
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
    final token = await _tokenService.getToken();
    Map<String, String> headers = {
      'Authorization': 'Bearer $token'
    };
    final response = await http.get(Uri.parse('${apiBase}/api/my/club'),headers: headers);
    if (response.statusCode == 200 || response.statusCode == 201) {
      final Map<String, dynamic> data = json.decode(response.body);

      final Map<String, dynamic> clubData = data['data'];
      setState(() {
        leagueName = clubData['leagueName'];
        name = clubData['name'];
        description = clubData['description'];
        playerCount = clubData['playerCount'];
        cupCount = clubData['cupCount'];
        state = clubData['state'];
        email = clubData['email'];
        photo = clubData['logoPath'];
        players = clubData['players'];
      });

      print('Description: $description');
      print('name: $name');
      print('state: $state');
      print('email: $email');
      print('photo: $photo');
      print('players: $players');
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
    fetchAvailablePlayers();
    fetchData();
  }

  void _showAvailablePlayersDialog(BuildContext context) {
    fetchAvailablePlayers();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Available Players'),
          content: Container(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: availablePlayersData.length,
              itemBuilder: (context, index) {
                final player = availablePlayersData[index];
                return Card(
                  margin: EdgeInsets.all(10.0),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(player['imgPath']),
                      radius: 30.0,
                    ),
                    title: Text(player['fullName'] ?? 'N/A'),
                    subtitle: Text('Age ${player['age']}'),
                    trailing: IconButton(
                      icon: Icon(Icons.add),
                      onPressed: () {
                        addPlayerToClub(player['playerId']);
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
        title: Text('Edit Club'),
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
                                  'Player Count: $playerCount',
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

            Container(
              child: Text(
                "Players",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),

            ListView.builder(
              shrinkWrap: true,
              physics: AlwaysScrollableScrollPhysics(),
              itemCount: players.length,
              itemBuilder: (context, index) {
                final player = players[index];
                return Card(
                  margin: EdgeInsets.all(10.0),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(player['imgPath']),
                      radius: 30.0,
                    ),
                    title: Text('${player['fullName']}'),
                    subtitle: Text('Goals: ${player['goals']}'),
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
              onPressed: () => _showAvailablePlayersDialog(context),
              child: Text('+ Add Player'),
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
                  final response = await http.delete(Uri.parse('${apiBase}/api/my/club/players/${players[index]['playerId']}'),headers: headers);

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

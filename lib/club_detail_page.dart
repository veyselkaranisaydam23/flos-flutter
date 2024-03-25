import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:league_for_enjoy/show_dialog.dart';
import 'constant.dart';

class ClubDetailPage extends StatefulWidget {
  final int? clubId;

  const ClubDetailPage({Key? key, required this.clubId}) : super(key: key);

  @override
  State<ClubDetailPage> createState() => _ClubDetailPageState();
}

class _ClubDetailPageState extends State<ClubDetailPage> {
  late String name = '';
  late int cupCount = 0;
  late String state = '';
  late String email = '';
  late String description = '';
  late String photo = '';
  List<Map<String, dynamic>> playersData = [];

  Future fetchData() async {
    final response = await http.get(Uri.parse('${apiBase}/api/clubs/${widget.clubId}'));

    if (response.statusCode == 200 || response.statusCode == 201) {
      final Map<String, dynamic> data = json.decode(response.body);
      final Map<String, dynamic> clubData = data['data'];
      print(data);

      playersData = List<Map<String, dynamic>>.from(clubData['players']);

      setState(() {
        name = clubData['name'];
        description = clubData['description'];
        cupCount = clubData['cupCount'];
        state = clubData['state'];
        email = clubData['email'];
        photo = clubData['logoPath'];
      });
    } else {
      final Map<String, dynamic> responseData = json.decode(response.body);
      ShowDialog.showResponseDialog(context,response.statusCode, responseData['httpStatus']['message'], responseData['clientErrors']);
      print('Error: ${response.statusCode}');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Club Detail'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: EdgeInsets.all(20.0),
              color: Colors.green[100]?.withOpacity(0.9),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundImage: NetworkImage(photo),
                    radius: 50.0,
                  ),
                  SizedBox(width: 25.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        Row(
                          children: [
                            Icon(Icons.emoji_events, color: Colors.black, size: 30),
                            SizedBox(width: 8.0),
                            Flexible(
                              child: Text(
                                'Cup Count: $cupCount',
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
                                description,
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
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: playersData.length,
              itemBuilder: (context, index) {
                final player = playersData[index];
                return Card(
                  margin: EdgeInsets.all(10.0),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(player['imgPath']),
                      radius: 30.0,
                    ),
                    title: Text('${player['fullName']}'),
                    subtitle: Text('Age ${player['age']}'),
                    trailing: Text('Goals: ${player['goals']}'),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

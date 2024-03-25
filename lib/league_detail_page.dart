import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'package:league_for_enjoy/show_dialog.dart';

import 'constant.dart';

class LeagueDetailPage extends StatefulWidget {
  final int? leagueId;
  const LeagueDetailPage({Key? key, required this.leagueId}) : super(key: key);

  @override
  _LeagueDetailPageState createState() => _LeagueDetailPageState();
}

class _LeagueDetailPageState extends State<LeagueDetailPage> {
  late String? name = '';
  late int? prize = 0;
  late String? state = '';
  late String? email = '';
  late String? description = '';
  late String? photo = '';
  List<dynamic> clubs = [];

  Future fetchData() async {
    print(widget.leagueId);
    final response = await http.get(Uri.parse('${apiBase}/api/leagues/${widget.leagueId}'));

    if (response.statusCode == 200 || response.statusCode == 201) {
      // Successful response
      final Map<String, dynamic> data = json.decode(response.body);

      // Accessing the nested fields
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

      // Print or use the extracted values
      print('Description: $description');
      print('Prize: $prize');
      print('name: $name');
      print('state: $state');
      print('email: $email');
      print('photo: $photo');
      print(clubs);
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
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(height: 40, color: Colors.white),
            Container(
              padding: EdgeInsets.all(20.0),
              color: Colors.green[100]?.withOpacity(0.9),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundImage: NetworkImage(photo!), // Load photo from the internet
                    radius: 50.0,
                  ),
                  SizedBox(width: 25.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name!, // Display league name under the photo
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8.0),
                        Row(
                          children: [
                            Icon(Icons.attach_money, color: Colors.black, size: 30), // Money icon
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
                            Icon(Icons.check_circle, color: Colors.black, size: 30), // Status icon
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
                            Icon(Icons.mail, color: Colors.black, size: 30), // Mail icon
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
                            Icon(Icons.info, color: Colors.black, size: 30), // Status icon
                            SizedBox(width: 8.0),
                            Flexible(
                              child: Text(
                                description!,
                                style: TextStyle(fontSize: 16.0, color: Colors.black),
                              ),
                            ),
                          ],
                        ),
                        Divider(),

                        Row(
                          children: [
                            ElevatedButton(onPressed: fetchData, child: Text('Press'), )
                          ],
                        ),
                        Divider(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              color: Colors.white,
              padding: EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: [
                    DataColumn(label: Text('Position', style: TextStyle(fontSize: 17),)),
                    DataColumn(label: Text('Club Name', style: TextStyle(fontSize: 17),)),
                    DataColumn(label: Text('PL', style: TextStyle(fontSize: 17),)),
                    DataColumn(label: Text('W', style: TextStyle(fontSize: 17),)),
                    DataColumn(label: Text('D', style: TextStyle(fontSize: 17),)),
                    DataColumn(label: Text('L', style: TextStyle(fontSize: 17),)),
                    DataColumn(label: Text('Avg', style: TextStyle(fontSize: 17),)),
                    DataColumn(label: Text('P', style: TextStyle(fontSize: 17),)),
                  ],
                  rows: List.generate(
                    clubs.length,
                        (index) => DataRow(
                      color: MaterialStateProperty.resolveWith<Color?>(
                            (Set<MaterialState> states) {
                          if (states.contains(MaterialState.selected)) {
                            return Colors.blue; // Customize as needed
                          }
                          return index.isOdd ? Colors.green[50]?.withOpacity(0.9) : Colors.green[100]?.withOpacity(0.9);
                        },
                      ),
                      cells: [
                        DataCell(Text((index + 1).toString())),
                        DataCell(Text(clubs[index]['name'])),
                        DataCell(Text(clubs[index]['played'].toString())),
                        DataCell(Text(clubs[index]['wins'].toString())),
                        DataCell(Text(clubs[index]['draws'].toString())),
                        DataCell(Text(clubs[index]['losses'].toString())),
                        DataCell(Text(clubs[index]['average'].toString())),
                        DataCell(Text(clubs[index]['points'].toString())),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

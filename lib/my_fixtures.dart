import 'package:flutter/material.dart';

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:league_for_enjoy/constant.dart';
import 'package:league_for_enjoy/edit_my_league.dart';
import 'package:league_for_enjoy/fixtureList.dart';
import 'package:league_for_enjoy/search_page.dart';
import 'package:league_for_enjoy/show_dialog.dart';
import 'package:league_for_enjoy/token_service.dart';

import 'fixtureModel.dart';


class MyFixtures extends StatefulWidget {
  @override
  _MyFixturesState createState() => _MyFixturesState();
}

class _MyFixturesState extends State<MyFixtures> {
  late List<FixtureData> fixtures = []; // Initialize with an empty list
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
        Uri.parse('${apiBase}/api/my/fixtures'),
        headers: headers,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final List<dynamic> data = json.decode(response.body)['data'];
        setState(() {
          fixtures = data.map((item) => FixtureData.fromJson(item)).toList();
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
          title: Text("My Fixtures"),
        ),
        body: FixtureList(
                fixtures: fixtures,
                onFixtureTap: (FixtureData fixture) {
                  simulateFixture(fixture.fixtureId);
                },
              ),
            ),

    );
  }

  Future<void> simulateFixture(int fixtureId) async {
    try {
      final String simulateUrl = '${apiBase}/api/my/fixtures/$fixtureId/simulate';
      final token = await _tokenService.getToken();
      final http.Response simulateResponse = await http.put(
        Uri.parse(simulateUrl),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (simulateResponse.statusCode == 200 || simulateResponse.statusCode == 201) {
        // Successful simulation, now fetch detailed information
        final String fetchUrl = '${apiBase}/api/my/fixtures/$fixtureId';
        final http.Response fetchResponse = await http.get(
          Uri.parse(fetchUrl),
          headers: <String, String>{
            'Authorization': 'Bearer $token',
          },
        );

        if (fetchResponse.statusCode == 200 || fetchResponse.statusCode == 201) {
          // Parse and display detailed information
          final Map<String, dynamic> detailedData = json.decode(fetchResponse.body);

          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Detailed Fixture Informations'),
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('${detailedData['data']['homeClubName']} : ${detailedData['data']['homeTeamScore']}'),
                    Text('${detailedData['data']['awayClubName']} : ${detailedData['data']['awayTeamScore']}'),
                    // Add other relevant attributes here
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      fetchData();
                      Navigator.of(context).pop(); // Close the dialog
                    },
                    child: Text('OK'),
                  ),
                ],
              );
            },
          );
        } else {
          print('Failed to fetch detailed data. Status code: ${fetchResponse.statusCode}');
          print('Response body: ${fetchResponse.body}');
        }
      } else {
        print('Failed to update data. Status code: ${simulateResponse.statusCode}');
        print('Response body: ${simulateResponse.body}');
      }
    } catch (e) {
      print('Error during update: $e');
    }
  }

}
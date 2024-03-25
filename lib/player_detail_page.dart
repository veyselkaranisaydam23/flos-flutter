import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';
import 'package:league_for_enjoy/show_dialog.dart';
import 'constant.dart';

class PlayerDetailPage extends StatefulWidget {
  final int? playerId;

  PlayerDetailPage({required this.playerId});

  @override
  _PlayerDetailPageState createState() => _PlayerDetailPageState();
}

class _PlayerDetailPageState extends State<PlayerDetailPage> {
  late Map<String, dynamic> playerData = {};

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      final response = await http.get(Uri.parse('${apiBase}/api/players/${widget.playerId}'));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = json.decode(response.body);

        if (responseData['data'] != null) {
          setState(() {
            playerData = responseData['data'];
          });
        } else {
          // Handle error: Data structure is not as expected
          print('Failed to parse player data');
        }
      } else {
        final Map<String, dynamic> responseData = json.decode(response.body);
        ShowDialog.showResponseDialog(context,response.statusCode, responseData['httpStatus']['message'], responseData['clientErrors']);
        print('Failed to load player data');
      }
    } catch (error) {
      // Handle other errors
      print('Error fetching player data: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Player Detail'),
      ),
      body: playerData.isEmpty
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Image.network(
              playerData['imgPath'] ?? '',
              height: 400,
              fit: BoxFit.cover,
            ),
            Container(
              color: Colors.green[100]?.withOpacity(0.5),
              margin: EdgeInsets.all(16),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildBoldHeader(Icons.person, 'FULL NAME'),
                    _buildAttributeRow('${playerData['fullName'] ?? ''}'),
                    Divider(),
                    _buildBoldHeader(Icons.sports_soccer, 'CLUB NAME'),
                    _buildAttributeRow('${playerData['clubName'] ?? ''}'),
                    Divider(),
                    _buildBoldHeader(Icons.location_on, 'STATE'),
                    _buildAttributeRow('${playerData['state'] ?? ''}'),
                    Divider(),
                    _buildBoldHeader(Icons.calendar_today, 'AGE'),
                    _buildAttributeRow('${playerData['age'] ?? ''}'),
                    Divider(),
                    _buildBoldHeader(Icons.sports_score, 'GOALS'),
                    _buildAttributeRow('${playerData['goals'] ?? ''}'),
                    Divider(),
                    _buildBoldHeader(Icons.sports_score, 'ASSISTS'),
                    _buildAttributeRow('${playerData['assists'] ?? ''}'),
                    Divider(),
                    _buildBoldHeader(Icons.email, 'EMAIL'),
                    _buildAttributeRow('${playerData['email'] ?? ''}'),
                    Divider(),
                    _buildBoldHeader(Icons.book, 'BIOGRAPHY'),
                    _buildAttributeRow('${playerData['biography'] ?? ''}'),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildAttributeRow(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          SizedBox(width: 32), // Add some space for the icon
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  text,
                  style: TextStyle(fontSize: 20, fontFamily: GoogleFonts.roboto().fontFamily),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBoldHeader(IconData icon, String headerText) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon),
          SizedBox(width: 8),
          Text(
            headerText,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: GoogleFonts.acme().fontFamily,
            ),
          ),
        ],
      ),
    );
  }
}

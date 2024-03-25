import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';
import 'package:league_for_enjoy/show_dialog.dart';
import 'constant.dart';

class RefereeDetailPage extends StatefulWidget {
  final int? refereeId;

  RefereeDetailPage({required this.refereeId});

  @override
  _RefereeDetailPageState createState() => _RefereeDetailPageState();
}

class _RefereeDetailPageState extends State<RefereeDetailPage> {
  late Map<String, dynamic> refereeData = {};

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      final response = await http.get(Uri.parse('${apiBase}/api/referees/${widget.refereeId}'));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = json.decode(response.body);

        if (responseData['data'] != null) {
          setState(() {
            refereeData = responseData['data'];
          });
        } else {
          // Handle error: Data structure is not as expected
          print('Failed to parse referee data');
        }
      } else {
        final Map<String, dynamic> responseData = json.decode(response.body);
        ShowDialog.showResponseDialog(context,response.statusCode, responseData['httpStatus']['message'], responseData['clientErrors']);
        print('Failed to load referee data');
      }
    } catch (error) {
      // Handle other errors
      print('Error fetching referee data: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Referee Detail'),
      ),
      body: refereeData.isEmpty
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Image.network(
              refereeData['imgPath'] ?? '',
              height: 400,
              width: 200,
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
                    _buildAttributeRow('${refereeData['fullName'] ?? ''}'),
                    Divider(),
                    _buildBoldHeader(Icons.calendar_today, 'AGE'),
                    _buildAttributeRow('${refereeData['age'] ?? ''}'),
                    Divider(),
                    _buildBoldHeader(Icons.assignment, 'LICENSE TYPE'),
                    _buildAttributeRow('${refereeData['licenseType'] ?? ''}'),
                    Divider(),
                    _buildBoldHeader(Icons.email, 'EMAIL'),
                    _buildAttributeRow('${refereeData['email'] ?? ''}'),
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

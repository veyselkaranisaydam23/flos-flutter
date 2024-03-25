import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:league_for_enjoy/show_dialog.dart';
import 'dart:convert';

import 'constant.dart';

class VenueDetailPage extends StatefulWidget {
  final int? venueId;

  VenueDetailPage({required this.venueId});

  @override
  _VenueDetailPageState createState() => _VenueDetailPageState();
}

class _VenueDetailPageState extends State<VenueDetailPage> {
  late Map<String, dynamic> venueData = {};

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      final response = await http.get(Uri.parse('${apiBase}/api/venues/${widget.venueId}'));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = json.decode(response.body);

        if (responseData['data'] != null) {
          setState(() {
            venueData = responseData['data'];
          });
        } else {
          // Handle error: Data structure is not as expected
          print('Failed to parse venue data');
        }
      } else {
        final Map<String, dynamic> responseData = json.decode(response.body);
        ShowDialog.showResponseDialog(context,response.statusCode, responseData['httpStatus']['message'], responseData['clientErrors']);
        print('Failed to load venue data');
      }
    } catch (error) {
      // Handle other errors
      print('Error fetching venue data: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Venue Detail'),
      ),
      body: venueData.isEmpty
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Image.network(
              venueData['imgPath'] ?? '',
              height: 200,
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
                    _buildBoldHeader(Icons.location_city, 'NAME'),
                    _buildAttributeRow('${venueData['name'] ?? ''}'),
                    Divider(),
                    _buildBoldHeader(Icons.people, 'CAPACITY'),
                    _buildAttributeRow('${venueData['capacity'] ?? ''}'),
                    Divider(),
                    _buildBoldHeader(Icons.star, 'CAPACITY RANK:'),
                    _buildAttributeRow(
                      '${venueData['capacityRank'] ?? ''}',
                      percentage: (venueData['capacityRank'] ?? 0) / 5 * 100,
                    ),
                    Divider(),
                    _buildBoldHeader(Icons.email, 'CONTACT:'),
                    _buildAttributeRow('${venueData['email'] ?? ''}'),
                    Divider(),
                    _buildBoldHeader(Icons.location_on, 'ADDRESS:'),
                    _buildAttributeRow('${venueData['address'] ?? ''}'),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildAttributeRow(String text, {double? percentage}) {
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
                  style: TextStyle(fontSize: 20,fontFamily: GoogleFonts.roboto().fontFamily),
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

  Widget _buildPercentageStick(double percentage) {
    return Container(
      width: 50,
      height: 8,
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.circular(4),
      ),
      child: FractionallySizedBox(
        widthFactor: percentage / 100,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.green,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }
}

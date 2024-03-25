import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:league_for_enjoy/constant.dart';
import 'package:league_for_enjoy/token_service.dart';

import 'edit_my_club.dart';

void main() {
  runApp(MyApp());
}

class NewClubPage extends StatefulWidget {
  @override
  _NewClubPageState createState() => _NewClubPageState();
}

class _NewClubPageState extends State<NewClubPage> {
  String tempSelectedPhotoLink = '';
  final TokenService _tokenService = TokenService();
  bool isEditing = false;
  late TextEditingController leagueNameController;
  late TextEditingController nameController;
  late TextEditingController stateController;
  late TextEditingController playerCountController;
  late TextEditingController cupCountController;
  late TextEditingController emailController;
  late TextEditingController descriptionController;
  String selectedPhotoLink = '';

  // Participant information
  int clubId = 0;
  String? leagueName;
  String name = "";
  String state = "";
  int playerCount = 0;
  int cupCount = 0;
  String email = "";
  String description = "";
  String logoPath = ""; // Replace with your image path

  List<String> photoLinks = [
    'https://cdn-icons-png.flaticon.com/512/919/919510.png',
    'https://cdn-icons-png.flaticon.com/512/919/919459.png',
    'https://cdn-icons-png.flaticon.com/512/9192/9192876.png',
    'https://cdn-icons-png.flaticon.com/512/5043/5043412.png',
    'https://cdn-icons-png.flaticon.com/512/2718/2718297.png',
  ];

  @override
  void initState() {
    super.initState();
    leagueNameController = TextEditingController(text: leagueName);
    nameController = TextEditingController(text: name);
    stateController = TextEditingController(text: state);
    playerCountController = TextEditingController(text: playerCount.toString());
    cupCountController = TextEditingController(text: cupCount.toString());
    emailController = TextEditingController(text: email);
    descriptionController = TextEditingController(text: description);

    fetchData();
  }

  Future<void> fetchData() async {
    final apiUrl = Uri.parse('${apiBase}/api/my/club');
    final token = await _tokenService.getToken();

    try {
      final response = await http.get(
        apiUrl,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        print(data);
        final clubData = data['data'];

        setState(() {
          // Update participant information with data from the API
          clubId = clubData['clubId'];
          leagueName = clubData['leagueName'];
          name = clubData['name'];
          state = clubData['state'];
          playerCount = clubData['playerCount'];
          cupCount = clubData['cupCount'];
          email = clubData['email'];
          description = clubData['description'];
          logoPath = clubData['logoPath'];

          // Display fetched data alert
          _showFetchedDataAlert();
        });
      } else if (response.statusCode == 404) {
        // Display alert for 404 error
        _showDataNotPostedAlert();
      } else {
        // Handle other errors
        print('Failed to fetch data: ${response.statusCode}');
      }
    } catch (error) {
      // Handle error
      print('Error: $error');
    }
  }

  void _showDataNotPostedAlert() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Data Not Posted'),
          content: Text('You did not post your information before. Please enter your information.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _collectAndPostData();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    ).then((_) => _rebuildWidget()); // Rebuild the widget after dialog is closed
  }

  void _showFetchedDataAlert() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Data Fetched'),
          content: Text('Participant information fetched successfully.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _rebuildWidget();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    ).then((_) => _rebuildWidget()); // Rebuild the widget after dialog is closed
  }

  void _rebuildWidget() {
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      // This ensures that the widget is rebuilt after the dialog is closed
      setState(() {});
    });
  }


  void _collectAndPostData() {
    showDialog(
      context: context,
      builder: (context) {
        String newName = "";
        String newDescription = "";
        String newLogoPath = photoLinks.first; // Default to the first item if not changed

        return AlertDialog(
          title: Text('Enter Club Information'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                onChanged: (value) {
                  newName = value;
                },
                decoration: InputDecoration(labelText: 'Full Name'),
              ),

              TextField(
                onChanged: (value) {
                  newDescription = value;
                },
                decoration: InputDecoration(labelText: 'Description'),
              ),
              DropdownButton<String>(
                value: newLogoPath,
                onChanged: (String? newValue) {
                  newLogoPath = newValue!;
                },
                items: photoLinks.map((String link) {
                  return DropdownMenuItem<String>(
                    value: link,
                    child: SizedBox(
                      width: 50,
                      height: 50,
                      child: Image.network(
                        link,
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _postNewData(newName, newDescription, newLogoPath);
              },
              child: Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  void _postNewData(String newName, String newDescription, String newLogoPath) async {
    final apiUrl = Uri.parse('${apiBase}/api/my/club');
    final token = await _tokenService.getToken();

    try {
      final response = await http.post(
        apiUrl,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'name': newName,
          'description': newDescription,
          'logoPath': newLogoPath,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Successfully posted data
        fetchData(); // Refresh data after posting
        _showFetchedDataAlert(); // Display alert for successful post
      } else {
        // Handle error in posting data
        print('Failed to post data: ${response.statusCode}');
      }
    } catch (error) {
      // Handle error
      print('Error: $error');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Club Information'),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => EditMyClubPage()),
              );
            },
          ),

          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              _confirmDelete();
            },
          ),

        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Display the photo at the top
            Image.network(
              logoPath,
              width: double.infinity, // Take the full width of the screen
              height: 300, // Adjust the height as needed
              fit: BoxFit.cover,
            ),
            SizedBox(height: 16), // Add some space between the photo and other info

            // Display other information
            _buildInfoField("Club ID", clubId.toString()),
            _buildEditableInfoField("League Name", leagueName ?? ''),
            _buildEditableInfoField("Name", name),
            _buildEditableInfoField("State", state),
            _buildEditableInfoField("Player Count", playerCount.toString()),
            _buildEditableInfoField("Cup Count", cupCount.toString()),
            _buildEditableInfoField("Email", email),
            _buildEditableInfoField("Description", description),
          ],
        ),
      ),
    );
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Delete Club'),
          content: Text('Are you sure you want to delete this club?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('No'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _deleteClub();
              },
              child: Text('Yes'),
            ),
          ],
        );
      },
    );
  }

  void _deleteClub() async {
    final apiUrl = Uri.parse('${apiBase}/api/my/club');
    final token = await _tokenService.getToken();

    try {
      final response = await http.delete(
        apiUrl,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200 || response.statusCode == 201 || response.statusCode == 204) {
        // Successfully deleted player
        fetchData();
      } else {
        // Handle error in deleting data
        print('Failed to delete player: ${response.statusCode} ${response.body}');
      }
    } catch (error) {
      // Handle error
      print('Error: $error');
    }
  }


  Widget _buildEditableInfoField(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        '$label: $value',
        style: TextStyle(fontSize: 16.0),
      ),
    );
  }


  Widget _buildInfoField(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        '$label: $value',
        style: TextStyle(fontSize: 16.0),
      ),
    );
  }

  void _confirmEdit() {
    setState(() {
      isEditing = true;
    });

    // Initialize local variables with the current data
    String editedName = name ?? '';
    String editedDescription = description ?? '';
    String editedLogoPath = selectedPhotoLink;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Enter Club Information'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: TextEditingController(text: editedName),
                onChanged: (value) {
                  editedName = value;
                },
                decoration: InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: TextEditingController(text: editedDescription),
                onChanged: (value) {
                  editedDescription = value;
                },
                decoration: InputDecoration(labelText: 'Description'),
              ),
              _buildPhotoDropdown(),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _updateData(editedName, editedDescription, editedLogoPath);
              },
              child: Text('Submit'),
            ),
          ],
        );
      },
    );
  }


  Widget _buildPhotoDropdown() {
    int initialIndex = photoLinks.indexOf(selectedPhotoLink);
    if (initialIndex == -1) {
      initialIndex = 0; // Default to the first item if not found
    }

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select Photo:',
            style: TextStyle(fontSize: 16.0),
          ),
          DropdownButton<int>(
            value: isEditing ? initialIndex : null,
            onChanged: _onPhotoLinkChanged,
            items: photoLinks.asMap().entries.map<DropdownMenuItem<int>>((entry) {
              return DropdownMenuItem<int>(
                value: entry.key,
                child: SizedBox(
                  width: 50,
                  height: 50,
                  child: Image.network(
                    entry.value,
                    fit: BoxFit.cover,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  void _onPhotoLinkChanged(int? newValue) {
    if (isEditing) {
      setState(() {
        tempSelectedPhotoLink = photoLinks[newValue!];
      });
    }
  }


  void _updateData(String newName, String newDescription, String newLogoPath) async {
    final apiUrl = Uri.parse('${apiBase}/api/my/club');
    final token = await _tokenService.getToken();

    try {
      final response = await http.put(
        apiUrl,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'fullName': newName,
          'biography': newDescription,
          'imgPath': tempSelectedPhotoLink, // Use the temporary variable here
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Successfully posted data
        fetchData(); // Refresh data after posting
        _showFetchedDataAlert(); // Display alert for successful post
      } else {
        // Handle error in posting data
        print('Failed to post data: ${response.statusCode} ${response.body}');
      }
    } catch (error) {
      // Handle error
      print('Error: $error');
    }
  }


  void _enableEditing() {
    setState(() {
      isEditing = true;
    });
  }

  void _saveChanges() {
    // Call API to save changes (replace with your actual API call)
    // After successful API call, disable editing
    setState(() {
      isEditing = false;
    });
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: NewClubPage(),
    );
  }
}

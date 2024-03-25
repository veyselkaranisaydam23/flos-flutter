import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:league_for_enjoy/constant.dart';
import 'package:league_for_enjoy/token_service.dart';

void main() {
  runApp(MyApp());
}

class ParticipantPage extends StatefulWidget {
  @override
  _ParticipantPageState createState() => _ParticipantPageState();
}

class _ParticipantPageState extends State<ParticipantPage> {
  String tempSelectedPhotoLink = '';
  final TokenService _tokenService = TokenService();
  bool isEditing = false;
  late TextEditingController clubNameController;
  late TextEditingController fullNameController;
  late TextEditingController stateController;
  late TextEditingController ageController;
  late TextEditingController goalsController;
  late TextEditingController assistsController;
  late TextEditingController emailController;
  late TextEditingController biographyController;
  String selectedPhotoLink = '';

  // Participant information
  int playerId = 123;
  String? clubName;
  String fullName = "";
  String state = "";
  int age = 0;
  int goals = 0;
  int assists = 0;
  String email = "";
  String biography = "";
  String imgPath = ""; // Replace with your image path

  List<String> photoLinks = [
    'https://cdn-icons-png.flaticon.com/512/166/166344.png',
    'https://cdn-icons-png.flaticon.com/512/7458/7458816.png',
    'https://cdn-icons-png.flaticon.com/512/607/607445.png',
    'https://cdn-icons-png.flaticon.com/512/164/164440.png',
    'https://cdn-icons-png.flaticon.com/256/5281/5281502.png',
  ];

  @override
  void initState() {
    super.initState();
    clubNameController = TextEditingController(text: clubName);
    fullNameController = TextEditingController(text: fullName);
    stateController = TextEditingController(text: state);
    ageController = TextEditingController(text: age.toString());
    goalsController = TextEditingController(text: goals.toString());
    assistsController = TextEditingController(text: assists.toString());
    emailController = TextEditingController(text: email);
    biographyController = TextEditingController(text: biography);

    // Fetch initial data from the API
    fetchData();
  }

  Future<void> fetchData() async {
    final apiUrl = Uri.parse('${apiBase}/api/my/player');
    final token = await _tokenService.getToken();

    try {
      final response = await http.get(
        apiUrl,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        print(data);
        final playerData = data['data'];

        setState(() {
          // Update participant information with data from the API
          playerId = playerData['playerId'];
          clubName = playerData['clubName'];
          fullName = playerData['fullName'];
          state = playerData['state'];
          age = playerData['age'];
          goals = playerData['goals'];
          assists = playerData['assists'];
          email = playerData['email'];
          biography = playerData['biography'];
          imgPath = playerData['imgPath'];

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
        String newFullName = "";
        String newBirthday = "";
        String newBiography = "";
        String newImgPath = photoLinks.first; // Default to the first item if not changed

        return AlertDialog(
          title: Text('Enter Participant Information'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                onChanged: (value) {
                  newFullName = value;
                },
                decoration: InputDecoration(labelText: 'Full Name'),
              ),
              TextField(
                onChanged: (value) {
                  newBirthday = value;
                },
                decoration: InputDecoration(labelText: 'Birthday (YYYY-MM-DD)'),
              ),
              TextField(
                onChanged: (value) {
                  newBiography = value;
                },
                decoration: InputDecoration(labelText: 'Biography'),
              ),
              DropdownButton<String>(
                value: newImgPath,
                onChanged: (String? newValue) {
                  newImgPath = newValue!;
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
                _postNewData(newFullName, newBirthday, newBiography, newImgPath);
              },
              child: Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  void _postNewData(String newFullName, String newBirthday, String newBiography, String newImgPath) async {
    final apiUrl = Uri.parse('${apiBase}/api/my/player');
    final token = await _tokenService.getToken();

    try {
      final response = await http.post(
        apiUrl,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'fullName': newFullName,
          'birthday': newBirthday,
          'biography': newBiography,
          'imgPath': newImgPath,
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
        title: Text('Participant Information'),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              _confirmEdit();
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
              imgPath,
              width: double.infinity, // Take the full width of the screen
              height: 300, // Adjust the height as needed
              fit: BoxFit.cover,
            ),
            SizedBox(height: 16), // Add some space between the photo and other info

            // Display other information
            _buildInfoField("Player ID", playerId.toString()),
            _buildEditableInfoField("Club Name", clubName ?? ''),
            _buildEditableInfoField("Full Name", fullName),
            _buildEditableInfoField("State", state),
            _buildEditableInfoField("Age", age.toString()),
            _buildEditableInfoField("Goals", goals.toString()),
            _buildEditableInfoField("Assists", assists.toString()),
            _buildEditableInfoField("Email", email),
            _buildEditableInfoField("Biography", biography),
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
          title: Text('Delete Participant'),
          content: Text('Are you sure you want to delete this participant?'),
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
                _deletePlayer();
              },
              child: Text('Yes'),
            ),
          ],
        );
      },
    );
  }

  void _deletePlayer() async {
    final apiUrl = Uri.parse('${apiBase}/api/my/player');
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
    String editedFullName = fullName ?? '';
    String editedBiography = biography ?? '';
    String editedImgPath = selectedPhotoLink;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Enter Participant Information'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: TextEditingController(text: editedFullName),
                onChanged: (value) {
                  editedFullName = value;
                },
                decoration: InputDecoration(labelText: 'Full Name'),
              ),
              TextField(
                onChanged: (value) {
                  // You might want to handle changes to birthday here
                },
                decoration: InputDecoration(labelText: 'Birthday (YYYY-MM-DD)'),
              ),
              TextField(
                controller: TextEditingController(text: editedBiography),
                onChanged: (value) {
                  editedBiography = value;
                },
                decoration: InputDecoration(labelText: 'Biography'),
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
                _updateData(editedFullName, '2005-04-02', editedBiography, editedImgPath);
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


  void _updateData(String newFullName, String newBirthday, String newBiography, String newImgPath) async {
    final apiUrl = Uri.parse('${apiBase}/api/my/player');
    final token = await _tokenService.getToken();

    try {
      final response = await http.put(
        apiUrl,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'fullName': newFullName,
          'birthday': newBirthday,
          'biography': newBiography,
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
      home: ParticipantPage(),
    );
  }
}

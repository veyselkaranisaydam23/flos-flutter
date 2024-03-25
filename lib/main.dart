import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:league_for_enjoy/constant.dart';
import 'package:league_for_enjoy/general_overview_page_participant.dart';
import 'package:league_for_enjoy/show_dialog.dart';
import 'package:league_for_enjoy/token_service.dart';
import 'general_overview_page_organizer.dart';

void main() {
  runApp(loginPage());
}

class loginPage extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey, // Add this line
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.green,
        fontFamily: GoogleFonts.acme().fontFamily,
      ),
      home: SplashScreen(navigatorKey: navigatorKey),
    );
  }
}

class SplashScreen extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey;

  SplashScreen({required this.navigatorKey});

  @override
  Widget build(BuildContext context) {
    const splashDuration = Duration(seconds: 5);

    // Delayed navigation to the HomeScreen
    Future.delayed(splashDuration, () {
      navigatorKey.currentState?.pushReplacement(
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    });

    return Scaffold(
      backgroundColor: Colors.green, // Set the background color to green
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'FLOS', // Your header text
              style: TextStyle(
                color: Colors.white, // Set the header text color
                fontSize: 45.0,
                fontWeight: FontWeight.bold,
                fontFamily: GoogleFonts.audiowide().fontFamily
              ),
            ),
            SizedBox(height: 16.0), // Add some spacing between header and title
            Text(
              'Elevate Your Game!', // Your title text
              style: TextStyle(
                color: Colors.white, // Set the title text color
                fontSize: 18.0,
              ),
            ),

            SizedBox(height: 16.0), // Add spacing between title and loading animation
            Container(
              width: 200,
              child: LinearProgressIndicator(
                color: Colors.white, // Set the color of the loading animation
              ),
            )


          ],
        ),
      ),
    );
  }
}

enum UserType { organizer, participant }

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TokenService _tokenService = TokenService();
  UserType userType = UserType.organizer; // Default to organizer mode
  TextEditingController _organizerUsernameController = TextEditingController();
  TextEditingController _organizerPasswordController = TextEditingController();
  TextEditingController _participantUsernameController = TextEditingController();
  TextEditingController _participantPasswordController = TextEditingController();

  Future<void> _login(String type) async {

    String username = _organizerUsernameController.text;
    String password = _organizerPasswordController.text;
    String api = '';

    if(type == "organizer")
    {
      username = _organizerUsernameController.text;
      password = _organizerPasswordController.text;
      api = '${apiBase}/api/login/organizer';
    }

    else if(type == "participant")
    {
      username = _participantUsernameController.text;
      password = _participantPasswordController.text;
      api = '${apiBase}/api/login/participant';
    }


    try {
      Map<String, String> headers = {
        "Content-Type": "application/json",
      };

      String jsonData = jsonEncode({
        "username": username,
        "password": password,
      });

      final response = await http.post(
        Uri.parse(api),
        headers: headers,
        body: jsonData,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        ShowDialog.showResponseDialog(context,response.statusCode, 'Login successful', []);
        final token = json.decode(response.body)['token'];
        print(token);
        final storage = FlutterSecureStorage();
        await storage.write(key: 'token', value: token);

        final tokenToSend = await storage.read(key: 'token');
        print(tokenToSend); // Ensure the token is not null before navigation

        if (tokenToSend != null) { // Add this check
          await _tokenService.saveToken(tokenToSend);
          print(tokenToSend);
          if(type == "organizer")
            {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => GeneralOverviewPageOrganizer()),
              );
            }

          else if(type == "participant")
          {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => GeneralOverviewPageParticipant()),
            );
          }

        }
      } else {
        final Map<String, dynamic> responseData = json.decode(response.body);
        ShowDialog.showResponseDialog(context,response.statusCode, responseData['httpStatus']['message'], responseData['clientErrors']);
        print("false");
        print(response.statusCode);
      }
    } catch (e) {
      print('Error sending data to API: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('photos/welcome_page.jpeg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                Container(
                  width: 300,
                  padding: EdgeInsets.all(16),
                  margin: EdgeInsets.symmetric(vertical: 20),
                  decoration: BoxDecoration(
                    border: Border.all(),
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.white
                  ),
                  child: Column(
                    children: [
                      Text(
                        'FLOS',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 35,fontFamily: GoogleFonts.audiowide().fontFamily),
                      ),
                      SizedBox(height: 10),
                      Icon(Icons.sports_soccer, size: 55,),
                      SizedBox(height: 10),
                      Container(
                        child: SingleChoice(
                          onUserTypeChanged: (type) {
                            setState(() {
                              userType = type;
                            });
                          },
                        ),
                      ),

                      SizedBox(height: 20),
                      if (userType == UserType.organizer)
                        _buildOrganizerContent()
                      else
                        _buildParticipantContent(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOrganizerContent() {
    return Column(
      children: [
        TextField(
          controller: _organizerUsernameController,
          decoration: InputDecoration(labelText: 'Organizer Username'),
        ),
        TextField(
          controller: _organizerPasswordController,
          obscureText: _isPasswordHiddenOrganizer,
          decoration: InputDecoration(
            labelText: 'Organizer Password',
            suffixIcon: IconButton(
              icon: Icon(
                _isPasswordHiddenOrganizer ? Icons.visibility_off : Icons.visibility,
              ),
              onPressed: _togglePasswordVisibilityOrganizer,
            ),
          ),
        ),
        SizedBox(height: 10),
        TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SignUpPage(type: 'organizer',)),
            );
          },
          child: Text('New Account'),
        ),
        ElevatedButton.icon(
          onPressed: () => _login("organizer"),
          icon: Icon(Icons.login),
          label: Text('Log In'),
        ),
      ],
    );
  }

  void _togglePasswordVisibilityOrganizer() {
    setState(() {
      _isPasswordHiddenOrganizer = !_isPasswordHiddenOrganizer;
    });
  }
  bool _isPasswordHiddenOrganizer = true;

  Widget _buildParticipantContent() {
    return Column(
      children: [
        TextField(
          controller: _participantUsernameController,
          decoration: InputDecoration(labelText: 'Participant Username'),
        ),
        TextField(
          controller: _participantPasswordController,
          obscureText: _isPasswordHiddenParticipant,
          decoration: InputDecoration(
            labelText: 'Participant Password',
            suffixIcon: IconButton(
              icon: Icon(
                _isPasswordHiddenParticipant ? Icons.visibility_off : Icons.visibility,
              ),
              onPressed: _togglePasswordVisibilityParticipant,
            ),
          ),
        ),
        SizedBox(height: 10),
        TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SignUpPage(type: 'participant',)),
            );
          },
          child: Text('New Account'),
        ),
        ElevatedButton.icon(
          onPressed: () => _login("participant"),
          icon: Icon(Icons.login),
          label: Text('Log In'),
        ),
      ],
    );
  }

  void _togglePasswordVisibilityParticipant() {
    setState(() {
      _isPasswordHiddenParticipant = !_isPasswordHiddenParticipant;
    });
  }
  bool _isPasswordHiddenParticipant = true;

}

class SingleChoice extends StatefulWidget {
  final ValueChanged<UserType> onUserTypeChanged;

  const SingleChoice({Key? key, required this.onUserTypeChanged})
      : super(key: key);

  @override
  State<SingleChoice> createState() => _SingleChoiceState();
}

class _SingleChoiceState extends State<SingleChoice> {
  UserType userType = UserType.organizer;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12), // Set the desired radius
        child: ToggleButtons(
          children: const <Widget>[
            Text('      Organizer      '),
            Text('      Participant      '),
          ],
          isSelected: <bool>[
            userType == UserType.organizer,
            userType == UserType.participant,
          ],
          onPressed: (int index) {
            setState(() {
              userType = index == 0 ? UserType.organizer : UserType.participant;
              widget.onUserTypeChanged(userType);
            });
          },
        ),
      ),
    );
  }
}

class SignUpPage extends StatefulWidget {
  final String? type;
  SignUpPage({required this.type});

  @override
  _SignUpPageState createState() => _SignUpPageState(type: type);
}

class _SignUpPageState extends State<SignUpPage> {
  final String? type;
  _SignUpPageState({required this.type});

  TextEditingController _usernameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  Future<void> _signup() async {
    final String username = _usernameController.text;
    final String password = _passwordController.text;
    final String email = _emailController.text;
    String api = '';

    if(type == "organizer")
      api = '${apiBase}/api/signup/organizer';

    else if(type == "participant")
      api = '${apiBase}/api/signup/participant';

    try {
      Map<String, String> headers = {
        "Content-Type": "application/json",
      };

      String jsonData = jsonEncode({
        "username": username,
        "password": password,
        "email": email,
      });

      final response = await http.post(
        Uri.parse(api),
        headers: headers,
        body: jsonData,
      );

      if (response.statusCode == 201||response.statusCode == 200) {
        ShowDialog.showResponseDialog(context, response.statusCode, 'Sign up successful', []);
        final token = json.decode(response.body)['token'];
        print(token);
        final storage = FlutterSecureStorage();
        await storage.write(key: 'token', value: token);

        final tokenToSend = await storage.read(key: 'token');
        print(tokenToSend); // Ensure the token is not null before navigation

        if (tokenToSend != null) { // Add this check
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen()),
          );
        }
      } else {
        final Map<String, dynamic> responseData = json.decode(response.body);
        ShowDialog.showResponseDialog(context,response.statusCode, responseData['httpStatus']['message'], responseData['clientErrors']);
        print(response.statusCode);
      }
    } catch (e) {
      print('Error sending data to API: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign Up'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: 'Username',
              ),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
                suffixIcon: IconButton(
                  icon: Icon(
                    _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                ),
              ),
              obscureText: !_isPasswordVisible,
            ),
            SizedBox(height: 24.0),
            ElevatedButton(
              onPressed: _signup,
              child: Text('Sign Up'),
            ),
          ],
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';

void main() {
  runApp(PillPoppinApp());
}

class PillPoppinApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PillPoppin',
      theme: ThemeData(
        colorScheme: ColorScheme.light(
          primary: Color(0xFFA8DADC), // Pastel Blue
          secondary: Color(0xFFFF9DC6), // Pastel Pink
          background: Color.fromARGB(255, 217, 242, 255), // White
          surface: Color.fromARGB(255, 175, 227, 252), // Pastel Bright Blue
          onPrimary: Color(0xFFFFFFFF), // White
          onSecondary: Color.fromARGB(255, 0, 0, 0), // White
          onBackground: Color(0xFFB0BEC5), // Light Gray
          onSurface: Color(0xFFB0BEC5), // Light Gray
        ),
        textTheme: TextTheme(
          headline1: TextStyle(color: Color(0xFF000000)), // Black
          bodyText1: TextStyle(color: Color(0xFF000000)), // Black
        ),
      ),
      home: WelcomeScreen(),
    );
  }
}

class WelcomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.start, // Align to the top
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                alignment: Alignment.topCenter,
                margin: EdgeInsets.only(top: 40), // Increased top margin
                child: Image.asset('images/FinalLogo.png',
                    width: 500, height: 300), // Adjusted size
              ),
              SizedBox(height: 20),
              Text(
                'Welcome to PillPoppin!',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 24, // Adjust the font size as needed
                  fontWeight: FontWeight
                      .bold, // You can adjust the font weight too if needed
                ),
              ),
              Text(
                'keep your health in check,\n one pill at a time!',
                style: TextStyle(
                  color: Color.fromARGB(255, 86, 87, 88),
                  fontFamily: 'Georgia', // Use Georgia font
                  fontSize: 20, // Adjust the font size as needed
                  fontStyle: FontStyle.italic, // Apply italic style
                ),
                textAlign: TextAlign.center, // Center align the text
              ),
              SizedBox(height: 20), // Adjust the space between text and button
              ElevatedButton(
                onPressed: () {
                  // Add navigation to next screen or functionality here
                },
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color.fromARGB(255, 238, 171, 194), // Pastel Pink
                        Color(0xFFF06292), // Slightly darker Pastel Pink
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      stops: [0.1, 1.0],
                    ),
                    borderRadius: BorderRadius.circular(30.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        offset: Offset(0, 4),
                        blurRadius: 4.0,
                        spreadRadius: 1.0,
                      ),
                    ],
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  child: Center(
                    child: Text(
                      'Let\'s get started!',
                      style: TextStyle(
                        fontSize: 16,
                        color: const Color.fromARGB(255, 0, 0, 0),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),

              SizedBox(height: 50), // Add some bottom margin if needed
            ],
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Image.asset(
              'images/Doctor1.png', // Replace 'your_photo.png' with your actual photo path
              width: 250, // Adjust the width as needed
              height: 250, // Adjust the height as needed
            ),
          ),
        ],
      ),
    );
  }
}

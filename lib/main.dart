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
          secondary: Color.fromARGB(255, 250, 157, 174), // Pastel Pink
          background: Color(0xFFFFFFFF), // White
          surface: Color(0xFFB3E5FC), // Pastel Bright Blue
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
      body: Column(
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
            style: ElevatedButton.styleFrom(
              alignment: Alignment.bottomCenter,
              backgroundColor:
                  Theme.of(context).colorScheme.secondary, // Pastel Pink
              foregroundColor:
                  Theme.of(context).colorScheme.onSecondary, // White
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              textStyle: TextStyle(fontSize: 16),
            ),
            child: Text('Let\'s get started!'),
          ),
          SizedBox(height: 50), // Add some bottom margin if needed
        ],
      ),
    );
  }
}

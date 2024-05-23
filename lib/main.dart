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
          secondary: Color(0xFFFFC1CC), // Pastel Pink
          background: Color(0xFFFFFFFF), // Pastel White
          surface: Color(0xFFB3E5FC), // Pastel Bright Blue
          onPrimary: Color(0xFFFFFFFF), // White
          onSecondary: Color(0xFFFFFFFF), // White
          onBackground: Color(0xFFB0BEC5), // Light Gray
          onSurface: Color(0xFFB0BEC5), // Light Gray
        ),
        textTheme: TextTheme(
          headline1:
              TextStyle(color: Color.fromARGB(255, 0, 0, 0)), // Light Gray
          bodyText1:
              TextStyle(color: Color.fromARGB(255, 0, 0, 0)), // Light Gray
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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              alignment: Alignment.topCenter,
              child:
                  Image.asset('images/FinalLogo.png', width: 300, height: 500),
            ), // Placeholder for logo image
            SizedBox(height: 20),
            Container(
              child: Text(
                'Welcome to PillPoppin!',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 24, // Adjust the font size as needed
                  fontWeight: FontWeight
                      .bold, // You can adjust the font weight too if needed
                ),
              ),
            ),

            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Add navigation to next screen or functionality here
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    Theme.of(context).colorScheme.primary, // Pastel Blue
                foregroundColor:
                    Theme.of(context).colorScheme.onPrimary, // White
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                textStyle: TextStyle(fontSize: 16),
              ),
              child: Text('Let\'s get started!'),
            ),
          ],
        ),
      ),
    );
  }
}

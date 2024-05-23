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
          headline1: TextStyle(color: Color(0xFFB0BEC5)), // Light Gray
          bodyText1: TextStyle(color: Color(0xFFB0BEC5)), // Light Gray
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
            Image.asset('images/FinalLogo.png',
                width: 150, height: 150), // Placeholder for logo image
            SizedBox(height: 20),
            Text(
              'Welcome to PillPoppin!',
              style: Theme.of(context).textTheme.headline4,
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
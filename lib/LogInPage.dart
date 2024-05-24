import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: LoginPage(),
    );
  }
}

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Define a common text style
    TextStyle commonTextStyle = TextStyle(
      color: Colors.blueGrey[900], // Darker shade of blue-grey for text
      fontSize: 20, // Increased font size for better readability
      fontWeight: FontWeight.w600, // Semi-bold weight
      fontStyle: FontStyle.italic, // Italic style for a creative touch
    );

    // Define a common border style
    OutlineInputBorder commonBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: Colors.black), // Set border color to black
    );

    return Scaffold(
      backgroundColor:
          Color.fromARGB(255, 217, 242, 255), // Set background color
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('images/FinalLogo.png'),
              SizedBox(height: 20),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Enter your Email',
                  labelStyle: commonTextStyle,
                  border: commonBorder, // Apply common border style
                  prefixIcon: Icon(Icons.email,
                      color: Colors.black), // Icon color set to black
                ),
              ),
              SizedBox(height: 20),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Enter your Password',
                  labelStyle: commonTextStyle,
                  border: commonBorder, // Apply common border style
                  prefixIcon: Icon(Icons.lock,
                      color: Colors.black), // Icon color set to black
                ),
                obscureText: true,
              ),
              SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    // Handle forgot password
                  },
                  child: Text(
                    'Forgot Password?',
                    style: commonTextStyle.copyWith(
                      color:
                          Colors.blueAccent, // Blue accent color for the button
                      fontStyle:
                          FontStyle.normal, // Normal font style for the button
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    // Handle login
                  },
                  borderRadius: BorderRadius.circular(30.0),
                  child: Ink(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color.fromARGB(255, 244, 167, 193), // Pastel Pink
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
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    child: Center(
                      child: Text(
                        'Log In',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.black, // Text color set to black
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: forgotPassword(),
    );
  }
}

class forgotPassword extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue[50],
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'images/FinalLogo.png', // Make sure to use the same image asset as in the login page
                height: 100,
              ),
              TextField(
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.email),
                  labelText: 'Enter your Email',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Implement forgot password functionality here
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      Color.fromARGB(255, 238, 154, 227), // Background color
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: Text(
                  'Send Reset Link',
                  style: TextStyle(fontSize: 16),
                ),
              ),
              SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Navigate back to the login page
                },
                child: Text(
                  'Back to Login',
                  style: TextStyle(color: Color.fromARGB(255, 238, 154, 227)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

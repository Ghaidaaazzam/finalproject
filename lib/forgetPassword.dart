import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ForgotPassword(),
    );
  }
}

class ForgotPassword extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 217, 242, 255),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'images/FinalLogo.png',
                height: 200,
              ),
              TextField(
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.email,
                      color: Colors.black), // Icon color set to black
                  labelText: 'Enter your Email',
                  labelStyle: TextStyle(
                      color: Colors.black), // Label text color set to black
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: Colors
                            .black), // Border color set to black when enabled
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: Colors
                            .black), // Border color set to black when focused
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                style: TextStyle(
                    color: Colors.black), // Input text color set to black
              ),

              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.all(50.0),
                child: Container(
                  height: 50,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        // Add navigation logic here
                      },
                      borderRadius: BorderRadius.circular(30.0),
                      child: Ink(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Color.fromARGB(255, 244, 167, 193),
                              Color(0xFFF06292),
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
                        padding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        child: Center(
                          child: Text(
                            'Send Reset Code',
                            style: TextStyle(
                              fontSize: 16,
                              color: const Color.fromARGB(255, 0, 0, 0),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              // Align(
              //   alignment: Alignment.centerLeft,
              //   child: TextButton(
              //     onPressed: () {
              //       Navigator.pop(context); // Navigate back to the login page
              //     },
              //     child: Row(
              //       mainAxisSize:
              //           MainAxisSize.min, // To align the icon and text properly
              //       children: <Widget>[
              //         Icon(Icons.arrow_back,
              //             color: Colors.black), // Back Icon with black color
              //         SizedBox(width: 8), // Space between icon and text
              //         Text(
              //           'Back to Login',
              //           style: TextStyle(
              //               color: Colors.black), // Text color set to black
              //         ),
              //       ],
              //     ),
              //   ),
              // ),
              // SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}

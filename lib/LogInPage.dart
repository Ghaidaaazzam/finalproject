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

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Define a common text style
  TextStyle commonTextStyle = TextStyle(
    color: Colors.blueGrey[900],
    fontSize: 20,
    fontWeight: FontWeight.w600,
    fontStyle: FontStyle.italic,
  );

  // Define a common border style
  OutlineInputBorder commonBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(8),
    borderSide: BorderSide(color: Colors.black),
  );

  // Define the forgot password button color
  Color _forgotPasswordButtonColor = Color.fromARGB(255, 24, 0, 162)!;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 217, 242, 255),
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
                  border: commonBorder,
                  prefixIcon: Icon(Icons.email, color: Colors.black),
                ),
              ),
              SizedBox(height: 20),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Enter your Password',
                  labelStyle: commonTextStyle,
                  border: commonBorder,
                  prefixIcon: Icon(Icons.lock, color: Colors.black),
                ),
                obscureText: true,
              ),
              SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  icon: Icon(Icons.vpn_key,
                      color: _forgotPasswordButtonColor), // Added icon
                  label: Text(
                    'Forgot Password?',
                    style: TextStyle(
                      decoration: TextDecoration.underline,
                      color: _forgotPasswordButtonColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: () {
                    // Handle forgot password
                  },
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
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
                          color: Colors.black,
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

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:finalproject/firebase_options.dart';
import 'forgetPassword.dart';
import 'myMedicines.dart'; // Import the MyMedicines page

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: LoginPage(),
      routes: {
        '/forgetPassword': (context) => ForgotPassword(),
      },
    );
  }
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final FocusNode _idFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  TextStyle commonTextStyle = TextStyle(
    color: Colors.blueGrey[900],
    fontSize: 20,
    fontWeight: FontWeight.w600,
    fontStyle: FontStyle.italic,
  );

  OutlineInputBorder commonBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(8),
    borderSide: BorderSide(color: Colors.black),
  );

  bool _isPasswordVisible = false;
  bool _isIdInvalid = false;
  bool _isPasswordInvalid = false;
  String _errorMessage = '';

  void _login() async {
    String enteredId = _idController.text;
    String enteredPassword = _passwordController.text;

    setState(() {
      _isIdInvalid = false;
      _isPasswordInvalid = false;
      _errorMessage = '';
    });

    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('patients')
          .where('ID', isEqualTo: enteredId)
          .where('Password', isEqualTo: enteredPassword)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login successful!')),
        );
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MyMedicines(userId: enteredId),
          ),
        );
      } else {
        setState(() {
          _isIdInvalid = true;
          _isPasswordInvalid = true;
          _errorMessage = 'Invalid ID or Password. Please try again.';
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 217, 242, 255),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('images/FinalLogo.png'),
              SizedBox(height: 20),
              TextField(
                controller: _idController,
                focusNode: _idFocusNode,
                decoration: InputDecoration(
                  labelText: 'Enter your ID',
                  labelStyle: commonTextStyle,
                  border: _isIdInvalid
                      ? commonBorder.copyWith(
                          borderSide: BorderSide(color: Colors.red))
                      : commonBorder,
                  focusedBorder: commonBorder,
                  prefixIcon: Icon(Icons.person, color: Colors.black),
                ),
                keyboardType: TextInputType.number,
                style: TextStyle(color: Colors.black),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _passwordController,
                focusNode: _passwordFocusNode,
                decoration: InputDecoration(
                  labelText: 'Enter your Password',
                  labelStyle: commonTextStyle,
                  border: _isPasswordInvalid
                      ? commonBorder.copyWith(
                          borderSide: BorderSide(color: Colors.red))
                      : commonBorder,
                  focusedBorder: commonBorder,
                  prefixIcon: Icon(Icons.lock, color: Colors.black),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: Colors.black,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),
                ),
                obscureText: !_isPasswordVisible,
                style: TextStyle(color: Colors.black),
              ),
              if (_isPasswordInvalid) // Display error message under the password field
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    _errorMessage,
                    style: TextStyle(color: Colors.red, fontSize: 14),
                  ),
                ),
              SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  icon: Icon(Icons.vpn_key, color: Colors.blue),
                  label: Text(
                    'Forgot Password?',
                    style: TextStyle(
                      decoration: TextDecoration.underline,
                      color: Colors.blue,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, '/forgetPassword');
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
                  onTap: _login,
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

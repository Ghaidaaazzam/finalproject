import 'package:flutter/material.dart';
import 'ResetPassword.dart'; // Import the ResetPassword page

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ForgotPassword(userId: 'exampleUserId'), // Add userId here
    );
  }
}

class ForgotPassword extends StatelessWidget {
  final String userId; // Add this line

  ForgotPassword({required this.userId}); // Add this line

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
                height: 300, // Increased the height to make the image bigger
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
                  child: CustomButton(
                    text: 'Send Reset Code',
                    fontSize: 18,
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            backgroundColor: Color.fromARGB(255, 217, 242, 255),
                            title: Text(
                              'Enter the code sent to your email',
                              style: TextStyle(color: Colors.black),
                            ),
                            content: VerificationCodeInput(),
                            actions: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: CustomButton(
                                      text: 'Cancel',
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: CustomButton(
                                      text: 'Submit',
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => ResetPassword(
                                                userId:
                                                    userId), // Add userId here
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class VerificationCodeInput extends StatefulWidget {
  @override
  _VerificationCodeInputState createState() => _VerificationCodeInputState();
}

class _VerificationCodeInputState extends State<VerificationCodeInput> {
  List<FocusNode> _focusNodes = List.generate(4, (index) => FocusNode());
  List<TextEditingController> _controllers =
      List.generate(4, (index) => TextEditingController());

  @override
  void dispose() {
    for (var node in _focusNodes) {
      node.dispose();
    }
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        for (var i = 0; i < 4; i++)
          Container(
            width: 40,
            child: TextField(
              controller: _controllers[i],
              focusNode: _focusNodes[i],
              maxLength: 1,
              decoration: InputDecoration(
                counterText: '',
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              style: TextStyle(color: Colors.black),
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              onChanged: (value) {
                if (value.length == 1 && i < 3) {
                  FocusScope.of(context).requestFocus(_focusNodes[i + 1]);
                }
                if (value.isEmpty && i > 0) {
                  FocusScope.of(context).requestFocus(_focusNodes[i - 1]);
                }
              },
            ),
          ),
      ],
    );
  }
}

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final double fontSize;

  CustomButton(
      {required this.text, required this.onPressed, this.fontSize = 14});

  @override
  Widget build(BuildContext context) {
    return Ink(
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
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(30.0),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                fontSize: fontSize,
                color: const Color.fromARGB(255, 0, 0, 0),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'LogInPage.dart';

class ResetPassword extends StatefulWidget {
  final String userId; // Add this line

  ResetPassword({required this.userId}); // Add this line

  @override
  _ResetPasswordState createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  TextEditingController _newPasswordController = TextEditingController();
  TextEditingController _confirmPasswordController = TextEditingController();
  String _errorMessage = '';
  bool _isNewPasswordError = false;
  bool _isConfirmPasswordError = false;

  void _resetPassword() {
    setState(() {
      _isNewPasswordError = _newPasswordController.text.isEmpty;
      _isConfirmPasswordError = _confirmPasswordController.text.isEmpty;
      if (_isNewPasswordError || _isConfirmPasswordError) {
        _errorMessage = 'Please fill in both fields';
      } else if (_newPasswordController.text !=
          _confirmPasswordController.text) {
        _errorMessage = 'Passwords do not match';
        _isConfirmPasswordError = true;
      } else {
        _updatePasswordInFirebase();
      }
    });
  }

  void _updatePasswordInFirebase() async {
    try {
      // Find the document by the field 'ID'
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('patients')
          .where('ID', isEqualTo: widget.userId)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        DocumentSnapshot userDoc = querySnapshot.docs.first;
        await FirebaseFirestore.instance
            .collection('patients')
            .doc(userDoc.id)
            .update({
          'Password': _newPasswordController.text,
        });

        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: Color.fromARGB(255, 217, 242, 255),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              title: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green),
                  SizedBox(width: 8),
                  Text(
                    'Success',
                    style: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              content: Text(
                'Password has been changed successfully.',
                style: TextStyle(fontSize: 18, color: Colors.black),
              ),
              actions: [
                Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    height: 40,
                    width: 80,
                    child: CustomButton(
                      text: 'OK',
                      fontSize: 16,
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  LoginPage()), // Change this to navigate to the login page
                        );
                      },
                    ),
                  ),
                ),
              ],
            );
          },
        );
      } else {
        setState(() {
          _errorMessage = 'User not found';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error updating password: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 217, 242, 255),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'images/FinalLogo.png',
                height: 300,
              ),
              TextField(
                controller: _newPasswordController,
                obscureText: _obscureNewPassword,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.lock, color: Colors.black),
                  labelText: 'Enter new password',
                  labelStyle: TextStyle(
                    color: _isNewPasswordError ? Colors.red : Colors.black,
                    fontSize: 18,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: _isNewPasswordError ? Colors.red : Colors.black),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: _isNewPasswordError ? Colors.red : Colors.black),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureNewPassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: Colors.black,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureNewPassword = !_obscureNewPassword;
                      });
                    },
                  ),
                ),
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                ),
                onTap: () {
                  setState(() {
                    _isNewPasswordError = false;
                  });
                },
              ),
              SizedBox(height: 20),
              TextField(
                controller: _confirmPasswordController,
                obscureText: _obscureConfirmPassword,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.lock, color: Colors.black),
                  labelText: 'Confirm new password',
                  labelStyle: TextStyle(
                    color: _isConfirmPasswordError ? Colors.red : Colors.black,
                    fontSize: 18,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: _isConfirmPasswordError
                            ? Colors.red
                            : Colors.black),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: _isConfirmPasswordError
                            ? Colors.red
                            : Colors.black),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: Colors.black,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
                  ),
                ),
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                ),
                onTap: () {
                  setState(() {
                    _isConfirmPasswordError = false;
                  });
                },
              ),
              if (_errorMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    _errorMessage,
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.all(50.0),
                child: Container(
                  height: 50,
                  child: CustomButton(
                    text: 'Reset Password',
                    fontSize: 18,
                    onPressed: _resetPassword,
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
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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

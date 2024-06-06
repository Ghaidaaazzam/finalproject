import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Edit Profile',
      theme: ThemeData(
        colorScheme: ColorScheme.light(
          primary: Color(0xFFA8DADC), // Pastel Blue
          secondary: Color(0xFFFF9DC6), // Pastel Pink
          background: Color.fromARGB(255, 217, 242, 255), // White
          surface: Color.fromARGB(255, 175, 227, 252), // Pastel Bright Blue
          onPrimary: Color(0xFFFFFFFF), // White
          onSecondary: Color.fromARGB(255, 0, 0, 0), // Black
          onBackground: Color(0xFFB0BEC5), // Light Gray
          onSurface: Color(0xFFB0BEC5), // Light Gray
        ),
      ),
      home: EditProfilePage(),
    );
  }
}

class EditProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 217, 242, 255),
      appBar: AppBar(
        backgroundColor: Color(0xFFA8DADC),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Profile',
          style: TextStyle(color: Colors.black),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.settings, color: Colors.black),
            onPressed: () {
              // Handle settings button
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            SizedBox(height: 20),
            CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage('assets/images/your_photo.png'),
              child: Align(
                alignment: Alignment.bottomRight,
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: 15,
                  child: Icon(
                    Icons.edit,
                    size: 20,
                    color: Colors.black, // Changed to black
                  ),
                ),
              ),
            ),
            SizedBox(height: 10),
            buildTextField('Full Name', 'John Doe'),
            buildTextField('Phone Number', '+123 567 89000'),
            buildTextField('Email', 'johndoe@example.com'),
            buildTextField('Date Of Birth', 'DD / MM / YYYY'),
            SizedBox(height: 30),
            Ink(
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
              child: InkWell(
                onTap: () {
                  // Handle update profile button press
                },
                borderRadius: BorderRadius.circular(30.0),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  child: Text(
                    'Update Profile',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTextField(String labelText, String placeholder) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: TextField(
        decoration: InputDecoration(
          contentPadding: EdgeInsets.only(bottom: 5),
          labelText: labelText,
          labelStyle: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          floatingLabelBehavior: FloatingLabelBehavior.always,
          hintText: placeholder,
          hintStyle: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
          filled: true,
          fillColor: Colors.white.withOpacity(0.5),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}

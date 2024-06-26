import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
      home: EditProfilePage(userId: 'ZExnO5oRMBJfQuR2VOoX'), // example userId
    );
  }
}

class EditProfilePage extends StatefulWidget {
  final String userId;

  EditProfilePage({required this.userId});

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late Future<DocumentSnapshot> userDoc;
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _emergencyContactController =
      TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  late Map<String, dynamic> initialData;
  String? docId; // Variable to hold the document ID

  @override
  void initState() {
    super.initState();
    _fetchUserDoc();
  }

  void _fetchUserDoc() {
    userDoc = FirebaseFirestore.instance
        .collection('patients')
        .where('ID', isEqualTo: widget.userId)
        .get()
        .then((QuerySnapshot querySnapshot) {
      if (querySnapshot.docs.isNotEmpty) {
        var doc = querySnapshot.docs.first;
        docId = doc.id; // Get the document ID
        initialData = doc.data() as Map<String, dynamic>;
        _fullNameController.text = initialData['FullName'];
        _phoneNumberController.text = initialData['Phone Number'];
        _emergencyContactController.text = initialData['Phone Number2'];
        _emailController.text = initialData['Email'];
        _dobController.text = initialData['Birthdate'];
        return doc;
      } else {
        throw Exception('User not found');
      }
    });
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  void _updateProfile() async {
    if (_fullNameController.text == initialData['FullName'] &&
        _phoneNumberController.text == initialData['Phone Number'] &&
        _emergencyContactController.text == initialData['Phone Number2'] &&
        _emailController.text == initialData['Email'] &&
        _dobController.text == initialData['Birthdate']) {
      _showSnackBar('No changes detected.');
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection('patients')
          .doc(docId) // Use the document ID to update
          .update({
        'FullName': _fullNameController.text,
        'Phone Number': _phoneNumberController.text,
        'Phone Number2': _emergencyContactController.text,
        'Email': _emailController.text,
        'Birthdate': _dobController.text,
      });
      _showSnackBar('Profile updated successfully!');
    } catch (e) {
      _showSnackBar('Error updating profile: $e');
    }
  }

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
      body: FutureBuilder<DocumentSnapshot>(
        future: userDoc,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error loading user data'));
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text('User not found'));
          }

          var userData = snapshot.data!.data() as Map<String, dynamic>;
          var gender = userData['Gender'];

          return SingleChildScrollView(
            padding: EdgeInsets.all(16.0),
            child: Column(
              children: [
                SizedBox(height: 20),
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.white,
                  child: ClipOval(
                    child: Image.asset(
                      gender == 'M' ? 'images/male.png' : 'images/female.png',
                      fit: BoxFit.cover,
                      width: 90,
                      height: 90,
                    ),
                  ),
                ),
                SizedBox(height: 10),
                buildTextField('Full Name', _fullNameController),
                buildTextField('Phone Number', _phoneNumberController),
                buildTextField(
                    'Emergency Contact Number', _emergencyContactController),
                buildTextField('Email', _emailController),
                buildTextField('Date Of Birth', _dobController),
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
                    onTap: _updateProfile,
                    borderRadius: BorderRadius.circular(30.0),
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 40, vertical: 15),
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
          );
        },
      ),
    );
  }

  Widget buildTextField(String labelText, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.only(bottom: 5),
          labelText: labelText,
          labelStyle: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          floatingLabelBehavior: FloatingLabelBehavior.always,
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

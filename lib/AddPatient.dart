import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

/*
This Flutter app allows doctors to add new patients to a Firestore database. 
It validates patient IDs using data from a CSV file, collects details like email and contact numbers, and ensures all fields are filled. After validation, the patient data, including a randomly generated password, is saved to Firestore. The app also 
provides navigation between different pages like Home, Prescription, Add Patient, and Manage Prescriptions using a bottom navigation bar.
 Upon successful submission, a success message is displayed, and the form fields are cleared.
*/
class AddPatientPage extends StatefulWidget {
  @override
  _AddPatientPageState createState() => _AddPatientPageState();
}

class _AddPatientPageState extends State<AddPatientPage> {
  final TextEditingController _patientIdController = TextEditingController();
  final TextEditingController _patientEmailController = TextEditingController();
  final TextEditingController _contactNumberController =
      TextEditingController();
  final TextEditingController _contactNumberController2 =
      TextEditingController();
  final FocusNode _patientIdFocusNode = FocusNode();
  final FocusNode _patientEmailFocusNode = FocusNode();
  final FocusNode _contactNumberFocusNode = FocusNode();
  final FocusNode _contactNumberFocusNode2 = FocusNode();
  bool _isPatientIdValid = true;
  bool _showErrorMessage = false;
  List<List<dynamic>> patientData = [];
  int _selectedIndex = 2;

  @override
  void initState() {
    super.initState();
    loadPatientData();

    _patientIdFocusNode.addListener(() {
      if (!_patientIdFocusNode.hasFocus) {
        _checkPatientId(_patientIdController.text);
      }
    });
  }

  @override
  void dispose() {
    _patientIdController.dispose();
    _patientEmailController.dispose();
    _contactNumberController.dispose();
    _contactNumberController2.dispose();
    _patientIdFocusNode.dispose();
    _patientEmailFocusNode.dispose();
    _contactNumberFocusNode.dispose();
    super.dispose();
  }

  Future<void> loadPatientData() async {
    try {
      final ByteData data = await rootBundle.load('Excels/Users.csv');
      final String csvData = String.fromCharCodes(data.buffer.asUint8List());
      List<List<dynamic>> rowsAsListOfValues =
          const CsvToListConverter().convert(csvData);

      patientData = rowsAsListOfValues;
    } catch (e) {
      print("Error reading CSV file: $e");
    }
  }

  void _checkPatientId(String id) {
    setState(() {
      _isPatientIdValid = patientData.any((row) =>
          row[0].toString() ==
          id); // Assuming Patient ID is in the first column
    });
  }

  String generateRandomPassword(int length) {
    const characters =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return String.fromCharCodes(Iterable.generate(length,
        (_) => characters.codeUnitAt(random.nextInt(characters.length))));
  }

  void _addPatient() async {
    setState(() {
      _showErrorMessage = !_isPatientIdValid ||
          _patientEmailController.text.isEmpty ||
          _contactNumberController.text.isEmpty ||
          _contactNumberController2.text.isEmpty;
    });

    if (!_showErrorMessage) {
      String randomPassword =
          generateRandomPassword(10); // Generate a 10-character password

      // Retrieve data from the CSV file based on Patient ID
      var patientRow = patientData
          .firstWhere((row) => row[0].toString() == _patientIdController.text);
      String fullName =
          "${patientRow[1]} ${patientRow[2]}"; // Assuming FirstName is in the second column and LastName in the third
      String birthdate =
          patientRow[4]; // Assuming Birthdate is in the fifth column
      String gender = patientRow[7];
      try {
        await FirebaseFirestore.instance.collection('patients').add({
          'FullName': fullName,
          'ID': _patientIdController.text,
          'Password': randomPassword,
          'Email': _patientEmailController.text,
          'Phone Number': _contactNumberController.text,
          'Phone Number2': _contactNumberController2.text,
          'Birthdate': birthdate,
          'Gender': gender,
          'FirstLogin': false, // Set initial value to false
        });

        // Clear the text fields after successful submission
        _patientIdController.clear();
        _patientEmailController.clear();
        _contactNumberController.clear();
        _contactNumberController2.clear();

        // Print success message to the console
        print('Patient added successfully with password: $randomPassword');

        // Show a success message using ScaffoldMessenger
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Patient added successfully!')),
        );
      } catch (e) {
        print('Error adding patient: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add patient. Please try again.')),
        );
      }
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    switch (index) {
      case 0:
        Navigator.pushNamed(
            context, '/doctorHome'); // Navigate to DoctorHomePage
        break;
      case 1:
        Navigator.pushNamed(
            context, '/prescription'); // Navigate to PrescriptionPage
        break;
      case 2:
        Navigator.pushNamed(context, '/addPatient');
        break;
      case 3:
        Navigator.pushNamed(context, '/managePrescriptions');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 217, 242, 255),
      appBar: null,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Add Patient',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 40),
                  TextField(
                    controller: _patientIdController,
                    focusNode: _patientIdFocusNode,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Patient ID',
                      labelStyle: TextStyle(
                        color: Colors.blueGrey[900],
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        fontStyle: FontStyle.italic,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      prefixIcon:
                          Icon(Icons.perm_identity, color: Colors.black),
                      errorText:
                          _isPatientIdValid ? null : 'Invalid Patient ID',
                    ),
                  ),
                  SizedBox(height: 30),
                  TextField(
                    controller: _patientEmailController,
                    focusNode: _patientEmailFocusNode,
                    decoration: InputDecoration(
                      labelText: 'Patient Email',
                      labelStyle: TextStyle(
                        color: Colors.blueGrey[900],
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        fontStyle: FontStyle.italic,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      prefixIcon: Icon(Icons.email, color: Colors.black),
                    ),
                  ),
                  SizedBox(height: 30),
                  TextField(
                    controller: _contactNumberController,
                    focusNode: _contactNumberFocusNode,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Contact Number',
                      labelStyle: TextStyle(
                        color: Colors.blueGrey[900],
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        fontStyle: FontStyle.italic,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      prefixIcon: Icon(Icons.phone, color: Colors.black),
                    ),
                  ),
                  SizedBox(height: 30),
                  TextField(
                    controller: _contactNumberController2,
                    focusNode: _contactNumberFocusNode2,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Contact Number 2',
                      labelStyle: TextStyle(
                        color: Colors.blueGrey[900],
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        fontStyle: FontStyle.italic,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      prefixIcon: Icon(Icons.phone, color: Colors.black),
                    ),
                  ),
                  SizedBox(height: 40),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _addPatient,
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
                            'Add Patient',
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
                  if (_showErrorMessage)
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: Text(
                        'Please correct the errors above before adding the patient.',
                        style: TextStyle(color: Colors.red, fontSize: 16),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black,
        showUnselectedLabels: true,
        selectedLabelStyle: TextStyle(color: Colors.black),
        unselectedLabelStyle: TextStyle(color: Colors.black),
        items: [
          BottomNavigationBarItem(
            icon: Image.asset(
              'images/SmallLogo.png',
              height: 50.0,
              width: 50.0,
            ),
            label: 'Home Page',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              'images/prescriptionIcon.png',
              height: 50.0,
              width: 50.0,
            ),
            label: 'Prescription',
          ),
          BottomNavigationBarItem(
            icon: Stack(
              children: <Widget>[
                Icon(
                  Icons.person,
                  color: Colors.black,
                  size: 40,
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Icon(
                    Icons.add_circle,
                    color: Colors.blue,
                    size: 24,
                  ),
                ),
              ],
            ),
            label: 'Add Patient',
          ),
          BottomNavigationBarItem(
            icon: Stack(
              children: <Widget>[
                Icon(
                  Icons.list_alt,
                  color: Colors.black,
                  size: 40,
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Icon(
                    Icons.edit,
                    color: Colors.blue,
                    size: 24,
                  ),
                ),
              ],
            ),
            label: 'Manage Prescriptions',
          ),
        ],
      ),
    );
  }
}

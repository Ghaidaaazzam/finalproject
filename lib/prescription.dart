import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PrescriptionPage extends StatefulWidget {
  @override
  _PrescriptionPageState createState() => _PrescriptionPageState();
}

class _PrescriptionPageState extends State<PrescriptionPage> {
  int _selectedIndex = 1;

  TextEditingController startDateController = TextEditingController();
  TextEditingController endDateController = TextEditingController();
  TextEditingController patientIdController = TextEditingController();
  TextEditingController medicineNameController = TextEditingController();
  TextEditingController dailyDoseController = TextEditingController();
  TextEditingController pillsPerDoseController = TextEditingController();
  TextEditingController doctorNoticeController = TextEditingController();

  List<String> medicineNames = [];
  Map<String, Map<String, dynamic>> medicineData = {};

  bool _isPatientIdValid = true;
  bool _isFormValid = true;
  String _formErrorMessage = '';
  String medicineForm = '';
  int medicineCapacity = 0;

  @override
  void initState() {
    super.initState();
    _loadMedicineNames();

    patientIdController.addListener(() {
      if (!patientIdController.text.isEmpty) {
        _checkPatientId(patientIdController.text);
      }
    });
  }

  void _loadMedicineNames() async {
    final data = await rootBundle.loadString('Excels/Medicine.csv');
    final lines = LineSplitter.split(data);
    for (var line in lines) {
      final values = line.split(',');
      if (values.isNotEmpty) {
        print('Loaded line: $values'); // Debug print
        medicineNames
            .add(values[0]); // Assuming the first column is the medicine name
        if (values.length > 4) {
          final capacity = _extractNumber(
              values[4]); // Extract numerical part from the fourth column
          print(
              'Extracted capacity for ${values[0]}: $capacity'); // Debug print
          medicineData[values[0]] = {'form': values[1], 'capacity': capacity};
        } else {
          print('Error: Unexpected format in line: $line');
        }
      }
    }
    setState(() {});
  }

  int _extractNumber(String input) {
    final RegExp regex = RegExp(r'\d+');
    final match = regex.firstMatch(input);
    return match != null ? int.parse(match.group(0)!) : 0;
  }

  Future<void> _checkPatientId(String id) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('patients')
        .where('ID', isEqualTo: id)
        .get();

    setState(() {
      _isPatientIdValid = querySnapshot.docs.isNotEmpty;
    });
  }

  void _onItemTapped(int index) {
    switch (index) {
      case 0:
        Navigator.pushNamed(context, '/');
        break;
      case 1:
        Navigator.pushNamed(context, '/prescription');
        break;
      case 2:
        Navigator.pushNamed(context, '/addPatient');
        break;
    }
  }

  Future<void> _selectDate(
      BuildContext context, TextEditingController controller) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: Colors.pink,
            colorScheme: ColorScheme.light(
                primary: Colors.pink, secondary: Colors.pinkAccent),
            buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        controller.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  void _showCancelConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color.fromARGB(255, 255, 228, 237),
          title: Text(
            'Cancel Confirmation',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          content: Text(
            'Are you sure you want to cancel?',
            style: TextStyle(
              fontSize: 18,
              color: Colors.black,
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('No'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.black,
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  patientIdController.clear();
                  medicineNameController.clear();
                  dailyDoseController.clear();
                  pillsPerDoseController.clear();
                  startDateController.clear();
                  endDateController.clear();
                  doctorNoticeController.clear();
                });
              },
              child: Text('Yes'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.black,
              ),
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        );
      },
    );
  }

  bool _validateForm() {
    if (patientIdController.text.isEmpty ||
        medicineNameController.text.isEmpty ||
        dailyDoseController.text.isEmpty ||
        pillsPerDoseController.text.isEmpty ||
        startDateController.text.isEmpty ||
        endDateController.text.isEmpty) {
      setState(() {
        _isFormValid = false;
        _formErrorMessage = 'All fields except Doctor Notice are required.';
      });
      return false;
    }
    setState(() {
      _isFormValid = true;
      _formErrorMessage = '';
    });
    return true;
  }

  Future<void> _addPrescription() async {
    if (!_validateForm()) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text(_formErrorMessage),
            actions: <Widget>[
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
      return;
    }

    String patientId = patientIdController.text;

    final querySnapshot = await FirebaseFirestore.instance
        .collection('patients')
        .where('ID', isEqualTo: patientId)
        .get();

    if (querySnapshot.docs.isEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('Patient not found.'),
            actions: <Widget>[
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
      return;
    }

    DocumentReference patientDoc = querySnapshot.docs.first.reference;
    CollectionReference prescriptions = patientDoc.collection('prescriptions');

    String medicineName = medicineNameController.text;
    String dailyDose = dailyDoseController.text;
    int pillsPerDose =
        int.parse(pillsPerDoseController.text); // Parsing as integer
    String startDate = startDateController.text;
    String endDate = endDateController.text;
    String doctorNotice = doctorNoticeController.text;

    int capacity = medicineData[medicineName]!['capacity'] as int;
    print('Adding prescription with capacity: $capacity'); // Debug print

    DocumentReference newPrescriptionRef = prescriptions.doc();
    String prescriptionId = newPrescriptionRef.id;

    await newPrescriptionRef.set({
      'prescriptionId': prescriptionId,
      'medicineName': medicineName,
      'dailyDose': dailyDose,
      'pillsPerDose': pillsPerDose,
      'startDate': startDate,
      'endDate': endDate,
      'doctorNotice': doctorNotice,
      'capacity': capacity,
    });

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Success'),
          content: Text('Prescription added successfully.'),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );

    setState(() {
      patientIdController.clear();
      medicineNameController.clear();
      dailyDoseController.clear();
      pillsPerDoseController.clear();
      startDateController.clear();
      endDateController.clear();
      doctorNoticeController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 217, 242, 255),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 50),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Add Prescription',
                    style: TextStyle(
                      color: Colors.blueGrey[900],
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 40),
                TextField(
                  controller: patientIdController,
                  keyboardType: TextInputType.number,
                  style: TextStyle(fontSize: 16),
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.account_circle),
                    labelText: 'Patient Id',
                    labelStyle: TextStyle(
                      color: Colors.blueGrey[900],
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.black),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.black, width: 2.0),
                    ),
                    errorText: _isPatientIdValid ? null : 'Invalid Patient ID',
                  ),
                ),
                SizedBox(height: 20),
                TypeAheadField<String>(
                  textFieldConfiguration: TextFieldConfiguration(
                    controller: medicineNameController,
                    style: TextStyle(fontSize: 16),
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.medical_services),
                      labelText: 'Name of Medicine',
                      labelStyle: TextStyle(
                        color: Colors.blueGrey[900],
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.black, width: 2.0),
                      ),
                    ),
                  ),
                  suggestionsCallback: (pattern) {
                    return medicineNames.where((name) =>
                        name.toLowerCase().contains(pattern.toLowerCase()));
                  },
                  itemBuilder: (context, suggestion) {
                    return ListTile(
                      title: Text(suggestion),
                    );
                  },
                  onSuggestionSelected: (suggestion) {
                    setState(() {
                      medicineNameController.text = suggestion;
                      medicineForm = medicineData[suggestion]!['form']!;
                      medicineCapacity = medicineData[suggestion]!['capacity']!;
                      print(
                          'Selected medicine: $suggestion, Form: $medicineForm, Capacity: $medicineCapacity'); // Debug print
                    });
                  },
                ),
                SizedBox(height: 20),
                Text(
                  'Selected Medicine Form: $medicineForm',
                  style: TextStyle(fontSize: 16, color: Colors.blueGrey[900]),
                ),
                SizedBox(height: 20),
                Text(
                  'Selected Medicine Capacity: $medicineCapacity',
                  style: TextStyle(fontSize: 16, color: Colors.blueGrey[900]),
                ),
                SizedBox(height: 20),
                TextField(
                  controller: dailyDoseController,
                  keyboardType: TextInputType.number,
                  style: TextStyle(fontSize: 16),
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.repeat),
                    labelText: _getDailyDoseLabel(),
                    labelStyle: TextStyle(
                      color: Colors.blueGrey[900],
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.black),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.black, width: 2.0),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                TextField(
                  controller: pillsPerDoseController,
                  keyboardType: TextInputType.number,
                  style: TextStyle(fontSize: 16),
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.format_list_numbered),
                    labelText: _getPillsPerDoseLabel(),
                    labelStyle: TextStyle(
                      color: Colors.blueGrey[900],
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.black),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.black, width: 2.0),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                TextField(
                  controller: startDateController,
                  style: TextStyle(fontSize: 16),
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.date_range),
                    labelText: 'Enter the start Date',
                    labelStyle: TextStyle(
                      color: Colors.blueGrey[900],
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.black),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.black, width: 2.0),
                    ),
                  ),
                  onTap: () {
                    FocusScope.of(context).requestFocus(new FocusNode());
                    _selectDate(context, startDateController);
                  },
                ),
                SizedBox(height: 20),
                TextField(
                  controller: endDateController,
                  style: TextStyle(fontSize: 16),
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.date_range),
                    labelText: 'Enter the end Date',
                    labelStyle: TextStyle(
                      color: Colors.blueGrey[900],
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.black),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.black, width: 2.0),
                    ),
                  ),
                  onTap: () {
                    FocusScope.of(context).requestFocus(new FocusNode());
                    _selectDate(context, endDateController);
                  },
                ),
                SizedBox(height: 20),
                TextField(
                  controller: doctorNoticeController,
                  style: TextStyle(fontSize: 16),
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.notes),
                    labelText: 'Doctor Notice',
                    labelStyle: TextStyle(
                      color: Colors.blueGrey[900],
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.black),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.black, width: 2.0),
                    ),
                  ),
                  maxLines: 3,
                ),
                SizedBox(height: 20),
                _isFormValid
                    ? Container()
                    : Text(
                        _formErrorMessage,
                        style: TextStyle(color: Colors.red, fontSize: 16),
                      ),
                SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            _showCancelConfirmationDialog(context);
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
                            padding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 12),
                            child: Center(
                              child: Text(
                                'Cancel',
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
                    ),
                    SizedBox(width: 20),
                    Expanded(
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: _addPrescription,
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
                            padding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 12),
                            child: Center(
                              child: Text(
                                'Submit',
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
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: [
          BottomNavigationBarItem(
            icon: Image.asset(
              'images/SmallLogo.png',
              height: 50.0,
              width: 50.0,
            ),
            label: 'Logo',
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
                  Icons.person,
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
            label: 'Edit Profile',
          ),
        ],
      ),
    );
  }

  String _getDailyDoseLabel() {
    switch (medicineForm.toLowerCase()) {
      case 'pill (tablet)':
        return 'How many pills (tablets) in each day?';
      case 'capsule':
        return 'How many capsules in each day?';
      case 'liquid (syrup)':
        return 'How many ml in each day?';
      case 'injection (shot)':
        return 'How many injections in each day?';
      case 'inhaler':
        return 'How many puffs in each day?';
      case 'topical (cream/ointment)':
        return 'How many applications in each day?';
      case 'suppository':
        return 'How many suppositories in each day?';
      case 'patch (transdermal)':
        return 'How many patches in each day?';
      case 'drops (eye/ear)':
        return 'How many drops in each day?';
      case 'powder (for reconstitution)':
        return 'How many doses in each day?';
      default:
        return 'How many in each day?';
    }
  }

  String _getPillsPerDoseLabel() {
    switch (medicineForm.toLowerCase()) {
      case 'pill (tablet)':
        return 'How many pills (tablets) to take in a time?';
      case 'capsule':
        return 'How many capsules to take in a time?';
      case 'liquid (syrup)':
        return 'How many ml to take in a time?';
      case 'injection (shot)':
        return 'How many injections to take in a time?';
      case 'inhaler':
        return 'How many puffs to take in a time?';
      case 'topical (cream/ointment)':
        return 'How many applications to take in a time?';
      case 'suppository':
        return 'How many suppositories to take in a time?';
      case 'patch (transdermal)':
        return 'How many patches to use in a time?';
      case 'drops (eye/ear)':
        return 'How many drops to take in a time?';
      case 'powder (for reconstitution)':
        return 'How many doses to take in a time?';
      default:
        return 'How many to take in a time?';
    }
  }
}

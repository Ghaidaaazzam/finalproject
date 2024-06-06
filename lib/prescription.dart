import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: PrescriptionPage(),
    );
  }
}

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
          backgroundColor:
              Color.fromARGB(255, 255, 228, 237), // Kept background color
          title: Text(
            'Cancel Confirmation',
            style: TextStyle(
              fontSize: 18, // Increased font size
              fontWeight: FontWeight.bold,
              color: Colors.black, // Text color changed to black
            ),
          ),
          content: Text(
            'Are you sure you want to cancel?',
            style: TextStyle(
              fontSize: 18, // Increased font size for the note
              color: Colors.black, // Text color changed to black
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('No'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.black, // Text color changed to black
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                setState(() {
                  // Clear all the fields
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
                foregroundColor: Colors.black, // Text color changed to black
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
                  style: TextStyle(fontSize: 16), // Adjusted font size
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.account_circle),
                    labelText: 'Patient Id',
                    labelStyle: TextStyle(
                      color: Colors.blueGrey[900],
                      fontSize: 16, // Adjusted font size
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
                  controller: medicineNameController,
                  style: TextStyle(fontSize: 16), // Adjusted font size
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.medical_services),
                    labelText: 'Name of Medicine',
                    labelStyle: TextStyle(
                      color: Colors.blueGrey[900],
                      fontSize: 16, // Adjusted font size
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
                  controller: dailyDoseController,
                  keyboardType: TextInputType.number,
                  style: TextStyle(fontSize: 16), // Adjusted font size
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.repeat),
                    labelText: 'How many in each day?',
                    labelStyle: TextStyle(
                      color: Colors.blueGrey[900],
                      fontSize: 16, // Adjusted font size
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
                  style: TextStyle(fontSize: 16), // Adjusted font size
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.format_list_numbered),
                    labelText: 'How many pills to take in a time?',
                    labelStyle: TextStyle(
                      color: Colors.blueGrey[900],
                      fontSize: 16, // Adjusted font size
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
                  style: TextStyle(fontSize: 16), // Adjusted font size
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.date_range),
                    labelText: 'Enter the start Date',
                    labelStyle: TextStyle(
                      color: Colors.blueGrey[900],
                      fontSize: 16, // Adjusted font size
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
                  style: TextStyle(fontSize: 16), // Adjusted font size
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.date_range),
                    labelText: 'Enter the end Date',
                    labelStyle: TextStyle(
                      color: Colors.blueGrey[900],
                      fontSize: 16, // Adjusted font size
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
                  style: TextStyle(fontSize: 16), // Adjusted font size
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.notes),
                    labelText: 'Doctor Notice',
                    labelStyle: TextStyle(
                      color: Colors.blueGrey[900],
                      fontSize: 16, // Adjusted font size
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
                                horizontal: 12,
                                vertical: 12), // Adjusted padding
                            child: Center(
                              child: Text(
                                'Cancel',
                                style: TextStyle(
                                  fontSize: 18, // Adjusted font size
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
                          onTap: () {
                            // Handle submit action
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
                                horizontal: 12,
                                vertical: 12), // Adjusted padding
                            child: Center(
                              child: Text(
                                'Submit',
                                style: TextStyle(
                                  fontSize: 18, // Adjusted font size
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
}

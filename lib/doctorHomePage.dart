import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:finalproject/firebase_options.dart';
import 'prescription.dart';
import 'AddPatient.dart';
import 'TrackMedicineIntakePage.dart';
import 'LoginPage.dart'; // Import the login page
import 'ManagePrescriptionsPage.dart';

/*
The `DoctorHomePage` in this code provides a dashboard for doctors to manage prescriptions and patients. 
It displays a list of prescriptions that are about to end, with filters for patient ID and days left until the prescription expires. 
The doctor can also add new patients, manage prescriptions, and track medicine intake for patients. Additionally, there is functionality to renew prescriptions through a pop-up dialog, where the doctor can edit details such as daily dose, pills per dose, and prescription dates. 
The app supports navigation between different pages using a bottom navigation bar, including options to log out and refresh the page.
*/
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
      initialRoute: '/',
      routes: {
        '/': (context) => DoctorHomePage(),
        '/prescription': (context) => PrescriptionPage(),
        '/doctorHome': (context) => DoctorHomePage(),
        '/addPatient': (context) => AddPatientPage(),
        '/trackMedicineIntake': (context) => TrackMedicineIntakePage(),
        '/login': (context) => LoginPage(), // Add the login page route
        '/managePrescriptions': (context) =>
            ManagePrescriptionsPage(), // Add the manage prescriptions page route
      },
    );
  }
}

class DoctorHomePage extends StatefulWidget {
  @override
  _DoctorHomePageState createState() => _DoctorHomePageState();
}

class _DoctorHomePageState extends State<DoctorHomePage> {
  int _selectedIndex = 0;
  String idFilter = '';
  int? daysLeftFilter;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    switch (index) {
      case 0:
        break;
      case 1:
        Navigator.pushNamed(context, '/prescription');
        break;
      case 2:
        Navigator.pushNamed(context, '/addPatient');
        break;
      case 3:
        Navigator.pushNamed(context, '/managePrescriptions');
        break;
    }
  }

  DateTime _calculateExpectedEndDate(
      int capacity, int dailyDose, int pillsPerDose) {
    int totalDosesLeft = capacity ~/ pillsPerDose;
    int daysLeft = totalDosesLeft ~/ dailyDose;
    return DateTime.now().add(Duration(days: daysLeft));
  }

  Future<List<Map<String, dynamic>>> _fetchAllPrescriptions() async {
    List<Map<String, dynamic>> allPrescriptions = [];

    QuerySnapshot patientsSnapshot =
        await FirebaseFirestore.instance.collection('patients').get();
    for (var patientDoc in patientsSnapshot.docs) {
      final patientData = patientDoc.data() as Map<String, dynamic>;
      final patientName = patientData['FullName'];
      final patientId = patientData['ID'];

      QuerySnapshot prescriptionsSnapshot = await FirebaseFirestore.instance
          .collection('patients')
          .doc(patientDoc.id)
          .collection('prescriptions')
          .get();

      for (var prescriptionDoc in prescriptionsSnapshot.docs) {
        final prescriptionData = prescriptionDoc.data() as Map<String, dynamic>;

        int capacity = prescriptionData['capacity'] is int
            ? prescriptionData['capacity']
            : int.parse(prescriptionData['capacity'].toString());
        int dailyDose = prescriptionData['dailyDose'] is int
            ? prescriptionData['dailyDose']
            : int.parse(prescriptionData['dailyDose'].toString());
        int pillsPerDose = prescriptionData['pillsPerDose'] is int
            ? prescriptionData['pillsPerDose']
            : int.parse(prescriptionData['pillsPerDose'].toString());

        DateTime expectedEndDate =
            _calculateExpectedEndDate(capacity, dailyDose, pillsPerDose);
        int daysLeft = expectedEndDate.difference(DateTime.now()).inDays;

        if (daysLeft <= 7) {
          allPrescriptions.add({
            'patientName': patientName,
            'patientId': patientId,
            'medicineName': prescriptionData['medicineName'],
            'expectedEndDate': expectedEndDate,
            'daysLeft': daysLeft,
            'isUrgent': daysLeft <= 2,
          });
        }
      }
    }

    return allPrescriptions;
  }

  void _logout() {
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    DateFormat dateFormat = DateFormat('yyyy-MM-dd');

    return Scaffold(
      backgroundColor: Color.fromARGB(255, 217, 242, 255),
      appBar: AppBar(
        title: Text(
          'Doctor Home Page',
          style:
              TextStyle(color: Colors.black), // Change the text color to black
        ),
        backgroundColor: Color.fromARGB(255, 244, 167, 193),
        iconTheme: IconThemeData(
            color: Colors.black), // Change the icon color to black
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              setState(() {});
            },
          ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Prescriptions Ending Soon',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey[900],
              ),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: 'Filter by ID',
                      labelStyle: TextStyle(color: Colors.black),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      prefixIcon: Icon(Icons.search, color: Colors.black),
                    ),
                    style: TextStyle(color: Colors.black),
                    onChanged: (value) {
                      setState(() {
                        idFilter = value;
                      });
                    },
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: 'Days Left (<=)',
                      labelStyle: TextStyle(color: Colors.black),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      prefixIcon: Icon(Icons.filter_alt, color: Colors.black),
                    ),
                    keyboardType: TextInputType.number,
                    style: TextStyle(color: Colors.black),
                    onChanged: (value) {
                      setState(() {
                        daysLeftFilter =
                            value.isEmpty ? null : int.tryParse(value);
                      });
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _fetchAllPrescriptions(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Something went wrong'));
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('No prescriptions found'));
                  }

                  List<Map<String, dynamic>> filteredPrescriptions =
                      snapshot.data!.where((prescription) {
                    return (idFilter.isEmpty ||
                            prescription['patientId'].contains(idFilter)) &&
                        (daysLeftFilter == null ||
                            prescription['daysLeft'] <= daysLeftFilter!);
                  }).toList();

                  return ListView.builder(
                    itemCount: filteredPrescriptions.length,
                    itemBuilder: (context, index) {
                      var prescription = filteredPrescriptions[index];
                      bool isUrgent = prescription['isUrgent'];
                      return Card(
                        color: isUrgent ? Colors.red[50] : Colors.white,
                        margin: EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          leading: isUrgent
                              ? Icon(Icons.warning, color: Colors.red)
                              : null,
                          title: Text(
                            '${prescription['patientName']} (ID: ${prescription['patientId']})',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.blueGrey[900],
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                prescription['medicineName'],
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.blueGrey[700],
                                ),
                              ),
                              Text(
                                'Ends on: ${dateFormat.format(prescription['expectedEndDate'])}',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.blueGrey[700],
                                ),
                              ),
                              Text(
                                'Days left: ${prescription['daysLeft']}',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: isUrgent
                                      ? Colors.red
                                      : Colors.blueGrey[700],
                                  fontWeight: isUrgent
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                          trailing: IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () => _renewPrescription(prescription),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/trackMedicineIntake');
              },
              child: Text('Track Medicine Intake'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromARGB(255, 244, 167, 193),
                foregroundColor: Colors.blueGrey[900],
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                textStyle: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
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

  void _renewPrescription(Map<String, dynamic> prescription) {
    TextEditingController dailyDoseController =
        TextEditingController(text: prescription['dailyDose'].toString());
    TextEditingController pillsPerDoseController =
        TextEditingController(text: prescription['pillsPerDose'].toString());
    TextEditingController doctorNoticeController =
        TextEditingController(text: prescription['doctorNotice'] ?? '');
    TextEditingController startDateController = TextEditingController(
        text: DateFormat('yyyy-MM-dd').format(prescription['startDate']));
    TextEditingController endDateController = TextEditingController(
        text: DateFormat('yyyy-MM-dd').format(prescription['endDate']));

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color.fromARGB(255, 217, 242, 255), // צבע רקע חלון
          title: Text(
            'Renew Prescription for ${prescription['medicineName']}',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.blueGrey[900],
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: dailyDoseController,
                  decoration: InputDecoration(
                    labelText: 'Daily Dose',
                    labelStyle: TextStyle(
                      color: Colors.blueGrey[900],
                      fontSize: 18,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.black),
                    ),
                  ),
                  style: TextStyle(color: Colors.black),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: pillsPerDoseController,
                  decoration: InputDecoration(
                    labelText: 'Pills Per Dose',
                    labelStyle: TextStyle(
                      color: Colors.blueGrey[900],
                      fontSize: 18,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.black),
                    ),
                  ),
                  style: TextStyle(color: Colors.black),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: doctorNoticeController,
                  decoration: InputDecoration(
                    labelText: 'Doctor Notice',
                    labelStyle: TextStyle(
                      color: Colors.blueGrey[900],
                      fontSize: 18,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.black),
                    ),
                  ),
                  style: TextStyle(color: Colors.black),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: startDateController,
                  decoration: InputDecoration(
                    labelText: 'Start Date',
                    labelStyle: TextStyle(
                      color: Colors.blueGrey[900],
                      fontSize: 18,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.black),
                    ),
                  ),
                  readOnly: true,
                  style: TextStyle(color: Colors.black),
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: prescription['startDate'],
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2101),
                    );
                    if (pickedDate != null) {
                      startDateController.text =
                          DateFormat('yyyy-MM-dd').format(pickedDate);
                    }
                  },
                ),
                SizedBox(height: 10),
                TextField(
                  controller: endDateController,
                  decoration: InputDecoration(
                    labelText: 'End Date',
                    labelStyle: TextStyle(
                      color: Colors.blueGrey[900],
                      fontSize: 18,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.black),
                    ),
                  ),
                  readOnly: true,
                  style: TextStyle(color: Colors.black),
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: prescription['endDate'],
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2101),
                    );
                    if (pickedDate != null) {
                      endDateController.text =
                          DateFormat('yyyy-MM-dd').format(pickedDate);
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.blueGrey[900],
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(
                'Save',
                style: TextStyle(
                  color: Colors.blueGrey[900],
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () {
                setState(() {
                  prescription['dailyDose'] = dailyDoseController.text;
                  prescription['pillsPerDose'] = pillsPerDoseController.text;
                  prescription['doctorNotice'] = doctorNoticeController.text;
                  prescription['startDate'] =
                      DateFormat('yyyy-MM-dd').parse(startDateController.text);
                  prescription['endDate'] =
                      DateFormat('yyyy-MM-dd').parse(endDateController.text);
                });
                Navigator.of(context).pop();
              },
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        );
      },
    );
  }
}

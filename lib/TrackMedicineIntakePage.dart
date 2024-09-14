import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:url_launcher/url_launcher.dart'; // Import the url_launcher package
import 'package:intl/intl.dart'; // Import the intl package

/*
This code provides a `TrackMedicineIntakePage` interface that allows tracking of a patient's medication intake. 
It enables users to search for a patient by their ID, displaying detailed medication intake information, including how much of their medication was taken or missed each day. 
The app uses Firebase Firestore to fetch patient and prescription data, and the results are visualized through stacked bars representing taken and missed doses. 
The interface also includes an emergency contact feature, allowing users to call or message the emergency contact listed for a patient.
*/

class TrackMedicineIntakePage extends StatefulWidget {
  @override
  _TrackMedicineIntakePageState createState() =>
      _TrackMedicineIntakePageState();
}

class _TrackMedicineIntakePageState extends State<TrackMedicineIntakePage> {
  TextEditingController _patientIdController = TextEditingController();
  Map<String, dynamic> patientData = {};
  List<Widget> barChartData = [];
  List<String> patientIds = [];
  String emergencyContact = '';

  @override
  void initState() {
    super.initState();
    fetchPatientIds();
  }

  Future<void> fetchPatientIds() async {
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('patients').get();
      List<String> ids = snapshot.docs
          .map((doc) => (doc.data() as Map<String, dynamic>)['ID'].toString())
          .toList();
      setState(() {
        patientIds = ids;
      });
    } catch (e) {
      print('Error fetching patient IDs: $e');
    }
  }

  Future<void> fetchPatientData(String patientId) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('patients')
          .where('ID', isEqualTo: patientId)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        DocumentSnapshot userDoc = querySnapshot.docs.first;
        Map<String, dynamic>? data = userDoc.data() as Map<String, dynamic>?;

        String emergencyContact = data?['phoneNumber2'] ?? '';
        List<Map<String, dynamic>> medicineIntake = [];

        QuerySnapshot prescriptionsSnapshot =
            await userDoc.reference.collection('prescriptions').get();
        for (var doc in prescriptionsSnapshot.docs) {
          var prescriptionData = doc.data() as Map<String, dynamic>?;
          String medicineName =
              prescriptionData?['medicineName'] ?? 'Unknown Medicine';
          int dailyDose =
              int.tryParse(prescriptionData?['dailyDose'] ?? '1') ?? 1;

          QuerySnapshot dailySnapshot =
              await doc.reference.collection('medicines').get();
          for (var dailyDoc in dailySnapshot.docs) {
            var dailyData = dailyDoc.data() as Map<String, dynamic>?;
            DateTime date = (dailyData?['date'] as Timestamp).toDate();

            QuerySnapshot takeOrMissSnapshot =
                await dailyDoc.reference.collection('takeOrMiss').get();

            int takenCount = 0;
            int missedCount = 0;

            for (var takeOrMissDoc in takeOrMissSnapshot.docs) {
              var takeOrMissData =
                  takeOrMissDoc.data() as Map<String, dynamic>?;
              bool taken = takeOrMissData?['taken'] ?? false;
              if (taken) {
                takenCount++;
              } else {
                missedCount++;
              }
            }

            medicineIntake.add({
              'date': DateFormat('yyyy-MM-dd').format(date),
              'medicine': medicineName,
              'dailyDose': dailyDose,
              'taken': takenCount,
              'missed': dailyDose - takenCount,
            });
          }
        }

        setState(() {
          patientData = {
            'patientName': data?['FullName'] ?? 'Unknown',
            'phoneNumber2': emergencyContact,
            'medicineIntake': medicineIntake,
          };
          _generateData();
        });
      } else {
        setState(() {
          patientData = {};
          barChartData = [];
          emergencyContact = '';
        });
      }
    } catch (e) {
      print('Error fetching patient data: $e');
    }
  }

  void _generateData() {
    List<Widget> tempList = [];
    for (var intake in patientData['medicineIntake'] ?? []) {
      double total = intake['dailyDose'].toDouble();
      double takenPercentage = intake['taken'].toDouble() / total;
      double missedPercentage = intake['missed'].toDouble() / total;

      tempList.add(
        Card(
          margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.calendar_today, color: Colors.blueGrey[900]),
                    SizedBox(width: 8),
                    Text(
                      intake['date'] ?? '',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueGrey[900],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  'Medicine: ${intake['medicine'] ?? ''}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey[900],
                  ),
                ),
                SizedBox(height: 8),
                Stack(
                  children: [
                    Container(
                      height: 20,
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(missedPercentage),
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    FractionallySizedBox(
                      widthFactor: takenPercentage,
                      child: Container(
                        height: 20,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green, size: 18),
                        SizedBox(width: 4),
                        Text(
                          'Taken: ${intake['taken'] ?? 0}',
                          style: TextStyle(fontSize: 14, color: Colors.green),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(Icons.cancel, color: Colors.red, size: 18),
                        SizedBox(width: 4),
                        Text(
                          'Missed: ${intake['missed'] ?? 0} (${intake['missed'] ?? 0}/$total)',
                          style: TextStyle(fontSize: 14, color: Colors.red),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }
    setState(() {
      barChartData = tempList;
    });
  }

  void _searchPatient(String patientId) {
    fetchPatientData(patientId);
  }

  void _resetSearch() {
    setState(() {
      _patientIdController.clear();
      patientData = {};
      barChartData = [];
      emergencyContact = '';
    });
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    await launchUrl(launchUri);
  }

  Future<void> _sendSMS(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'sms',
      path: phoneNumber,
    );
    await launchUrl(launchUri);
  }

  void _showEmergencyContact() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color.fromARGB(255, 217, 242, 255),
          title: Text(
            'Emergency Contact',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.blueGrey[900],
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.phone, size: 40, color: Colors.redAccent),
              SizedBox(height: 10),
              Text(
                'Phone Number: $emergencyContact',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.blueGrey[700],
                ),
              ),
              SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: () => _makePhoneCall(emergencyContact),
                icon: Icon(Icons.call),
                label: Text('Call'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green, // Correct parameter name
                ),
              ),
              SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: () => _sendSMS(emergencyContact),
                icon: Icon(Icons.message),
                label: Text('Message'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue, // Correct parameter name
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text(
                'Close',
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
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 217, 242, 255),
      appBar: AppBar(
        title: Text(
          'Track Medicine Intake',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Color.fromARGB(255, 217, 242, 255),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TypeAheadFormField<String?>(
              textFieldConfiguration: TextFieldConfiguration(
                controller: _patientIdController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Enter Patient ID',
                  labelStyle: TextStyle(color: Colors.black),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15.0),
                    borderSide: BorderSide(color: Colors.black),
                  ),
                  prefixIcon: Icon(Icons.search, color: Colors.black),
                  filled: true,
                  fillColor: Colors.white,
                ),
                style: TextStyle(color: Colors.black),
              ),
              suggestionsCallback: (pattern) {
                return patientIds.where((id) => id.contains(pattern));
              },
              itemBuilder: (context, String? suggestion) {
                return ListTile(
                  title: Text(
                    suggestion!,
                    style: TextStyle(color: Colors.black),
                  ),
                );
              },
              onSuggestionSelected: (String? suggestion) {
                if (suggestion != null) {
                  _patientIdController.text = suggestion;
                  _searchPatient(suggestion);
                }
              },
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () => _searchPatient(_patientIdController.text),
                  child: Text('Search'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 244, 167, 193),
                    foregroundColor: Colors.blueGrey[900],
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    textStyle: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: _resetSearch,
                  child: Text('Reset'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 244, 167, 193),
                    foregroundColor: Colors.blueGrey[900],
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    textStyle: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            patientData.isNotEmpty
                ? Expanded(
                    child: ListView(
                      children: [
                        Text(
                          'Patient ID: ${_patientIdController.text}',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueGrey[900],
                          ),
                        ),
                        Text(
                          'Patient Name: ${patientData['patientName'] ?? 'Unknown'}',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueGrey[900],
                          ),
                        ),
                        SizedBox(height: 10),
                        if (emergencyContact.isNotEmpty)
                          Card(
                            color: Colors.red[50],
                            margin: EdgeInsets.symmetric(vertical: 8.0),
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            child: ListTile(
                              leading: Icon(
                                Icons.phone,
                                color: Colors.redAccent,
                                size: 40,
                              ),
                              title: Text(
                                'Emergency Contact',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.redAccent,
                                ),
                              ),
                              subtitle: Text(
                                emergencyContact,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.blueGrey[700],
                                ),
                              ),
                              onTap: _showEmergencyContact,
                            ),
                          ),
                        SizedBox(height: 10),
                        Column(
                          children: barChartData,
                        ),
                      ],
                    ),
                  )
                : Center(
                    child: Text(
                      'No data available. Please search for a patient.',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.blueGrey[700],
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}

void main() => runApp(MaterialApp(
      home: TrackMedicineIntakePage(),
    ));

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart'; // Add this import for rootBundle
import 'package:intl/intl.dart';
import 'dart:convert'; // Add this import for LineSplitter

// The user is presented with a medicine stock tracking interface that displays detailed information about their current medications,
// including the form, total pills left, and expected end date based on daily dosage and pill intake.
// The interface fetches prescription data from a Firestore database and provides visual representation through images and text.

class MedicineStock extends StatefulWidget {
  final String userId;

  MedicineStock({required this.userId});

  @override
  _MedicineStockState createState() => _MedicineStockState();
}

class _MedicineStockState extends State<MedicineStock> {
  List<String> medicineNames = [];
  Map<String, Map<String, String>> medicineDetails = {};
  String medicineForm = '';

  @override
  void initState() {
    super.initState();
    _loadMedicineDetails();
  }

  void _loadMedicineDetails() async {
    final data = await rootBundle.loadString('Excels/Medicine.csv');
    final lines = LineSplitter.split(data);
    for (var line in lines.skip(1)) {
      final values = line.split(',');
      if (values.isNotEmpty && values.length > 7) {
        medicineDetails[values[0]] = {
          'form': values[1],
          'unit': values[2],
          'doseType': values[3],
          'capacity': values[4],
          'image': values[5],
          'warning': values[6],
          'sideEffect': values[7],
        };
      }
    }
    setState(() {});
    print("Medicine details loaded: $medicineDetails"); // Debug print
  }

  String _getDailyDoseLabel(String medicineForm) {
    switch (medicineForm.toLowerCase()) {
      default:
        return 'Doses per day';
    }
  }

  String _getPillsPerDoseLabel(String medicineForm) {
    switch (medicineForm.toLowerCase()) {
      case 'pill (tablet)':
        return 'Pills per dose';
      case 'capsule':
        return 'Capsules per dose';
      case 'liquid (syrup)':
        return 'ml per dose';
      case 'injection (shot)':
        return 'Injections per dose';
      case 'inhaler':
        return 'Puffs per dose';
      case 'topical (cream/ointment)':
        return 'Applications per dose';
      case 'suppository':
        return 'Suppositories per dose';
      case 'patch (transdermal)':
        return 'Patches per dose';
      case 'drops (eye/ear)':
        return 'Drops per dose';
      case 'powder (for reconstitution)':
        return 'Doses per dose';
      default:
        return 'Doses per dose';
    }
  }

  DateTime _calculateExpectedEndDate(
      int capacity, int dailyDose, int pillsPerDose) {
    int totalDosesLeft = capacity ~/ pillsPerDose;
    int daysLeft = totalDosesLeft ~/ dailyDose;
    return DateTime.now().add(Duration(days: daysLeft));
  }

  void _showEnlargedImage(String imagePath) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(imagePath, fit: BoxFit.contain),
              SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(
                  'Close',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
                style: TextButton.styleFrom(
                  backgroundColor: Colors.black54,
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Medicine Stock'),
        backgroundColor: Color.fromARGB(255, 217, 242, 255),
        iconTheme: IconThemeData(color: Colors.black),
      ),
      backgroundColor: Color.fromARGB(255, 217, 242, 255),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('patients')
            .where('ID', isEqualTo: widget.userId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Something went wrong'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No prescriptions found'));
          }

          final patientDoc = snapshot.data!.docs.first;
          final prescriptionsStream = FirebaseFirestore.instance
              .collection('patients')
              .doc(patientDoc.id)
              .collection('prescriptions')
              .snapshots();

          return StreamBuilder<QuerySnapshot>(
            stream: prescriptionsStream,
            builder: (context, prescriptionsSnapshot) {
              if (prescriptionsSnapshot.connectionState ==
                  ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              if (prescriptionsSnapshot.hasError) {
                return Center(
                    child: Text('Something went wrong with prescriptions'));
              }

              if (!prescriptionsSnapshot.hasData ||
                  prescriptionsSnapshot.data!.docs.isEmpty) {
                return Center(child: Text('No prescriptions found'));
              }

              return ListView(
                children: prescriptionsSnapshot.data!.docs.map((document) {
                  Map<String, dynamic> prescription =
                      document.data() as Map<String, dynamic>;

                  // Debugging information
                  print("Prescription Data: $prescription");

                  try {
                    int dailyDose = prescription['dailyDose'] is int
                        ? prescription['dailyDose']
                        : int.parse(prescription['dailyDose'].toString());
                    int pillsPerDose = prescription['pillsPerDose'] is int
                        ? prescription['pillsPerDose']
                        : int.parse(prescription['pillsPerDose'].toString());
                    int capacity = prescription['capacity'] is int
                        ? prescription['capacity']
                        : int.parse(prescription['capacity'].toString());

                    String medicineForm =
                        medicineDetails[prescription['medicineName']]
                                ?['form'] ??
                            'dose';
                    String imagePath =
                        medicineDetails[prescription['medicineName']]
                                ?['image'] ??
                            '';

                    DateTime expectedEndDate = _calculateExpectedEndDate(
                        capacity, dailyDose, pillsPerDose);
                    String formattedEndDate =
                        DateFormat('yyyy-MM-dd').format(expectedEndDate);

                    return Card(
                      color: Colors.white,
                      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GestureDetector(
                              onTap: () => _showEnlargedImage(imagePath),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: Image.asset(
                                  imagePath,
                                  width: double.infinity,
                                  height: 150,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Medicine: ${prescription['medicineName']}',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Form: $medicineForm',
                              style:
                                  TextStyle(color: Colors.black, fontSize: 22),
                            ),
                            Text(
                              'Total pills left: $capacity',
                              style:
                                  TextStyle(color: Colors.black, fontSize: 22),
                            ),
                            Text(
                              'Expected End Date: $formattedEndDate',
                              style:
                                  TextStyle(color: Colors.black, fontSize: 22),
                            ),
                          ],
                        ),
                      ),
                    );
                  } catch (e) {
                    print("Error processing prescription data: $e");
                    return Center(
                        child: Text('Error processing prescription data.'));
                  }
                }).toList(),
              );
            },
          );
        },
      ),
    );
  }
}

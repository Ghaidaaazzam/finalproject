import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart'; // Add this import for rootBundle
import 'package:intl/intl.dart';
import 'dart:convert'; // Add this import for LineSplitter

class MedicineStock extends StatefulWidget {
  final String userId;

  MedicineStock({required this.userId});

  @override
  _MedicineStockState createState() => _MedicineStockState();
}

class _MedicineStockState extends State<MedicineStock> {
  List<String> medicineNames = [];
  Map<String, String> medicineForms = {};
  String medicineForm = '';

  @override
  void initState() {
    super.initState();
    _loadMedicineForms();
  }

  void _loadMedicineForms() async {
    final data = await rootBundle.loadString('Excels/Medicine.csv');
    final lines = LineSplitter.split(data);
    for (var line in lines) {
      final values = line.split(',');
      if (values.isNotEmpty) {
        medicineNames
            .add(values[0]); // Assuming the first column is the medicine name
        if (values.length > 1) {
          medicineForms[values[0]] =
              values[1]; // Assuming the second column is the medicine form
        }
      }
    }
    setState(() {});
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
                  int dailyDose = int.tryParse(prescription['dailyDose']) ?? 0;
                  int pillsPerDose =
                      int.tryParse(prescription['pillsPerDose']) ?? 0;
                  int totalPills = dailyDose * pillsPerDose;
                  DateTime startDate =
                      DateFormat('yyyy-MM-dd').parse(prescription['startDate']);
                  DateTime endDate =
                      DateFormat('yyyy-MM-dd').parse(prescription['endDate']);
                  int daysPrescribed = endDate.difference(startDate).inDays + 1;
                  int totalNeeded = dailyDose * pillsPerDose * daysPrescribed;

                  String medicineForm =
                      medicineForms[prescription['medicineName']] ?? 'dose';

                  return Card(
                    color: Colors.white,
                    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
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
                            'Form: ${medicineForm}',
                            style: TextStyle(color: Colors.black, fontSize: 22),
                          ),
                          Text(
                            '${_getDailyDoseLabel(medicineForm)}: ${prescription['dailyDose']}',
                            style: TextStyle(color: Colors.black, fontSize: 22),
                          ),
                          Text(
                            '${_getPillsPerDoseLabel(medicineForm)}: ${prescription['pillsPerDose']}',
                            style: TextStyle(color: Colors.black, fontSize: 22),
                          ),
                          Text(
                            'Start Date: ${prescription['startDate']}',
                            style: TextStyle(color: Colors.black, fontSize: 22),
                          ),
                          Text(
                            'End Date: ${prescription['endDate']}',
                            style: TextStyle(color: Colors.black, fontSize: 22),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Total ${medicineForm.toLowerCase()}s Needed: $totalNeeded',
                            style: TextStyle(color: Colors.black, fontSize: 22),
                          ),
                          // Add any additional information you want to display
                        ],
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          );
        },
      ),
    );
  }
}
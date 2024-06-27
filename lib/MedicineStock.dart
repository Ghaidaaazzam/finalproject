import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class MedicineStock extends StatefulWidget {
  final String userId;

  MedicineStock({required this.userId});

  @override
  _MedicineStockState createState() => _MedicineStockState();
}

class _MedicineStockState extends State<MedicineStock> {
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
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Daily Dose: ${prescription['dailyDose']}',
                            style: TextStyle(color: Colors.black),
                          ),
                          Text(
                            'Pills per Dose: ${prescription['pillsPerDose']}',
                            style: TextStyle(color: Colors.black),
                          ),
                          Text(
                            'Start Date: ${prescription['startDate']}',
                            style: TextStyle(color: Colors.black),
                          ),
                          Text(
                            'End Date: ${prescription['endDate']}',
                            style: TextStyle(color: Colors.black),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Total Pills Needed: $totalNeeded',
                            style: TextStyle(color: Colors.black),
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

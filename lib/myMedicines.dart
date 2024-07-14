import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'UserProfile.dart'; // Import UserProfile
import 'TakeORMiss.dart'; // Import MedicineIntakePage
import 'HomePage.dart'; // Import HomePage
import 'notification_helper.dart'; // Import NotificationHelper
import 'MedicineStock.dart'; // Import MedicineStock

class MyMedicines extends StatefulWidget {
  final String userId;

  MyMedicines({required this.userId});

  @override
  _MyMedicinesState createState() => _MyMedicinesState();
}

class _MyMedicinesState extends State<MyMedicines> {
  int _selectedIndex = 2;
  late NotificationHelper notificationHelper;
  Map<String, Map<String, String>> medicineDetails = {};

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    notificationHelper = NotificationHelper(context);
    loadMedicineDetails();
  }

  @override
  void dispose() {
    notificationHelper.removeObserver();
    super.dispose();
  }

  Future<void> loadMedicineDetails() async {
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

  void _onItemTapped(int index) {
    switch (index) {
      case 0:
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => HomePage(userId: widget.userId)),
        );
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => UserProfile(userId: widget.userId)),
        );
        break;
      case 2:
        // Stay on current page
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  MedicineIntakePage(patientId: widget.userId)),
        );
        break;
    }
  }

  Future<void> _selectTime(BuildContext context,
      DocumentReference prescriptionDoc, List<dynamic> times,
      [int? index]) async {
    TimeOfDay initialTime = TimeOfDay.now();
    if (index != null && index < times.length) {
      final timeParts = times[index].split(':');
      initialTime = TimeOfDay(
          hour: int.parse(timeParts[0]), minute: int.parse(timeParts[1]));
    }

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Color(0xFFF06292), // header background color
              onPrimary: Colors.white, // header text color
              onSurface: Colors.black, // body text color
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.black, // button text color
                side:
                    BorderSide(color: Color(0xFFF06292)), // button border color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
          ),
          child: MediaQuery(
            data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
            child: child!,
          ),
        );
      },
    );

    if (picked != null) {
      setState(() {
        final timeString =
            "${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}";
        if (index == null || index >= times.length) {
          times.add(timeString);
        } else {
          times[index] = timeString;
        }
        prescriptionDoc.update({'times': times}).then((_) {
          print('Times updated successfully');
        }).catchError((error) {
          print('Failed to update times: $error');
        });
      });

      // Schedule the notification with prescription information
      notificationHelper.scheduleNotification(
          picked, 'Time to take your medicine!', prescriptionDoc);

      print('Scheduling notification for $picked');
    }
  }

  void _navigateToMedicineStock() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => MedicineStock(userId: widget.userId)),
    );
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
        title: Text(
          'My Medicines',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Color.fromARGB(255, 217, 242, 255),
        iconTheme: IconThemeData(color: Colors.black),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _navigateToMedicineStock,
                borderRadius: BorderRadius.circular(30.0),
                child: Ink(
                  height: 40, // Add this line to set a specific height
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
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 1),
                  child: Center(
                    child: Text(
                      'Medicines Stock',
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

                  // Ensure 'times' field is initialized
                  List<dynamic> times = prescription['times'] ?? [];
                  if (times.isEmpty) {
                    document.reference.update({'times': []});
                  }

                  return Card(
                    color: Colors.white, // Setting the card color to white
                    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (medicineDetails
                              .containsKey(prescription['medicineName']))
                            GestureDetector(
                              onTap: () {
                                print(
                                    "Image clicked: ${medicineDetails[prescription['medicineName']]!['image']!}");
                                _showEnlargedImage(medicineDetails[
                                    prescription['medicineName']]!['image']!);
                              },
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: Image.asset(
                                  medicineDetails[
                                      prescription['medicineName']]!['image']!,
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
                              color:
                                  Colors.black, // Setting text color to black
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Daily Dose: ${prescription['dailyDose']}',
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 22), // Text color
                          ),
                          Text(
                            'Pills per Dose: ${prescription['pillsPerDose']}',
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 22), // Text color
                          ),
                          Text(
                            'Capacity: ${prescription['capacity']}',
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 22), // Text color
                          ),
                          Text(
                            'Start Date: ${prescription['startDate']}',
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 22), // Text color
                          ),
                          Text(
                            'End Date: ${prescription['endDate']}',
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 22), // Text color
                          ),
                          if (prescription['doctorNotice'] != null &&
                              prescription['doctorNotice'].isNotEmpty)
                            Text(
                              'Doctor\'s Notice: ${prescription['doctorNotice']}',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 22), // Text color
                            ),
                          SizedBox(height: 8),
                          Text(
                            'Times:',
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 22), // Text color
                          ),
                          ListView.builder(
                            shrinkWrap: true,
                            itemCount: dailyDose,
                            itemBuilder: (context, index) {
                              return ListTile(
                                title: Text(
                                  times.length > index
                                      ? times[index]
                                      : 'Set Time',
                                  style: TextStyle(
                                      color: Colors.black), // Text color
                                ),
                                trailing: IconButton(
                                  icon: Icon(Icons.edit,
                                      color: Colors
                                          .black), // Set icon color to black
                                  onPressed: () => _selectTime(
                                    context,
                                    document.reference,
                                    times,
                                    index,
                                  ),
                                ),
                              );
                            },
                          ),
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
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Image.asset('images/SmallLogo.png', width: 40, height: 40),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person, size: 30, color: Colors.black),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Image.asset('images/Medicines.png', width: 40, height: 40),
            label: 'Medicines',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart, size: 30, color: Colors.black),
            label: 'Statistics',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black,
        onTap: _onItemTapped,
        selectedLabelStyle: TextStyle(color: Colors.black),
        unselectedLabelStyle: TextStyle(color: Colors.black),
        showUnselectedLabels: true,
      ),
    );
  }
}

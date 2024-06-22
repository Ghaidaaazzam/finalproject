import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'UserProfile.dart'; // Import UserProfile
import 'EditProfilePage.dart'; // Import EditProfilePage

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Medicines',
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
      home: MyMedicines(userId: 'user123'),
    );
  }
}

class MyMedicines extends StatefulWidget {
  final String userId;

  MyMedicines({required this.userId});

  @override
  _MyMedicinesState createState() => _MyMedicinesState();
}

class _MyMedicinesState extends State<MyMedicines> {
  int _selectedIndex = 2;

  void _onItemTapped(int index) {
    switch (index) {
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => UserProfile(userId: widget.userId)),
        );
        break;
      case 2:
        // Do nothing as we are already on this page
        break;
      case 3:
        // Do nothing for Statistics icon
        break;
    }
  }

  @override
  void initState() {
    super.initState();
    print('User ID: ${widget.userId}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Medicines'),
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

                  return Card(
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
                            ),
                          ),
                          SizedBox(height: 8),
                          Text('Daily Dose: ${prescription['dailyDose']}'),
                          Text(
                              'Pills per Dose: ${prescription['pillsPerDose']}'),
                          Text('Start Date: ${prescription['startDate']}'),
                          Text('End Date: ${prescription['endDate']}'),
                          if (prescription['doctorNotice'] != null &&
                              prescription['doctorNotice'].isNotEmpty)
                            Text(
                                'Doctor\'s Notice: ${prescription['doctorNotice']}'),
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

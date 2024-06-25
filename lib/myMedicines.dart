import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'UserProfile.dart'; // Import UserProfile
import 'EditProfilePage.dart'; // Import EditProfilePage

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('en', 'US'), // English (US)
        const Locale('en', 'GB'), // English (UK)
      ],
      locale: const Locale(
          'en', 'GB'), // Set the locale to UK English for 24-hour format
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
        textTheme: TextTheme(
          displayLarge: TextStyle(color: Color(0xFF000000)), // Black
          bodyLarge: TextStyle(color: Color(0xFF000000)), // Black
        ),
        timePickerTheme: TimePickerThemeData(
          backgroundColor: Color(0xFFF8E1E9), // Light pastel pink
          hourMinuteTextColor: Colors.black,
          hourMinuteColor: Color(0xFFF06292), // Slightly darker pastel pink
          dialHandColor: Color(0xFFF06292),
          dialBackgroundColor: Colors.white,
          entryModeIconColor: Color(0xFFF06292),
          helpTextStyle: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          hourMinuteTextStyle: TextStyle(
            color: Colors.black,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
          dialTextColor: MaterialStateColor.resolveWith((states) =>
              states.contains(MaterialState.selected)
                  ? Colors.white
                  : Colors.black),
          inputDecorationTheme: InputDecorationTheme(
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFFF06292)),
            ),
          ),
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

  Future<void> _selectTime(BuildContext context,
      DocumentReference prescriptionDoc, List<dynamic> times,
      [int? index]) async {
    TimeOfDay initialTime = TimeOfDay.now();
    if (index != null) {
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
        if (index == null) {
          times.add(timeString);
        } else {
          times[index] = timeString;
        }
        prescriptionDoc.update({'times': times});
      });
    }
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
                          SizedBox(height: 8),
                          Text('Times:'),
                          ListView.builder(
                            shrinkWrap: true,
                            itemCount: prescription['times']?.length ?? 0,
                            itemBuilder: (context, index) {
                              return ListTile(
                                title: Text(prescription['times'][index]),
                                trailing: IconButton(
                                  icon: Icon(Icons.edit),
                                  onPressed: () => _selectTime(
                                      context,
                                      document.reference,
                                      List.from(prescription['times']),
                                      index),
                                ),
                              );
                            },
                          ),
                          Align(
                            alignment: Alignment.center,
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () => _selectTime(
                                    context,
                                    document.reference,
                                    List.from(prescription['times'] ?? [])),
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
                                      horizontal: 8,
                                      vertical: 8), // Adjusted padding
                                  child: Container(
                                    width: 100, // Adjusted width
                                    child: Center(
                                      child: Text(
                                        'Add Time',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
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

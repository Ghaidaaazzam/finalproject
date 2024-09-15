import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'MyMedicines.dart';
import 'UserProfile.dart';
import 'TakeORMiss.dart';

// The user is presented with a home page where they can view today's medication list,
// see detailed information about their medications, and navigate to other sections such as profile,
// medicines, and statistics. The page retrieves the user's medication data from a Firestore database and displays relevant warnings,
// side effects, and images for each medication.

class HomePage extends StatefulWidget {
  final String userId;

  HomePage({required this.userId});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  List<Map<String, String>> medications = [];
  bool isLoading = true;
  Map<String, Map<String, String>> medicineDetails = {};

  @override
  void initState() {
    super.initState();
    loadMedicineDetails();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    switch (index) {
      case 0:
        // Remain on HomePage
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => UserProfile(userId: widget.userId)),
        );
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => MyMedicines(userId: widget.userId)),
        );
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  MedicineIntakePage(patientId: widget.userId)),
        );
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 217, 242, 255),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Color.fromARGB(255, 244, 167, 193),
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(30.0),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Image.asset('images/Medicines.png', width: 40, height: 40),
                  ],
                ),
                SizedBox(height: 10),
                Text(
                  'Today is ${DateFormat('MMMM dd, yyyy').format(DateTime.now())}',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
                SizedBox(height: 5),
                Text(
                  'Take your medicine on time and stay healthy!',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              "Today's Medicine List",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey[900],
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('patients')
                  .where('ID', isEqualTo: widget.userId)
                  .snapshots(),
              builder: (context, patientSnapshot) {
                if (patientSnapshot.connectionState ==
                    ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (patientSnapshot.hasError) {
                  return Center(child: Text('Something went wrong'));
                }

                if (!patientSnapshot.hasData ||
                    patientSnapshot.data!.docs.isEmpty) {
                  return Center(child: Text('No patient data found'));
                }

                final patientDoc = patientSnapshot.data!.docs.first;
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
                          child:
                              Text('Something went wrong with prescriptions'));
                    }

                    if (!prescriptionsSnapshot.hasData ||
                        prescriptionsSnapshot.data!.docs.isEmpty) {
                      return Center(child: Text('No prescriptions found'));
                    }

                    medications.clear();
                    DateTime today = DateTime.now();

                    prescriptionsSnapshot.data!.docs.forEach((doc) {
                      Map<String, dynamic> data =
                          doc.data() as Map<String, dynamic>;
                      DateTime startDate = DateTime.parse(data['startDate']);
                      DateTime endDate = DateTime.parse(data['endDate']);
                      print('Checking prescription: ${data['medicineName']}');
                      print(
                          'Start date: ${data['startDate']}, End date: ${data['endDate']}');

                      if (today
                              .isAfter(startDate.subtract(Duration(days: 1))) &&
                          today.isBefore(endDate.add(Duration(days: 1)))) {
                        print('Adding medication: ${data['medicineName']}');
                        print(
                            'Medicine details: ${medicineDetails[data['medicineName']]}'); // Debug print
                        medications.add({
                          'name': data['medicineName'],
                          'form': medicineDetails[data['medicineName']]
                                  ?['form'] ??
                              'No form available',
                          'image': medicineDetails[data['medicineName']]
                                  ?['image'] ??
                              '',
                          'warning': medicineDetails[data['medicineName']]
                                  ?['warning'] ??
                              'No warning available',
                          'sideEffect': medicineDetails[data['medicineName']]
                                  ?['sideEffect'] ??
                              'No side effect available',
                        });
                      }
                    });

                    print(
                        'Medications to display: $medications'); // Debug print

                    return ListView.builder(
                      itemCount: medications.length,
                      itemBuilder: (context, index) {
                        return _buildMedicineCard(medications[index], index);
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: [
          BottomNavigationBarItem(
            icon: Image.asset(
              'images/SmallLogo.png',
              height: 40.0,
              width: 40.0,
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person, size: 30, color: Colors.black),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              'images/Medicines.png',
              width: 40,
              height: 40,
            ),
            label: 'Medicines',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart, size: 30, color: Colors.black),
            label: 'Statistics',
          ),
        ],
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black,
        showUnselectedLabels: true,
      ),
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

  void _showDetails(String title, String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color.fromARGB(255, 217, 242, 255),
          title: Text(
            title,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.blueGrey[900],
            ),
          ),
          content: Text(
            content,
            style: TextStyle(
              fontSize: 18,
              color: Colors.blueGrey[700],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Close',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.blueGrey[900],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMedicineCard(Map<String, String> medicine, int index) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 5,
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () => _showEnlargedImage(medicine['image']!),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.asset(
                  medicine['image']!,
                  width: double.infinity,
                  height: 150,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(height: 10),
            Row(
              children: [
                CircleAvatar(
                  radius: 12,
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(color: Colors.white),
                  ),
                  backgroundColor: Colors.blueGrey[900],
                ),
                SizedBox(width: 10),
                Text(
                  'Medicine:',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey[900],
                  ),
                ),
              ],
            ),
            SizedBox(height: 5),
            Text(
              medicine['name']!,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey[900],
              ),
            ),
            SizedBox(height: 5),
            Text(
              'Form: ${medicine['form']}',
              style: TextStyle(
                fontSize: 16,
                fontStyle: FontStyle.italic,
                color: Colors.blueGrey[700],
              ),
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  onPressed: () =>
                      _showDetails('Warning', medicine['warning']!),
                  icon: Icon(Icons.warning, color: Colors.red),
                  label: Text('Warning'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[100],
                    foregroundColor: Colors.red[900],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () =>
                      _showDetails('Side Effect', medicine['sideEffect']!),
                  icon: Icon(Icons.healing, color: Colors.blueGrey[900]),
                  label: Text('Side Effect'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueGrey[100],
                    foregroundColor: Colors.blueGrey[900],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

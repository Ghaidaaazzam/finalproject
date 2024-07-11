import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'HomePage.dart'; // Import HomePage
import 'UserProfile.dart';
import 'MyMedicines.dart';

class MedicineIntakePage extends StatefulWidget {
  final String patientId;

  MedicineIntakePage({required this.patientId});

  @override
  _MedicineIntakePageState createState() => _MedicineIntakePageState();
}

class _MedicineIntakePageState extends State<MedicineIntakePage> {
  int _selectedIndex = 3; // Set the initial selected index to the current page
  List<Widget> intakeDataWidgets = [];

  @override
  void initState() {
    super.initState();
    fetchMedicineIntakeData();
  }

  Future<void> fetchMedicineIntakeData() async {
    try {
      print('Fetching prescriptions for patientId: ${widget.patientId}');

      // Fetch the patient document
      QuerySnapshot patientSnapshot = await FirebaseFirestore.instance
          .collection('patients')
          .where('ID', isEqualTo: widget.patientId)
          .get();

      if (patientSnapshot.docs.isEmpty) {
        print('Patient not found.');
        setState(() {
          intakeDataWidgets = [
            Center(
                child: Text('No patient found with ID: ${widget.patientId}')),
          ];
          return;
        });
      }

      final patientDoc = patientSnapshot.docs.first;
      QuerySnapshot prescriptionSnapshot = await FirebaseFirestore.instance
          .collection('patients')
          .doc(patientDoc.id)
          .collection('prescriptions')
          .get();

      if (prescriptionSnapshot.docs.isEmpty) {
        print('No prescriptions found for this patient.');
        setState(() {
          intakeDataWidgets = [
            Center(child: Text('No prescriptions found for this patient.')),
          ];
        });
        return;
      }

      List<Widget> tempList = [];
      for (var doc in prescriptionSnapshot.docs) {
        var prescriptionData = doc.data() as Map<String, dynamic>;
        String medicineName =
            prescriptionData['medicineName'] ?? 'Unknown Medicine';
        int dailyDose = int.tryParse(prescriptionData['dailyDose'] ?? '1') ?? 1;

        print('Fetching daily intake records for prescription: ${doc.id}');
        QuerySnapshot dailySnapshot =
            await doc.reference.collection('medicines').get();

        if (dailySnapshot.docs.isEmpty) {
          print('No daily intake records found for prescription: ${doc.id}');
        }

        for (var dailyDoc in dailySnapshot.docs) {
          var dailyData = dailyDoc.data() as Map<String, dynamic>;
          DateTime date = (dailyData['date'] as Timestamp).toDate();

          print('Fetching take or miss records for date: ${dailyDoc.id}');
          QuerySnapshot takeOrMissSnapshot =
              await dailyDoc.reference.collection('takeOrMiss').get();

          if (takeOrMissSnapshot.docs.isEmpty) {
            print('No take or miss records found for date: ${dailyDoc.id}');
          }

          int takenCount = 0;
          int missedCount = 0;

          for (var takeOrMissDoc in takeOrMissSnapshot.docs) {
            var takeOrMissData = takeOrMissDoc.data() as Map<String, dynamic>;
            bool taken = takeOrMissData['taken'] ?? false;
            if (taken) {
              takenCount++;
            } else {
              missedCount++;
            }
          }

          tempList.add(
            Card(
              color: Colors.white, // Set card color to white
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
                          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}',
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
                      'Medicine: $medicineName',
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
                            color:
                                Colors.red.withOpacity(missedCount / dailyDose),
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        FractionallySizedBox(
                          widthFactor: takenCount / dailyDose,
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
                            Icon(Icons.check_circle,
                                color: Colors.green, size: 18),
                            SizedBox(width: 4),
                            Text(
                              'Taken: $takenCount',
                              style:
                                  TextStyle(fontSize: 14, color: Colors.green),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Icon(Icons.cancel, color: Colors.red, size: 18),
                            SizedBox(width: 4),
                            Text(
                              'Missed: $missedCount ($missedCount/$dailyDose)',
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
      }

      setState(() {
        intakeDataWidgets = tempList;
      });
    } catch (e) {
      print('Error fetching medicine intake data: $e');
    }
  }

  void _onItemTapped(int index) {
    switch (index) {
      case 0:
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => HomePage(userId: widget.patientId)),
        );
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => UserProfile(userId: widget.patientId)),
        );
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => MyMedicines(userId: widget.patientId)),
        );
        break;
      case 3:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 217, 242, 255),
      appBar: AppBar(
        title: Text(
          'Medicine Intake Overview',
          style: TextStyle(color: Colors.black),
        ),

        backgroundColor:
            Color.fromARGB(255, 217, 242, 255), // Same color as background
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: intakeDataWidgets.isNotEmpty
            ? ListView(
                children: intakeDataWidgets,
              )
            : Center(
                child: Text(
                  'No data available for this patient.',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.blueGrey[700],
                  ),
                ),
              ),
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

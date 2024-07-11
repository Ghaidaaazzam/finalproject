import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'MyMedicines.dart';
import 'UserProfile.dart';

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
    fetchMedicationsForToday();
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
        // Do nothing for Statistics icon
        break;
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

  Future<void> fetchMedicationsForToday() async {
    try {
      String userId = widget.userId;
      DateTime today = DateTime.now();
      String formattedToday = DateFormat('yyyy-MM-dd').format(today);
      print('Formatted date for today: $formattedToday');

      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('patients')
          .where('ID', isEqualTo: userId)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        DocumentSnapshot userDoc = querySnapshot.docs.first;
        CollectionReference prescriptions =
            userDoc.reference.collection('prescriptions');

        QuerySnapshot prescriptionsSnapshot = await prescriptions.get();
        prescriptionsSnapshot.docs.forEach((doc) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          DateTime startDate = DateTime.parse(data['startDate']);
          DateTime endDate = DateTime.parse(data['endDate']);
          print('Checking prescription: ${data['medicineName']}');
          print(
              'Start date: ${data['startDate']}, End date: ${data['endDate']}');

          if (today.isAfter(startDate.subtract(Duration(days: 1))) &&
              today.isBefore(endDate.add(Duration(days: 1)))) {
            print('Adding medication: ${data['medicineName']}');
            print(
                'Medicine details: ${medicineDetails[data['medicineName']]}'); // Debug print
            setState(() {
              medications.add({
                'name': data['medicineName'],
                'form': medicineDetails[data['medicineName']]?['form'] ??
                    'No form available',
                'image': medicineDetails[data['medicineName']]?['image'] ?? '',
                'warning': medicineDetails[data['medicineName']]?['warning'] ??
                    'No warning available',
                'sideEffect': medicineDetails[data['medicineName']]
                        ?['sideEffect'] ??
                    'No side effect available',
              });
            });
          }
        });
      }

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching medications: $e');
      setState(() {
        isLoading = false;
      });
    }
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
            child: Center(
              child: isLoading
                  ? CircularProgressIndicator()
                  : medications.isEmpty
                      ? Text('No medications for today.')
                      : ListView.builder(
                          itemCount: medications.length,
                          itemBuilder: (context, index) {
                            return _buildMedicineCard(
                                medications[index], index);
                          },
                        ),
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
}

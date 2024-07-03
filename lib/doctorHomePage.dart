import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:finalproject/firebase_options.dart';
import 'prescription.dart';
import 'AddPatient.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      routes: {
        '/': (context) => DoctorHomePage(),
        '/prescription': (context) => PrescriptionPage(),
        '/doctorHome': (context) => DoctorHomePage(),
        '/addPatient': (context) => AddPatientPage(),
        '/editProfile': (context) => EditProfilePage(),
      },
    );
  }
}

class DoctorHomePage extends StatefulWidget {
  @override
  _DoctorHomePageState createState() => _DoctorHomePageState();
}

class _DoctorHomePageState extends State<DoctorHomePage> {
  int _selectedIndex = 0;
  String idFilter = '';
  int? daysLeftFilter;

  List<Map<String, dynamic>> prescriptions = [
    {
      'patientName': 'John Doe',
      'patientId': '123456789',
      'medicineName': 'Medicine A',
      'dailyDose': '2',
      'pillsPerDose': '1',
      'startDate': DateTime.now().subtract(Duration(days: 10)),
      'endDate': DateTime.now().add(Duration(days: 2)),
      'doctorNotice': 'Take with food',
    },
    {
      'patientName': 'Jane Smith',
      'patientId': '987654321',
      'medicineName': 'Medicine B',
      'dailyDose': '1',
      'pillsPerDose': '1',
      'startDate': DateTime.now().subtract(Duration(days: 20)),
      'endDate': DateTime.now().add(Duration(days: 4)),
      'doctorNotice': 'Take before bed',
    },
    {
      'patientName': 'Mike Johnson',
      'patientId': '112233445',
      'medicineName': 'Medicine C',
      'dailyDose': '3',
      'pillsPerDose': '1',
      'startDate': DateTime.now().subtract(Duration(days: 5)),
      'endDate': DateTime.now().add(Duration(days: 1)),
      'doctorNotice': 'Avoid alcohol',
    },
    {
      'patientName': 'Emily Davis',
      'patientId': '998877665',
      'medicineName': 'Medicine D',
      'dailyDose': '2',
      'pillsPerDose': '2',
      'startDate': DateTime.now().subtract(Duration(days: 15)),
      'endDate': DateTime.now().add(Duration(days: 5)),
      'doctorNotice': 'Take with water',
    },
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    switch (index) {
      case 0:
        Navigator.pushNamed(context, '/doctorHome');
        break;
      case 1:
        Navigator.pushNamed(context, '/prescription');
        break;
      case 2:
        Navigator.pushNamed(context, '/addPatient');
        break;
      case 3:
        Navigator.pushNamed(context, '/editProfile');
        break;
    }
  }

  void _renewPrescription(Map<String, dynamic> prescription) {
    TextEditingController dailyDoseController =
        TextEditingController(text: prescription['dailyDose']);
    TextEditingController pillsPerDoseController =
        TextEditingController(text: prescription['pillsPerDose']);
    TextEditingController doctorNoticeController =
        TextEditingController(text: prescription['doctorNotice']);
    TextEditingController startDateController = TextEditingController(
        text: DateFormat('yyyy-MM-dd').format(prescription['startDate']));
    TextEditingController endDateController = TextEditingController(
        text: DateFormat('yyyy-MM-dd').format(prescription['endDate']));

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color.fromARGB(255, 217, 242, 255), // צבע רקע חלון
          title: Text(
            'Renew Prescription for ${prescription['medicineName']}',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.blueGrey[900],
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: dailyDoseController,
                  decoration: InputDecoration(
                    labelText: 'Daily Dose',
                    labelStyle: TextStyle(
                      color: Colors.blueGrey[900],
                      fontSize: 18,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.black),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: pillsPerDoseController,
                  decoration: InputDecoration(
                    labelText: 'Pills Per Dose',
                    labelStyle: TextStyle(
                      color: Colors.blueGrey[900],
                      fontSize: 18,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.black),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: doctorNoticeController,
                  decoration: InputDecoration(
                    labelText: 'Doctor Notice',
                    labelStyle: TextStyle(
                      color: Colors.blueGrey[900],
                      fontSize: 18,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.black),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: startDateController,
                  decoration: InputDecoration(
                    labelText: 'Start Date',
                    labelStyle: TextStyle(
                      color: Colors.blueGrey[900],
                      fontSize: 18,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.black),
                    ),
                  ),
                  readOnly: true,
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: prescription['startDate'],
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2101),
                    );
                    if (pickedDate != null) {
                      startDateController.text =
                          DateFormat('yyyy-MM-dd').format(pickedDate);
                    }
                  },
                ),
                SizedBox(height: 10),
                TextField(
                  controller: endDateController,
                  decoration: InputDecoration(
                    labelText: 'End Date',
                    labelStyle: TextStyle(
                      color: Colors.blueGrey[900],
                      fontSize: 18,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.black),
                    ),
                  ),
                  readOnly: true,
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: prescription['endDate'],
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2101),
                    );
                    if (pickedDate != null) {
                      endDateController.text =
                          DateFormat('yyyy-MM-dd').format(pickedDate);
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text(
                'Cancel',
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
            TextButton(
              child: Text(
                'Save',
                style: TextStyle(
                  color: Colors.blueGrey[900],
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () {
                setState(() {
                  prescription['dailyDose'] = dailyDoseController.text;
                  prescription['pillsPerDose'] = pillsPerDoseController.text;
                  prescription['doctorNotice'] = doctorNoticeController.text;
                  prescription['startDate'] =
                      DateFormat('yyyy-MM-dd').parse(startDateController.text);
                  prescription['endDate'] =
                      DateFormat('yyyy-MM-dd').parse(endDateController.text);
                });
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
    DateFormat dateFormat = DateFormat('yyyy-MM-dd');
    List<Map<String, dynamic>> filteredPrescriptions =
        prescriptions.where((prescription) {
      int daysLeft = prescription['endDate'].difference(DateTime.now()).inDays;
      return (idFilter.isEmpty ||
              prescription['patientId'].contains(idFilter)) &&
          (daysLeftFilter == null || daysLeft <= daysLeftFilter!);
    }).toList();

    return Scaffold(
      backgroundColor: Color.fromARGB(255, 217, 242, 255),
      appBar: AppBar(
        title: Text('Doctor Home Page'),
        backgroundColor: Color.fromARGB(255, 244, 167, 193),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                // אפשרות לרענן את הנתונים
                // כרגע זה לא מבצע פעולה אמיתית כיוון שהנתונים ידניים
              });
            },
          ),
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.pushNamed(context, '/prescription');
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Prescriptions Ending Soon',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey[900],
              ),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: 'Filter by ID',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: (value) {
                      setState(() {
                        idFilter = value;
                      });
                    },
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: 'Days Left (<=)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.filter_alt),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      setState(() {
                        daysLeftFilter =
                            value.isEmpty ? null : int.tryParse(value);
                      });
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: filteredPrescriptions.length,
                itemBuilder: (context, index) {
                  var prescription = filteredPrescriptions[index];
                  int daysLeft =
                      prescription['endDate'].difference(DateTime.now()).inDays;
                  bool isUrgent = daysLeft <= 2;
                  return Card(
                    color: isUrgent ? Colors.red[50] : Colors.white,
                    margin: EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      leading: isUrgent
                          ? Icon(Icons.warning, color: Colors.red)
                          : null,
                      title: Text(
                        '${prescription['patientName']} (ID: ${prescription['patientId']})',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueGrey[900],
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${prescription['medicineName']} - Ends on: ${dateFormat.format(prescription['endDate'])}',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.blueGrey[700],
                            ),
                          ),
                          Text(
                            'Days left: $daysLeft',
                            style: TextStyle(
                              fontSize: 16,
                              color:
                                  isUrgent ? Colors.red : Colors.blueGrey[700],
                              fontWeight: isUrgent
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () => _renewPrescription(prescription),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: [
          BottomNavigationBarItem(
            icon: Image.asset(
              'images/SmallLogo.png',
              height: 50.0,
              width: 50.0,
            ),
            label: 'Logo',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              'images/prescriptionIcon.png',
              height: 50.0,
              width: 50.0,
            ),
            label: 'Prescription',
          ),
          BottomNavigationBarItem(
            icon: Stack(
              children: <Widget>[
                Icon(
                  Icons.person,
                  color: Colors.black,
                  size: 40,
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Icon(
                    Icons.add_circle,
                    color: Colors.blue,
                    size: 24,
                  ),
                ),
              ],
            ),
            label: 'Add Patient',
          ),
          BottomNavigationBarItem(
            icon: Stack(
              children: <Widget>[
                Icon(
                  Icons.person,
                  color: Colors.black,
                  size: 40,
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Icon(
                    Icons.edit,
                    color: Colors.blue,
                    size: 24,
                  ),
                ),
              ],
            ),
            label: 'Edit Profile',
          ),
        ],
      ),
    );
  }
}

class EditProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'Edit Profile Page',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}

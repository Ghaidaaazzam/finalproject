import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

class TrackMedicineIntakePage extends StatefulWidget {
  @override
  _TrackMedicineIntakePageState createState() =>
      _TrackMedicineIntakePageState();
}

class _TrackMedicineIntakePageState extends State<TrackMedicineIntakePage> {
  TextEditingController _patientIdController = TextEditingController();
  Map<String, dynamic> patientData = {};
  List<Widget> barChartData = [];
  List<String> patientIds = [];

  @override
  void initState() {
    super.initState();
    fetchPatientIds();
  }

  Future<void> fetchPatientIds() async {
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('patients').get();
      List<String> ids = snapshot.docs
          .map((doc) => (doc.data() as Map<String, dynamic>)['ID'].toString())
          .toList();
      setState(() {
        patientIds = ids;
      });
    } catch (e) {
      print('Error fetching patient IDs: $e');
    }
  }

  // Dummy data for patients
  Map<String, Map<String, dynamic>> patients = {
    '323032': {
      'patientName': 'Ghaidaa Azzam',
      'medicineIntake': [
        {
          'date': '2023-07-01',
          'medicine': 'Medicine A',
          'taken': 2,
          'missed': 1
        },
        {
          'date': '2023-07-02',
          'medicine': 'Medicine A',
          'taken': 3,
          'missed': 0
        },
        {
          'date': '2023-07-03',
          'medicine': 'Medicine A',
          'taken': 2,
          'missed': 1
        },
        {
          'date': '2023-07-04',
          'medicine': 'Medicine A',
          'taken': 3,
          'missed': 0
        },
        {
          'date': '2023-07-05',
          'medicine': 'Medicine A',
          'taken': 1,
          'missed': 2
        },
      ],
    },
    '987654321': {
      'patientName': 'Mohamad Zoabi',
      'medicineIntake': [
        {
          'date': '2023-07-01',
          'medicine': 'Medicine B',
          'taken': 1,
          'missed': 2
        },
        {
          'date': '2023-07-02',
          'medicine': 'Medicine B',
          'taken': 2,
          'missed': 1
        },
        {
          'date': '2023-07-03',
          'medicine': 'Medicine B',
          'taken': 3,
          'missed': 0
        },
        {
          'date': '2023-07-04',
          'medicine': 'Medicine B',
          'taken': 1,
          'missed': 2
        },
        {
          'date': '2023-07-05',
          'medicine': 'Medicine B',
          'taken': 2,
          'missed': 1
        },
      ],
    },
    '123456789': {
      'patientName': 'Yomna Zoabi',
      'medicineIntake': [
        {
          'date': '2023-07-01',
          'medicine': 'Medicine C',
          'taken': 0,
          'missed': 3
        },
        {
          'date': '2023-07-02',
          'medicine': 'Medicine C',
          'taken': 1,
          'missed': 2
        },
        {
          'date': '2023-07-03',
          'medicine': 'Medicine C',
          'taken': 2,
          'missed': 1
        },
        {
          'date': '2023-07-04',
          'medicine': 'Medicine C',
          'taken': 3,
          'missed': 0
        },
        {
          'date': '2023-07-05',
          'medicine': 'Medicine C',
          'taken': 1,
          'missed': 2
        },
      ],
    },
  };

  void _generateData() {
    List<Widget> tempList = [];
    for (var intake in patientData['medicineIntake']) {
      double total = intake['taken'].toDouble() + intake['missed'].toDouble();
      double takenPercentage = intake['taken'].toDouble() / total;
      double missedPercentage = intake['missed'].toDouble() / total;

      tempList.add(
        Card(
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
                      intake['date'],
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
                  'Medicine: ${intake['medicine']}',
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
                        color: Colors.red.withOpacity(missedPercentage),
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    FractionallySizedBox(
                      widthFactor: takenPercentage,
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
                        Icon(Icons.check_circle, color: Colors.green, size: 18),
                        SizedBox(width: 4),
                        Text(
                          'Taken: ${intake['taken']}',
                          style: TextStyle(fontSize: 14, color: Colors.green),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(Icons.cancel, color: Colors.red, size: 18),
                        SizedBox(width: 4),
                        Text(
                          'Missed: ${intake['missed']} (${intake['missed']}/$total)',
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
    setState(() {
      barChartData = tempList;
    });
  }

  void _searchPatient(String patientId) {
    if (patients.containsKey(patientId)) {
      setState(() {
        patientData = patients[patientId]!;
        _generateData();
      });
    } else {
      setState(() {
        patientData = {};
        barChartData = [];
      });
    }
  }

  void _resetSearch() {
    setState(() {
      _patientIdController.clear();
      patientData = {};
      barChartData = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 217, 242, 255),
      appBar: AppBar(
        title: Text('Track Medicine Intake'),
        backgroundColor: Color.fromARGB(255, 244, 167, 193),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TypeAheadFormField<String?>(
              textFieldConfiguration: TextFieldConfiguration(
                controller: _patientIdController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Enter Patient ID',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  prefixIcon: Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              suggestionsCallback: (pattern) {
                return patientIds.where((id) => id.contains(pattern));
              },
              itemBuilder: (context, String? suggestion) {
                return ListTile(
                  title: Text(suggestion!),
                );
              },
              onSuggestionSelected: (String? suggestion) {
                if (suggestion != null) {
                  _patientIdController.text = suggestion;
                  _searchPatient(suggestion);
                }
              },
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () => _searchPatient(_patientIdController.text),
                  child: Text('Search'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 244, 167, 193),
                    foregroundColor: Colors.blueGrey[900],
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    textStyle: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: _resetSearch,
                  child: Text('Reset'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 244, 167, 193),
                    foregroundColor: Colors.blueGrey[900],
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    textStyle: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            patientData.isNotEmpty
                ? Expanded(
                    child: ListView(
                      children: [
                        Text(
                          'Patient ID: ${_patientIdController.text}',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueGrey[900],
                          ),
                        ),
                        Text(
                          'Patient Name: ${patientData['patientName']}',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueGrey[900],
                          ),
                        ),
                        SizedBox(height: 10),
                        Column(
                          children: barChartData,
                        ),
                      ],
                    ),
                  )
                : Center(
                    child: Text(
                      'No data available. Please search for a patient.',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.blueGrey[700],
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}

void main() => runApp(MaterialApp(
      home: TrackMedicineIntakePage(),
    ));

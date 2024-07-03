import 'package:flutter/material.dart';

class TrackMedicineIntakePage extends StatefulWidget {
  @override
  _TrackMedicineIntakePageState createState() =>
      _TrackMedicineIntakePageState();
}

class _TrackMedicineIntakePageState extends State<TrackMedicineIntakePage> {
  TextEditingController _patientIdController = TextEditingController();
  Map<String, dynamic> patientData = {};
  List<Widget> barChartData = [];

  // נתונים מדומים של מטופלים
  Map<String, Map<String, dynamic>> patients = {
    '323032': {
      'patientName': 'Ghaidaa Azzam',
      'medicineIntake': [
        {'date': '2023-07-01', 'taken': 2, 'missed': 1},
        {'date': '2023-07-02', 'taken': 3, 'missed': 0},
        {'date': '2023-07-03', 'taken': 2, 'missed': 1},
        {'date': '2023-07-04', 'taken': 3, 'missed': 0},
        {'date': '2023-07-05', 'taken': 1, 'missed': 2},
      ],
    },
    '987654321': {
      'patientName': 'Mohamad Zoabi',
      'medicineIntake': [
        {'date': '2023-07-01', 'taken': 1, 'missed': 2},
        {'date': '2023-07-02', 'taken': 2, 'missed': 1},
        {'date': '2023-07-03', 'taken': 3, 'missed': 0},
        {'date': '2023-07-04', 'taken': 1, 'missed': 2},
        {'date': '2023-07-05', 'taken': 2, 'missed': 1},
      ],
    },
    '123456789': {
      'patientName': 'Yomna Zoabi',
      'medicineIntake': [
        {'date': '2023-07-01', 'taken': 0, 'missed': 3},
        {'date': '2023-07-02', 'taken': 1, 'missed': 2},
        {'date': '2023-07-03', 'taken': 2, 'missed': 1},
        {'date': '2023-07-04', 'taken': 3, 'missed': 0},
        {'date': '2023-07-05', 'taken': 1, 'missed': 2},
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
                          'Missed: ${intake['missed']}',
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

  void _searchPatient() {
    // פונקציה לביצוע חיפוש מטופל לפי תעודת זהות
    String patientId = _patientIdController.text;
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
            TextField(
              controller: _patientIdController,
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
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: _searchPatient,
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

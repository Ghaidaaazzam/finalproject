import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class TrackMedicineIntakePage extends StatefulWidget {
  @override
  _TrackMedicineIntakePageState createState() =>
      _TrackMedicineIntakePageState();
}

class _TrackMedicineIntakePageState extends State<TrackMedicineIntakePage> {
  TextEditingController _patientIdController = TextEditingController();
  Map<String, dynamic> patientData = {};
  List<BarChartGroupData> barChartData = [];
  String errorMessage = '';

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
    List<BarChartGroupData> tempList = [];
    int index = 1;
    for (var intake in patientData['medicineIntake']) {
      tempList.add(
        BarChartGroupData(
          x: index,
          barRods: [
            BarChartRodData(
              y: intake['taken'].toDouble(),
              colors: [Colors.green],
              width: 8,
              borderRadius: const BorderRadius.all(Radius.zero),
            ),
            BarChartRodData(
              y: intake['missed'].toDouble(),
              colors: [Colors.red],
              width: 8,
              borderRadius: const BorderRadius.all(Radius.zero),
            ),
          ],
        ),
      );
      index++;
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
        errorMessage = '';
      });
    } else {
      setState(() {
        patientData = {};
        barChartData = [];
        errorMessage = 'No data available for the entered ID.';
      });
    }
  }

  void _resetFields() {
    setState(() {
      _patientIdController.clear();
      patientData = {};
      barChartData = [];
      errorMessage = '';
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
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
            ),
            SizedBox(height: 10),
            Row(
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
                  ),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _resetFields,
                  child: Text('Reset'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 244, 167, 193),
                    foregroundColor: Colors.blueGrey[900],
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    textStyle: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            if (errorMessage.isNotEmpty)
              Text(
                errorMessage,
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.red,
                ),
              ),
            patientData.isNotEmpty
                ? Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Patient Name: ${patientData['patientName']}',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blueGrey[900],
                                ),
                              ),
                              SizedBox(height: 10),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 16.0, right: 16.0),
                                  child: BarChart(
                                    BarChartData(
                                      barGroups: barChartData,
                                      titlesData: FlTitlesData(
                                        leftTitles: SideTitles(
                                          showTitles: true,
                                          getTextStyles: (context, value) =>
                                              const TextStyle(
                                            color: Colors.black,
                                            fontSize: 14,
                                          ),
                                          margin: 16,
                                          reservedSize: 28,
                                          interval: 1,
                                        ),
                                        bottomTitles: SideTitles(
                                          showTitles: true,
                                          getTextStyles: (context, value) =>
                                              const TextStyle(
                                            color: Colors.black,
                                            fontSize: 14,
                                          ),
                                          margin: 16,
                                          getTitles: (double value) {
                                            switch (value.toInt()) {
                                              case 1:
                                                return '01/07';
                                              case 2:
                                                return '02/07';
                                              case 3:
                                                return '03/07';
                                              case 4:
                                                return '04/07';
                                              case 5:
                                                return '05/07';
                                            }
                                            return '';
                                          },
                                        ),
                                      ),
                                      borderData: FlBorderData(show: true),
                                      gridData: FlGridData(show: true),
                                      barTouchData: BarTouchData(
                                        touchTooltipData: BarTouchTooltipData(
                                          tooltipBgColor: Colors.grey,
                                          getTooltipItem: (group, groupIndex,
                                              rod, rodIndex) {
                                            return BarTooltipItem(
                                              '${rod.y}',
                                              TextStyle(color: rod.colors[0]),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 10),
                              Center(
                                child: Text(
                                  'Date',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blueGrey[900],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 10),
                        Padding(
                          padding: const EdgeInsets.only(
                              top:
                                  190.0), // Adjust the value to position the title lower
                          child: RotatedBox(
                            quarterTurns: -1,
                            child: Text(
                              'Number of Intakes/Misses',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.blueGrey[900],
                              ),
                            ),
                          ),
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

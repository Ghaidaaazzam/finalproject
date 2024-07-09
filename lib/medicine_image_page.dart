import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';

void main() {
  runApp(MedicineImageApp());
}

class MedicineImageApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MedicineImagePage(),
    );
  }
}

class MedicineImagePage extends StatefulWidget {
  @override
  _MedicineImagePageState createState() => _MedicineImagePageState();
}

class _MedicineImagePageState extends State<MedicineImagePage> {
  Map<String, String> medicineImages = {};
  String? selectedMedicine;

  @override
  void initState() {
    super.initState();
    _loadMedicineData();
  }

  void _loadMedicineData() async {
    final data = await rootBundle.loadString('Excels/Medicine.csv');
    final lines = LineSplitter.split(data);
    for (var line in lines.skip(1)) {
      // Skip header line
      final values = line.split(',');
      if (values.length > 4) {
        setState(() {
          medicineImages[values[0]] = values[5].trim();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Medicine Image Test'),
      ),
      body: Column(
        children: [
          DropdownButton<String>(
            hint: Text('Select Medicine'),
            value: selectedMedicine,
            onChanged: (String? newValue) {
              setState(() {
                selectedMedicine = newValue;
              });
            },
            items: medicineImages.keys.map((String medicine) {
              return DropdownMenuItem<String>(
                value: medicine,
                child: Text(medicine),
              );
            }).toList(),
          ),
          if (selectedMedicine != null &&
              medicineImages[selectedMedicine]!.isNotEmpty)
            Image.asset(medicineImages[selectedMedicine]!)
          else
            Text('No image available'),
        ],
      ),
    );
  }
}

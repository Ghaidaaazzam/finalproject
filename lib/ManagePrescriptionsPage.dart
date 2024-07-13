import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

class ManagePrescriptionsPage extends StatefulWidget {
  @override
  _ManagePrescriptionsPageState createState() =>
      _ManagePrescriptionsPageState();
}

class _ManagePrescriptionsPageState extends State<ManagePrescriptionsPage> {
  final TextEditingController _typeAheadController = TextEditingController();
  int _selectedIndex = 3;

  bool _isPatientDataVisible = false;
  String _patientName = '';
  String _patientId = '';
  String _patientAge = '';
  List<Map<String, dynamic>> _prescriptions = [];
  String _patientDocId = '';

  Future<List<String>> _getPatientIds(String pattern) async {
    final QuerySnapshot patientsSnapshot =
        await FirebaseFirestore.instance.collection('patients').get();

    final List<String> patientIds = patientsSnapshot.docs
        .map((doc) => doc['ID'].toString())
        .where((id) => id.contains(pattern))
        .toList();

    return patientIds;
  }

  Future<void> _fetchPatientData(String id) async {
    final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('patients')
        .where('ID', isEqualTo: id)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      final DocumentSnapshot patientDoc = querySnapshot.docs.first;
      final Map<String, dynamic> patientData =
          patientDoc.data() as Map<String, dynamic>;

      final String birthdateStr = patientData['Birthdate'];
      DateTime birthdate;

      try {
        birthdate = DateFormat('MM/dd/yyyy').parse(birthdateStr);
      } catch (e) {
        try {
          birthdate = DateFormat('dd/MM/yyyy').parse(birthdateStr);
        } catch (e) {
          birthdate = DateTime.now();
        }
      }

      final int age = DateTime.now().year - birthdate.year;

      setState(() {
        _isPatientDataVisible = true;
        _patientName = patientData['FullName'];
        _patientId = patientData['ID'];
        _patientAge = age.toString();
        _patientDocId = patientDoc.id;
      });

      _fetchPrescriptions(patientDoc.id);
    } else {
      setState(() {
        _isPatientDataVisible = false;
        _prescriptions = [];
      });
    }
  }

  Future<void> _fetchPrescriptions(String patientDocId) async {
    final QuerySnapshot prescriptionsSnapshot = await FirebaseFirestore.instance
        .collection('patients')
        .doc(patientDocId)
        .collection('prescriptions')
        .get();

    final List<Map<String, dynamic>> prescriptions =
        prescriptionsSnapshot.docs.map((doc) {
      var data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id;
      return data;
    }).toList();

    setState(() {
      _prescriptions = prescriptions;
    });
  }

  Future<void> _updatePrescription(Map<String, dynamic> prescription) async {
    TextEditingController dailyDoseController =
        TextEditingController(text: prescription['dailyDose'].toString());
    TextEditingController pillsPerDoseController =
        TextEditingController(text: prescription['pillsPerDose'].toString());
    TextEditingController doctorNoticeController =
        TextEditingController(text: prescription['doctorNotice'] ?? '');
    TextEditingController startDateController =
        TextEditingController(text: prescription['startDate']);
    TextEditingController endDateController =
        TextEditingController(text: prescription['endDate']);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color.fromARGB(255, 217, 242, 255),
          title: Text(
            'Update Prescription for ${prescription['medicineName']}',
            style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey[900]),
          ),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: dailyDoseController,
                  decoration: InputDecoration(
                    labelText: 'Daily Dose',
                    labelStyle:
                        TextStyle(color: Colors.blueGrey[900], fontSize: 18),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.black)),
                  ),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: pillsPerDoseController,
                  decoration: InputDecoration(
                    labelText: 'Pills Per Dose',
                    labelStyle:
                        TextStyle(color: Colors.blueGrey[900], fontSize: 18),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.black)),
                  ),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: doctorNoticeController,
                  decoration: InputDecoration(
                    labelText: 'Doctor Notice',
                    labelStyle:
                        TextStyle(color: Colors.blueGrey[900], fontSize: 18),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.black)),
                  ),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: startDateController,
                  decoration: InputDecoration(
                    labelText: 'Start Date',
                    labelStyle:
                        TextStyle(color: Colors.blueGrey[900], fontSize: 18),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.black)),
                  ),
                  readOnly: true,
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.parse(prescription['startDate']),
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
                    labelStyle:
                        TextStyle(color: Colors.blueGrey[900], fontSize: 18),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.black)),
                  ),
                  readOnly: true,
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.parse(prescription['endDate']),
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
              child: Text('Cancel',
                  style: TextStyle(
                      color: Colors.blueGrey[900],
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Save',
                  style: TextStyle(
                      color: Colors.blueGrey[900],
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
              onPressed: () async {
                await FirebaseFirestore.instance
                    .collection('patients')
                    .doc(_patientDocId)
                    .collection('prescriptions')
                    .doc(prescription['id'])
                    .update({
                  'dailyDose': dailyDoseController.text,
                  'pillsPerDose': pillsPerDoseController.text,
                  'doctorNotice': doctorNoticeController.text,
                  'startDate': startDateController.text,
                  'endDate': endDateController.text,
                });
                Navigator.of(context).pop();
                _fetchPrescriptions(
                    _patientDocId); // Refresh the list of prescriptions
              },
            ),
          ],
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        );
      },
    );
  }

  Future<void> _deletePrescription(String prescriptionId) async {
    await FirebaseFirestore.instance
        .collection('patients')
        .doc(_patientDocId)
        .collection('prescriptions')
        .doc(prescriptionId)
        .delete();
    _fetchPrescriptions(_patientDocId); // Refresh the list of prescriptions
  }

  Future<void> _confirmDeletePatient() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Delete'),
          content: Text(
              'Are you sure you want to delete this patient? This action cannot be undone.'),
          actions: <Widget>[
            TextButton(
              child:
                  Text('Cancel', style: TextStyle(color: Colors.blueGrey[900])),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Delete', style: TextStyle(color: Colors.red)),
              onPressed: () async {
                Navigator.of(context).pop();
                await _deletePatient();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _deletePatient() async {
    final WriteBatch batch = FirebaseFirestore.instance.batch();

    final QuerySnapshot prescriptionsSnapshot = await FirebaseFirestore.instance
        .collection('patients')
        .doc(_patientDocId)
        .collection('prescriptions')
        .get();

    for (final DocumentSnapshot prescriptionDoc in prescriptionsSnapshot.docs) {
      batch.delete(prescriptionDoc.reference);
    }

    batch.delete(
        FirebaseFirestore.instance.collection('patients').doc(_patientDocId));

    await batch.commit();

    setState(() {
      _resetPage();
    });
  }

  void _resetPage() {
    setState(() {
      _typeAheadController.clear();
      _isPatientDataVisible = false;
      _patientName = '';
      _patientId = '';
      _patientAge = '';
      _prescriptions = [];
      _patientDocId = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 217, 242, 255),
      appBar: AppBar(
        title: Text(
          'Manage Prescriptions',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Color.fromARGB(255, 217, 242, 255),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TypeAheadFormField<String?>(
              textFieldConfiguration: TextFieldConfiguration(
                controller: _typeAheadController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Enter Patient ID',
                  labelStyle: TextStyle(color: Colors.black),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  prefixIcon: Icon(Icons.search, color: Colors.black),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              suggestionsCallback: _getPatientIds,
              itemBuilder: (context, String? suggestion) {
                return ListTile(
                  title:
                      Text(suggestion!, style: TextStyle(color: Colors.black)),
                );
              },
              onSuggestionSelected: (String? suggestion) {
                if (suggestion != null) {
                  _typeAheadController.text = suggestion;
                  _fetchPatientData(suggestion);
                }
              },
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () => _fetchPatientData(_typeAheadController.text),
                  child: Text('Fetch Prescriptions'),
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
                  onPressed: _resetPage,
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
            if (_isPatientDataVisible) ...[
              SizedBox(height: 20),
              Text(
                'Patient Details',
                style: TextStyle(
                  color: Colors.blueGrey[900],
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Name: $_patientName',
                style: TextStyle(
                  color: Colors.blueGrey[700],
                  fontSize: 18,
                ),
              ),
              Text(
                'ID: $_patientId',
                style: TextStyle(
                  color: Colors.blueGrey[700],
                  fontSize: 18,
                ),
              ),
              Text(
                'Age: $_patientAge',
                style: TextStyle(
                  color: Colors.blueGrey[700],
                  fontSize: 18,
                ),
              ),
              SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: _confirmDeletePatient,
                icon: Icon(Icons.delete),
                label: Text('Delete Patient'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
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
              SizedBox(height: 20),
              Text(
                'Prescriptions',
                style: TextStyle(
                  color: Colors.blueGrey[900],
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  itemCount: _prescriptions.length,
                  itemBuilder: (context, index) {
                    final prescription = _prescriptions[index];
                    return Card(
                      color: Colors.white,
                      margin: EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        title: Text(
                          prescription['medicineName'],
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.blueGrey[900]),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Daily Dose: ${prescription['dailyDose']}',
                              style: TextStyle(
                                  fontSize: 16, color: Colors.blueGrey[700]),
                            ),
                            Text(
                              'Pills Per Dose: ${prescription['pillsPerDose']}',
                              style: TextStyle(
                                  fontSize: 16, color: Colors.blueGrey[700]),
                            ),
                            Text(
                              'Start Date: ${prescription['startDate']}',
                              style: TextStyle(
                                  fontSize: 16, color: Colors.blueGrey[700]),
                            ),
                            Text(
                              'End Date: ${prescription['endDate']}',
                              style: TextStyle(
                                  fontSize: 16, color: Colors.blueGrey[700]),
                            ),
                            Text(
                              'Doctor Notice: ${prescription['doctorNotice'] ?? ''}',
                              style: TextStyle(
                                  fontSize: 16, color: Colors.blueGrey[700]),
                            ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit, color: Colors.blue),
                              onPressed: () =>
                                  _updatePrescription(prescription),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () =>
                                  _deletePrescription(prescription['id']),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
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
              Navigator.pushNamed(context, '/managePrescriptions');
              break;
          }
        },
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black,
        showUnselectedLabels: true,
        selectedLabelStyle: TextStyle(color: Colors.black),
        unselectedLabelStyle: TextStyle(color: Colors.black),
        items: [
          BottomNavigationBarItem(
            icon: Image.asset(
              'images/SmallLogo.png',
              height: 50.0,
              width: 50.0,
            ),
            label: 'Home Page',
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
                  Icons.list_alt,
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
            label: 'Manage Prescriptions',
          ),
        ],
      ),
    );
  }
}

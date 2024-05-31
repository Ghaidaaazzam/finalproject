import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: AddPatientPage(),
    );
  }
}

class AddPatientPage extends StatefulWidget {
  @override
  _AddPatientPageState createState() => _AddPatientPageState();
}

class _AddPatientPageState extends State<AddPatientPage> {
  // Define a common text style
  TextStyle commonTextStyle = TextStyle(
    color: Colors.blueGrey[900],
    fontSize: 20,
    fontWeight: FontWeight.w600,
    fontStyle: FontStyle.italic,
  );

  // Define a common border style
  OutlineInputBorder commonBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(8),
    borderSide: BorderSide(color: Colors.black),
  );

  int _selectedIndex = 2;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // Handle navigation based on the index
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 217, 242, 255),
      appBar: null, // Remove the AppBar
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Add Patient',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 36, // Increased font size
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 40), // Increased spacing
                  TextField(
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Enter Patient ID',
                      labelStyle: commonTextStyle,
                      border: commonBorder,
                      focusedBorder: commonBorder.copyWith(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      prefixIcon:
                          Icon(Icons.perm_identity, color: Colors.black),
                    ),
                  ),
                  SizedBox(height: 30), // Increased spacing
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Enter Patient Email',
                      labelStyle: commonTextStyle,
                      border: commonBorder,
                      focusedBorder: commonBorder.copyWith(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      prefixIcon: Icon(Icons.email, color: Colors.black),
                    ),
                  ),
                  SizedBox(height: 30), // Increased spacing
                  TextField(
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Enter Contact Number',
                      labelStyle: commonTextStyle,
                      border: commonBorder,
                      focusedBorder: commonBorder.copyWith(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      prefixIcon: Icon(Icons.phone, color: Colors.black),
                    ),
                  ),
                  SizedBox(height: 40), // Increased spacing
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        // Handle add patient action
                      },
                      borderRadius: BorderRadius.circular(30.0),
                      child: Ink(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Color.fromARGB(255, 244, 167, 193), // Pastel Pink
                              Color(0xFFF06292), // Slightly darker Pastel Pink
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
                        padding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        child: Center(
                          child: Text(
                            'Add Patient',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 217, 242, 255),
              Color.fromRGBO(132, 197, 238, 1),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              spreadRadius: 5,
              blurRadius: 10,
              offset: Offset(0, 3), // changes position of shadow
            ),
          ],
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.transparent, // Make background transparent
          elevation: 0, // Remove shadow/elevation
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          selectedItemColor:
              Colors.black, // Set the selected item color to black
          unselectedItemColor:
              Colors.black, // Set the unselected item color to black
          showSelectedLabels: true, // Show labels for selected items
          showUnselectedLabels: true, // Show labels for unselected items
          selectedLabelStyle: TextStyle(
              color: Colors.black), // Set the label text color to black
          unselectedLabelStyle: TextStyle(
              color: Colors.black), // Set the label text color to black
          items: [
            BottomNavigationBarItem(
              icon: Image.asset(
                'images/SmallLogo.png', // Make sure to add this image to your assets
                height: 50.0, // Adjusted size
                width: 50.0, // Adjusted size
              ),
              label: 'Logo',
            ),
            BottomNavigationBarItem(
              icon: Image.asset(
                'images/prescriptionIcon.png', // Use the new prescription icon
                height: 50.0, // Adjusted size
                width: 50.0, // Adjusted size
              ),
              label: 'Prescription',
            ),
            BottomNavigationBarItem(
              icon: Stack(
                children: <Widget>[
                  Icon(
                    Icons.person,
                    color: Colors.black,
                    size: 40, // Adjusted size
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Icon(
                      Icons.add_circle,
                      color: Colors.blue,
                      size: 24, // Adjusted size
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
                    size: 40, // Adjusted size
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Icon(
                      Icons.edit,
                      color: Colors.blue,
                      size: 24, // Adjusted size
                    ),
                  ),
                ],
              ),
              label: 'Edit Profile',
            ),
          ],
        ),
      ),
    );
  }
}

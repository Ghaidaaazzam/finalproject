import 'package:flutter/material.dart';
import 'AddPatient.dart';
import 'Prescription.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      routes: {
        '/': (context) => NavigationPage(),
        '/addPatient': (context) => AddPatientPage(),
        '/prescription': (context) => PrescriptionPage(),
      },
    );
  }
}

class NavigationPage extends StatefulWidget {
  @override
  _NavigationPageState createState() => _NavigationPageState();
}

class _NavigationPageState extends State<NavigationPage> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    switch (index) {
      case 0:
        Navigator.pushNamed(context, '/');
        break;
      case 1:
        Navigator.pushNamed(context, '/prescription');
        break;
      case 2:
        Navigator.pushNamed(context, '/addPatient');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 217, 242, 255),
      body: Center(
        child: Text(
          'Home Page',
          style: TextStyle(
            color: Colors.black,
            fontSize: 36,
            fontWeight: FontWeight.bold,
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
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          selectedItemColor: Colors.black,
          unselectedItemColor: Colors.black,
          showSelectedLabels: true,
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
      ),
    );
  }
}

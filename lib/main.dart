import 'package:finalproject/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'LogInPage.dart';
import 'doctorHomePage.dart';
import 'prescription.dart';
import 'AddPatient.dart';
import 'TrackMedicineIntakePage.dart';
import 'ManagePrescriptionsPage.dart'; // ייבוא העמוד החדש

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(PillPoppinApp());
}

class PillPoppinApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PillPoppin',
      theme: ThemeData(
        colorScheme: ColorScheme.light(
          primary: Color(0xFFA8DADC), // Pastel Blue
          secondary: Color(0xFFFF9DC6), // Pastel Pink
          background: Color.fromARGB(255, 217, 242, 255), // White
          surface: Color.fromARGB(255, 175, 227, 252), // Pastel Bright Blue
          onPrimary: Color(0xFFFFFFFF), // White
          onSecondary: Color.fromARGB(255, 0, 0, 0), // Black
          onBackground: Color(0xFFB0BEC5), // Light Gray
          onSurface: Color(0xFFB0BEC5), // Light Gray
        ),
        textTheme: TextTheme(
          headline1: TextStyle(color: Color(0xFF000000)), // Black
          bodyText1: TextStyle(color: Color(0xFF000000)), // Black
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => WelcomeScreen(),
        '/login': (context) => LoginPage(),
        '/doctorHome': (context) => DoctorHomePage(),
        '/prescription': (context) => PrescriptionPage(),
        '/addPatient': (context) => AddPatientPage(),
        '/trackMedicineIntake': (context) => TrackMedicineIntakePage(),
        '/managePrescriptions': (context) =>
            ManagePrescriptionsPage(), // הוספת הנתיב החדש
      },
    );
  }
}

class WelcomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                alignment: Alignment.topCenter,
                margin: EdgeInsets.only(top: 40),
                child: Image.asset('images/FinalLogo.png',
                    width: 500, height: 300),
              ),
              SizedBox(height: 20),
              Text(
                'Welcome to PillPoppin!',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Keep your health in check,\n one pill at a time!',
                style: TextStyle(
                  color: Color.fromARGB(255, 86, 87, 88),
                  fontFamily: 'Georgia',
                  fontSize: 20,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    Navigator.pushNamed(context, '/login');
                  },
                  borderRadius: BorderRadius.circular(30.0),
                  child: Ink(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color.fromARGB(255, 244, 167, 193),
                          Color(0xFFF06292),
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
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Center(
                      child: Text(
                        'Let\'s get started!',
                        style: TextStyle(
                          fontSize: 16,
                          color: const Color.fromARGB(255, 0, 0, 0),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 50),
            ],
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Image.asset(
              'images/Doctor1.png',
              width: 250,
              height: 250,
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'LogInPage.dart'; // Import the LoginPage
import 'myMedicines.dart'; // Import the MyMedicines page
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:timezone/data/latest.dart' as tz;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();
  runApp(PillPoppinApp());
}

class PillPoppinApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('en', 'US'), // English (US)
        const Locale('en', 'GB'), // English (UK)
      ],
      locale: const Locale(
          'en', 'GB'), // Set the locale to UK English for 24-hour format
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
          displayLarge: TextStyle(color: Color(0xFF000000)), // Black
          bodyLarge: TextStyle(color: Color(0xFF000000)), // Black
        ),
        timePickerTheme: TimePickerThemeData(
          backgroundColor: Color(0xFFF8E1E9), // Light pastel pink
          hourMinuteTextColor: Colors.black,
          hourMinuteColor: Color(0xFFF06292), // Slightly darker pastel pink
          dialHandColor: Color(0xFFF06292),
          dialBackgroundColor: Colors.white,
          entryModeIconColor: Color(0xFFF06292),
          helpTextStyle: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          hourMinuteTextStyle: TextStyle(
            color: Colors.black,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
          dialTextColor: MaterialStateColor.resolveWith((states) =>
              states.contains(MaterialState.selected)
                  ? Colors.white
                  : Colors.black),
          inputDecorationTheme: InputDecorationTheme(
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFFF06292)),
            ),
          ),
        ),
      ),
      home: QuestionScreen(
          userId: '3FCQN3X6Sykn5y01f2xS'), // Replace with actual userId
    );
  }
}

class QuestionScreen extends StatefulWidget {
  final String userId;

  QuestionScreen({required this.userId});

  @override
  _QuestionScreenState createState() => _QuestionScreenState();
}

class _QuestionScreenState extends State<QuestionScreen> {
  final PageController _pageController = PageController();
  final List<Widget> _questions = [];
  final Map<String, String> _surveyAnswers = {};

  @override
  void initState() {
    super.initState();
    _questions.addAll([
      TimeQuestionScreen(
        question: 'What time do you wake up in the morning?',
        pageController: _pageController,
        imagePath: 'images/sun.png', // Image for waking up
        userId: widget.userId,
        isLast: false,
        onAnswered: _storeAnswer,
        surveyAnswers: _surveyAnswers,
      ),
      TimeQuestionScreen(
        question: 'At what time do you have breakfast?',
        pageController: _pageController,
        imagePath: 'images/coffee.png', // Image for breakfast
        userId: widget.userId,
        isLast: false,
        onAnswered: _storeAnswer,
        surveyAnswers: _surveyAnswers,
      ),
      TimeQuestionScreen(
        question: 'What time do you have lunch?',
        pageController: _pageController,
        imagePath: 'images/launch.png', // Image for lunch
        userId: widget.userId,
        isLast: false,
        onAnswered: _storeAnswer,
        surveyAnswers: _surveyAnswers,
      ),
      TimeQuestionScreen(
        question: 'What time do you have dinner?',
        pageController: _pageController,
        imagePath: 'images/dinner.png', // Image for dinner
        userId: widget.userId,
        isLast: false,
        onAnswered: _storeAnswer,
        surveyAnswers: _surveyAnswers,
      ),
      TimeQuestionScreen(
        question: 'What time do you go to bed at night?',
        pageController: _pageController,
        imagePath: 'images/moon.png', // Image for going to bed
        userId: widget.userId,
        isLast: true,
        onAnswered: _storeAnswer,
        surveyAnswers: _surveyAnswers,
      ),
    ]);
  }

  void _storeAnswer(String question, String answer) {
    setState(() {
      _surveyAnswers[question] = answer;
    });
    print('Stored answer: $question -> $answer');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 217, 242, 255),
        title: Text('PillPoppin Questions'),
      ),
      backgroundColor: Color.fromARGB(255, 217, 242, 255),
      body: PageView(
        controller: _pageController,
        children: _questions,
        physics:
            NeverScrollableScrollPhysics(), // Disable swipe to change pages
      ),
    );
  }
}

class TimeQuestionScreen extends StatefulWidget {
  final String question;
  final PageController pageController;
  final String imagePath; // Change to use image path
  final bool isLast;
  final String userId;
  final void Function(String question, String answer) onAnswered;
  final Map<String, String> surveyAnswers;

  TimeQuestionScreen({
    required this.question,
    required this.pageController,
    required this.imagePath, // Change to use image path
    required this.isLast,
    required this.userId,
    required this.onAnswered,
    required this.surveyAnswers,
  });

  @override
  _TimeQuestionScreenState createState() => _TimeQuestionScreenState();
}

class _TimeQuestionScreenState extends State<TimeQuestionScreen> {
  TimeOfDay _selectedTime = TimeOfDay(hour: 7, minute: 0);

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Color(0xFFF06292), // header background color
              onPrimary: Colors.white, // header text color
              onSurface: Colors.black, // body text color
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.black, // button text color
                side:
                    BorderSide(color: Color(0xFFF06292)), // button border color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
          ),
          child: MediaQuery(
            data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
            child: child!,
          ),
        );
      },
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  TextStyle commonTextStyle = TextStyle(
    color: Colors.blueGrey[900],
    fontSize: 20,
    fontWeight: FontWeight.w600,
    fontStyle: FontStyle.italic,
  );

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(height: 40.0),
            Container(
              alignment: Alignment.topCenter,
              child: Image.asset(
                widget.imagePath, // Use image asset
                width: 80.0, // Adjust the size of the image
                height: 80.0, // Adjust the size of the image
                fit: BoxFit.contain,
              ),
            ),
            SizedBox(height: 40.0),
            Text(
              widget.question,
              textAlign: TextAlign.center,
              style: commonTextStyle,
            ),
            SizedBox(height: 20.0),
            GestureDetector(
              onTap: () => _selectTime(context),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8.0),
                  color: Colors.white,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}",
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Icon(
                      Icons.arrow_drop_down,
                      color: Colors.black,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 30.0),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  widget.onAnswered(
                    widget.question,
                    "${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}",
                  );
                  widget.surveyAnswers[widget.question] =
                      "${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}";
                  if (widget.isLast) {
                    _showSurveyCompletionDialog();
                  } else {
                    widget.pageController.nextPage(
                      duration: Duration(milliseconds: 300),
                      curve: Curves.easeIn,
                    );
                  }
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
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.arrow_forward,
                        color: Colors.black,
                      ),
                      SizedBox(width: 8.0),
                      Text(
                        'Next',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  if (widget.pageController.page! > 0) {
                    widget.pageController.previousPage(
                      duration: Duration(milliseconds: 300),
                      curve: Curves.easeIn,
                    );
                  }
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
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.arrow_back,
                        color: Colors.black,
                      ),
                      SizedBox(width: 8.0),
                      Text(
                        'Previous',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSurveyCompletionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color.fromARGB(255, 217, 242, 255),
          title: Text('End of Survey'),
          content: Text(
            'You have completed the survey! Do you want to submit your answers?',
            style: TextStyle(color: Colors.black),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'No, go back',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () {
                Navigator.of(context)
                    .pop(); // Close the dialog and stay on the survey
              },
            ),
            TextButton(
              child: Text(
                'Yes, submit',
                style: TextStyle(color: Colors.green),
              ),
              onPressed: () {
                _submitSurvey();
              },
            ),
          ],
        );
      },
    );
  }

  void _submitSurvey() async {
    Navigator.of(context).pop(); // Close the dialog

    // Debug print statements
    print('Submitting survey answers: ${widget.surveyAnswers}');

    // Check if patient exists
    final querySnapshot = await FirebaseFirestore.instance
        .collection('patients')
        .where('ID', isEqualTo: widget.userId)
        .get();

    if (querySnapshot.docs.isEmpty) {
      print('Patient not found.');
      return;
    }

    // Patient exists, proceed with adding survey answers
    DocumentReference patientDoc = querySnapshot.docs.first.reference;
    CollectionReference surveyCollection = patientDoc.collection('survey');

    // Add each question and answer as a document in the survey collection
    for (var entry in widget.surveyAnswers.entries) {
      await surveyCollection
          .add({
            'question': entry.key,
            'answer': entry.value,
          })
          .then((value) => print('Survey entry added to Firestore'))
          .catchError((error) => print('Failed to add survey entry: $error'));
    }

    // Update FirstLogin field to true
    await patientDoc.update({'FirstLogin': true}).then((value) {
      print('FirstLogin updated to true');
    }).catchError((error) {
      print('Failed to update FirstLogin: $error');
    });

    // Navigate to MyMedicines page
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => MyMedicines(userId: widget.userId)),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Survey submitted successfully!')),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class FavoritePage extends StatefulWidget {
  final String userId;
  final List<String> questions;
  final List<String> images;

  FavoritePage({
    required this.userId,
    required this.questions,
    required this.images,
  });

  @override
  _FavoritePageState createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  Map<String, TimeOfDay> _userAnswers = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchSurveyAnswers();
  }

  Future<void> _fetchSurveyAnswers() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('patients')
          .where('ID', isEqualTo: widget.userId)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        DocumentSnapshot userDoc = querySnapshot.docs.first;
        QuerySnapshot surveySnapshot =
            await userDoc.reference.collection('survey').get();

        Map<String, TimeOfDay> answers = {};
        for (var doc in surveySnapshot.docs) {
          String question = doc['question'];
          String answer = doc['answer'];
          List<String> timeParts = answer.split(':');
          int hour = int.parse(timeParts[0]);
          int minute = int.parse(timeParts[1]);
          answers[question] = TimeOfDay(hour: hour, minute: minute);
        }

        setState(() {
          _userAnswers = answers;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching survey answers: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _selectTime(BuildContext context, String question) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _userAnswers[question] ?? TimeOfDay(hour: 7, minute: 0),
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
    if (picked != null && picked != _userAnswers[question]) {
      setState(() {
        _userAnswers[question] = picked;
      });
      // Update the answer in Firebase
      await _updateAnswerInFirebase(question, picked);
    }
  }

  Future<void> _updateAnswerInFirebase(
      String question, TimeOfDay answer) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('patients')
          .where('ID', isEqualTo: widget.userId)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        DocumentSnapshot userDoc = querySnapshot.docs.first;
        QuerySnapshot surveySnapshot = await userDoc.reference
            .collection('survey')
            .where('question', isEqualTo: question)
            .get();

        if (surveySnapshot.docs.isNotEmpty) {
          DocumentSnapshot questionDoc = surveySnapshot.docs.first;
          await questionDoc.reference.update({
            'answer':
                "${answer.hour.toString().padLeft(2, '0')}:${answer.minute.toString().padLeft(2, '0')}"
          });
        }
      }
    } catch (e) {
      print('Error updating answer in Firebase: $e');
    }
  }

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
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Color.fromARGB(255, 217, 242, 255),
          title: Text('Favorite Times'),
        ),
        backgroundColor: Color.fromARGB(255, 217, 242, 255),
        body: _isLoading
            ? Center(child: CircularProgressIndicator())
            : ListView.builder(
                itemCount: widget.questions.length,
                itemBuilder: (context, index) {
                  String question = widget.questions[index];
                  TimeOfDay? answer = _userAnswers[question];
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Image.asset(
                              widget.images[index],
                              width: 40,
                              height: 40,
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                question,
                                style: TextStyle(
                                  color: Colors.blueGrey[900],
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10.0),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 16.0, vertical: 16.0),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(8.0),
                                  color: Colors.white,
                                ),
                                child: Text(
                                  "${answer?.hour.toString().padLeft(2, '0') ?? '--'}:${answer?.minute.toString().padLeft(2, '0') ?? '--'}",
                                  style: TextStyle(
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                            SizedBox(width: 10.0),
                            ElevatedButton(
                              onPressed: () => _selectTime(context, question),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFFF06292),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                              ),
                              child: Text(
                                'Update',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16.0,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}

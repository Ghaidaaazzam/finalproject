import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  runApp(FavoriteApp());
}

class FavoriteApp extends StatelessWidget {
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
      home: FavoritePage(
        userAnswers: {
          'What time do you wake up in the morning?':
              TimeOfDay(hour: 7, minute: 0),
          'At what time do you have breakfast?': TimeOfDay(hour: 8, minute: 0),
          'What time do you have lunch?': TimeOfDay(hour: 12, minute: 0),
          'What time do you have dinner?': TimeOfDay(hour: 18, minute: 0),
          'What time do you go to bed at night?':
              TimeOfDay(hour: 22, minute: 0),
        },
        questions: [
          'What time do you wake up in the morning?',
          'At what time do you have breakfast?',
          'What time do you have lunch?',
          'What time do you have dinner?',
          'What time do you go to bed at night?',
        ],
        images: [
          'images/sun.png', // Icon for waking up
          'images/coffee.png', // Icon for breakfast
          'images/launch.png', // Icon for lunch
          'images/dinner.png', // Icon for dinner
          'images/moon.png', // Icon for going to bed
        ],
      ),
    );
  }
}

class FavoritePage extends StatefulWidget {
  final Map<String, TimeOfDay> userAnswers;
  final List<String> questions;
  final List<String> images;

  FavoritePage(
      {required this.userAnswers,
      required this.questions,
      required this.images});

  @override
  _FavoritePageState createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  late Map<String, TimeOfDay> _userAnswers;
  late String _currentQuestion;

  @override
  void initState() {
    super.initState();
    _userAnswers = Map.from(widget.userAnswers);
    _currentQuestion = '';
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
          child: child!,
        );
      },
    );
    if (picked != null && picked != _userAnswers[question]) {
      setState(() {
        _userAnswers[question] = picked;
      });
    }
  }

  void _updateAnswer(String question) async {
    _currentQuestion = question;
    await _selectTime(context, question);
    setState(() {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Updated the answer for "$question"')),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 217, 242, 255),
        title: Text('Favorite Times'),
      ),
      backgroundColor: Color.fromARGB(255, 217, 242, 255),
      body: ListView.builder(
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
                      onPressed: () => _updateAnswer(question),
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
    );
  }
}

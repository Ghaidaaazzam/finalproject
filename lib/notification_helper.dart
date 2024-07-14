import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/services.dart'; // Add this import for rootBundle
import 'dart:convert'; // Add this import for LineSplitter

class NotificationHelper with WidgetsBindingObserver {
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  late BuildContext context;
  Map<String, String> medicineImages = {};
  bool _isAppInForeground = true;
  List<Map<String, dynamic>> _scheduledNotifications = [];

  NotificationHelper(BuildContext context) {
    this.context = context;
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');

    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
    );

    flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        if (response.payload != null) {
          final prescriptionDocPath = response.payload!;
          _showPopup("Time to take your medicine!", prescriptionDocPath);
        }
      },
    );

    // Initialize timezone data
    tz.initializeTimeZones();

    // Load medicine images from CSV
    _loadMedicineImages();

    // Add the observer to monitor app state
    WidgetsBinding.instance.addObserver(this);
  }

  void removeObserver() {
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _isAppInForeground = state == AppLifecycleState.resumed;
    if (_isAppInForeground) {
      _cancelAllNotifications();
    } else {
      _rescheduleAllNotifications();
    }
  }

  Future<void> _loadMedicineImages() async {
    final data = await rootBundle.loadString('Excels/Medicine.csv');
    final lines = LineSplitter.split(data);
    for (var line in lines.skip(1)) {
      final values = line.split(',');
      if (values.isNotEmpty && values.length > 5) {
        medicineImages[values[0]] =
            values[5]; // Assuming image path is at index 5
      }
    }
  }

  Future<void> scheduleNotification(
      TimeOfDay time, String message, DocumentReference prescriptionDoc) async {
    final now = DateTime.now();
    final scheduleDateTime = DateTime(
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    final scheduleTime = tz.TZDateTime.from(scheduleDateTime, tz.local);

    final androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'your_channel_id',
      'your_channel_name',
      channelDescription: 'your_channel_description',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
    );

    final platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    // Use the prescription document path as the payload
    final payload = prescriptionDoc.path;

    _scheduledNotifications.add({
      'id': _scheduledNotifications.length,
      'time': scheduleTime,
      'message': message,
      'details': platformChannelSpecifics,
      'payload': payload,
    });

    if (_isAppInForeground) {
      Future.delayed(scheduleTime.difference(now), () {
        if (_isAppInForeground) {
          _showPopup(message, payload);
        } else {
          _scheduleNotification(_scheduledNotifications.length, message,
              scheduleTime, platformChannelSpecifics, payload);
        }
      });
    } else {
      _scheduleNotification(_scheduledNotifications.length, message,
          scheduleTime, platformChannelSpecifics, payload);
    }

    print('Notification scheduled for $scheduleTime with payload: $payload');
  }

  void _scheduleNotification(int id, String message, tz.TZDateTime scheduleTime,
      NotificationDetails details, String payload) async {
    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      'Medicine Reminder',
      message,
      scheduleTime,
      details,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: payload,
    );
  }

  void _cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
    print('All notifications canceled');
  }

  void _rescheduleAllNotifications() async {
    for (var notification in _scheduledNotifications) {
      _scheduleNotification(
          notification['id'],
          notification['message'],
          notification['time'],
          notification['details'],
          notification['payload']);
    }
    print('All notifications rescheduled');
  }

  void _showPopup(String message, String prescriptionDocPath) async {
    final docRef = FirebaseFirestore.instance.doc(prescriptionDocPath);
    final docSnapshot = await docRef.get();
    final prescriptionData = docSnapshot.data() as Map<String, dynamic>;

    String medicineName = prescriptionData['medicineName'];
    String imagePath = medicineImages[medicineName] ??
        'images/Medicines.png'; // Default image if not found

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Container(
            padding: EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              color: Color.fromARGB(255, 255, 245, 238),
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () => _showEnlargedImage(imagePath),
                  child: Image.asset(
                    imagePath,
                    height: 300,
                    width: 300,
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'Reminder',
                  style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 10),
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 18.0,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Color(0xFF81C784), // Green color for "I take it"
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      onPressed: () {
                        print("I take it button pressed");
                        _updateIntakeStatus(
                            prescriptionDocPath, true); // Mark as taken
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        'I take it',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromARGB(255, 201, 19,
                            19), // Red color for "I didn't get it"
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      onPressed: () {
                        _updateIntakeStatus(
                            prescriptionDocPath, false); // Mark as missed
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        'I didn\'t get it',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Color(0xFFFFD700), // Yellow color for "Remind me later"
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  onPressed: () {
                    print("Remind me later button pressed");
                    Navigator.of(context).pop();
                    _selectTimeForReschedule(context, prescriptionDocPath);
                  },
                  child: Text(
                    'Remind me later',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showEnlargedImage(String imagePath) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(imagePath, fit: BoxFit.contain),
              SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(
                  'Close',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
                style: TextButton.styleFrom(
                  backgroundColor: Colors.black54,
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _selectTimeForReschedule(
      BuildContext context, String prescriptionDocPath) async {
    TimeOfDay initialTime = TimeOfDay.now();

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
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

    if (picked != null) {
      final scheduleTime = tz.TZDateTime.from(
        DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day,
            picked.hour, picked.minute),
        tz.local,
      );

      // Update the new time in Firestore
      final docRef = FirebaseFirestore.instance.doc(prescriptionDocPath);
      final docSnapshot = await docRef.get();
      if (docSnapshot.exists) {
        final prescriptionData = docSnapshot.data() as Map<String, dynamic>;
        List<dynamic> times = prescriptionData['times'] ?? [];
        times.add(
            "${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}");
        await docRef.update({'times': times});
        print('Updated times in Firestore: $times');
      }

      await flutterLocalNotificationsPlugin.zonedSchedule(
        0,
        'Medicine Reminder',
        'Time to take your medicine!',
        scheduleTime,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'your_channel_id',
            'your_channel_name',
            channelDescription: 'your_channel_description',
            importance: Importance.max,
            priority: Priority.high,
            showWhen: false,
          ),
        ),
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: prescriptionDocPath,
      );

      print('Notification rescheduled for $scheduleTime');
    }
  }

  Future<void> _updateIntakeStatus(
      String prescriptionDocPath, bool taken) async {
    try {
      print(
          'Updating intake status for prescriptionDocPath: $prescriptionDocPath');
      final docRef = FirebaseFirestore.instance.doc(prescriptionDocPath);

      print('Document reference path: ${docRef.path}');

      final docSnapshot = await docRef.get();
      print('Fetched document: ${docSnapshot.data()}');

      if (docSnapshot.exists) {
        final prescriptionData = docSnapshot.data() as Map<String, dynamic>;
        final medicineName = prescriptionData['medicineName'];

        // Create or update the daily record
        final now = DateTime.now();
        final dateId =
            '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
        final dailyDocRef = docRef.collection('medicines').doc(dateId);

        await dailyDocRef.set({
          'date': now,
        }, SetOptions(merge: true));

        final takeOrMissDocRef =
            dailyDocRef.collection('takeOrMiss').doc(medicineName);
        await takeOrMissDocRef.set({
          'medicineName': medicineName,
          'taken': taken,
        }, SetOptions(merge: true));

        // Update capacity if the medicine was taken
        if (taken) {
          final capacity = prescriptionData['capacity'] as int;
          final pillsPerDose = prescriptionData['pillsPerDose'] as int;
          final newCapacity = capacity - pillsPerDose;

          await docRef.update({'capacity': newCapacity});
          print('Capacity updated: $newCapacity');
        }
      } else {
        print('Document does not exist');
      }
    } catch (e) {
      print('Failed to update intake status: $e');
    }
  }
}

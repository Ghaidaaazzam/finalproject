import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationHelper {
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  late BuildContext context;

  NotificationHelper(BuildContext context) {
    this.context = context;
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    final initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');
    final initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse:
            (NotificationResponse response) async {
      // Handle notification tapped logic here
      print("Notification Tapped");
      if (response.payload != null) {
        final prescriptionDocPath = response.payload!;
        print('Payload data: prescriptionDocPath = $prescriptionDocPath');
        _showPopup("Time to take your medicine!", prescriptionDocPath);
      }
    });

    // Initialize timezone data
    tz.initializeTimeZones();
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

    await flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      'Medicine Reminder',
      message,
      scheduleTime,
      platformChannelSpecifics,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: payload,
    );

    print('Notification scheduled for $scheduleTime with payload: $payload');
  }

  void _showPopup(String message, String prescriptionDocPath) {
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
                Image.asset(
                  'images/Medicines.png', // Add your medicine image asset
                  height: 100,
                  width: 100,
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
                        _updateCapacity(prescriptionDocPath);
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        'I take it',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(
                            0xFFFFF176), // Yellow color for "Remind me later"
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                        // Add logic to reschedule the notification
                      },
                      child: Text(
                        'Remind me later',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _updateCapacity(String prescriptionDocPath) async {
    try {
      print('Updating capacity for prescriptionDocPath: $prescriptionDocPath');
      final docRef = FirebaseFirestore.instance.doc(prescriptionDocPath);

      print('Document reference path: ${docRef.path}');

      final docSnapshot = await docRef.get();
      print('Fetched document: ${docSnapshot.data()}');

      if (docSnapshot.exists) {
        final prescriptionData = docSnapshot.data() as Map<String, dynamic>;

        final capacity = prescriptionData['capacity'] as int;
        final pillsPerDose = prescriptionData['pillsPerDose'] as int;

        final newCapacity = capacity - pillsPerDose;

        await docRef.update({'capacity': newCapacity});
        print('Capacity updated: $newCapacity');
      } else {
        print('Document does not exist');
      }
    } catch (e) {
      print('Failed to update capacity: $e');
    }
  }
}

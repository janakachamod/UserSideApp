import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';

class SetEvent extends StatefulWidget {
  @override
  _SetEventState createState() => _SetEventState();
}

class _SetEventState extends State<SetEvent> {
  final TextEditingController _eventNameController = TextEditingController();
  DateTime? _selectedDateTime;
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    // Initialize the notifications
    _initializeNotifications();
  }

  void _initializeNotifications() {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> _scheduleNotification(
      String eventName, DateTime dateTime) async {
    var androidPlatformChannelSpecifics = const AndroidNotificationDetails(
        'event_reminder_channel', 'Medicare',
        importance: Importance.max, priority: Priority.high, ticker: 'ticker');

    var platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.schedule(
      0,
      'Event Reminder',
      eventName,
      dateTime,
      platformChannelSpecifics,
    );
  }

  Future<void> _pickDateTime() async {
    DateTime? date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (date != null) {
      TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (time != null) {
        setState(() {
          _selectedDateTime =
              DateTime(date.year, date.month, date.day, time.hour, time.minute);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Set Event'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _eventNameController,
              decoration: const InputDecoration(
                labelText: 'Event Name',
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Text(
                  _selectedDateTime != null
                      ? DateFormat('yyyy-MM-dd HH:mm')
                          .format(_selectedDateTime!)
                      : 'No date/time selected',
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: _pickDateTime,
                  child: const Text('Pick Date & Time'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  if (_eventNameController.text.isNotEmpty &&
                      _selectedDateTime != null) {
                    _scheduleNotification(
                        _eventNameController.text, _selectedDateTime!);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Event scheduled successfully!'),
                    ));
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text(
                          'Please enter event details and select date/time.'),
                    ));
                  }
                },
                child: const Text('Set Event'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

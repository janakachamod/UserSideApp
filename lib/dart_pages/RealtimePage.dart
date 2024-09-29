import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class RealtimePage extends StatefulWidget {
  const RealtimePage({super.key});

  @override
  _RealtimePageState createState() => _RealtimePageState();
}

class _RealtimePageState extends State<RealtimePage> {
  final DatabaseReference _dbRef =
      FirebaseDatabase.instance.ref(); // Reference to the root of your database
  int _bpm = 0;
  bool _alert = false;

  @override
  void initState() {
    super.initState();
    _setupRealtimeListeners();
  }

  void _setupRealtimeListeners() {
    // Listen for BPM value changes
    _dbRef.child('BPM').onValue.listen((event) {
      DataSnapshot bpmSnapshot = event.snapshot;
      setState(() {
        _bpm = bpmSnapshot.value is int ? bpmSnapshot.value as int : 0;
      });
    });

    // Listen for alert value changes
    _dbRef.child('Alert').onValue.listen((event) {
      DataSnapshot alertSnapshot = event.snapshot;
      setState(() {
        int alertValue =
            alertSnapshot.value is int ? alertSnapshot.value as int : 0;
        _alert = alertValue == 1;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BPM REAL TIME DATA'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildDataCard('BPM', '$_bpm', Colors.blueAccent),
            SizedBox(height: 20),
            _buildAlertCard(_alert),
          ],
        ),
      ),
    );
  }

  Widget _buildDataCard(String title, String value, Color color) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: color.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertCard(bool alert) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: alert
          ? Colors.redAccent.withOpacity(0.1)
          : Colors.greenAccent.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Alert',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: alert ? Colors.redAccent : Colors.greenAccent,
              ),
            ),
            Text(
              alert ? 'Activated' : 'Deactivated',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: alert ? Colors.redAccent : Colors.greenAccent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

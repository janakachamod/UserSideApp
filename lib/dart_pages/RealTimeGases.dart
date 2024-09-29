import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:crebrew/dart_pages/AllGasesGraphPage.dart';

class RealTimeGases extends StatefulWidget {
  const RealTimeGases({super.key});

  @override
  _RealTimeGasesState createState() => _RealTimeGasesState();
}

class _RealTimeGasesState extends State<RealTimeGases> {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();
  double _co = 0.0;
  double _nh3 = 0.0;
  double _toluene = 0.0;
  double _no2 = 0.0;

  @override
  void initState() {
    super.initState();
    _setupRealtimeListeners();
  }

  void _setupRealtimeListeners() {
    _dbRef.child('gases/CO').onValue.listen((event) {
      DataSnapshot coSnapshot = event.snapshot;
      print("CO: ${coSnapshot.value}");
      setState(() {
        _co = coSnapshot.value is double ? coSnapshot.value as double : 0.0;
      });
    });

    _dbRef.child('gases/NH3').onValue.listen((event) {
      DataSnapshot nh3Snapshot = event.snapshot;
      print("NH3: ${nh3Snapshot.value}");
      setState(() {
        _nh3 = nh3Snapshot.value is double ? nh3Snapshot.value as double : 0.0;
      });
    });

    _dbRef.child('gases/Toluene').onValue.listen((event) {
      DataSnapshot tolueneSnapshot = event.snapshot;
      print("Toluene: ${tolueneSnapshot.value}");
      setState(() {
        _toluene = tolueneSnapshot.value is double
            ? tolueneSnapshot.value as double
            : 0.0;
      });
    });

    _dbRef.child('gases/NH4').onValue.listen((event) {
      DataSnapshot no2Snapshot = event.snapshot;
      print("NO2: ${no2Snapshot.value}");
      setState(() {
        _no2 = no2Snapshot.value is double ? no2Snapshot.value as double : 0.0;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Realtime Gases'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildGasCard('CO', _co, Colors.redAccent, () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const AllGasesGraphPage()),
              );
            }),
            SizedBox(height: 20),
            _buildGasCard('NH3', _nh3, Colors.blueAccent, () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const AllGasesGraphPage()),
              );
            }),
            SizedBox(height: 20),
            _buildGasCard('Toluene', _toluene, Colors.greenAccent, () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const AllGasesGraphPage()),
              );
            }),
            SizedBox(height: 20),
            _buildGasCard('NO2', _no2, Colors.orangeAccent, () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const AllGasesGraphPage()),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildGasCard(
      String gasName, double value, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        color: color.withOpacity(0.2),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                gasName,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                '${value.toStringAsFixed(2)} ppm',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

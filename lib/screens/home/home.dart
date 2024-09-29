import 'package:crebrew/dart_pages/AllGasesGraphPage.dart';
import 'package:crebrew/dart_pages/BPMGraphPage.dart';
import 'package:crebrew/dart_pages/SetEvent.dart';
import 'package:crebrew/dart_pages/UserProfile.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:crebrew/dart_pages/StreamData.dart';
import 'package:crebrew/dart_pages/StreamGases.dart';
import 'package:crebrew/dart_pages/RealtimePage.dart';
import 'package:crebrew/dart_pages/GasPrediction.dart';
import 'package:crebrew/dart_pages/HealthPrediction.dart';
import 'package:crebrew/dart_pages/GetCurrentLocation.dart';
import 'package:crebrew/dart_pages/viewProfile.dart';
import 'package:crebrew/dart_pages/RealTimeGases.dart';
import 'package:crebrew/constants/colors.dart';
import 'package:crebrew/constants/description.dart';
import 'package:crebrew/services/auth.dart';
import 'package:crebrew/screens/authenicate/signin.dart'; // Correct import for SignIn page
import 'package:intl/intl.dart'; // For date formatting

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final AuthService _auth = AuthService();
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  bool _alert = false;
  bool _fan = false;
  String _vehicleStatus = 'Unknown';

  @override
  void initState() {
    super.initState();
    _database.child('Alert').onValue.listen((event) {
      final int alertValue = event.snapshot.value as int;
      setState(() {
        _alert = alertValue == 1;
      });
    });

    _database.child('fan').onValue.listen((event) {
      final int fanValue = event.snapshot.value as int;
      setState(() {
        _fan = fanValue == 1;
      });
    });

    _database.child('vehicle').onValue.listen((event) {
      final int vehicleValue = event.snapshot.value as int;
      setState(() {
        _vehicleStatus = vehicleValue == 1 ? 'Stopped' : 'Driving';
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final double latitude = 6.6843;
    final double longitude = 80.1139; // -122.4194; // Example longitude value

    // Get the current date and month
    final now = DateTime.now();
    final dateFormat = DateFormat('MMMM dd, yyyy');
    final formattedDate = dateFormat.format(now);

    return Scaffold(
      backgroundColor: bgBlack,
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: bgBlack,
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              await _auth.signOut();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                    builder: (context) =>
                        SignIn(toggle: () {})), // Create instance without const
                (route) => false, // Remove all previous routes
              );
            },
          )
        ],
      ),
      drawer: Drawer(
        backgroundColor: bgBlack,
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.deepPurple,
                image: DecorationImage(
                  image: AssetImage('assets/images/drawer_header_bg.png'),
                  fit: BoxFit.cover,
                ),
              ),
              child: const Text(
                'Navigation Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            _buildDrawerItem('BPM Real Time', RealtimePage()),
            _buildDrawerItem('Gas Prediction', GasPrediction()),
            _buildDrawerItem('Health Prediction', HeartAttackPrediction()),
            _buildDrawerItem('User Profile', UserProfile()),
            _buildDrawerItem('Profile Update',
                ViewProfile(latitude: latitude, longitude: longitude)),
            _buildDrawerItem('Real Time Gases Values', RealTimeGases()),
            _buildDrawerItem('BPM Recent Data Graph', BPMGraphPage()),
            _buildDrawerItem(
                'All Gases Real Time Updates', AllGasesGraphPage()),
            _buildDrawerItem('Set Reminders', SetEvent()),
            _buildDrawerItem('All BPM Data', StreamData()),
            _buildDrawerItem('All Gas Values Data', StreamGases()),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Main Dashboard text and current date
            Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Main Dashboard",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold),
                  ),
                  Text(
                    formattedDate,
                    style: TextStyle(
                        color: Colors.white60,
                        fontSize: 16,
                        fontWeight: FontWeight.w400),
                  ),
                ],
              ),
            ),
            // Main content cards
            _buildCard(
              child: SwitchListTile(
                title:
                    const Text('Alert', style: TextStyle(color: Colors.white)),
                value: _alert,
                onChanged: (bool newValue) {
                  _database.child('Alert').set(newValue ? 1 : 0);
                },
              ),
            ),
            const SizedBox(height: 16),
            _buildCard(
              child: SwitchListTile(
                title: const Text('Fan', style: TextStyle(color: Colors.white)),
                value: _fan,
                onChanged: (bool newValue) {
                  _database.child('fan').set(newValue ? 1 : 0);
                },
              ),
            ),
            const SizedBox(height: 16),
            _buildCard(
              child: ListTile(
                title: const Text('Vehicle Status',
                    style: TextStyle(color: Colors.white)),
                subtitle: Text(
                  _vehicleStatus,
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Card(
      color: Colors.grey[800],
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: child,
    );
  }

  Widget _buildDrawerItem(String title, Widget page) {
    return ListTile(
      title: Text(title, style: TextStyle(color: Colors.white)),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => page),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_database/firebase_database.dart';
import 'package:crebrew/services/auth.dart'; // Import your AuthService
import 'package:crebrew/models/profile_model.dart'; // Import ProfileModel

class HeartAttackPrediction extends StatefulWidget {
  @override
  _HeartAttackPredictionState createState() => _HeartAttackPredictionState();
}

class _HeartAttackPredictionState extends State<HeartAttackPrediction> {
  final _formKey = GlobalKey<FormState>();
  final AuthService _auth =
      AuthService(); // AuthService instance for fetching user data
  ProfileModel? _profile; // Profile data variable
  bool _isLoading = true;
  String _errorMessage = '';

  // Controllers for heart attack prediction inputs
  final TextEditingController ageController = TextEditingController();
  final TextEditingController sexController = TextEditingController();
  final TextEditingController bpmController = TextEditingController();
  final TextEditingController fbsController = TextEditingController();
  final TextEditingController cholController = TextEditingController();

  String? predictionResult;
  bool _alert = false; // Variable to track alert status

  // Firebase database reference
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();

  @override
  void initState() {
    super.initState();
    _loadUserProfile(); // Fetch the user profile data
    _setupRealtimeListeners(); // Setup real-time listeners for BPM and Alert
  }

  // Fetch user profile data from AuthService or other backend
  Future<void> _loadUserProfile() async {
    try {
      final profile = await _auth.getCurrentUserDetails();
      setState(() {
        _profile = profile;
        _isLoading = false;
      });
      _populateUserData(); // Populate the form with the fetched profile data
    } catch (e) {
      print('Error loading user profile: $e');
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load user profile. Please try again.';
      });
    }
  }

  // Populate the data from the user profile if available
  void _populateUserData() {
    if (_profile != null) {
      ageController.text = _profile!.age.toString();
      cholController.text = _profile!.cholesterol.toString();
      fbsController.text = _profile!.sugar.toString();
      sexController.text =
          _profile!.gender == 1 ? '1' : '0'; // 1 = Male, 0 = Female
    }
  }

  // Setup listeners to receive real-time updates from Firebase
  void _setupRealtimeListeners() {
    // Listen for BPM value changes
    _dbRef.child('BPM').onValue.listen((event) {
      final bpmSnapshot = event.snapshot;
      int bpmValue = bpmSnapshot.value is int ? bpmSnapshot.value as int : 0;

      // Check if BPM exceeds the threshold and update Alert
      if (bpmValue > 100) {
        _dbRef.child('Alert').set(1); // Set Alert to 1
        setState(() {
          _alert = true; // Update local alert status
        });
      } else {
        _dbRef.child('Alert').set(0); // Set Alert to 0
        setState(() {
          _alert = false; // Update local alert status
        });
      }
    });

    // Listen for alert value changes
    _dbRef.child('Alert').onValue.listen((event) {
      DataSnapshot alertSnapshot = event.snapshot;
      setState(() {
        int alertValue =
            alertSnapshot.value is int ? alertSnapshot.value as int : 0;
        _alert = alertValue == 1; // Update _alert status
      });
    });
  }

  // Function to predict heart attack risk using the heart attack prediction API
  Future<void> predictHeartAttack() async {
    if (_formKey.currentState?.validate() ?? false) {
      final apiUrl =
          'http://192.168.79.195:5000/predict'; // Replace with your API URL
      var data = {
        'age': int.parse(ageController.text),
        'sex': int.parse(sexController.text),
        'BPM': double.tryParse(bpmController.text) ?? 0.0, // Safe parsing
        'fbs': int.parse(fbsController.text),
        'chol': int.parse(cholController.text),
      };

      try {
        final response = await http.post(
          Uri.parse(apiUrl),
          headers: {'Content-Type': 'application/json'},
          body: json.encode(data),
        );

        if (response.statusCode == 200) {
          final responseData = json.decode(response.body);
          setState(() {
            predictionResult = responseData['prediction'].toString();
          });
        } else {
          setState(() {
            predictionResult =
                'Error: ${response.statusCode} - ${response.reasonPhrase}';
          });
        }
      } catch (e) {
        setState(() {
          predictionResult = 'Error: $e'; // Show error in UI
        });
      }
    }
  }

  // Function to return a user-friendly message based on prediction result
  String _getPredictionMessage(String? predictionResult) {
    if (predictionResult == '1') {
      return 'High Risk of Heart Attack';
    } else if (predictionResult == '0') {
      return 'Low Risk of Heart Attack';
    } else {
      return 'Prediction Error';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Heart Attack Risk Prediction'),
      ),
      body: _isLoading
          ? const Center(
              child:
                  CircularProgressIndicator()) // Show loader if data is loading
          : _errorMessage.isNotEmpty
              ? Center(child: Text(_errorMessage)) // Show error message if any
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // Heart Attack Prediction Fields
                        TextFormField(
                          controller: ageController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Age'),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your age';
                            }
                            return null;
                          },
                        ),
                        TextFormField(
                          controller: sexController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                              labelText: 'Sex (1: Male, 0: Female)'),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your sex';
                            }
                            return null;
                          },
                        ),
                        TextFormField(
                          controller: bpmController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'BPM'),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your BPM';
                            }
                            return null;
                          },
                        ),
                        TextFormField(
                          controller: fbsController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                              labelText: 'Fasting Blood Sugar (fbs)'),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your fasting blood sugar level';
                            }
                            return null;
                          },
                        ),
                        TextFormField(
                          controller: cholController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                              labelText: 'Cholesterol Level (chol)'),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your cholesterol level';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: predictHeartAttack,
                          child: const Text('Predict Heart Attack Risk'),
                        ),
                        const SizedBox(height: 20),
                        if (predictionResult != null)
                          Text(
                            _getPredictionMessage(predictionResult),
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        const SizedBox(height: 20),
                        if (_alert)
                          const Text(
                            'ALERT: High BPM Detected!',
                            style: TextStyle(color: Colors.red, fontSize: 18),
                          ),
                      ],
                    ),
                  ),
                ),
    );
  }

  @override
  void dispose() {
    ageController.dispose();
    sexController.dispose();
    bpmController.dispose();
    fbsController.dispose();
    cholController.dispose();
    super.dispose();
  }
}

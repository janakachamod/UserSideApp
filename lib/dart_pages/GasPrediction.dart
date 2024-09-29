import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

class GasPrediction extends StatefulWidget {
  const GasPrediction({Key? key}) : super(key: key);

  @override
  _GasPredictionState createState() => _GasPredictionState();
}

class _GasPredictionState extends State<GasPrediction> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for gas prediction inputs
  final TextEditingController no2Controller = TextEditingController();
  final TextEditingController coController = TextEditingController();
  final TextEditingController nh3Controller = TextEditingController();
  final TextEditingController tolueneController = TextEditingController();

  String predictionResult = '';

  // Firebase database reference
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();

  @override
  void initState() {
    super.initState();
    _setupListeners();
  }

  // Setup listeners to receive real-time updates from Firebase
  void _setupListeners() {
    _dbRef.child('gases').onValue.listen((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data != null) {
        setState(() {
          no2Controller.text = data['NO2']?.toString() ?? '';
          coController.text = data['CO']?.toString() ?? '';
          nh3Controller.text = data['NH4']?.toString() ?? '';
          tolueneController.text = data['Toluene']?.toString() ?? '';
        });
      }
    });
  }

  // Function to predict gas using the gas prediction API
  Future<void> predictGas() async {
    if (_formKey.currentState?.validate() ?? false) {
      final apiUrl =
          'http://192.168.79.195:5001/predict'; // Replace with your API URL
      var data = {
        'NO2': no2Controller.text,
        'CO': coController.text,
        'NH3': nh3Controller.text,
        'Toluene': tolueneController.text,
      };

      try {
        final response = await http.post(
          Uri.parse(apiUrl),
          headers: {'Content-Type': 'application/json'},
          body: json.encode(data),
        );

        if (response.statusCode == 200) {
          final prediction = json.decode(response.body)['prediction'];
          setState(() {
            predictionResult = prediction;
          });
          _updateFanStatus(prediction);
        } else {
          setState(() {
            predictionResult = 'Error: ${response.statusCode}';
          });
        }
      } catch (e) {
        setState(() {
          predictionResult = 'Error: $e';
        });
      }
    }
  }

  // Function to update the FAN status in Firebase based on the prediction
  Future<void> _updateFanStatus(String prediction) async {
    final fanStatus = prediction == 'Poor' ? 1 : 0;
    try {
      await _dbRef.child('fan').set(fanStatus);
    } catch (e) {
      print('Error updating fan status: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gas Prediction'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // Gas Prediction Fields
              TextFormField(
                controller: no2Controller,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'NO2'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter NO2 level';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: coController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'CO'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter CO level';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: nh3Controller,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'NH3'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter NH3 level';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: tolueneController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Toluene'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter Toluene level';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: predictGas,
                child: const Text('Predict'),
              ),
              const SizedBox(height: 20.0),
              Text(
                'Prediction Result: $predictionResult',
                style: const TextStyle(fontSize: 18.0),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    no2Controller.dispose();
    coController.dispose();
    nh3Controller.dispose();
    tolueneController.dispose();
    super.dispose();
  }
}

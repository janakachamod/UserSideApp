import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:firebase_database/firebase_database.dart';

class AllGasesGraphPage extends StatefulWidget {
  const AllGasesGraphPage({super.key});

  @override
  _AllGasesGraphPageState createState() => _AllGasesGraphPageState();
}

class _AllGasesGraphPageState extends State<AllGasesGraphPage> {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();
  List<FlSpot> _coData = [];
  List<FlSpot> _nh3Data = [];
  List<FlSpot> _tolueneData = [];
  List<FlSpot> _no2Data = [];

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _setupRealtimeListeners();
  }

  void _setupRealtimeListeners() {
    _dbRef.child('gases/CO').onValue.listen((event) {
      final double coValue =
          event.snapshot.value is double ? event.snapshot.value as double : 0.0;

      setState(() {
        _coData.add(FlSpot(_coData.length.toDouble(), coValue));
        if (_coData.length > 50) {
          _coData.removeAt(0);
        }
        _isLoading = false;
      });
    });

    _dbRef.child('gases/NH3').onValue.listen((event) {
      final double nh3Value =
          event.snapshot.value is double ? event.snapshot.value as double : 0.0;

      setState(() {
        _nh3Data.add(FlSpot(_nh3Data.length.toDouble(), nh3Value));
        if (_nh3Data.length > 50) {
          _nh3Data.removeAt(0);
        }
        _isLoading = false;
      });
    });

    _dbRef.child('gases/Toluene').onValue.listen((event) {
      final double tolueneValue =
          event.snapshot.value is double ? event.snapshot.value as double : 0.0;

      setState(() {
        _tolueneData.add(FlSpot(_tolueneData.length.toDouble(), tolueneValue));
        if (_tolueneData.length > 50) {
          _tolueneData.removeAt(0);
        }
        _isLoading = false;
      });
    });

    _dbRef.child('gases/NO2').onValue.listen((event) {
      final double no2Value =
          event.snapshot.value is double ? event.snapshot.value as double : 0.0;

      setState(() {
        _no2Data.add(FlSpot(_no2Data.length.toDouble(), no2Value));
        if (_no2Data.length > 50) {
          _no2Data.removeAt(0);
        }
        _isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Gases Real-Time Graphs'),
        backgroundColor: Colors.teal,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  _buildGraph(),
                  SizedBox(height: 20),
                  _buildLegend(),
                ],
              ),
            ),
    );
  }

  Widget _buildGraph() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      height: 300, // Adjust as needed
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: false),
          titlesData: FlTitlesData(show: true),
          borderData: FlBorderData(show: true),
          lineBarsData: [
            LineChartBarData(
              spots: _coData,
              isCurved: true,
              colors: [Colors.redAccent],
              dotData: FlDotData(show: false),
              belowBarData: BarAreaData(show: false),
            ),
            LineChartBarData(
              spots: _nh3Data,
              isCurved: true,
              colors: [Colors.blueAccent],
              dotData: FlDotData(show: false),
              belowBarData: BarAreaData(show: false),
            ),
            LineChartBarData(
              spots: _tolueneData,
              isCurved: true,
              colors: [Colors.greenAccent],
              dotData: FlDotData(show: false),
              belowBarData: BarAreaData(show: false),
            ),
            LineChartBarData(
              spots: _no2Data,
              isCurved: true,
              colors: [Colors.orangeAccent],
              dotData: FlDotData(show: false),
              belowBarData: BarAreaData(show: false),
            ),
          ],
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              tooltipBgColor: Colors.blueAccent,
            ),
            handleBuiltInTouches: true,
          ),
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _legendItem('CO', Colors.redAccent),
          _legendItem('NH3', Colors.blueAccent),
          _legendItem('Toluene', Colors.greenAccent),
          _legendItem('NO2', Colors.orangeAccent),
        ],
      ),
    );
  }

  Widget _legendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 20,
          height: 20,
          color: color,
        ),
        SizedBox(width: 8),
        Text(label),
      ],
    );
  }
}

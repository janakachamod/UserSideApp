import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../mongodb.dart';

class BPMGraphPage extends StatefulWidget {
  const BPMGraphPage({super.key});

  @override
  _BPMGraphPageState createState() => _BPMGraphPageState();
}

class _BPMGraphPageState extends State<BPMGraphPage> {
  List<Map<String, dynamic>> _data = [];
  bool _isLoading = true; // Track loading state

  @override
  void initState() {
    super.initState();
    _fetchRecentData();
  }

  Future<void> _fetchRecentData() async {
    setState(() {
      _isLoading = true; // Start loading
    });

    try {
      final data = await MongoDatabase.fetchData();

      // Ensure data is sorted and sliced correctly
      data.sort((a, b) {
        // Assuming _id includes timestamp and is formatted correctly
        return (b['_id'] as String).compareTo(a['_id'] as String);
      });

      setState(() {
        _data = data.take(10).toList(); // Get the most recent 10 entries
      });
    } catch (e) {
      print("Error fetching data: $e");
    } finally {
      setState(() {
        _isLoading = false; // Stop loading
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BPM Data Graph'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchRecentData, // Refresh data on button press
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _data.isEmpty
              ? const Center(child: Text('No data available'))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: LineChart(
                    LineChartData(
                      gridData: FlGridData(show: false),
                      titlesData: FlTitlesData(show: true),
                      borderData: FlBorderData(show: true),
                      lineBarsData: [
                        LineChartBarData(
                          spots: _data.asMap().entries.map((entry) {
                            final index = entry.key.toDouble();
                            final value =
                                entry.value['value']?.toDouble() ?? 0.0;
                            return FlSpot(index, value);
                          }).toList(),
                          isCurved: true,
                          colors: [Colors.blue],
                          dotData: FlDotData(show: false),
                          belowBarData: BarAreaData(show: false),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }
}

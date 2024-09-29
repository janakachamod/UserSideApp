import 'package:crebrew/dart_pages/viewProfile.dart';
import 'package:flutter/material.dart';

class GetCurrentLocation extends StatelessWidget {
  // Example hardcoded values for latitude and longitude
  final double latitude = 37.7749;
  final double longitude = -122.4194;

  const GetCurrentLocation({Key? key})
      : super(key: key); // Ensure const constructor

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Current Location'),
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text('View Profile',
                style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ViewProfile(
                    latitude: latitude,
                    longitude: longitude,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:crebrew/services/auth.dart'; // Import your AuthService
import 'package:crebrew/models/profile_model.dart'; // Import ProfileModel

class UserProfile extends StatefulWidget {
  @override
  _UserProfileState createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  final AuthService _auth = AuthService();
  ProfileModel? _profile;
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      final profile = await _auth.getCurrentUserDetails();
      setState(() {
        _profile = profile;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading user profile: $e');
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load user profile. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _profile != null
                ? ListView(
                    children: [
                      _buildProfileCard(
                        'Email',
                        _profile!.email,
                        Icons.email,
                      ),
                      _buildProfileCard(
                        'Sugar Level',
                        _profile!.sugar.toString(),
                        Icons.access_alarm,
                      ),
                      _buildProfileCard(
                        'Cholesterol Level',
                        _profile!.cholesterol.toString(),
                        Icons.favorite,
                      ),
                      _buildProfileCard(
                        'Gender',
                        _profile!.gender == 1 ? 'Male' : 'Female',
                        Icons.person,
                      ),
                      _buildProfileCard(
                        'Age',
                        _profile!.age.toString(),
                        Icons.cake,
                      ),
                      _buildProfileCard(
                        'Latitude',
                        _profile!.latitude.toString(),
                        Icons.location_on,
                      ),
                      _buildProfileCard(
                        'Longitude',
                        _profile!.longitude.toString(),
                        Icons.location_searching,
                      ),
                      _buildProfileCard(
                        'Online Status',
                        _profile!.onlineStatus ? 'Online' : 'Offline',
                        _profile!.onlineStatus
                            ? Icons.check_circle
                            : Icons.cancel,
                        _profile!.onlineStatus ? Colors.green : Colors.red,
                      ),
                      if (_errorMessage.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 16.0),
                          child: Center(
                            child: Text(
                              _errorMessage,
                              style: TextStyle(color: Colors.red, fontSize: 16),
                            ),
                          ),
                        ),
                    ],
                  )
                : Center(child: Text('No profile data available')),
      ),
    );
  }

  Widget _buildProfileCard(String title, String value, IconData icon,
      [Color? iconColor]) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Icon(icon, color: iconColor ?? Colors.teal),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(value, style: const TextStyle(fontSize: 16)),
      ),
    );
  }
}

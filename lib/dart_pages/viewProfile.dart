import 'package:flutter/material.dart';
import 'package:crebrew/services/auth.dart';
import 'package:crebrew/models/profile_model.dart';

class ViewProfile extends StatefulWidget {
  final double latitude;
  final double longitude;

  const ViewProfile({
    Key? key,
    required this.latitude,
    required this.longitude,
  }) : super(key: key);

  @override
  _ViewProfileState createState() => _ViewProfileState();
}

class _ViewProfileState extends State<ViewProfile> {
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();

  String _email = '';
  String _password = '';
  int _sugar = 0;
  int _cholesterol = 0;
  int _gender = 1; // Default to Male
  int _age = 0;
  double _latitude = 0.0;
  double _longitude = 0.0;
  bool _onlineStatus = false;

  @override
  void initState() {
    super.initState();
    // Initialize latitude and longitude with values passed from the previous page
    _latitude = widget.latitude;
    _longitude = widget.longitude;
    _loadUserProfile();

    // Set online status to true when user is logged in
    _auth.user.listen((user) {
      if (user != null) {
        _setOnlineStatus(true);
      }
    });
  }

  Future<void> _loadUserProfile() async {
    try {
      final profile = await _auth.fetchUserProfile();
      if (profile != null) {
        setState(() {
          _email = profile.email;
          _password = profile.password;
          _sugar = profile.sugar;
          _cholesterol = profile.cholesterol;
          _gender = profile.gender;
          _age = profile.age;
          // Optionally update latitude and longitude from profile
          // _latitude = profile.latitude;
          // _longitude = profile.longitude;
          _onlineStatus = profile.onlineStatus;
        });
      } else {
        print('No profile found for this user.');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No profile found for this user.')),
        );
      }
    } catch (e) {
      print('Error loading user profile: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading user profile')),
      );
    }
  }

  Future<void> _updateProfile() async {
    if (_formKey.currentState?.validate() ?? false) {
      final profile = ProfileModel(
        email: _email,
        password: _password,
        sugar: _sugar,
        cholesterol: _cholesterol,
        gender: _gender,
        age: _age,
        latitude: _latitude,
        longitude: _longitude,
        onlineStatus: _onlineStatus,
      );

      try {
        await _auth.updateUserProfile(profile);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profile updated successfully')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update profile')),
        );
      }
    }
  }

  Future<void> _setOnlineStatus(bool status) async {
    try {
      await _auth.setOnlineStatus(status);
    } catch (e) {
      print('Failed to update online status: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update online status')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                initialValue: _email,
                decoration: const InputDecoration(labelText: 'Email'),
                onChanged: (value) => _email = value,
                validator: (value) => value == null || value.isEmpty
                    ? 'Enter a valid email'
                    : null,
              ),
              TextFormField(
                initialValue: _password,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Password'),
                onChanged: (value) => _password = value,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Enter a password';
                  } else if (value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<int>(
                value: _sugar,
                decoration: const InputDecoration(labelText: 'Sugar Level'),
                items: [
                  DropdownMenuItem(child: Text('0'), value: 0),
                  DropdownMenuItem(child: Text('1'), value: 1),
                ],
                onChanged: (value) => setState(() => _sugar = value!),
              ),
              TextFormField(
                initialValue: _cholesterol.toString(),
                decoration:
                    const InputDecoration(labelText: 'Cholesterol Level'),
                keyboardType: TextInputType.number,
                onChanged: (value) => _cholesterol = int.tryParse(value) ?? 0,
                validator: (value) => value == null || value.isEmpty
                    ? 'Enter cholesterol level'
                    : null,
              ),
              DropdownButtonFormField<int>(
                value: _gender,
                decoration: const InputDecoration(labelText: 'Gender'),
                items: [
                  DropdownMenuItem(child: Text('Male'), value: 1),
                  DropdownMenuItem(child: Text('Female'), value: 0),
                ],
                onChanged: (value) => setState(() => _gender = value!),
              ),
              TextFormField(
                initialValue: _age.toString(),
                decoration: const InputDecoration(labelText: 'Age'),
                keyboardType: TextInputType.number,
                onChanged: (value) => _age = int.tryParse(value) ?? 0,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Enter age' : null,
              ),
              TextFormField(
                initialValue: _latitude.toString(),
                decoration: const InputDecoration(labelText: 'Latitude'),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                onChanged: (value) => _latitude = double.tryParse(value) ?? 0.0,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Enter latitude' : null,
              ),
              TextFormField(
                initialValue: _longitude.toString(),
                decoration: const InputDecoration(labelText: 'Longitude'),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                onChanged: (value) =>
                    _longitude = double.tryParse(value) ?? 0.0,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Enter longitude' : null,
              ),
              SwitchListTile(
                title: const Text('Online Status'),
                value: _onlineStatus,
                onChanged: (value) {
                  setState(() => _onlineStatus = value);
                  _setOnlineStatus(value);
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _updateProfile,
                child: const Text('Update Profile'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

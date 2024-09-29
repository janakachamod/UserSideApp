// profile_model.dart
class ProfileModel {
  final String email;
  final String password;
  final int sugar; // 1 or 0
  final int cholesterol; // Value to represent level
  final int gender; // 1 for male, 0 for female
  final int age;
  final double latitude; // Added latitude
  final double longitude; // Added longitude
  final bool onlineStatus; // Added onlineStatus

  ProfileModel({
    required this.email,
    required this.password,
    required this.sugar,
    required this.cholesterol,
    required this.gender,
    required this.age,
    required this.latitude,
    required this.longitude,
    required this.onlineStatus, // Initialize onlineStatus
  });

  // Method to convert ProfileModel to Map
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'password': password,
      'sugar': sugar,
      'cholesterol': cholesterol,
      'gender': gender,
      'age': age,
      'latitude': latitude,
      'longitude': longitude,
      'onlineStatus': onlineStatus, // Include onlineStatus in Map
    };
  }

  // Factory method to create ProfileModel from Map
  factory ProfileModel.fromMap(Map<String, dynamic> map) {
    return ProfileModel(
      email: map['email'] ?? '',
      password: map['password'] ?? '',
      sugar: map['sugar'] ?? 0,
      cholesterol: map['cholesterol'] ?? 0,
      gender: map['gender'] ?? 1,
      age: map['age'] ?? 0,
      latitude: map['latitude']?.toDouble() ?? 0.0,
      longitude: map['longitude']?.toDouble() ?? 0.0,
      onlineStatus: map['onlineStatus'] ?? false,
    );
  }
}

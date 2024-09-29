import 'package:crebrew/models/usermodel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:crebrew/models/profile_model.dart'; // Import the ProfileModel

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _dbRef =
      FirebaseDatabase.instance.ref(); // Updated to use ref() method

  // Create UserModel based on Firebase User
  UserModel? _userFromFirebaseUser(User? user) {
    return user != null ? UserModel(uid: user.uid) : null;
  }

  // Auth change user stream
  Stream<UserModel?> get user {
    return _auth.authStateChanges().map(_userFromFirebaseUser);
  }

  // Register with email and password
  Future<UserModel?> registerWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      User? user = result.user;
      return _userFromFirebaseUser(user);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  // Sign in with email and password
  Future<UserModel?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      User? user = result.user;
      return _userFromFirebaseUser(user);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await _dbRef
            .child('users')
            .child(user.uid)
            .update({'onlineStatus': false});
      }
      await _auth.signOut();
    } catch (e) {
      print(e.toString());
    }
  }

  // Sign in anonymously
  Future<UserModel?> signInAnonymously() async {
    try {
      UserCredential result = await _auth.signInAnonymously();
      User? user = result.user;
      return _userFromFirebaseUser(user);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  // Fetch user profile data
  Future<ProfileModel?> fetchUserProfile() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    try {
      final snapshot = await _dbRef.child('users').child(user.uid).get();
      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        return ProfileModel(
          email: data['email'] as String? ?? '',
          password: data['password'] as String? ??
              '', // Consider handling passwords securely
          sugar: data['sugar'] as int? ?? 0,
          cholesterol: data['cholesterol'] as int? ?? 0,
          gender: data['gender'] as int? ?? 1,
          age: data['age'] as int? ?? 0,
          latitude: data['latitude']?.toDouble() ?? 0.0,
          longitude: data['longitude']?.toDouble() ?? 0.0,
          onlineStatus: data['onlineStatus'] as bool? ?? false,
        );
      } else {
        print("No profile found for this user.");
        return null;
      }
    } catch (e) {
      print("Error fetching user profile: $e");
      return null;
    }
  }

  // Get current user details
  Future<ProfileModel?> getCurrentUserDetails() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    try {
      final snapshot = await _dbRef.child('users').child(user.uid).get();
      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        return ProfileModel.fromMap(data.cast<String, dynamic>());
      } else {
        print("No details found for this user.");
        return null;
      }
    } catch (e) {
      print("Error fetching user details: $e");
      return null;
    }
  }

  // Update user profile data
  Future<void> updateUserProfile(ProfileModel profile) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      // Handle password separately using Firebase Authentication's method
      if (profile.password.isNotEmpty) {
        await user.updatePassword(profile.password);
      }

      await _dbRef.child('users').child(user.uid).update({
        'email': profile.email,
        'sugar': profile.sugar,
        'cholesterol': profile.cholesterol,
        'gender': profile.gender,
        'age': profile.age,
        'latitude': profile.latitude,
        'longitude': profile.longitude,
        'onlineStatus': profile.onlineStatus,
      });
    } catch (e) {
      print("Error updating user profile: $e");
      throw e; // Re-throw the error to handle it in the UI
    }
  }

  // Method to set online status to true when user logs in
  Future<void> setOnlineStatus(bool status) async {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        await _dbRef
            .child('users')
            .child(user.uid)
            .update({'onlineStatus': status});
      } catch (e) {
        print("Error setting online status: $e");
      }
    }
  }
}

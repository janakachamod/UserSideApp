import 'package:crebrew/models/usermodel.dart';
import 'package:crebrew/screens/authenicate/authenicate.dart';
import 'package:crebrew/screens/home/home.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Wrapper extends StatelessWidget {
  const Wrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserModel?>(context);

    // Return either the Authenicate screen or the Home screen based on authentication state
    if (user == null) {
      return Authenicate();
    } else {
      return Home();
    }
  }
}

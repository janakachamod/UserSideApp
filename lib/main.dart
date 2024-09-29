import 'package:crebrew/mongodb.dart';
import 'package:crebrew/screens/wrapper.dart';
import 'package:crebrew/services/auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:crebrew/models/usermodel.dart';
import 'package:crebrew/screens/authenicate/authenicate.dart';
import 'package:crebrew/screens/home/home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await MongoDatabase.connect();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamProvider<UserModel?>.value(
      value:
          AuthService().user, // Assuming AuthService has a stream of UserModel
      initialData: null,
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const Wrapper(),
        debugShowCheckedModeBanner: false, // This line removes the debug banner
      ),
    );
  }
}

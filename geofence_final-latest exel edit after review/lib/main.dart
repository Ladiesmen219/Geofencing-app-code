import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:geofence/app.dart';
import 'package:geofence/firebase_options.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  SharedPreferences prefs = await SharedPreferences.getInstance();
  if(prefs.getInt('count') != 1){
    prefs.setInt('count', 0);
  }
  bool isLoggedIn = prefs.getBool("isLoggedIn") ?? false;

  runApp(MyApp(isLoggedIn: isLoggedIn));
}

class MyApp extends StatelessWidget {
  bool isLoggedIn = false;

  MyApp({required this.isLoggedIn, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: App(
        isLoggedIn: isLoggedIn,
      ),
      // Define routes for the login and signup pages if needed
    );
  }
}

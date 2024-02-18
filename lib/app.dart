import 'package:flutter/material.dart';
import 'package:geofence/pages/splashscreen.dart';

class App extends StatelessWidget {
  const App({Key? key, required this.isLoggedIn}) : super(key: key);

  final isLoggedIn;
  @override
  Widget build(BuildContext context) {
    return SplashPage(
      isLoggedIn: isLoggedIn,
    );
  }
}

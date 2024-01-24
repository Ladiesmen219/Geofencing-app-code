import 'package:easy_splash_screen/easy_splash_screen.dart';
import 'package:geofence/pages/officelist.dart';
import 'package:geofence/pages/login.dart';

import 'package:flutter/material.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({Key? key, required this.isLoggedIn}) : super(key: key);

  final isLoggedIn;

  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  Widget build(BuildContext context) {
    return EasySplashScreen(
      logo: Image.asset('assets/images/geofence_icon.jpg'),
      title: const Text(
        "GeoFence",
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: Colors.white,
      loaderColor: Colors.orange[900]!,
      showLoader: true,
      loadingText: const Text("Loading..."),
      navigator: widget.isLoggedIn ? const OfficeList() : LoginPage(),
      durationInSeconds: 3,
    );
  }
}

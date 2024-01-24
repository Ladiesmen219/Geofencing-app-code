import 'dart:math';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:geofence/pages/google_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import '../services/firebase/firebase_services.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GeoFence extends StatefulWidget {
  final String name;
  final double latitudeCenter;
  final double longitudeCenter;
  final double radiusCenter;
  const GeoFence(
      {Key? key,
      required this.name,
      required this.latitudeCenter,
      required this.longitudeCenter,
      required this.radiusCenter})
      : super(key: key);

  @override
  State<GeoFence> createState() => _GeoFenceState();
}

class _GeoFenceState extends State<GeoFence> {
  // StreamSubscription<Position>? _positionStream;
  FirebaseServices firebaseServices = FirebaseServices();
  DatabaseReference userRef = FirebaseDatabase.instance.ref("user");
  late SharedPreferences prefs;
  Color colour = Colors.orange.shade100;
  // LocationSettings _locationSet = LocationSettings(
  //   accuracy: LocationAccuracy.bestForNavigation,
  //   distanceFilter: 1,
  //   timeLimit: Duration(seconds: 10000),
  // );

  // To stop the attendance
    void startGeofenceService() async {
    //parsing the values to double if in any case they are coming in int etc
    double latitude = widget.latitudeCenter;
    double longitude = widget.longitudeCenter;
    double radiusInMeter = widget.radiusCenter;
    int? eventPeriodInSeconds = 1;

    // if (_positionStream == null) {
    //   _positionStream = Geolocator.getPositionStream(
    //     locationSettings: _locationSet,
    //   ).listen((Position position) {
    //     double distanceInMeters = Geolocator.distanceBetween(
    //         latitude, longitude, position.latitude, position.longitude);
    //     try {
    //       _checkGeofence(distanceInMeters, radiusInMeter);
    //     } catch (e) {}
    //   });
    // }
    // _positionStream!
    //     .pause(Future.delayed(Duration(seconds: eventPeriodInSeconds!)));

    Position currentPosition =  await Geolocator.getCurrentPosition(
      timeLimit: const Duration(seconds: 5),
      desiredAccuracy: LocationAccuracy.bestForNavigation,
    );

    double distanceInMeters = Geolocator.distanceBetween(latitude, longitude, currentPosition.latitude, currentPosition.longitude);
    _checkGeofence(distanceInMeters, radiusInMeter);
  }

  void _checkGeofence(double distanceInMeters, double radiusInMeter) async {
    if (distanceInMeters <= radiusInMeter) {
      print("Enter");

      if (prefs.getInt('count') == 0) {
        // print(prefs.getInt('count'));

        prefs.setInt('count', 1);
        firebaseServices.markAttendanceEntry(
          uId: FirebaseAuth.instance.currentUser!.uid,
          officeName: widget.name,
        );

        showTopSnackBar(
          Overlay.of(context),
          const CustomSnackBar.success(
            message: "Your attendance is started",
          ),
        );
        setState(() {
          colour = Colors.orange.shade700;
        });
      }
      else{
        showTopSnackBar(
          Overlay.of(context),
          const CustomSnackBar.success(
            message: "Your attendance is already started",
          ),
        );
        setState(() {
         colour = Colors.orange.shade700;
        });
      }
    }
    else{
      showTopSnackBar(
        Overlay.of(context),
        const CustomSnackBar.error(
          message: "You are outside the area",
        ),
      );
    }
  }
  // To stop the attendance
  void endGeoFenceService(){
    if (prefs.getInt('count') == 1) {
      prefs.setInt('count', 0);
      firebaseServices.markAttendanceExit(
          uId: FirebaseAuth.instance.currentUser!.uid);
      showTopSnackBar(
        Overlay.of(context),
        const CustomSnackBar.error(
          message: "Your attendance is stopped",
        ),
      );
      setState(() {
        colour = Colors.orange.shade100;
      });
    }
    else{
      showTopSnackBar(
        Overlay.of(context),
        const CustomSnackBar.error(
          message: "Your attendance is already stopped",
        ),
      );
    }
  }

  double distanceBetween(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var c = cos as double Function(num?);
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  void saveSharedPreferences() async {
    prefs = await SharedPreferences.getInstance();
    print(prefs.getInt('count'));
  }
  setColor()async {
    prefs = await SharedPreferences.getInstance();
    if (prefs.getInt('count') == 1){
      setState(() {
        colour = Colors.orange.shade700;
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    saveSharedPreferences();
    setColor();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child:
      Stack(
        children: [
          GoogleMapPage(
              latitudeCenter: widget.latitudeCenter,
              longitudeCenter: widget.longitudeCenter,
              radiusCenter: widget.radiusCenter),
          Positioned(
            bottom: MediaQuery.of(context).size.height/15,
            left: MediaQuery.of(context).size.width/5,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    startGeofenceService();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colour,
                  ),
                  child: Container(
                    child: const Text(
                      'Entry',
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.w500,
                        color: Colors.green,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10,),
                ElevatedButton(
                    onPressed: () {
                      endGeoFenceService();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange.shade100,
                    ),
                    child: Container(
                      child: const Text(
                        'Exit',
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.w500,
                          color: Colors.red,
                        ),
                      ),
                    )
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }
}

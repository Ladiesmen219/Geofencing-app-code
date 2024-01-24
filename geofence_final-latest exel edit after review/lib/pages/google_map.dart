import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class GoogleMapPage extends StatefulWidget {
  final double latitudeCenter;
  final double longitudeCenter;
  final double radiusCenter;
  const GoogleMapPage(
      {Key? key,
      required this.latitudeCenter,
      required this.longitudeCenter,
      required this.radiusCenter})
      : super(key: key);

  @override
  State<GoogleMapPage> createState() => _GoogleMapPageState();
}

class _GoogleMapPageState extends State<GoogleMapPage> {
  Position? position;
  Position? currentPosition;
  bool isReady = false;

  LocationSettings locationSetting = const LocationSettings(
    accuracy: LocationAccuracy.bestForNavigation,
    distanceFilter: 1,
    timeLimit: Duration(seconds: 10000),
  );

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCurrentLocation();
  }

  Future<Position> determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }

  void getCurrentLocation() async {
    position = await determinePosition();
    if (position != null) {
      isReady = true;
      currentPosition = position;
      print("$position.longitude");
    }
    if (isReady) {
      setState(() {});
    }

    StreamSubscription<Position> positionStream =
    Geolocator.getPositionStream(locationSettings: locationSetting)
        .listen((Position? positionNew) {
      print(positionNew == null
          ? 'Unknown'
          : '${positionNew.latitude.toString()}, ${positionNew.longitude
          .toString()}');
      if (position != null && mounted) {
        setState(() {
          currentPosition = positionNew;
        });
        // try {
        //   if (position != null) {
        //     setState(() {
        //       currentPosition = positionNew;
        //     });
        //   }
        // } catch (e) {}
      }
    });
  }

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        body: !isReady
            ? SizedBox(
          width: MediaQuery
              .of(context)
              .size
              .width,
          height: MediaQuery
              .of(context)
              .size
              .height,
          child:
          const Center(child: CircularProgressIndicator(color: Colors.blue)),
        )
            : GoogleMap(
          initialCameraPosition: CameraPosition(
            target: LatLng(
                currentPosition!.latitude, currentPosition!.longitude),
            zoom: 20,
          ),
          markers: {
            Marker(
              markerId: const MarkerId("Current Location"),
              position: LatLng(
                  currentPosition!.latitude, currentPosition!.longitude),
            ),
          },
          circles: {
              Circle(
                circleId: const CircleId("Center"),
                center:
                LatLng(widget.latitudeCenter, widget.longitudeCenter),
                radius: widget.radiusCenter,
                fillColor: Colors.blue.shade200.withOpacity(0.35),
                strokeColor: Colors.blue,
                strokeWidth: 5,
              ),
            },
          compassEnabled: true,
        ),
      );
    }
  }

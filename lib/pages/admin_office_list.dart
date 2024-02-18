import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:geofence/services/firebase/firebase_services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';

import 'admin_calender.dart';
import 'admin_geo_card.dart';

class AdminOfficeList extends StatefulWidget {
  const AdminOfficeList({Key? key}) : super(key: key);

  @override
  State<AdminOfficeList> createState() => _AdminOfficeListState();
}

class _AdminOfficeListState extends State<AdminOfficeList> {
  Position? currentPosition;
  final officeReference = FirebaseDatabase.instance.ref('office');

  // TextEditingController officeController = TextEditingController();
  //
  // TextEditingController latitudeController = TextEditingController();
  //
  // TextEditingController longitudeController = TextEditingController();
  //
  // TextEditingController radiusController = TextEditingController();

  FirebaseServices firebaseServices = FirebaseServices();

  int _selectedIndex = 0;

  // Future<Position> determinePosition() async {
  //   bool serviceEnabled;
  //   LocationPermission permission;
  //
  //   // Test if location services are enabled.
  //   serviceEnabled = await Geolocator.isLocationServiceEnabled();
  //   if (!serviceEnabled) {
  //     // Location services are not enabled don't continue
  //     // accessing the position and request users of the
  //     // App to enable the location services.
  //     return Future.error('Location services are disabled.');
  //   }
  //
  //   permission = await Geolocator.checkPermission();
  //   if (permission == LocationPermission.denied) {
  //     permission = await Geolocator.requestPermission();
  //     if (permission == LocationPermission.denied) {
  //       // Permissions are denied, next time you could try
  //       // requesting permissions again (this is also where
  //       // Android's shouldShowRequestPermissionRationale
  //       // returned true. According to Android guidelines
  //       // your App should show an explanatory UI now.
  //       return Future.error('Location permissions are denied');
  //     }
  //   }
  //
  //   if (permission == LocationPermission.deniedForever) {
  //     // Permissions are denied forever, handle appropriately.
  //     return Future.error(
  //         'Location permissions are permanently denied, we cannot request permissions.');
  //   }
  //
  //   // When we reach here, permissions are granted and we can
  //   // continue accessing the position of the device.
  //   return await Geolocator.getCurrentPosition();
  // }
  //
  // void getCurrentLocation() async {
  //   currentPosition = await determinePosition();
  //   if (currentPosition != null) {
  //     setState(() {
  //       latitudeController.text = currentPosition!.latitude.toString();
  //       longitudeController.text = currentPosition!.longitude.toString();
  //     });
  //   }
  // }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
          bottomNavigationBar: SalomonBottomBar(
            currentIndex: _selectedIndex,
            onTap: (i) => setState(() => _selectedIndex = i),
            items: [
              /// Home
              SalomonBottomBarItem(
                icon: const Icon(Icons.home),
                title: const Text("Locations"),
                selectedColor: Colors.orange.shade900,
              ),

              /// Likes
              SalomonBottomBarItem(
                icon: const Icon(Icons.person),
                title: const Text("Profile"),
                selectedColor: Colors.orange.shade900,
              ),

              /// Search

              /// Profile
            ],
          ),
          body: _selectedIndex == 1
              ? const AdminCalender()
              : Column(
            children: [
              const SizedBox(
                height: 10,
              ),
              Text(
                "Select GeoFence",
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w700, fontSize: 18),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SizedBox(
                    height: 200,
                    child: FirebaseAnimatedList(
                      query: officeReference,
                      itemBuilder: (context, snapshot, animation, index) {
                        String name = snapshot.child('name').value.toString();
                        return AdminGeoCard(officeName: name);
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}

import 'package:flutter/material.dart';
import 'package:geofence/services/firebase/firebase_services.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminGeoCard extends StatelessWidget {
  final String officeName;
   AdminGeoCard({Key? key, required this.officeName}) : super(key: key);
final FirebaseServices _firebaseServices = FirebaseServices();
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      color: Colors.orange.shade50,
      shadowColor: Colors.orange,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SizedBox(
          width: MediaQuery.sizeOf(context).width,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Image.asset(
                "assets/images/location.png",
                height: 60,
                width: 60,
              ),

              Text(
                officeName,
                style: GoogleFonts.poppins(fontSize: 18),
              ),
              IconButton(
                onPressed: () {
                _firebaseServices.deleteOffice(officeName);
                },
                icon: const Icon(
                  Icons.delete_rounded,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

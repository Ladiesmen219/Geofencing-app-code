import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GeoCard extends StatelessWidget {
  final String officeName;
  const GeoCard({Key? key, required this.officeName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      color: Colors.orange.shade50,
      shadowColor: Colors.orange,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Image.asset(
              "assets/images/location.png",
              height: 60,
              width: 60,
            ),
            const SizedBox(
              width: 30,
            ),
            Text(
              officeName,
              style: GoogleFonts.poppins(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}

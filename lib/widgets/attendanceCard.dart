import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AttendanceCard extends StatefulWidget {
  const AttendanceCard({
    Key? key,
    required this.inTime,
    required this.outTime,
    required this.duration,
    required this.location,
  }) : super(key: key);

  final String inTime;
  final String outTime;
  final String duration;
  final String location;

  @override
  State<AttendanceCard> createState() => _AttendanceCardState();
}

class _AttendanceCardState extends State<AttendanceCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      shape: OutlineInputBorder(borderRadius: BorderRadius.circular(2)),
      color: Colors.orange.shade50,
      shadowColor: Colors.orange,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(2.0),
              child: Text(
                "inTime : ${widget.inTime}",
                style: GoogleFonts.poppins(fontSize: 12),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(2.0),
              child: Text(
                "outTime : ${widget.outTime}",
                style: GoogleFonts.poppins(fontSize: 12),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(2.0),
              child: Text(
                "duration : ${widget.duration}",
                style: GoogleFonts.poppins(fontSize: 12),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(2.0),
              child: Text(
                "name : ${widget.location}",
                style: GoogleFonts.poppins(fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

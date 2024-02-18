import 'package:flutter/material.dart';

class AttendanceName extends StatefulWidget {
  const AttendanceName({
    Key? key,
    required this.userName,
    required this.officeName,
  }) : super(key: key);

  final String userName;
  final String officeName;

  @override
  State<AttendanceName> createState() => _AttendanceNameState();
}

class _AttendanceNameState extends State<AttendanceName> {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      shape: OutlineInputBorder(borderRadius: BorderRadius.circular(2)),
      color: Colors.orange.shade50,
      shadowColor: Colors.orange,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(2.0),
                child: Text(
                  'Name: ${widget.userName}',
                  style: const TextStyle(
                    fontSize: 15,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(2.0),
                child: Text(
                  'Office Name: ${widget.officeName}',
                  style: const TextStyle(
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

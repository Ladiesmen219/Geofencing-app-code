import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:geofence/pages/login.dart';
import 'package:geofence/services/authServices/firebase_auth_services.dart';
import 'package:geofence/widgets/attendanceCard.dart';
import 'package:geofence/widgets/widgets.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class Profile extends StatefulWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  bool isEmpty = true;
  DateTime today = DateTime.now();
  final FirebaseAuthService _firebaseAuthService = FirebaseAuthService(authService: FirebaseAuth.instance);

  late String userId;
  DatabaseReference attendanceRef = FirebaseDatabase.instance.ref("attendance");

  late String date_Control;
  late Query _query ;
  late Key _key;

  @override
  void initState() {
    super.initState();
    getCurrentUser();
    getDateControl();
    getQuery();
  }

  void getCurrentUser() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      userId = user.uid;
    } else {
      // Handle situation when there's no current user logged in
      // For instance, you can navigate to the login screen
      // For now, assigning an empty string
      userId = '';
    }
  }

  void getDateControl() {
    date_Control = DateFormat('yMd').format(DateTime.now()).toString().replaceAll("/", "-");
    _key = const Key('New Key');
  }

  void _onSelectionChanged(DateRangePickerSelectionChangedArgs args) {
    final date = args.value.toString();
    final inprocess = date.split(" ").first.split("-");
    final RegExp regexp = RegExp(r'^0+(?=.)');
    for (int i = 0; i < inprocess.length; i++) {
      inprocess[i] = inprocess[i].replaceAll(regexp, "");
    }
    setState(() {
      date_Control = "${inprocess[1]}-${inprocess[2]}-${inprocess[0]}";
      _query = attendanceRef.child(date_Control).child(userId);
      _key = Key(date_Control);
      print(_query.path);
    });
    isAbsent();
    print(date_Control);
    print(userId);
  }

  getQuery() {
    _query = attendanceRef.child(date_Control).child(userId);
  }

  isAbsent() async {
    final snapshot = await attendanceRef.child(date_Control).child(userId).get();
    if (snapshot.exists) {
      setState(() {
        isEmpty = false;
      });
    } else {
      setState(() {
        isEmpty = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text('Attendance'),
          actions: [
            IconButton(
              onPressed: () {
                _firebaseAuthService.signOut();
                nextScreenReplace(context, LoginPage());
              },
              icon: const Icon(
                Icons.logout,
                size: 25,
              ),
            ),
          ],
        ),
        body: Center(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                child: SfDateRangePicker(
                  onSelectionChanged: _onSelectionChanged,
                  selectionMode: DateRangePickerSelectionMode.single,
                ),
              ),
              getAttendanceList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget getAttendanceList() {
    return isEmpty ? Expanded(
      child: Card(
        elevation: 5,
        shape: OutlineInputBorder(borderRadius: BorderRadius.circular(2)),
        color: Colors.orange.shade50,
        shadowColor: Colors.orange,
        child: const Center(
          child: Text(
            'ABSENT',
            style: TextStyle(
              fontSize: 15,
            ),
          ),
        ),
      ),
    )
    : Expanded(
      child: FirebaseAnimatedList(
        query: _query,
        key: _key,
        itemBuilder: (context, snapshot, animation, index) {
          String inTime = snapshot.child('entry_time').value.toString();
          String outTime = snapshot.child('exit_time').value.toString();
          String duration = snapshot.child('duration').value.toString();
          String location = snapshot.child('office_name').value.toString();
          return AttendanceCard(
            inTime: inTime,
            outTime: outTime,
            duration: duration,
            location: location,
          );
        },
      ),
    );
  }
}

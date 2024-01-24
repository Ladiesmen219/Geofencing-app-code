import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class FirebaseServices {
  DatabaseReference userRef = FirebaseDatabase.instance.ref("user");
  DatabaseReference officeRef = FirebaseDatabase.instance.ref("office");
  DatabaseReference attendanceRef = FirebaseDatabase.instance.ref("attendance");

  FirebaseAuth auth = FirebaseAuth.instance;

  int count = 0;

  Future<void> saveUser(String name, String email) async {
    await userRef
        .child(auth.currentUser!.uid)
        .set({"name": name, "email": email});
  }

  Future<void> createOffice(
      {required String name,
      required double longitude,
      required double latitude,
      required double radius}) async {
    final offices = await officeRef.get();

    if (offices.value != null) {
      // Cast offices.value to Map<dynamic, dynamic>
      final officeData = offices.value as Map<dynamic, dynamic>;

      // Check if an office with the given name already exists
      if (officeData.containsKey(name)) {
        // Office with the same name already exists, handle the error or update the existing entry
        print('An office with the name "$name" already exists.');
        // You can choose to throw an exception or take other actions based on your requirements.
      } else {
        await officeRef.child(name).set({
          "name": name,
          "longitude": longitude,
          "latitude": latitude,
          "radius": radius
        });
        print('Office "$name" created successfully.');
      }
    } else {
      await officeRef.child(name).set({
        "name": name,
        "longitude": longitude,
        "latitude": latitude,
        "radius": radius
      });
    }
  }

  Future<void> deleteOffice(String name) async {
    await officeRef.child(name).remove();
  }

  Future<void> markAttendanceEntry({
    required String uId,
    required String officeName,
  }) async {
    late String? userName;
    final snapshot = await userRef.child(uId).child('name').get();
    if (snapshot.exists) {
      userName = snapshot.value.toString();
    } else {
      userName = "";
    }
    final now = DateTime.now();
    // print(now);

    String enTime = DateFormat.Hm().format(now); // Format the DateTime object
    // String ex_time = DateFormat.Hm().format(now); // Format the DateTime object

    String d = DateFormat('yMd').format(now).toString().replaceAll("/", "-");

    final snapshotAttend = await attendanceRef.child(d).child(uId).get();
    if (snapshotAttend.exists) {
      count = snapshotAttend.children.length;
    }
    print(count);

    await attendanceRef.child(d).child(uId).child(count.toString()).set({
      "name": userName,
      "office_name": officeName,
      "entry_time": enTime,
      "exit_time": "",
      "duration": "",
    });
  }

  Future<void> markAttendanceExit({
    required String uId,
    // required String userName
  }) async {
    final now = DateTime.now();
    String exTime = DateFormat.Hm().format(now);
    String d = DateFormat('yMd').format(now).toString().replaceAll("/", "-");
    final snapshotAttend = await attendanceRef.child(d).child(uId).get();
    final snapshorAttendTime = await attendanceRef
        .child(d)
        .child(uId)
        .child('$count')
        .child('entry_time')
        .get();
    String inTime = "";
    if (snapshotAttend.exists) {
      count = snapshotAttend.children.length - 1;
    }
    if (snapshorAttendTime.exists) {
      inTime = snapshorAttendTime.value.toString();
    }
    print(inTime);
    var format = DateFormat("HH:mm");
    var one = format.parse(inTime);
    var two = format.parse(exTime);

    await attendanceRef.child(d).child(uId).child(count.toString()).update({
      "exit_time": exTime,
      "duration": two.difference(one).toString(),
    });
  }
}

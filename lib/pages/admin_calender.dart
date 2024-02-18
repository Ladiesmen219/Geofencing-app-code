import 'dart:io';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as xcel;
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:geofence/pages/login.dart';
import 'package:geofence/services/authServices/firebase_auth_services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:geofence/widgets/present_names.dart';
import 'package:geofence/widgets/widgets.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';


import '../services/firebase/firebase_services.dart';

class AdminCalender extends StatefulWidget {
  const AdminCalender({Key? key}) : super(key: key);

  @override
  State<AdminCalender> createState() => _AdminCalenderState();
}

class _AdminCalenderState extends State<AdminCalender> {
  Position? currentPosition;
  final officeReference = FirebaseDatabase.instance.ref('office');

  TextEditingController officeController = TextEditingController();

  TextEditingController latitudeController = TextEditingController();

  TextEditingController longitudeController = TextEditingController();

  TextEditingController radiusController = TextEditingController();

  FirebaseServices firebaseServices = FirebaseServices();

  var fromval = "Choose a time";
  var toval = "Choose a time";

  bool _downloading = false;

  var times = [
    "Choose a time",
    "00:00",
    "01:00",
    "02:00",
    "03:00",
    "04:00",
    "05:00",
    "06:00",
    "07:00",
    "08:00",
    "09:00",
    "10:00",
    "11:00",
    "12:00",
    "13:00",
    "14:00",
    "15:00",
    "16:00",
    "17:00",
    "18:00",
    "19:00",
    "20:00",
    "21:00",
    "22:00",
    "23:00",
  ];

  var offices = ["Choose an Office"];
  var chosenOffice = "Choose an Office";

  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  @override
  initState() {
    getOffices();
    super.initState();
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    _initializeNotifications();
  }

Future<void> _initializeNotifications() async {
  final InitializationSettings initializationSettings =
      InitializationSettings(
    android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    iOS: DarwinInitializationSettings(),
  );
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
}

  Future<void> _showDownloadNotification() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'attendance_data',
      'attendance_data',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'download',
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      0,
      'Attendance Data',
      'Downloading...',
      platformChannelSpecifics,
      payload: 'attendance_data',
    );
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
    currentPosition = await determinePosition();
    if (currentPosition != null) {
      setState(() {
        latitudeController.text = currentPosition!.latitude.toString();
        longitudeController.text = currentPosition!.longitude.toString();
      });
    }
  }

  String date_Control =
      DateFormat('yMd').format(DateTime.now()).toString().replaceAll("/", "-");
  final FirebaseAuthService _firebaseAuthService =
      FirebaseAuthService(authService: FirebaseAuth.instance);
  DatabaseReference attendanceRef = FirebaseDatabase.instance.ref("attendance");

  bool isEmpty = true;
  late Query _query;
  late Query _attendenceQuery;
  Key _key = const Key('New Key');

  void _onSelectionChanged(DateRangePickerSelectionChangedArgs args) async {
    //offices.clear();
    // TODO: implement your code here
    final date = args.value.toString();
    final inprocess = date.split(" ").first.split("-");
    final RegExp regexp = RegExp(r'^0+(?=.)');
    for (int i = 0; i < inprocess.length; i++) {
      inprocess[i] = inprocess[i].replaceAll(regexp, "");
    }
    setState(() {
      date_Control = "${inprocess[1]}-${inprocess[2]}-${inprocess[0]}";
      _query = attendanceRef.child(date_Control);
      _key = Key(date_Control);
    });
    noClass();
  }

  noClass() async {
    final snapshot = await attendanceRef.child(date_Control).get();
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

  getOffices() async {
    var index = 0;
    var ref = FirebaseDatabase.instance.ref('office');
    var snapshot = await ref.get();

    final map = snapshot.value as Map<dynamic, dynamic>;
    List newOffice = map.keys.toList();
    for (int i = 0; i < newOffice.length; i++) {
      offices.add(newOffice[i]);
    }

    print(offices);
  }

  getQuery() {
    _query = attendanceRef.child(date_Control);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.orange.shade100,
          onPressed: () {
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    backgroundColor: Colors.orange.shade50,
                    title: const Text(
                      "Create Office",
                      textAlign: TextAlign.center,
                    ),
                    content: StatefulBuilder(
                      builder: (BuildContext context, StateSetter setState) {
                        return SingleChildScrollView(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextField(
                                controller: officeController,
                                decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(5)),
                                    hintText: "office name..."),
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              TextField(
                                controller: latitudeController,
                                decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(5)),
                                    hintText: "latitude..."),
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              TextField(
                                controller: longitudeController,
                                decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(5)),
                                    hintText: "longitude..."),
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              TextField(
                                controller: radiusController,
                                decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(5)),
                                    hintText: "Radius..."),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    actionsAlignment: MainAxisAlignment.center,
                    actions: [
                      IconButton(
                          onPressed: () async {
                            getCurrentLocation();
                          },
                          icon: const Icon(Icons.location_history)),
                      IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: const Icon(Icons.close)),
                      IconButton(
                          onPressed: () {
                            firebaseServices.createOffice(
                                name: officeController.text,
                                latitude: double.parse(latitudeController.text),
                                longitude:
                                    double.parse(longitudeController.text),
                                radius: double.parse(radiusController.text));
                            Navigator.pop(context);
                          },
                          icon: const Icon(Icons.check)),
                    ],
                  );
                });
          },
          child: const Icon(Icons.add),
        ),
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
              Padding(
                padding: const EdgeInsets.only(left: 3),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    DropdownButton(
                        value: fromval,
                        items: times.map((String items) {
                          return DropdownMenuItem(
                            value: items,
                            child: Text(items),
                          );
                        }).toList(),
                        onChanged: (String? newval) {
                          setState(() {
                            fromval = newval!;
                            getQuery();
                          });
                        }),
                    DropdownButton(
                        value: toval,
                        items: times.map((String items) {
                          return DropdownMenuItem(
                            value: items,
                            child: Text(items),
                          );
                        }).toList(),
                        onChanged: (String? newval) {
                          setState(() {
                            toval = newval!;
                            getQuery();
                          });
                        }),
                    DropdownButton(
                        value: chosenOffice,
                        items: offices.map((String items) {
                          return DropdownMenuItem(
                            value: items,
                            child: Text(items),
                          );
                        }).toList(),
                        onChanged: (String? newval) {
                          setState(() {
                            chosenOffice = newval!;
                            getQuery();
                          });
                        }),
                  ],
                ),
              ),
              getAttendanceList(),
            ],
          ),
        ),
      ),
    );
  }

  getAttendanceList() {
    List<Map<String, dynamic>> excelData = [];
    return isEmpty
        ? Expanded(
            child: Card(
            elevation: 5,
            shape: OutlineInputBorder(borderRadius: BorderRadius.circular(2)),
            color: Colors.orange.shade50,
            shadowColor: Colors.orange,
            child: const Center(
              child: Text(
                'No Class',
                style: TextStyle(
                  fontSize: 15,
                ),
              ),
            ),
          ))
        : Expanded(
            child: FirebaseAnimatedList(
              query: _query,
              key: _key,
              itemBuilder: (context, snapshot, animation, index) {
                String userId = snapshot.value.toString();
                Object? data = snapshot.value;
                String userName =
                    snapshot.child('$index').child('name').value.toString();
                String userOffice = snapshot
                    .child('$index')
                    .child('office_name')
                    .value
                    .toString();
                String duration =
                    snapshot.child('$index').child('duration').value.toString();

                String attendanceEntry = snapshot
                    .child('$index')
                    .child('entry_time')
                    .value
                    .toString();
                String attendanceExit = snapshot
                    .child('$index')
                    .child('exit_time')
                    .value
                    .toString();
                DateTime entry;
                DateTime exit;
                DateTime toFilter;
                DateTime fromFilter;
                if (toval != times[0] &&
                    fromval != times[0] &&
                    chosenOffice != offices[0]) {
                  entry = DateFormat("yyyy-MM-dd hh:mm")
                      .parse("2002-09-11 $attendanceEntry");
                  exit = DateFormat("yyyy-MM-dd hh:mm")
                      .parse("2002-09-11 $attendanceExit");
                  toFilter =
                      DateFormat("yyyy-MM-dd hh:mm").parse("2002-09-11 $toval");
                  fromFilter = DateFormat("yyyy-MM-dd hh:mm")
                      .parse("2002-09-11 $fromval");
                  print(entry);
                  print(exit);
                  if (entry.isAfter(fromFilter) &&
                      exit.isBefore(toFilter) &&
                      userOffice == chosenOffice) {
                    excelData.add({
                      'username': userName,
                      'office': userOffice,
                      'duration': duration,
                      'entry': attendanceEntry,
                      'exit': attendanceExit
                    });
                    return Column(
                      children: [
                        AttendanceName(
                            userName: userName, officeName: userOffice),
                        IconButton(
                            onPressed: () {
                              exportDataToExcel(excelData);
                            },
                            icon: const Icon(Icons.download))
                      ],
                    );
                  } else {}
                } else {
                  excelData.add({
                    'username': userName,
                    'office': userOffice,
                    'duration': duration,
                    'entry': attendanceEntry,
                    'exit': attendanceExit
                  });
                  return Column(
                    children: [
                      AttendanceName(
                          userName: userName, officeName: userOffice),
                      IconButton(
                          onPressed: () {
                            exportDataToExcel(excelData);
                          },
                          icon: const Icon(Icons.download))
                    ],
                  );
                }

                print(userId);
                return Card(
                  elevation: 5,
                  shape: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(2)),
                  color: Colors.orange.shade50,
                  shadowColor: Colors.orange,
                  child: const Center(
                    child: Text(
                      'No Class',
                      style: TextStyle(
                        fontSize: 15,
                      ),
                    ),
                  ),
                );
              },
            ),
          );
  }

  Future<void> exportDataToExcel(List<Map<String, dynamic>> data) async {
    // Create a new Excel workbook
    setState(() {
      _downloading = true;
    });

    final xcel.Workbook workbook = xcel.Workbook();
    final xcel.Worksheet sheet = workbook.worksheets[0];

    sheet.getRangeByIndex(1, 1).setText("Duartion");
    sheet.getRangeByIndex(1, 2).setText("Entry Time");
    sheet.getRangeByIndex(1, 3).setText("Exit Time");
    sheet.getRangeByIndex(1, 4).setText("Name");
    sheet.getRangeByIndex(1, 5).setText("Office Name");

    int i = 0;
    // Add data to the sheet
    for (final item in data) {
      print("error here");
      sheet.getRangeByIndex(i + 2, 1).setText(item['duration']);
      sheet.getRangeByIndex(i + 2, 2).setText(item['entry']);
      sheet.getRangeByIndex(i + 2, 3).setText(item['exit']);
      sheet.getRangeByIndex(i + 2, 4).setText(item['username']);
      sheet.getRangeByIndex(i + 2, 5).setText(item['office']);
      i++;
    }

    final List<int> bytes = workbook.saveAsStream();
    //File.writeCounter(bytes, "geeksforgeeks.xlsx", context);

    // Get the device's external storage directory
    final directory = await getExternalStorageDirectory();

    // Create a file path for the Excel file
    final String? filePath = await getDownloadPath();

    if(filePath != null) {
      final File file = File('$filePath/attendance_data.xlsx');
      await file.writeAsBytes(bytes);
      print("file downloaded");
      setState(() {     
        _downloading = false;
      });
      await _showDownloadNotification();
    } else {
      print("Error in getting file path");
      setState(() {
        _downloading = false;
      });
    }

    // print(filePath);

    // File('${filePath.toString()}/attendance_data.xlsx').writeAsBytes(bytes);

    // Save the Excel file
    //print('saving executed in ${stopwatch.elapsed}');
  }

  Future<String?> getDownloadPath() async {
    Directory? directory;
    try {
      if (Platform.isIOS) {
        directory = await getApplicationDocumentsDirectory();
      } else {
        directory = Directory('/storage/emulated/0/Download');
        // Put file in global download folder, if for an unknown reason it didn't exist, we fallback
        // ignore: avoid_slow_async_io
        if (!await directory.exists()) {
          directory = await getExternalStorageDirectory();
        }
      }
    } catch (err) {
      print("Cannot get download folder path");
    }
    return directory?.path;
  }
}

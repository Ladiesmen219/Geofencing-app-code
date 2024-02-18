import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geofence/pages/admin_office_list.dart';
import 'package:geofence/pages/login.dart';
import 'package:geofence/pages/signup.dart';

import 'package:geofence/services/authServices/firebase_auth_services.dart';
import 'package:geofence/widgets/widgets.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

class AdminLogin extends StatelessWidget {
  final authService = FirebaseAuthService(authService: FirebaseAuth.instance);

  final TextEditingController _passwordController = TextEditingController();
  final FirebaseAuthService _firebaseAuthService =
      FirebaseAuthService(authService: FirebaseAuth.instance);

  AdminLogin({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
            gradient: LinearGradient(begin: Alignment.topCenter, colors: [
          Colors.orange[900]!,
          Colors.orange[800]!,
          Colors.orange[400]!
        ])),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 80,
            ),
            const Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Admin Login",
                    style: TextStyle(color: Colors.white, fontSize: 40),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    "Welcome Back Admin",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(60),
                        topRight: Radius.circular(60))),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(30),
                    child: Column(
                      children: [
                        const SizedBox(
                          height: 60,
                        ),
                        Container(
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: const [
                                BoxShadow(
                                    color: Color.fromRGBO(225, 95, 27, .3),
                                    blurRadius: 20,
                                    offset: Offset(0, 10))
                              ]),
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                    border: Border(
                                        bottom: BorderSide(
                                            color: Colors.grey[200]!))),
                                child: TextField(
                                  controller: _passwordController,
                                  decoration: const InputDecoration(
                                      hintText: "Password For Admin",
                                      hintStyle: TextStyle(color: Colors.grey),
                                      border: InputBorder.none),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 40,
                        ),
                        GestureDetector(
                          onTap: () async {
                            // showDialog(
                            //     context: context,
                            //     builder: (BuildContext context) {
                            //       return AlertDialog(
                            //         backgroundColor: Colors.orange.shade50,
                            //         content: Row(
                            //           mainAxisAlignment:
                            //           MainAxisAlignment.center,
                            //           children: [
                            //             CircularProgressIndicator(
                            //               color: Colors.orange[900]!,
                            //             ),
                            //           ],
                            //         ),
                            //       );
                            //     });
                          },
                          child: GestureDetector(
                            onTap: () async {
                              final valid = await _firebaseAuthService
                                  .checkPassAdmin(_passwordController.text);
                              if (valid) {
                                nextScreen(context, const AdminOfficeList());
                                showTopSnackBar(
                                  Overlay.of(context),
                                  const CustomSnackBar.success(
                                    message: "Logged in as Admin",
                                  ),
                                );
                              } else {
                                showTopSnackBar(
                                  Overlay.of(context),
                                  const CustomSnackBar.success(
                                    message: "Wrong password",
                                  ),
                                );
                              }
                            },
                            child: Container(
                              height: 50,
                              margin: const EdgeInsets.symmetric(horizontal: 50),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(50),
                                  color: Colors.orange[900]),
                              child: const Center(
                                child: Text(
                                  "Admin Login",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 50,
                        ),
                        const Text(
                          "Other Options",
                          style: TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(
                          height: 30,
                        ),
                        Row(
                          children: [
                            Expanded(
                                child: GestureDetector(
                              onTap: () {
                                nextScreenReplace(context, LoginPage());
                              },
                              child: Container(
                                height: 50,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(50),
                                    color: Colors.blue),
                                child: const Center(
                                  child: Text(
                                    "User Login",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            )),
                            const SizedBox(
                              width: 30,
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  nextScreenReplace(context, SignUp());
                                },
                                child: Container(
                                  height: 50,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(50),
                                      color: Colors.black),
                                  child: const Center(
                                    child: Text(
                                      "User Sign Up",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:geofence/models/user.dart';
import 'package:geofence/services/authServices/auth_errors.dart';
import 'package:geofence/services/authServices/auth_service.dart';
import 'package:geofence/services/firebase/firebase_services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FirebaseAuthService implements AuthService {
  FirebaseAuthService({
    required auth.FirebaseAuth authService,
  }) : _firebaseAuth = authService;

  final auth.FirebaseAuth _firebaseAuth;

  FirebaseServices firebaseServices = FirebaseServices();
  final DatabaseReference _adminRef = FirebaseDatabase.instance.ref("admin");

  UserEntity _mapFirebaseUser(auth.User? user) {
    if (user == null) {
      return UserEntity.empty();
    }

    final map = <String, dynamic>{
      'id': user.uid,
      'name': user.displayName ?? "",
      'email': user.email ?? '',
      'emailVerified': user.emailVerified,
      'imageUrl': user.photoURL ?? '',
    };
    return UserEntity.fromJson(map);
  }

  @override
  Future<UserEntity> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      return _mapFirebaseUser(userCredential.user!);
    } on auth.FirebaseAuthException catch (e) {
      throw _determineError(e);
    }
  }

  @override
  Future<UserEntity> createUserWithEmailAndPassword(
      {required String email,
      required String password,
      required String name}) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      firebaseServices.saveUser(name, email);

      return _mapFirebaseUser(_firebaseAuth.currentUser!);
    } on auth.FirebaseAuthException catch (e) {
      throw _determineError(e);
    }
  }

  @override
  Future<void> signOut() async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    try {
      auth.signOut();

      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setBool("isLoggedIn", false);
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  Future<bool> checkPassAdmin(String pass) async {
    DataSnapshot snapshot = await _adminRef.get();
    final password = snapshot.value.toString();
    if (pass == password) {
      return true;
    } else {
      return false;
    }
  }
}

AuthError _determineError(auth.FirebaseAuthException exception) {
  switch (exception.code) {
    case 'invalid-email':
      return AuthError.invalidEmail;
    case 'user-disabled':
      return AuthError.userDisabled;
    case 'user-not-found':
      return AuthError.userNotFound;
    case 'wrong-password':
      return AuthError.wrongPassword;
    case 'email-already-in-use':
    case 'account-exists-with-different-credential':
      return AuthError.emailAlreadyInUse;
    case 'invalid-credential':
      return AuthError.invalidCredential;
    case 'operation-not-allowed':
      return AuthError.operationNotAllowed;
    case 'weak-password':
      return AuthError.weakPassword;
    case 'ERROR_MISSING_GOOGLE_AUTH_TOKEN':
    default:
      return AuthError.error;
  }
}

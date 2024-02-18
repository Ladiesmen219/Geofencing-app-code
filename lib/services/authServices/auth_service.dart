import 'package:geofence/models/user.dart';

abstract class AuthService {
  Future<UserEntity> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<UserEntity> createUserWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
  });

  Future<void> signOut() async {}
}

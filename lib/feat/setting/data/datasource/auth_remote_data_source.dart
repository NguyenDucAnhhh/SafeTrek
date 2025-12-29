import 'package:firebase_auth/firebase_auth.dart';

class AuthRemoteDataSource {
  final FirebaseAuth auth;

  AuthRemoteDataSource(this.auth);

  Future<void> reauthenticate({
    required String email,
    required String password,
  }) async {
    final credential = EmailAuthProvider.credential(
      email: email,
      password: password,
    );
    await auth.currentUser!.reauthenticateWithCredential(credential);
  }

  Future<void> updatePassword(String newPassword) async {
    await auth.currentUser!.updatePassword(newPassword);
  }
}

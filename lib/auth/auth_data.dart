import 'package:firebase_auth/firebase_auth.dart';

class AuthenticationRemote {
  Future<void> login(String email, String password) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email.trim(), password: password.trim());
    } catch (e) {
      print('Error saat login: $e');
    }
  }

  Future<void> register(
      String email, String password, String PasswordConfirm) async {
    if (PasswordConfirm == password) {
      try {
        await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
                email: email.trim(), password: password.trim())
            .then((value) {});
      } catch (e) {
        print('Error saat registrasi: $e');
      }
    } else {
      print('Password dan konfirmasi password tidak sesuai');
    }
  }
}

import 'package:blog_app/app/routes/app_pages.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class FirebaseAuthentication {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> createAccount(String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      print(e);
    }
  }

  Future<bool> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return true;
    } on FirebaseAuthException catch (e) {
    print('login failed with error code: ${e.code}');
    return false;
  }
  }

  Future<void> logOut() async {
    try {
      await _auth.signOut().then((value) {
        Get.toNamed(Routes.LOGIN);
      });
    } catch (e) {
      print(e);
    }
  }
}

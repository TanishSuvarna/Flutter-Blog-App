import 'package:blog_app/app/data/const.dart';
import 'package:blog_app/app/data/firebase/firebase_auth.dart';
import 'package:blog_app/app/data/firebase/firebase_functions.dart';
import 'package:blog_app/app/data/global_widgets/indicator.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:blog_app/app/routes/app_pages.dart';

class SignUpController extends GetxController {
  final FirebaseAuthentication _authentication = FirebaseAuthentication();
  final FirebaseFunctions _functions = FirebaseFunctions();
  final TextEditingController fullName = TextEditingController();
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();
  final User? user = FirebaseAuth.instance.currentUser;
  
  void onCreateAccount() async {
    if (fullName.text.isNotEmpty &&
        email.text.isNotEmpty &&
        password.text.isNotEmpty) {
      Indicator.showLoading();

      await _authentication
          .createAccount(email.text, password.text)
          .then((value) {
        _functions.createUserCredential(fullName.text, email.text);
      }).then((value)async => {
        await FirebaseAuth.instance.currentUser?.updateDisplayName(
                fullName.text
          )
          ,Get.toNamed(Routes.HOME)
      });
    } else {
      showAlert("All Feilds are required");
      print("All fields are required");
    }
  }
}

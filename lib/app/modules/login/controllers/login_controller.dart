import 'package:blog_app/app/data/const.dart';
import 'package:blog_app/app/data/firebase/firebase_auth.dart';
import 'package:blog_app/app/data/global_widgets/indicator.dart';
import 'package:blog_app/app/routes/app_pages.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
class LoginController extends GetxController {
  final FirebaseAuthentication _authentication = FirebaseAuthentication();

  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();

  void onLogin() async {
 
   if (email.text.isNotEmpty && password.text.isNotEmpty) {
    Indicator.showLoading();
    bool loginSuccessful = await _authentication.login(email.text, password.text);
    Indicator.closeLoading();
    if (loginSuccessful) {
      Get.toNamed(Routes.HOME);
    } else {
      showAlert('Invalid email or password');
    }
  } else {
    showAlert('All fields are required');
  }
 
  }
}

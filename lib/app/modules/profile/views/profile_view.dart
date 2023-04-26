import 'package:blog_app/app/data/global_widgets/tiles.dart';
import 'package:blog_app/app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:blog_app/app/data/firebase/firebase_auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import '../controllers/profile_controller.dart';

class ProfileView extends GetView<ProfileController> {
  final FirebaseAuthentication _authentication = FirebaseAuthentication();
  User? user = FirebaseAuth.instance.currentUser;
  
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            SizedBox(
              height: 50.h,
            ),
            Align(
              alignment: Alignment.center,
              child: Container(
                height: 130.h,
                width: 130.h,
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  "A",
                  style: TextStyle(
                    fontSize: 70.sp,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 20.h,
            ),
            Text(
              user!.displayName ?? "Unknown",
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(
              height: 25.h,
            ),
            Tile(
              title: "My Blogs",
              icon: Icons.edit,
              function: () {
                Get.toNamed(Routes.MY_BLOGS);
              },
            ),
            Tile(
              title: "Favourite",
              icon: Icons.favorite_outline_outlined,
              function: () {
                Get.toNamed(Routes.FAVOURITE);
              },
            ),
            Tile(
              title: "Log Out",
              icon: Icons.logout,
              function: () async {
                await _authentication.logOut();
              },
            ),
          ],
        ),
      ),
    );
  }
}

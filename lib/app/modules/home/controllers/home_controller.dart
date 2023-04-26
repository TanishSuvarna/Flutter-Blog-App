import 'dart:async';

import 'package:blog_app/app/data/firebase/firebase_functions.dart';
import 'package:blog_app/app/data/global_widgets/indicator.dart';
import 'package:blog_app/app/models/blog_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:rxdart/rxdart.dart';
export 'home_controller.dart';
class HomeController extends GetxController {
  static HomeController get to => Get.find();
  final FirebaseFunctions _functions = FirebaseFunctions();
  final ScrollController controller = ScrollController();
  List<BlogsModel> blogs = [];
  List favouriteList = [];
  var isLoading = false.obs;
  Timer? _timer;
final _blogsController = BehaviorSubject<List<BlogsModel>>.seeded([]);
BehaviorSubject<List<BlogsModel>> get blogsController => _blogsController;
 bool _isLoadingData = false; // new boolean variable
  void getData() async {
    
     if (!_isLoadingData) { // check if data is already being loaded
      _isLoadingData = true; // set data loading flag to true
      List<BlogsModel> newBlogs = await _functions.getBlogs();
      blogs.addAll(newBlogs); // append new data to existing list
      if(newBlogs.isNotEmpty) blogsController.add([...blogs]);
      _isLoadingData = false; // set data loading flag to false
        Indicator.closeLoading();
      _timer?.cancel(); 
    }
  
  }

  @override
  void onReady() {
    // TODO: implement onReady
    super.onReady();
    Indicator.showLoading();
    _timer = Timer(Duration(seconds: 10), () {
      // Automatically dismiss the loading screen after 30 seconds
      Indicator.closeLoading();
      _timer = null;
    });

  }

  Future<void> getFavouriteList() async {
    favouriteList = await _functions.getFavouriteList();
  }


  @override
  void onInit() {
    super.onInit();
    getData();
    getFavouriteList();
    _functions.isLoading.listen((p) {
      isLoading.value = p;
    });
    _blogsController.listen((blogs) {
      print("blogsController updated with ${blogs.length}blogs");
    });
    controller.addListener(() {
      double maxScrollPoint = controller.position.maxScrollExtent;
      double currentPosition = controller.position.pixels;
      double height20 = Get.size.height * 0.20;

      if (maxScrollPoint - currentPosition <= height20) {
        getData();
      }
    });
  }
}


import 'package:blog_app/app/data/firebase/firebase_functions.dart';
import 'package:blog_app/app/data/global_widgets/indicator.dart';
import 'package:blog_app/app/models/blog_model.dart';
import 'package:blog_app/app/modules/home/controllers/home_controller.dart';
import 'package:get/get.dart';
import 'dart:async';
class FavouriteController extends GetxController {
  final FirebaseFunctions _functions = FirebaseFunctions();
  final controller = Get.find<HomeController>();
  List<BlogsModel> models = [];
  Timer? _timer;
  void getFavouriteList() async {
    models = [];
    for (var i = 0; i < controller.favouriteList.length; i++) {
      models.add(await _functions.getBlogsById(controller.favouriteList[i]));
    }

    Indicator.closeLoading();
     _timer?.cancel(); // Cancel the timer if it's still running
    update();
  }

  @override
  void onReady() {
    // TODO: implement onReady
    super.onReady();
    Indicator.showLoading();
    _timer = Timer(Duration(seconds: 8), () {
      // Automatically dismiss the loading screen after 30 seconds
      Indicator.closeLoading();
      _timer = null;
    });
  }

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    getFavouriteList();
  }
}

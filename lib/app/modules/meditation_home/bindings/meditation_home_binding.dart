import 'package:get/get.dart';

import '../controllers/home_controller.dart';

class MeditationHomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(
      () => HomeController(
        appService: Get.find(),
      ),
    );
  }
}

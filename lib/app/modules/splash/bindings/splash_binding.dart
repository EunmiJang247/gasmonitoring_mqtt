import 'package:get/get.dart';
import 'package:safety_check/app/data/services/app_service.dart';

import '../controllers/splash_controller.dart';

class SplashBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SplashController>(
      () => SplashController(
        appService: Get.find<AppService>()
      ),
    );
  }
}

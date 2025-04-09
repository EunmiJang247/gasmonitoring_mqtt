import 'package:get/get.dart';

import '../controllers/find_pw_controller.dart';

class FindPwBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FindPwController>(
      () => FindPwController(appService: Get.find()),
    );
  }
}

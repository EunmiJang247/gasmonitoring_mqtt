import 'package:get/get.dart';

import '../controllers/check_image_controller.dart';

class CheckImageBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CheckImageController>(
      () => CheckImageController(
          appService: Get.find(),
        localGalleryDataService: Get.find()
      ),
    );
  }
}

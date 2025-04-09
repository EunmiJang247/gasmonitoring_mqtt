import 'package:get/get.dart';

import '../controllers/project_gallery_controller.dart';

class ProjectGalleryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProjectGalleryController>(
      () => ProjectGalleryController(
          appService: Get.find(), localGalleryDataService: Get.find()),
    );
  }
}

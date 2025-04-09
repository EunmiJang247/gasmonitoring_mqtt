import 'package:get/get.dart';

import '../controllers/project_info_controller.dart';

class ProjectInfoBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProjectInfoController>(
      () => ProjectInfoController(
        appService: Get.find(),
        localGalleryDataService: Get.find(),
      ),
    );
  }
}

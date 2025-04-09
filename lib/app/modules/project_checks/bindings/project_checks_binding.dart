import 'package:get/get.dart';

import '../../project_checks/controllers/project_checks_controller.dart';

class ProjectChecksBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProjectChecksController>(
      () => ProjectChecksController(
        appService: Get.find(),
        localGalleryDataService: Get.find(),
      ),
    );
  }
}

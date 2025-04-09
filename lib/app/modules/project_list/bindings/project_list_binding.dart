import 'package:get/get.dart';

import '../controllers/project_list_controller.dart';

class ProjectListBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProjectListController>(
      () => ProjectListController(
        appService: Get.find()
      ),
    );
  }
}

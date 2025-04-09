import 'package:get/get.dart';

import '../controllers/drawing_list_controller.dart';

class DrawingListBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DrawingListController>(
      () => DrawingListController(
        appService: Get.find()
      ),
    );
  }
}

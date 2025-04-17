import 'package:get/get.dart';
import 'package:safety_check/app/data/services/local_gallery_data_service.dart';

import '../controllers/drawing_detail_controller.dart';

class DrawingDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DrawingDetailController>(
      () => DrawingDetailController(
          appService1: Get.find(),
          localGalleryDataService: Get.find<LocalGalleryDataService>()),
    );
  }
}

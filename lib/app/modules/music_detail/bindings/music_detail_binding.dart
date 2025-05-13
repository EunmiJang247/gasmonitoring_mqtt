import 'package:get/get.dart';
import 'package:meditation_friend/app/modules/music_detail/controllers/music_detail_controller.dart';

class MusicDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MusicDetailController>(
      () => MusicDetailController(appService: Get.find()),
    );
  }
}

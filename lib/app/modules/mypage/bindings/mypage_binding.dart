import 'package:get/get.dart';
import 'package:meditation_friend/app/data/services/app_service.dart';
import 'package:meditation_friend/app/data/services/local_app_data_service.dart';
import 'package:meditation_friend/app/modules/mypage/controllers/mypage_controller.dart';

class MypageBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MypageController>(
      () => MypageController(
          appService: Get.find<AppService>(),
          localAppDataService: Get.find<LocalAppDataService>()),
      //
    );
  }
}

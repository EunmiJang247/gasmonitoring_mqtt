import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:safety_check/app/data/services/local_app_data_service.dart';
import 'package:safety_check/app/routes/app_pages.dart';
import 'package:safety_check/app/utils/helper.dart';
import 'package:safety_check/app/utils/log.dart';

class SplashController extends GetxController {
  @override
  Future<void> onInit() async {
    // 권한체크
    await Permission.camera.request().then((value) async {
      await Permission.microphone.request().then((value) async {
        if (await getAndroidSdkVersion() >= 33) {
          await Permission.manageExternalStorage
              .request()
              .then((value) => null);
        } else {
          await Permission.storage.request().then((value) => null);
        }
      });
    });

    // 1초뒤 로그인 시도
    await Future.delayed(const Duration(milliseconds: 1000), () async {
      // 네트워크가 연결되어 있을때만 업데이트 확인
      final List<ConnectivityResult> connectivityResult =
          await Connectivity().checkConnectivity();
      if (connectivityResult.contains(ConnectivityResult.mobile) ||
          connectivityResult.contains(ConnectivityResult.ethernet) ||
          connectivityResult.contains(ConnectivityResult.wifi)) {
        try {
          print("SplashController 호출됨!"); // <-- 확인용
        } catch (e) {
          // ignore
          logError('업데이트 확인 실패: $e');
          print('에러 발생: $e'); // <-- 확인용
        }
      }

      if (Get.find<LocalAppDataService>().initialized) {
        Get.offAllNamed(Routes.MEDITATION_HOME);
      } else {
        EasyLoading.showError('데이터 서비스 초기화 실패');
      }
    });

    super.onInit();
  }
}

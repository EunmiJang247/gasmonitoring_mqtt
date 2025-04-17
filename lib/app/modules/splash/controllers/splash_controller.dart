import 'dart:async';
// import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:safety_check/app/data/models/base_response.dart';
import 'package:safety_check/app/data/models/update_history.dart';
import 'package:safety_check/app/data/services/app_service.dart';
import 'package:safety_check/app/data/services/local_app_data_service.dart';
import 'package:safety_check/app/routes/app_pages.dart';
import 'package:safety_check/app/utils/helper.dart';
import 'package:safety_check/app/utils/log.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class SplashController extends GetxController {
  final AppService _appService;
  final LocalAppDataService localAppDataService =
      Get.find<LocalAppDataService>();

  SplashController({
    required AppService appService,
  }) : _appService = appService;

  Rx<bool> needUpdate = Rx(false);
  // Rx란 ? 반응형 변수 (Reactive Variable) 라는 뜻
  // 값이 바뀌면 자동으로 "얘를 감지하고 있는 UI"가 업데이트됨.
  // 즉, setState() 안 써도 됨

  String test = "test"; // 얘는 변화가 추적되지 않음
  Rx<String> test11 = Rx("test11"); // 이것도 가능!

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
          BaseResponse? response = await _appService.init();

          List<dynamic> historyList = response?.data['history'] as List;
          List<UpdateHistoryItem?> updateHistoryList =
              historyList.map((e) => UpdateHistoryItem.fromJson(e)).toList();

          _appService.lastUpdateHistory.value = updateHistoryList.first!;
          _appService.lastUpdateHistory.value!.history = _appService
              .lastUpdateHistory.value!.history
              .where((element) => element.trim() != "")
              .toList();

          localAppDataService.putUpdateHistory(updateHistoryList);

          PackageInfo packageInfo = await PackageInfo.fromPlatform();
          String lastUpdateVersion =
              _appService.lastUpdateHistory.value!.version;
          String packageVersion = packageInfo.version;
          if (lastUpdateVersion != packageVersion) {
            logError(packageVersion, des: 'need update to $lastUpdateVersion');
            needUpdate.value = true;
          } else {
            logSuccess(packageVersion, des: '최신버전입니다.');
          }
        } catch (e) {
          // ignore
        }
      }

      FlutterNativeSplash.remove();

      if (!needUpdate.value) {
        if (Get.find<LocalAppDataService>().initialized) {
          Get.offAllNamed(Routes.LOGIN);
        } else {
          EasyLoading.showError('데이터 서비스 초기화 실패');
        }
      }
    });

    super.onInit();
  }

  UpdateHistoryItem get lastUpdateHistory {
    return _appService.lastUpdateHistory.value!;
  }
}

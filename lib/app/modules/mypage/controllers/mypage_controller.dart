import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:get/get.dart';

import '../../../data/services/app_service.dart';
import '../../../data/services/local_app_data_service.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';

class MypageController extends GetxController {
  final AppService appService;
  final LocalAppDataService _localAppDataService;
  final keyboardVisibilityController = KeyboardVisibilityController();

  MypageController({
    required this.appService,
    required LocalAppDataService localAppDataService,
  }) : _localAppDataService = localAppDataService;

  TextEditingController idController = TextEditingController();
  TextEditingController pwController = TextEditingController();
  RxBool isSaveLoginInfo = false.obs;
  Rx<String?> errorText = Rx(null);

  @override
  void onInit() {
    // User? savedUser = _localAppDataService.getLastLoginUser();
    String? savedPw = _localAppDataService.getConfigValue('saved_pw');
    // if (savedUser != null && savedPw != null && savedPw != "") {
    //   idController.text = savedUser.email;
    //   pwController.text = savedPw;
    //   isSaveLoginInfo.value = true;
    // }

    super.onInit();
  }

  @override
  dispose() {
    idController.dispose();
    pwController.dispose();
    super.dispose();
  }

  setIsSaveInfo(bool value) {
    isSaveLoginInfo.value = value;
  }

  Future<void> _getUserInfo() async {
    try {
      User user = await UserApi.instance.me();

      // setState(() {
      //   _nickname = user.kakaoAccount?.profile?.nickname ?? '닉네임 없음';
      //   _email = user.kakaoAccount?.email ?? '이메일 없음';
      //   _profileImageUrl = user.kakaoAccount?.profile?.profileImageUrl ?? '';
      //   _status = "로그인 성공";
      // });

      print('user: $user');
    } catch (e) {
      print('유저 정보 가져오기 실패: $e');
      // setState(() {
      //   _status = '유저 정보 가져오기 실패';
      // });
    }
  }

  onKakaoLogin(BuildContext context, {required bool offline}) async {
    print('카카오 로그인 클릭!');
    FocusScope.of(context).unfocus();
    if (EasyLoading.isShow) return;

    bool isInstalled = await isKakaoTalkInstalled();
    OAuthToken token = isInstalled
        ? await UserApi.instance.loginWithKakaoTalk()
        : await UserApi.instance.loginWithKakaoAccount();
    print('로그인 성공: ${token.accessToken}');
    await _getUserInfo(); // 로그인 성공 후 유저 정보 가져오기
    // if (errorMsg != null) {
    //   errorText.value = errorMsg;
    //   await EasyLoading.showError(errorMsg);

    //   Timer(const Duration(seconds: 1), () {
    //     if (Get.isDialogOpen == true) Get.back();
    //   });
    // } else {
    //   // 아이디/비밀번호 저장
    //   if (isSaveLoginInfo.value) {
    //     _localAppDataService.setConfigValue('saved_pw', pwController.text);
    //   } else {
    //     _localAppDataService.setConfigValue('saved_pw', "");
    //   }
    //   Get.offAllNamed(Routes.MEDITATION_HOME);
    // }
  }
}

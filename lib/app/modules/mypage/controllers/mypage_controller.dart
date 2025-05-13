import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:get/get.dart';
import 'package:meditation_friend/app/data/models/00_user.dart';

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

  Future<void> onKakaoLogin() async {
    try {
      print('카카오 로그인 클릭!');

      // 카카오톡 설치 여부 확인
      if (await isKakaoTalkInstalled()) {
        try {
          await UserApi.instance.loginWithKakaoTalk();
          print('카카오톡으로 로그인 성공');
        } catch (error) {
          print('카카오톡 로그인 실패: $error');
          // 카카오톡 로그인 실패 시 카카오 계정으로 로그인 시도
          await UserApi.instance.loginWithKakaoAccount();
          print('카카오 계정으로 로그인 성공');
        }
      } else {
        // 카카오톡 미설치: 카카오 계정으로 로그인
        await UserApi.instance.loginWithKakaoAccount();
        print('카카오 계정으로 로그인 성공');
      }

      // 사용자 정보 가져오기
      final kakaoUser = await UserApi.instance.me();
      print('user 정보: $kakaoUser');

      // User 모델로 변환
      final user = MeditationFriendUser(
        id: kakaoUser.id.toString(),
        nickname: kakaoUser.properties?['nickname'] ?? '',
        profileImageUrl: kakaoUser.properties?['profile_image'] ?? '',
        thumbnailImageUrl: kakaoUser.properties?['thumbnail_image'] ?? '',
        connectedAt: kakaoUser.connectedAt,
      );

      // AppService에 사용자 정보 저장
      appService.user.value = user;
      await _localAppDataService.writeLastLoginUser(user);

      // 로그인 성공 시 홈 화면으로 이동
      Get.offAllNamed('/meditation-home');
    } catch (error) {
      print('카카오 로그인 실패: $error');
      Get.snackbar(
        '로그인 실패',
        '카카오 로그인 중 오류가 발생했습니다.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}

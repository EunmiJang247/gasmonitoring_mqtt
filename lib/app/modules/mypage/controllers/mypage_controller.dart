import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:get/get.dart';
import 'package:meditation_friend/app/constant/app_color.dart';
import 'package:meditation_friend/app/data/models/00_user.dart';
import 'package:meditation_friend/app/data/models/base_response.dart';

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

  // 알람 설정 관련 변수
  RxString alarmDays = "0000000".obs; // 월~일 순서로 비트 플래그 (0: 선택 안함, 1: 선택함)
  RxInt alarmHour = 12.obs;
  RxInt alarmMinute = 30.obs;
  RxBool isAlarmEnabled = false.obs;

  @override
  void onInit() {
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

  Future<void> onKakaoLogin() async {
    try {
      // 로딩 표시 시작
      EasyLoading.show(status: '로그인 중...');
      // 카카오톡 설치 여부 확인
      if (await isKakaoTalkInstalled()) {
        try {
          await UserApi.instance.loginWithKakaoTalk();
        } catch (error) {
          // 카카오톡 로그인 실패 시 카카오 계정으로 로그인 시도
          await UserApi.instance.loginWithKakaoAccount();
        }
      } else {
        // 카카오톡 미설치: 카카오 계정으로 로그인
        await UserApi.instance.loginWithKakaoAccount();
      }

      // 사용자 정보 가져오기
      final kakaoUser = await UserApi.instance.me();

      String? fcmToken = await appService.getFcmToken() ?? "";

      // 서버에 보내서 로그인 처리
      BaseResponse? response = await appService.signInUsingKakao(
        id: kakaoUser.id.toString(),
        fcmToken: fcmToken,
        nickname: kakaoUser.properties?['nickname'] ?? '',
        profileImageUrl: kakaoUser.properties?['profile_image'] ?? '',
        thumbnailImageUrl: kakaoUser.properties?['thumbnail_image'] ?? '',
        connectedAt: kakaoUser.connectedAt,
      );
      // 로딩 표시 종료
      EasyLoading.dismiss();
      if (response?.result?.code == 200) {
        // 서버의 데이터베이스에 user가 있는 경우
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
        // 로컬 DB에 사용자 정보 저장
        await _localAppDataService.writeLastLoginUser(user);
        // 로그인 성공 시 홈 화면으로 이동
        appService.currentIndex.value = 0;
        Get.offAllNamed('/meditation-home');
      }
    } catch (error) {
      Get.snackbar(
        '로그인 실패',
        '카카오 로그인 중 오류가 발생했습니다.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> saveAlarmSettings() async {
    await appService.saveAlarmSettings(
      alarmDays: alarmDays.value,
      alarmHour: alarmHour.value,
      alarmMinute: alarmMinute.value,
    );

    // 로컬스토리지에 이 시간 저장하는 부분

    Get.back(); // BottomSheet 닫기
    Future.delayed(Duration(milliseconds: 100), () {
      Get.snackbar('알림 설정', '저장되었습니다.', snackPosition: SnackPosition.BOTTOM);
    });
  }
}

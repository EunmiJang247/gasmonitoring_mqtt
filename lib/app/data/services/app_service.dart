import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:meditation_friend/app/data/models/music.dart';

import '../../routes/app_pages.dart';
import '../../utils/log.dart';
import '../models/base_response.dart';
import '../models/sign_in_response.dart';
import '../models/00_user.dart';
import '../repository/app_repository.dart';
import 'local_app_data_service.dart';

import 'package:just_audio/just_audio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class AppService extends GetxService {
  final AppRepository _appRepository;
  final LocalAppDataService _localAppDataService;

  final AudioPlayer audioPlayer = AudioPlayer();
  Rx<MeditationFriendUser?> user = Rx<MeditationFriendUser?>(null);
  Rx<bool> isOfflineMode = false.obs;
  DateTime? currentBackPressTime;
  RxList<Music> musicList = <Music>[].obs;
  Rx<Music>? curMusic = Music().obs;
  RxBool isPlaying = false.obs;
  RxInt currentIndex = 0.obs;

  AppService({
    required AppRepository appRepository,
    required LocalAppDataService localAppDataService,
  })  : _appRepository = appRepository,
        _localAppDataService = localAppDataService;
  @override
  Future<void> onInit() async {
    super.onInit();
    audioPlayer.playerStateStream.listen((state) {
      isPlaying.value = state.playing;
    });

    final musics = await _getMusicList();
    musicList.value = musics ?? [];
    curMusic?.value = await getRandomMusic();
    user.value = _localAppDataService.getLastLoginUser();
  }

  Future<String?> getFcmToken() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    String? token = await messaging.getToken();
    return token;
  }

  Future<String?> sendFirebaseToken() async {
    String? fcmToken = await getFcmToken() ?? "";
    print('sendFirebaseToken: ${fcmToken}');
    // 서버에 fcmToken 전송
    fcmToken = await _appRepository.sendFirebaseToken(
      fcmToken: fcmToken,
    );
    return fcmToken;
  }

  Future<void> sendAlaram() async {
    // 권한 확인
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    print('알림 권한 상태: ${settings.authorizationStatus}');

    await _appRepository.sendAlarm();
  }

  clearLastLoginUser() {
    _localAppDataService.clearLastLoginUser();
    user.value = null;
  }

  Future<Music> getRandomMusic() async {
    if (musicList.isNotEmpty) {
      int randomIndex =
          DateTime.now().millisecondsSinceEpoch % musicList.length;
      return musicList[randomIndex];
    } else {
      return Music();
    }
  }

  void onPop(context) {
    // 뒤로가기 두 번 클릭으로 앱 종료하기 기능
    DateTime now = DateTime.now();
    if (currentBackPressTime == null ||
        now.difference(currentBackPressTime!) >
            const Duration(milliseconds: 1500)) {
      currentBackPressTime = now;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("한번 더 누르면 종료됩니다."),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(bottom: 46),
          duration: Duration(milliseconds: 1500),
        ),
      );
    } else {
      SystemNavigator.pop();
    }
  }

  String createId() {
    return DateTime.now().toString().replaceAll(RegExp(r"[\s-:.]"), "");
  }

  // 카카오 로그인
  Future<String?> signIn({
    required String kakaoToken,
    required bool offline,
  }) async {
    isOfflineMode.value = offline;
    String? result;
    SignInResponse? response;

    if (offline) {
      user.value = _localAppDataService.getLastLoginUser();
    } else {
      // 온라인 일경우
      await EasyLoading.show(dismissOnTap: true);
      // 로딩 인디케이터 표시
      BaseResponse? baseResponse = await _appRepository.signIn(
        kakaoToken: kakaoToken,
      );
      if (baseResponse?.result?.code != 200) {
        // 100번이 아닌 경우 에러 발생한 것임
        result = baseResponse?.result?.message;
      } else {
        // 로그인 성공 시 사용자 정보 저장
        response = SignInResponse(
          user: MeditationFriendUser.fromJson(baseResponse?.data?['user']),
        );
        user.value = response.user!;
        // appService에 user정보 저장
        if (user.value != null) {
          // 응답에 사용자에 대한 정보가 있다면
          await _localAppDataService.writeLastLoginUser(user.value!);
        }
        logSuccess(response.user!.toJson(),
            des: 'AppService.signIn($kakaoToken)');
      }
    }
    return result;
  }

  Future<String?> logOut() async {
    String? result;
    try {
      user.value = null;
      currentIndex.value = 0;
      // 1. 로컬 데이터 정리
      await clearLastLoginUser();

      // 2. 서버 로그아웃 요청
      // BaseResponse? baseResponse = await _appRepository.logOut();
      // if (baseResponse?.result?.code != 100) {
      //   result = baseResponse?.result?.message;
      // }

      // 3. 로그인 페이지로 이동
      await Get.offAllNamed(Routes.MEDITATION_HOME);
    } catch (e) {
      print('로그아웃 실패: $e');
      result = '로그아웃 중 오류가 발생했습니다.';
    }

    return result;
  }

  Future<String?> findPw({String? email}) async {
    if (email != null) {
      String? result = await _appRepository.findPw(email: email);
      return result;
    } else {
      return "";
    }
  }

  // 음악 리스트 가져오는 부분
  Future<List<Music>?> _getMusicList() async {
    if (isOfflineMode.value) {
      // 오프라인 일때
      return [];
    } else {
      final musicResult = await _appRepository.searchMusicList();
      return musicResult;
    }
  }
}

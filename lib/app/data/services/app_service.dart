import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:meditation_friend/app/data/models/alaram_time.dart';
import 'package:meditation_friend/app/data/models/music.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../routes/app_pages.dart';
import '../../utils/log.dart';
import '../models/base_response.dart';
import '../models/00_user.dart';
import '../repository/app_repository.dart';
import 'local_app_data_service.dart';

import 'package:just_audio/just_audio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class AppService extends GetxService {
  final AppRepository _appRepository;
  // api 호출하는 리포지토리
  final LocalAppDataService _localAppDataService;
  // Hive를 관리하는 서비스

  AudioPlayer audioPlayer = AudioPlayer();
  // 디코더를 직접 들고 있는 리모컨
  Rx<MeditationFriendUser?> user = Rx<MeditationFriendUser?>(null);
  Rx<bool> isOfflineMode = false.obs;
  DateTime? currentBackPressTime;
  RxList<Music> musicList = <Music>[].obs;
  RxList<String> attendanceList = <String>[].obs;
  Rx<Music>? curMusic = Music().obs;
  RxBool isPlaying = false.obs;
  RxInt currentIndex = 0.obs;
  String fcmToken = '';
  // 현재 재생 중인 음악의 musicList 내 위치

  RxBool isLoading = false.obs;
  // 음악 로딩 상태를 UI에 표시하기 위한 변수
  RxString playerError = ''.obs;

  NotificationSetting notificationSetting = NotificationSetting(
    notifyHour: 9,
    notifyMinute: 0,
    notifyDays: '1111100', // 월~금
    enabled: true,
  );
  AppService({
    required AppRepository appRepository,
    required LocalAppDataService localAppDataService,
  })  : _appRepository = appRepository,
        _localAppDataService = localAppDataService;

  @override
  Future<void> onInit() async {
    super.onInit();
    await initUser(); // 로그인 유저가 없을경우 hive에 저장된 유저로 로그인 시도
    await getAttendanceCheck(); // 출석체크 날짜 가져오기
    initFirebaseMessageHandler(); // Firebase 메시지 핸들러 초기화
    await getNotificationSettings(); // 알림 설정 가져오기
  }

  // user백업
  Future<void> initUser() async {
    if (user.value == null) {
      // getLastLoginUser로 가져온 user만 있고 로그인이 되지는 않은 경우
      MeditationFriendUser? lastUser = _localAppDataService.getLastLoginUser();
      if (lastUser != null) {
        logInfo('유저가 없어요. 예전유저는요 ${lastUser.toJson()}');
        fcmToken = await getFcmToken() ?? "";
        BaseResponse? response = await signInUsingKakao(
          id: lastUser.id.toString(),
          nickname: lastUser.nickname ?? '',
          profileImageUrl: lastUser.profileImageUrl ?? '',
          thumbnailImageUrl: lastUser.thumbnailImageUrl ?? '',
          connectedAt: lastUser.connectedAt,
        );
        logInfo('예전유저로 로그인 완료에요');
        if (response?.result?.code == 200) {
          // AppService에 사용자 정보 저장
          user.value = _localAppDataService.getLastLoginUser();
        }
      }
    }
  }

  // 출석체크 날짜 가져오기
  Future<void> getAttendanceCheck() async {
    if (user.value != null) {
      BaseResponse? baseResponse = await _appRepository.getAttendanceCheck();
      if (baseResponse?.data != null && baseResponse!.data is List) {
        attendanceList.value =
            (baseResponse!.data as List).map((e) => e.toString()).toList();
      }
    }
  }

  void initFirebaseMessageHandler() {
    // 앱이 포그라운드, 백그라운드, 종료 상태일 때 각각 FCM 알림을 수신하고 처리하는 로직

    // 포그라운드: 앱이 현재 화면에 떠 있고, 사용자가 보고 있는 상태
    FirebaseMessaging.onMessage.listen((RemoteMessage? message) {
      if (message != null && message.notification != null) {
        // 푸시 메시지가 실제로 존재하고, 그 안에 notification (알림 제목/내용 등)이 포함되어 있는지 확인
        final notification = message.notification;

        final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
            FlutterLocalNotificationsPlugin();
        // Flutter용 로컬 알림(Local Notification) 플러그인의 클래스
        if (notification != null) {
          flutterLocalNotificationsPlugin.show(
            // 이것을 통해 내부 알림을 표시한다
            0,
            notification.title,
            notification.body,
            NotificationDetails(
              // 로컬 알림의 플랫폼별(안드로이드, iOS 등) 세부 옵션을 담은 객체
              android: AndroidNotificationDetails(
                // Android용 알림 설정을 위한 객체
                'default_channel',
                '명상친구',
                importance: Importance.max, // 알림의 중요도를 설정
                priority: Priority.high,
              ),
            ),
          );
        }
      }
    });

    // 백그라운드에서 푸시 클릭했을 때
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage? message) {
      if (message != null && message.notification != null) {
        print(message.data["click_action"]);
      }
    });

    // 종료 상태에서 푸시 클릭했을 때
    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage? message) {
      if (message != null && message.notification != null) {
        print(message.data["click_action"]);
      }
    });
  }

  Future<String?> getFcmToken() async {
    // 현재 디바이스의 FCM 토큰을 가져오는 역할
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    String? token = await messaging.getToken();
    return token;
  }

  Future<String?> sendFirebaseToken() async {
    String? fcmToken = await getFcmToken() ?? "";
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

    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }
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
  Future<BaseResponse?> signInUsingKakao({
    required id,
    required nickname,
    required profileImageUrl,
    required thumbnailImageUrl,
    connectedAt,
  }) async {
    // 온라인 일경우
    // await EasyLoading.show(dismissOnTap: true);
    // 로딩 인디케이터 표시
    BaseResponse? baseResponse = await _appRepository.signInUsingKakao(
      id: id,
      fcmToken: fcmToken,
      nickname: nickname,
      profileImageUrl: profileImageUrl,
      thumbnailImageUrl: thumbnailImageUrl,
      connectedAt: connectedAt,
    );

    return baseResponse;
  }

  // 출석체크 하는함수
  Future<BaseResponse?> attendanceCheck() async {
    if (user.value != null) {
      BaseResponse? baseResponse = await _appRepository.attendanceCheck();
      return baseResponse;
    }
  }

  // 마이페이지에서 설정한 알람시간
  Future<BaseResponse?> getNotificationSettings() async {
    if (user.value != null) {
      BaseResponse? baseResponse =
          await _appRepository.getNotificationSettings();
      if (baseResponse?.data != null &&
          baseResponse!.data is Map<String, dynamic>) {
        notificationSetting = NotificationSetting.fromJson(
          baseResponse.data as Map<String, dynamic>,
        );
      }
    }
    return null;
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

  // 카테고리별 명상 음악 요청 메서드 (AppService에 추가)
  // 카테고리별 명상 음악 요청 메서드 (HomeController에서 수정)
  Future<List<Music>> fetchMeditationByCategory(String category) async {
    logInfo("카테고리별 명상 음악 요청: $category");
    try {
      // 전체 음악 목록 가져오기
      final allMusic = await _getMusicList();

      if (allMusic != null) {
        // 카테고리로 필터링
        final filteredMusic = category.isEmpty
            ? allMusic // 모든 음악 반환
            : allMusic
                .where((music) => music.category == category)
                .toList(); // 특정 카테고리 필터링

        // 앱 서비스에 저장
        musicList.assignAll(filteredMusic);
        return filteredMusic;
      } else {
        // 에러 처리
        logError("명상 음악 로드 실패");
        Get.snackbar('오류', '인터넷 연결을 확인해주세요.');
        return <Music>[];
      }
    } catch (e) {
      logError("카테고리별 음악 로드 중 예외 발생: $e");
      Get.snackbar('오류', '서버 연결에 문제가 발생했습니다.');
      return <Music>[];
    }
  }

  Future<void> saveAlarmSettings({
    required String alarmDays,
    required int alarmHour,
    required int alarmMinute,
  }) async {
    if (user.value != null) {
      notificationSetting = NotificationSetting(
        notifyDays: alarmDays,
        notifyHour: alarmHour,
        notifyMinute: alarmMinute,
        enabled: true, // 알람 활성화 상태
      );
      await _localAppDataService.saveAlarmSettings(
        alarmDays: alarmDays,
        alarmHour: alarmHour,
        alarmMinute: alarmMinute,
      );

      await _appRepository.saveAlarmSettings(
        alarmDays: alarmDays,
        alarmHour: alarmHour,
        alarmMinute: alarmMinute,
      );
    } else {
      Get.snackbar('오류', '로그인이 필요합니다.');
    }
  }
}

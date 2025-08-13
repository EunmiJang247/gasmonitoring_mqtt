import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:get/get.dart';

import 'app/constant/app_color.dart';
import 'app/data/api/app_api.dart';
import 'app/data/repository/app_repository.dart';
import 'app/data/services/app_service.dart';
import 'app/data/services/local_app_data_service.dart';
import 'app/routes/app_pages.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
// Flutter 앱에서 알림(Local Notification)을 전역적으로 사용하기 위한 인스턴스를 선언하고 초기화하는 코드
// 앱 실행 중에 언제든지 로컬 알림을 띄우기 위함

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Flutter 앱과 엔진 사이의 "바인딩" 초기화

  await dotenv.load(fileName: ".env");
  // .env파일을 사용하기 위함

  HttpOverrides.global = MyHttpOverrides();
  // http 요청 시 SSL 인증 오류를 무시하도록 설정

  await initializeDateFormatting('ko');
  // Flutter 앱에서 날짜/시간을 한국어(로케일: ko) 형식으로 포맷해서 보여주기 위한 준비 작업

  await Firebase.initializeApp();
  // Firebase SDK를 앱에서 사용할 수 있도록 초기 설정을 로드하고 네이티브와 연결하는 함수

  // 4. 알림 설정
  const AndroidInitializationSettings androidInitSettings =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  // 알림이 뜰 때 사용할 기본 아이콘을 지정

  const InitializationSettings initSettings =
      InitializationSettings(android: androidInitSettings);
  // 안드로이드에서 로컬 알림을 띄우기 위한 설정
  // 24번째 줄은 알림 기계를 사온것이고 50줄은 플러그 꽂고 실제 작동가능하게 만든것

  await flutterLocalNotificationsPlugin.initialize(initSettings);
  // flutterLocalNotificationsPlugin 인스턴스에 대해 initSettings 값을 기반으로
  // 알림 기능을 실제 사용할 수 있도록 설정값을 적용

  // ✅ 알림 채널 등록
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'meditation_friend_daily_alarm',
    '🧘 명상친구의 하루 알림',
    importance: Importance.high,
  );

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);
  // 안드로이드에서 알림 채널을 생성하는 코드
  // 채널을 만들지 않으면 Android는 푸시 알림을 무시하거나 표시하지 않을 수 있다

  KakaoSdk.init(nativeAppKey: 'a31ddf410fd27c9e9f0afa5e440756af'); // 네이티브 앱 키
  // 보는페이지: https://developers.kakao.com/console/app/1286297/config
  // final String keyHash = await KakaoSdk.origin;
  // print('키해시: $keyHash'); // 이 값을 복사해두세요

  final localService = await Get.putAsync(() => LocalAppDataService().init());

  final lastUser = localService.getLastLoginUser();
  final hasVisitedBefore = localService.hasVisitedBefore();
  // hive에서 has_visited_before값을 가져옴. 방문한적이 있다면 true, 없다면 false

  // ✅ 유저가 저장되어 있거나 방문기록이 있으면 홈으로 시작, 아니면 스플래시
  final String initialRoute = Routes.MEDITATION_HOME;
  // final String initialRoute = Routes.SPLASH;

  await localService.saveAppVisitState(true);
  // hive에서 has_visited_before값을 true로 저장

  Get.lazyPut<AppAPI>(() => AppAPI());
  // HTTP 요청을 담당하는 API 클래스

  Get.put<AppRepository>(
    AppRepository(appAPI: Get.find<AppAPI>()),
    permanent: true,
  );
  // API를 감싸서 비즈니스 로직을 담당하는 클래스

  Get.put<AppService>(
    AppService(
      appRepository: Get.find<AppRepository>(),
      localAppDataService: Get.find<LocalAppDataService>(),
    ),
    permanent: true,
  );
  // 앱 로직을 총괄하는 상위 서비스 계층

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  await SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  // 앱 화면을 완전히 전체화면으로 만듬
  // portraitUp = 화면을 똑바로 들었을 때
  // portraitDown = 화면을 거꾸로 들었을 때
  // 가로모드는 비활성화

  runApp(
    ScreenUtilInit(
        designSize: const Size(360, 690),
        // 앱의 디자인 기준 사이즈를 설정해 주고, 디바이스 해상도에 맞춰 자동으로 크기를 조정해주는 역할
        builder: (BuildContext context, Widget? child) {
          return GetMaterialApp(
            // GETX 패키지를 사용하여 앱을 구성하는 위젯
            debugShowCheckedModeBanner: false,
            // 오른쪽 상단 DEBUG 리본을 숨기기 위해서
            title: "meditationFriend",
            locale: const Locale('ko'),
            supportedLocales: const [
              Locale('ko'),
              Locale('en'),
            ],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              // Material 위젯 (예: 버튼, 다이얼로그, 날짜 선택 등)의 다국어 번역 지원
              GlobalWidgetsLocalizations.delegate,
              // 기본 Widget의 레이아웃 방향(LTR/RTL), 텍스트 정렬 등 지원
              GlobalCupertinoLocalizations.delegate,
              // iOS 스타일의 Cupertino 위젯
            ],
            initialRoute: initialRoute,
            getPages: AppPages.routes,
            theme: ThemeData(
              fontFamily: "Pretendard",
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              scaffoldBackgroundColor: Colors.white,
              appBarTheme: const AppBarTheme(
                systemOverlayStyle: SystemUiOverlayStyle.dark,
                titleTextStyle: TextStyle(
                  fontFamily: "Pretendard",
                  fontWeight: FontWeight.w600,
                  fontSize: 20,
                  color: Colors.black,
                ),
              ),
              scrollbarTheme: ScrollbarThemeData(
                  thickness: WidgetStatePropertyAll(8),
                  thumbColor: WidgetStatePropertyAll(AppColors.kOrange),
                  radius: Radius.circular(4)),
            ),
            builder: EasyLoading.init(),
          );
        }),
  );
}

class MyHttpOverrides extends HttpOverrides {
  // 모든 SSL 인증 오류를 무시하도록 설정
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

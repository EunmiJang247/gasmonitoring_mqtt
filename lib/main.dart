import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:get/get.dart';
import 'package:meditation_friend/app/utils/log.dart';

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
    FlutterLocalNotificationsPlugin(); // ✅ 글로벌 플러그인 인스턴스

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("🔔 [백그라운드 메시지 수신]: ${message.notification?.title}");
  // 여기서 로컬 알림 띄우기도 가능함
}

Future<void> main() async {
  // 1. Flutter 바인딩 초기화
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  // 2. 기본 설정 초기화
  await dotenv.load(fileName: ".env");
  HttpOverrides.global = MyHttpOverrides();
  await initializeDateFormatting('ko');

  // 3. 필수 서비스 초기화
  await Firebase.initializeApp();
  final localService = await Get.putAsync(() => LocalAppDataService().init());

  // 4. 알림 설정
  const AndroidInitializationSettings androidInitSettings =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initSettings =
      InitializationSettings(android: androidInitSettings);

  await flutterLocalNotificationsPlugin.initialize(initSettings);

  // ✅ 알림 채널 등록
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'meditation_friend_daily_alarm', // ⚠️ 여기와 알림 생성 시 ID 일치해야 함
    '기본 채널',
    importance: Importance.high,
  );

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel); // ✅ 채널 생성 누락된 부분

  // ✅ 백그라운드 메시지 핸들러 등록
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  KakaoSdk.init(nativeAppKey: '41fc802ab8a066fcc2b3016fb2c5fb98'); // 네이티브 앱 키
  // final String keyHash = await KakaoSdk.origin;
  // print('키해시: $keyHash'); // 이 값을 복사해두세요

  final lastUser = localService.getLastLoginUser();
  final hasVisitedBefore = localService.hasVisitedBefore();

  // ✅ 유저가 저장되어 있거나 방문기록이 있으면 홈으로 시작, 아니면 스플래시
  final String initialRoute = (lastUser != null || hasVisitedBefore)
      ? Routes.MEDITATION_HOME
      : Routes.SPLASH;

  await localService.saveAppVisitState(true);
  Get.lazyPut<AppAPI>(() => AppAPI());

  Get.put<AppRepository>(
    AppRepository(appAPI: Get.find<AppAPI>()),
    permanent: true,
  );

  Get.put<AppService>(
    AppService(
      appRepository: Get.find<AppRepository>(),
      localAppDataService: Get.find<LocalAppDataService>(),
    ),
    permanent: true,
  );

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  await SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

  runApp(
    ScreenUtilInit(
        designSize: const Size(360, 690),
        builder: (BuildContext context, Widget? child) {
          return GetMaterialApp(
            title: "meditationFriend",
            locale: const Locale('ko'),
            supportedLocales: const [
              Locale('ko'),
              Locale('en'),
            ],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
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

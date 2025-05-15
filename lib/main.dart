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
import 'package:kakao_flutter_sdk_common/kakao_flutter_sdk_common.dart';
import 'package:firebase_core/firebase_core.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env");

  HttpOverrides.global = MyHttpOverrides();

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // 💥 여기가 꼭 필요해
  await initializeDateFormatting('ko');
  KakaoSdk.init(nativeAppKey: '41fc802ab8a066fcc2b3016fb2c5fb98'); // 네이티브 앱 키
  // final String keyHash = await KakaoSdk.origin;
  // print('키해시: $keyHash'); // 이 값을 복사해두세요

  Get.put<LocalAppDataService>(
    LocalAppDataService(),
    permanent: true,
  );

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
            initialRoute: AppPages.INITIAL,
            getPages: AppPages.routes,
            theme: ThemeData(
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

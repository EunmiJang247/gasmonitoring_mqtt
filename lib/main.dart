import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:get/get.dart';
import 'package:safety_check/app/data/services/local_gallery_data_service.dart';

import 'app/constant/app_color.dart';
import 'app/data/api/app_api.dart';
import 'app/data/repository/app_repository.dart';
import 'app/data/services/app_service.dart';
import 'app/data/services/local_app_data_service.dart';
import 'app/routes/app_pages.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env");

  HttpOverrides.global = MyHttpOverrides();

  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  Get.put<LocalAppDataService>(
    LocalAppDataService(),
    permanent: true,
  );

  Get.put<LocalGalleryDataService>(
    LocalGalleryDataService(),
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
      localGalleryDataService: Get.find<LocalGalleryDataService>(),
    ),
    permanent: true,
  );
  //AppService 인스턴스를 만들고 메모리에 한 번 생성
  // GetX의 DI 컨테이너에 전역으로 등록.
  // permanent: true 덕분에 앱이 꺼지기 전까지 절대 Dispose 되지 않아.
  // → 즉, 앱 전 생애 주기 동안 살아있는 진짜 전역 객체야

  // AppService는 이미 전역으로 등록했는데, 왜 LoginBinding에서 또 설정하냐?
  // 바인딩에서는 AppService를 주입하는 게 아니라, 이미 등록된 인스턴스를 찾아서 LoginController에 “의존성 주입”하는 거야
  // 페이지가 바뀔 때 마다 재등록/해제가 번거로움 → Binding이 자동으로 해줘서 편한 거야

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  await SystemChrome.setPreferredOrientations(
      [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);

  runApp(
    ScreenUtilInit(
        designSize: const Size(360, 690),
        builder: (BuildContext context, Widget? child) {
          return GetMaterialApp(
            title: "Application",
            initialRoute: AppPages.INITIAL,
            getPages: AppPages.routes,
            defaultTransition: Transition.rightToLeftWithFade,
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
                  thumbColor: WidgetStatePropertyAll(AppColors.c4),
                  radius: Radius.circular(4)),
            ),
            builder: EasyLoading.init(),
          );
        }),
  );
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

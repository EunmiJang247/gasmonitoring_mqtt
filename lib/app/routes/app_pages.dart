import 'package:get/get.dart';
import 'package:safety_check/app/modules/meditation_home/bindings/meditation_home_binding.dart';
import 'package:safety_check/app/modules/meditation_home/view/meditation_home.dart';
import 'package:safety_check/app/modules/music_detail/bindings/music_detail_binding.dart';
import 'package:safety_check/app/modules/music_detail/views/music_detail.dart';
import '../modules/find_pw/bindings/find_pw_binding.dart';
import '../modules/find_pw/views/find_pw_view.dart';
import '../modules/login/bindings/login_binding.dart';
import '../modules/login/views/login_view.dart';
import '../modules/splash/bindings/splash_binding.dart';
import '../modules/splash/views/splash_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  // ignore: constant_identifier_names
  static const INITIAL = Routes.SPLASH;

  static final routes = [
    GetPage(
      name: _Paths.SPLASH,
      page: () => const UpdateScreen(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: _Paths.LOGIN, // 1. 경로 이름
      page: () => const LoginView(), // 2. 진입할 페이지 (View)
      binding: LoginBinding(), // 3. 페이지 로드시 실행할 바인딩 클래스
      // LoginView로 진입할 때, GetX가 먼저 LoginBinding의 dependencies()를 실행해.
      // 그래서 이 View에서 사용될 컨트롤러들이 메모리에 등록돼 있는 상태가 되는 거야.
    ),
    GetPage(
      name: _Paths.FIND_PW,
      page: () => const FindPwView(),
      binding: FindPwBinding(),
    ),
    GetPage(
      name: _Paths.MEDITATION_HOME,
      page: () => const MeditationHome(),
      binding: MeditationHomeBinding(),
    ),
    GetPage(
      name: _Paths.MUSIC_DETAIL,
      page: () => const MusicDetailView(),
      binding: MusicDetailBinding(),
    ),
  ];
}

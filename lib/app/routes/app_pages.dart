import 'package:get/get.dart';
import 'package:meditation_friend/app/modules/calendar/binding/calendar_binding.dart';
import 'package:meditation_friend/app/modules/calendar/views/calendar_view.dart';
import 'package:meditation_friend/app/modules/meditation_home/bindings/meditation_home_binding.dart';
import 'package:meditation_friend/app/modules/meditation_home/view/meditation_home.dart';
import 'package:meditation_friend/app/modules/music_detail/bindings/music_detail_binding.dart';
import 'package:meditation_friend/app/modules/music_detail/views/music_detail.dart';
import 'package:meditation_friend/app/modules/mypage/bindings/mypage_binding.dart';
import 'package:meditation_friend/app/modules/mypage/views/mypage_view.dart';
import '../modules/splash/bindings/splash_binding.dart';
import '../modules/splash/views/splash_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  // ignore: constant_identifier_names
  // static const INITIAL = Routes.SPLASH;

  static final routes = [
    GetPage(
      name: _Paths.SPLASH,
      page: () => const SplashView(),
      binding: SplashBinding(),
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
    GetPage(
      name: _Paths.MYPAGE,
      page: () => const MypageView(),
      binding: MypageBinding(),
    ),
    GetPage(
      name: _Paths.CALENDAR,
      page: () => const CalendarView(),
      binding: CalendarBinding(),
    ),
  ];
}

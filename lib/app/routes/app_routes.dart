// ignore_for_file: constant_identifier_names

part of 'app_pages.dart';

abstract class Routes {
  Routes._();
  static const HOME = _Paths.HOME;
  static const LOGIN = _Paths.LOGIN;
  static const FIND_PW = _Paths.FIND_PW;
  static const SPLASH = _Paths.SPLASH;
  static const MEDITATION_HOME = _Paths.MEDITATION_HOME;
  static const MUSIC_DETAIL = _Paths.MUSIC_DETAIL;
  static const MYPAGE = _Paths.MYPAGE;
  static const CALENDAR = _Paths.CALENDAR;
}

abstract class _Paths {
  _Paths._();
  static const HOME = '/home';
  static const LOGIN = '/login';
  static const FIND_PW = '/find-pw';
  static const SPLASH = '/splash';
  static const MEDITATION_HOME = '/meditation-home';
  static const MUSIC_DETAIL = '/music-detail';
  static const MYPAGE = '/mypage';
  static const CALENDAR = '/caldendar';
}

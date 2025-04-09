import 'package:get/get.dart';
import 'package:safety_check/app/modules/project_checks/bindings/project_checks_binding.dart';
import 'package:safety_check/app/modules/project_info/bindings/project_info_binding.dart';
import 'package:safety_check/app/modules/project_checks/view/project_checks_view.dart';
import 'package:safety_check/app/modules/project_info/views/project_info_view.dart';

import '../modules/check_image/bindings/check_imgage_binding.dart';
import '../modules/check_image/views/check_image_view.dart';
import '../modules/drawing_detail/bindings/drawing_detail_binding.dart';
import '../modules/drawing_detail/views/drawing_detail_view.dart';
import '../modules/drawing_list/bindings/drawing_list_binding.dart';
import '../modules/drawing_list/views/drawing_list_view.dart';
import '../modules/find_pw/bindings/find_pw_binding.dart';
import '../modules/find_pw/views/find_pw_view.dart';
import '../modules/login/bindings/login_binding.dart';
import '../modules/login/views/login_view.dart';
import '../modules/project_gallery/bindings/project_gallery_binding.dart';
import '../modules/project_gallery/views/project_gallery_view.dart';
import '../modules/project_list/bindings/project_list_binding.dart';
import '../modules/project_list/views/project_list_view.dart';
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
      name: _Paths.LOGIN,
      page: () => const LoginView(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: _Paths.FIND_PW,
      page: () => const FindPwView(),
      binding: FindPwBinding(),
    ),
    GetPage(
      name: _Paths.PROJECT_INFO,
      page: () => const ProjectInfoView(),
      binding: ProjectInfoBinding(),
    ),
    GetPage(
      name: _Paths.PROJECT_LIST,
      page: () => const ProjectListView(),
      binding: ProjectListBinding(),
    ),
    GetPage(
      name: _Paths.PROJECT_CHECK_LIST,
      page: () => const CheckList(),
      binding: ProjectChecksBinding(),
    ),
    GetPage(
      name: _Paths.DRAWING_LIST,
      page: () => const DrawingListView(),
      binding: DrawingListBinding(),
    ),
    GetPage(
      name: _Paths.PROJECT_GALLERY,
      page: () => const ProjectGalleryView(),
      binding: ProjectGalleryBinding(),
    ),
    GetPage(
      name: _Paths.DRAWING_DETAIL,
      page: () => const DrawingDetailView(),
      binding: DrawingDetailBinding(),
    ),
    GetPage(
      name: _Paths.CHECK_IMGAGE,
      page: () => const CheckImageView(),
      binding: CheckImageBinding(),
    ),
  ];
}

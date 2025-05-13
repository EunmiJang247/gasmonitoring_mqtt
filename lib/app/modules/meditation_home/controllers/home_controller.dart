import 'package:get/get.dart';
import 'package:meditation_friend/app/data/services/app_service.dart';
import 'package:meditation_friend/app/routes/app_pages.dart';

class HomeController extends GetxController {
  final AppService appService;
  HomeController({required this.appService});

  // 프로젝트 선택 = > 프로젝트 정보 페이지로 이동
  onMusicListen() {
    Get.toNamed(Routes.MUSIC_DETAIL);
  }

  // 출석체크
  onAttendanceCheck() {
    // 출석체크 API 호출
  }
}

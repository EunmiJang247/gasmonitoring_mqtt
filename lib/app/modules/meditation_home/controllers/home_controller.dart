import 'package:get/get.dart';
import 'package:meditation_friend/app/data/services/app_service.dart';
import 'package:meditation_friend/app/routes/app_pages.dart';

class HomeController extends GetxController {
  final AppService appService;
  HomeController({required this.appService});

  @override
  void onInit() {
    super.onInit();
    _initializeAttendance();
  }

  Future<void> _initializeAttendance() async {
    // 출석체크 하기
    // logInfo("user는요 ${appService.user.toJson()}");
    await appService.attendanceCheck();
    await appService.getAttendanceCheck();
  }

  // 프로젝트 선택 = > 프로젝트 정보 페이지로 이동
  onMusicListen() {
    Get.toNamed(Routes.MUSIC_DETAIL);
  }

  onAttendanceCheck() {
    Get.toNamed(Routes.CALENDAR);
  }
}

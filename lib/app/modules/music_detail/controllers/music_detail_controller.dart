import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:safety_check/app/data/models/music.dart';
import 'package:safety_check/app/data/services/app_service.dart';
import 'package:safety_check/app/utils/log.dart';

class MusicDetailController extends GetxController {
  MusicDetailController({required this.appService});
  final AppService appService;

  // 현재 음악 가져오기
  Music? get currentMusic => appService.curMusic?.value;

  // 음악 재생 관련 메서드들
  Future<void> playMusic() async {
    logInfo("재생!");
    if (currentMusic?.musicUrl != null) {
      final apiBaseUrl = dotenv.env['DEV_BASE_URL_WT_API'];
      final url = '${apiBaseUrl}${currentMusic!.musicUrl}';

      // 디버깅을 위한 상세 로깅 추가
      logInfo('Current Music: ${currentMusic?.toJson()}');
      logInfo('API Base URL: $apiBaseUrl');
      logInfo('Full URL: $url');

      try {
        await appService.audioPlayer.setUrl(url);
        await appService.audioPlayer.play();
        logInfo('재생 상태: ${appService.audioPlayer.playing}');
      } catch (e) {
        logInfo('재생 오류: $e');
      }
    }
  }

  void pauseMusic() {
    appService.audioPlayer.pause();
  }

  void stopMusic() {
    appService.audioPlayer.stop();
  }
}

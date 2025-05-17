import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:meditation_friend/app/data/models/music.dart';
import 'package:meditation_friend/app/data/services/app_service.dart';
import 'package:meditation_friend/app/utils/log.dart';

class MusicDetailController extends GetxController {
  MusicDetailController({required this.appService});
  final AppService appService;

  // 현재 음악 가져오기
  Rx<Music?> get currentMusic => appService.curMusic ?? Rx<Music?>(null);
  RxBool get isPlaying => appService.isPlaying;

  // 다음곡 재생
  Future<void> playNextMusic() async {
    try {
      // 1. 새로운 음악 가져오기
      var newMusic = await appService.getRandomMusic();
      logInfo('다음 곡: ${newMusic.toJson()}');

      // 2. 현재 음악 업데이트
      appService.curMusic?.value = newMusic;

      // 3. 새로운 음악 재생
      if (newMusic.musicUrl != null) {
        final apiBaseUrl = dotenv.env['DEV_BASE_URL_WT_API'];
        final url = '$apiBaseUrl${newMusic.musicUrl}';

        // 현재 재생 중인 음악 중지
        await appService.audioPlayer.stop();

        // 새로운 음악 설정 및 재생
        await appService.audioPlayer.setUrl(url);
        await appService.audioPlayer.play();

        logInfo('새로운 음악 재생 시작: ${newMusic.title}');
      } else {
        logInfo('음악 URL이 없습니다');
      }
    } catch (e) {
      logInfo('다음 곡 재생 오류: $e');
    }
  }

  // 음악 재생
  Future<void> playMusic() async {
    if (currentMusic.value?.musicUrl != null) {
      final apiBaseUrl = dotenv.env['DEV_BASE_URL_WT_API'];
      final url = '$apiBaseUrl${currentMusic.value?.musicUrl}';
      try {
        await appService.audioPlayer.setUrl(url);
        await appService.audioPlayer.play();
        appService.isPlaying.value = appService.audioPlayer.playing;
      } catch (e) {
        logInfo('재생 오류: $e');
      }
    }
  }

  // 음악 일시정지
  void pauseMusic() {
    appService.audioPlayer.pause();
    appService.isPlaying.value = appService.audioPlayer.playing;
  }

  Future<void> stopMusic() async {
    try {
      // 1. 음악 정지
      await appService.audioPlayer.stop();
      // 2. 위치를 처음으로 되돌림
      await appService.audioPlayer.seek(Duration.zero);
      logInfo('음악 정지 및 위치 초기화');
    } catch (e) {
      logInfo('음악 정지 오류: $e');
    }
  }
}

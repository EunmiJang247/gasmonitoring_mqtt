import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:meditation_friend/app/data/models/music.dart';
import 'package:meditation_friend/app/data/services/app_service.dart';
import 'package:meditation_friend/app/utils/log.dart';

class MusicDetailController extends GetxController {
  MusicDetailController({required this.appService});
  final AppService appService;

  RxString category = ''.obs;

  // 현재 음악 가져오기
  Rx<Music?> get currentMusic => appService.curMusic ?? Rx<Music?>(null);
  RxBool get isPlaying => appService.isPlaying;

  @override
  void onClose() {
    // URL 추적 변수만 초기화 (실제 음악 상태는 유지)
    _currentLoadedUrl = null;
    super.onClose();
  }

  @override
  void onInit() {
    turnOnMusic();
    super.onInit();

    // 현재 재생 중인 음악이 있으면 URL 동기화
    if (appService.curMusic?.value.musicUrl != null) {
      final apiBaseUrl = dotenv.env['DEV_BASE_URL_WT_API'];
      _currentLoadedUrl = '$apiBaseUrl${appService.curMusic?.value?.musicUrl}';
      logInfo('페이지 재진입 - 현재 음악 URL 동기화: $_currentLoadedUrl');
    }
  }

  Future<void> turnOnMusic() async {
    final args = Get.arguments;
    logInfo("받은 arguments: $args");
    if (args != null && args is Map<String, dynamic>) {
      // 카테고리 정보 추출
      category.value = args['category'] ?? '';
      final continueCurrent = args['continue_current'] ?? false;

      if (continueCurrent) {
        // 재생중이었던 음악이 있으면
        if (appService.curMusic?.value != null) {
          // 이미 로드된 음악이 있으면 그대로 사용
          logInfo('이전 음악 계속 재생: ${appService.curMusic?.value.title}');
          return; // 이미 로드된 음악이 있으므로 추가 로딩 불필요
        }
      } else {
        // 현재 재생되고 있던 음악이 없으면
        logInfo("처리할 카테고리: ${category.value}");
        await loadMusicByCategory(category.value);
      }
    }
  }

  // 카테고리별 음악 로드
  Future<void> loadMusicByCategory(String category) async {
    try {
      logInfo("카테고리 음악 로드 시작: $category");
      // AppService를 통해 해당 카테고리의 음악 요청
      final musicList = await appService.fetchMeditationByCategory(category);

      if (musicList.isNotEmpty) {
        // 음악 리스트 업데이트
        appService.musicList.value = musicList;

        // 첫 번째 음악을 현재 음악으로 설정
        appService.curMusic?.value = musicList.first;

        logInfo('${category} 카테고리 음악 ${musicList.length}개 로드 완료');
      } else {
        logError('${category} 카테고리에 음악이 없습니다');
        // Get.snackbar('알림', '해당 카테고리에 음악이 없습니다');
        appService.curMusic?.value = Music();
      }
    } catch (e) {
      logError('카테고리 음악 로드 오류: $e');
      Get.snackbar('오류', '음악을 불러오는 중 문제가 발생했습니다');
    } finally {}
  }

  // 다음곡 재생
  Future<void> playNextMusic() async {
    try {
      // 1. 새로운 음악 가져오기
      var newMusic = await appService.getRandomMusic();

      // 2. 현재 재생 중인 음악 정지
      await appService.audioPlayer.stop();

      // 3. 현재 음악 업데이트
      appService.curMusic?.value = newMusic;

      // 4. 새로운 음악 재생
      if (newMusic.musicUrl != null) {
        final apiBaseUrl = dotenv.env['DEV_BASE_URL_WT_API'];
        final url = '$apiBaseUrl${newMusic.musicUrl}';

        // 약간의 지연을 주어 상태가 정리되도록 함
        await Future.delayed(Duration(milliseconds: 100));

        // URL이 변경되었으므로 반드시 setUrl 호출
        logInfo('다음곡 URL 설정: $url');
        await appService.audioPlayer.setUrl(url);
        _currentLoadedUrl = url;

        await appService.audioPlayer.play();
        logInfo('새로운 음악 재생 시작: ${newMusic.title}');
      } else {
        logInfo('음악 URL이 없습니다');
      }
    } catch (e) {
      logInfo('다음 곡 재생 오류: $e');
      _currentLoadedUrl = null; // 오류 시 URL 초기화
    }
  }

  // 음악 재생
  String? _currentLoadedUrl; // 현재 로드된 URL 추적
  Future<void> playMusic() async {
    if (currentMusic.value?.musicUrl != null) {
      final apiBaseUrl = dotenv.env['DEV_BASE_URL_WT_API'];
      final url = '$apiBaseUrl${currentMusic.value?.musicUrl}';

      try {
        // 현재 로드된 URL과 다른 경우에만 setUrl 호출
        if (_currentLoadedUrl != url) {
          logInfo('새로운 URL 설정: $url');
          await appService.audioPlayer.setUrl(url);
          _currentLoadedUrl = url;
        } else {
          logInfo('동일한 URL이므로 setUrl 스킵: $url');
        }

        await appService.audioPlayer.play();
        logInfo('음악 재생 시작');
      } catch (e) {
        logInfo('재생 오류: $e');
      }
    }
  }

  // 음악 일시정지
  Future<void> pauseMusic() async {
    try {
      await appService.audioPlayer.pause();
      logInfo('음악 일시정지');
    } catch (e) {
      logInfo('일시정지 오류: $e');
    }
  }
}

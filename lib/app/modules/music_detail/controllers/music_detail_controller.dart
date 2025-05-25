import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:meditation_friend/app/data/models/music.dart';
import 'package:meditation_friend/app/data/services/app_service.dart';
import 'package:meditation_friend/app/utils/log.dart';

class MusicDetailController extends GetxController {
  MusicDetailController({required this.appService});
  final AppService appService;

  // 상태 변수들
  RxBool isLoading = true.obs;
  RxString category = ''.obs;

  // 현재 음악 가져오기
  Rx<Music?> get currentMusic => appService.curMusic ?? Rx<Music?>(null);
  RxBool get isPlaying => appService.isPlaying;

  @override
  void onInit() {
    super.onInit();
    // 빌드 사이클 후에 실행되도록 스케줄링
    Future.microtask(() => _processArguments());
  }

  // 넘겨받은 인자 처리
  void _processArguments() async {
    final args = Get.arguments;

    if (args != null && args is Map<String, dynamic>) {
      // 카테고리 정보 추출
      category.value = args['category'] ?? '';
      final continueCurrent = args['continue_current'] ?? false;

      logInfo('카테고리 수신: ${category.value}, 계속 재생: $continueCurrent');

      // 현재 음악 계속 재생 여부 확인
      if (continueCurrent == true && appService.curMusic?.value != null) {
        // 이미 로드된 음악이 있으면 그대로 사용
        isLoading.value = false;
        logInfo('이전 음악 계속 재생: ${appService.curMusic?.value.title}');

        // 재생 중이었다면 계속 재생
        if (appService.isPlaying.value) {
          // 이미 재생 중이므로 별도 조치 불필요
        } else {
          // 일시정지 상태였다면 그대로 유지
        }
      }
      // 카테고리가 있고 계속 재생이 아니면 해당 카테고리 음악 로드
      else if (category.value.isNotEmpty) {
        await loadMusicByCategory(category.value);
      }
      // 그 외의 경우는 기본 음악 로드
      else {
        await loadDefaultMusic();
      }
    } else {
      // 인자가 없으면 기본 음악 로드
      await loadDefaultMusic();
    }
  }

  // 카테고리별 음악 로드
  Future<void> loadMusicByCategory(String category) async {
    try {
      isLoading.value = true;

      // AppService를 통해 해당 카테고리의 음악 요청
      final musicList = await appService.fetchMeditationByCategory(category);
      if (musicList.isNotEmpty) {
        // 음악 리스트 업데이트
        appService.musicList.assignAll(musicList);

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
    } finally {
      isLoading.value = false;
    }
  }

  // 기본 음악 로드 (카테고리 정보가 없을 때)
  Future<void> loadDefaultMusic() async {
    try {
      isLoading.value = true;
      // 임의의 음악 로드
      final music = await appService.getRandomMusic();
      appService.curMusic?.value = music;
      logInfo('기본 음악 로드 완료: ${music.title}');
    } catch (e) {
      logError('기본 음악 로드 오류: $e');
      Get.snackbar('오류', '음악을 불러오는 중 문제가 발생했습니다');
    } finally {
      isLoading.value = false;
    }
  }

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

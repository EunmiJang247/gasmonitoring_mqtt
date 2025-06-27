import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:meditation_friend/app/data/models/music.dart';
import 'package:meditation_friend/app/data/services/app_service.dart';
import 'package:meditation_friend/app/utils/log.dart';

class MusicDetailController extends GetxController {
  MusicDetailController({required this.appService});
  final AppService appService;

  RxString category = ''.obs;
  String? _currentLoadedUrl;
  bool _isChangingMusic = false; // 음악 변경 중 플래그

  // 현재 음악 가져오기
  Rx<Music?> get currentMusic => appService.curMusic ?? Rx<Music?>(null);
  RxBool get isPlaying => appService.isPlaying;
  RxBool get isLoading => appService.isLoading;
  RxString get playerError => appService.playerError;

  @override
  void onInit() {
    super.onInit();
    // 로그 추가로 진입점 확인
    logInfo("MusicDetailController onInit 호출됨");

    // 지연 호출로 의존성이 모두 준비된 후 실행
    WidgetsBinding.instance.addPostFrameCallback((_) {
      turnOnMusic();
    });

    // 현재 재생 중인 음악이 있으면 URL 동기화
    if (appService.curMusic?.value.musicUrl != null) {
      final apiBaseUrl = dotenv.env['DEV_BASE_URL_WT_API'];
      _currentLoadedUrl = '$apiBaseUrl${appService.curMusic?.value.musicUrl}';
      logInfo('페이지 재진입 - 현재 음악 URL 동기화: $_currentLoadedUrl');
    }
  }

  @override
  void onClose() {
    _currentLoadedUrl = null;
    _isChangingMusic = false;
    super.onClose();
  }

  // 음악 재생
  Future<void> playMusic() async {
    if (_isChangingMusic) {
      logInfo('음악 변경 중이므로 재생 요청 무시');
      return;
    }

    if (currentMusic.value?.musicUrl != null) {
      final apiBaseUrl = dotenv.env['DEV_BASE_URL_WT_API'];
      final url = '$apiBaseUrl${currentMusic.value?.musicUrl}';

      try {
        _isChangingMusic = true;
        appService.playerError.value = '';

        // 현재 로드된 URL과 다른 경우에만 setUrl 호출
        if (_currentLoadedUrl != url) {
          logInfo('새로운 URL 설정: $url');
          await appService.audioPlayer.setUrl(url);
          _currentLoadedUrl = url;
        } else {
          logInfo('동일한 URL이므로 setUrl 스킵: $url');
        }

        await appService.audioPlayer.play();
      } catch (e) {
        logError('재생 오류: $e');
        appService.playerError.value = e.toString();
        _currentLoadedUrl = null;
      } finally {
        _isChangingMusic = false;
      }
    }
  }

  // 안전한 URL 설정
  Future<void> _safeSetUrl(String url) async {
    try {
      // 현재 재생 중이면 정지
      if (appService.audioPlayer.playing) {
        await appService.audioPlayer.stop();
      }

      // 잠시 대기 (리소스 정리)
      await Future.delayed(Duration(milliseconds: 200));

      // URL 설정 시도
      await appService.audioPlayer.setUrl(url).timeout(
        Duration(seconds: 10),
        onTimeout: () {
          throw TimeoutException('URL 로딩 시간 초과', Duration(seconds: 10));
        },
      );

      logInfo('URL 설정 완료: $url');
    } catch (e) {
      logError('URL 설정 오류: $e');
      throw e;
    }
  }

  // 음악 일시정지
  Future<void> pauseMusic() async {
    if (_isChangingMusic) {
      logInfo('음악 변경 중이므로 일시정지 요청 무시');
      return;
    }

    try {
      await appService.audioPlayer.pause();
      logInfo('음악 일시정지');
    } catch (e) {
      logError('일시정지 오류: $e');
      appService.playerError.value = e.toString();
    }
  }

  // 다음곡 재생 (개선)
  Future<void> playNextMusic() async {
    if (_isChangingMusic) {
      logInfo('음악 변경 중이므로 다음곡 요청 무시');
      return;
    }

    try {
      _isChangingMusic = true;
      appService.playerError.value = '';

      // 1. 새로운 음악 가져오기
      var newMusic = await appService.getRandomMusic();
      if (newMusic.musicUrl == null) {
        throw Exception('새로운 음악 URL이 없습니다');
      }

      // 2. 현재 재생 중인 음악 안전하게 정지
      await _safeStop();

      // 3. 현재 음악 업데이트
      appService.curMusic?.value = newMusic;

      // 4. 새로운 음악 재생
      final apiBaseUrl = dotenv.env['DEV_BASE_URL_WT_API'];
      final url = '$apiBaseUrl${newMusic.musicUrl}';

      await _safeSetUrl(url);
      _currentLoadedUrl = url;

      await appService.audioPlayer.play();
      logInfo('새로운 음악 재생 시작: ${newMusic.title}');
    } catch (e) {
      logError('다음 곡 재생 오류: $e');
      appService.playerError.value = e.toString();
      _currentLoadedUrl = null;
    } finally {
      _isChangingMusic = false;
    }
  }

  // 안전한 정지
  Future<void> _safeStop() async {
    try {
      if (appService.audioPlayer.playing) {
        await appService.audioPlayer.stop();
      }
      await appService.audioPlayer.seek(Duration.zero);
      await Future.delayed(Duration(milliseconds: 100));
      _currentLoadedUrl = null;
    } catch (e) {
      logError('안전 정지 오류: $e');
    }
  }

  // 카테고리 변경 (개선)
  Future<void> changeCategory(String newCategory) async {
    if (_isChangingMusic) {
      logInfo('음악 변경 중이므로 카테고리 변경 요청 무시');
      return;
    }

    try {
      _isChangingMusic = true;
      logInfo('카테고리 변경: $newCategory');

      await _safeStop();
      category.value = newCategory;
      await loadMusicByCategory(newCategory);

      logInfo('카테고리 변경 완료: $newCategory');
    } catch (e) {
      logError('카테고리 변경 오류: $e');
      appService.playerError.value = e.toString();
    } finally {
      _isChangingMusic = false;
    }
  }

  // 첫 번째 음악 재생 (개선)
  Future<void> _playFirstMusic(Music music) async {
    try {
      if (music.musicUrl != null) {
        final apiBaseUrl = dotenv.env['DEV_BASE_URL_WT_API'];
        final url = '$apiBaseUrl${music.musicUrl}';

        await Future.delayed(Duration(milliseconds: 200));
        await _safeSetUrl(url);
        _currentLoadedUrl = url;

        await appService.audioPlayer.play();
        logInfo('첫 번째 음악 자동 재생 시작: ${music.title}');
      } else {
        throw Exception('첫 번째 음악의 URL이 없습니다');
      }
    } catch (e) {
      logError('첫 번째 음악 재생 오류: $e');
      appService.playerError.value = e.toString();
      _currentLoadedUrl = null;
    }
  }

  Future<void> turnOnMusic() async {
    logInfo("계속 들어와야 하는거 아닌가?");
    final args = Get.arguments;
    if (args != null && args is Map<String, dynamic>) {
      // 카테고리 정보 추출
      category.value = args['category'] ?? '';
      final continueCurrent = args['continue_current'] ?? false;
      logInfo("continueCurrent: $continueCurrent");

      if (continueCurrent) {
        // 재생중이었던 음악이 있으면
        if (appService.curMusic?.value != null) {
          // 이미 로드된 음악이 있으면 그대로 사용
          logInfo('이전 음악 계속 재생: ${appService.curMusic?.value.title}');
          return; // 이미 로드된 음악이 있으므로 추가 로딩 불필요
        }
      } else {
        logInfo("여긴데요?");
        // 현재 재생 중인 음악이 있으면 중지
        if (appService.curMusic?.value != null) {
          await appService.audioPlayer.stop();
          await appService.audioPlayer.seek(Duration.zero);
          _currentLoadedUrl = null; // URL 추적 변수 초기화
          logInfo("이전 음악 중지: ${appService.curMusic?.value.title}");
        }

        // 새 카테고리 음악 로드
        logInfo("새 카테고리 음악 로드: ${category.value}");
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

      logInfo('음악 재생 요청: ${musicList}');
      if (musicList.isNotEmpty) {
        // 음악 리스트가 있으면 musicList에 업데이트
        appService.musicList.value = musicList;
        // 첫 번째 음악을 현재 음악으로 설정
        appService.curMusic?.value = musicList.first;

        // 첫 번째 음악 자동 재생 시작
        await _playFirstMusic(musicList.first);

        logInfo('${category} 카테고리 음악 ${musicList.length}개 로드 완료');
      } else {
        // 음악 리스트가 없으면
        logError('${category} 카테고리에 음악이 없습니다');
        appService.curMusic?.value = Music();
      }
    } catch (e) {
      logError('카테고리 음악 로드 오류: $e');
      Get.snackbar('오류', '음악을 불러오는 중 문제가 발생했습니다');
    }
  }

// music_detail_controller.dart
  Future<void> selectMusic(Music selectedMusic) async {
    try {
      logInfo('음악 선택: ${selectedMusic.title}');

      // 1. 현재 재생 중인 음악 정지
      await appService.audioPlayer.stop();
      await appService.audioPlayer.seek(Duration.zero); // 재생 위치를 0으로 초기화

      // 2. URL 추적 변수 초기화 (새로운 음악이므로)
      _currentLoadedUrl = null;

      // 3. 선택한 음악을 현재 음악으로 설정
      appService.curMusic?.value = selectedMusic;

      // 4. 잠시 대기 (상태 정리)
      await Future.delayed(Duration(milliseconds: 100));

      // 5. 새로운 음악 자동 재생
      if (selectedMusic.musicUrl != null) {
        final apiBaseUrl = dotenv.env['DEV_BASE_URL_WT_API'];
        final url = '$apiBaseUrl${selectedMusic.musicUrl}';

        logInfo('새로운 음악 URL 설정: $url');
        await appService.audioPlayer.setUrl(url);
        _currentLoadedUrl = url;

        await appService.audioPlayer.play();
        logInfo('새로운 음악 재생 시작: ${selectedMusic.title}');
      } else {
        logError('선택한 음악의 URL이 없습니다');
      }

      logInfo('음악 선택 완료: ${selectedMusic.title}');
    } catch (e) {
      logError('음악 선택 오류: $e');
      // 오류 발생 시 URL 추적 변수 초기화
      _currentLoadedUrl = null;
    }
  }
}

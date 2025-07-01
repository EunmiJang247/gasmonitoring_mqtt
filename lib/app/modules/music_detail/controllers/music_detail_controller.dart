import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:meditation_friend/app/data/models/music.dart';
import 'package:meditation_friend/app/data/services/app_service.dart';
import 'package:meditation_friend/app/utils/log.dart';

class MusicDetailController extends GetxController {
  MusicDetailController({required this.appService});
  final AppService appService;

  RxString category = ''.obs;
  String? _currentLoadedUrl;

  Rx<Music?> get currentMusic => appService.curMusic;
  // 현재 음악 가져오기
  RxBool get isPlaying => appService.isPlaying;
  RxBool get isLoading => appService.isLoading;
  @override
  void onInit() {
    super.onInit();
    // Flutter는 위젯을 그리는 과정을 "프레임(Frame)" 단위로 처리하는데,
    // addPostFrameCallback을 쓰면 화면이 다 그려진 다음(= build 이후)
    // 실행하고 싶은 코드를 넣을 수 있음
    WidgetsBinding.instance.addPostFrameCallback((_) {
      turnOnMusic();
    });
  }

  Future<void> turnOnMusic() async {
    final args = Get.arguments;
    if (args != null && args is Map<String, dynamic>) {
      // 카테고리 정보 추출
      category.value = args['category'] ?? '';
      final continueCurrent = args['continue_current'] ?? false;

      if (continueCurrent) {
        // 재생중이었던 음악이 있으면 이미 로드된 음악이 있으면 그대로 사용
        logInfo('이전 음악 계속 재생: ${appService.curMusic.value?.title}');
        return; // 이미 로드된 음악이 있으므로 추가 로딩 불필요
      } else {
        // 현재 재생 중인 음악이 없으면 새로 로드
        logInfo(
            "appService.curMusic?.value: ${appService.curMusic.value?.toJson()}");
        if (appService.curMusic.value != null) {
          // 현재 재생 중인 음악이 있다면 정지
          await appService.audioPlayer.stop();
          await appService.audioPlayer.seek(Duration.zero);
          await appService.audioPlayer.dispose();
          appService.audioPlayer = AudioPlayer();
          _currentLoadedUrl = null;
          logInfo("이전 음악 중지: ${appService.curMusic.value?.title}");
        }
        await loadMusicByCategory(category.value);
      }
    }
  }

  // 카테고리별 음악 로드
  Future<void> loadMusicByCategory(String category) async {
    try {
      logInfo("카테고리 음악 로드 시작: $category");
      // AppService를 통해 해당 카테고리의 음악 요청
      await appService.fetchMeditationByCategory(category);

      if (appService.musicList.isNotEmpty &&
          appService.curMusic.value!.musicUrl != null) {
        // 첫 번째 음악 자동 재생 시작
        await _playFirstMusic(appService.curMusic.value!);
      } else {
        // 음악 리스트가 없으면
        logError('${category} 카테고리에 음악이 없습니다');
      }
    } catch (e) {
      logError('카테고리 음악 로드 오류: $e');
      Get.snackbar('오류', '음악을 불러오는 중 문제가 발생했습니다');
    }
  }

  // 첫 번째 음악 재생 (개선)
  Future<void> _playFirstMusic(Music music) async {
    try {
      final apiBaseUrl = dotenv.env['DEV_BASE_URL_WT_API'];
      final url = '$apiBaseUrl${music.musicUrl}';
      logInfo("url은 ${url}");

      await Future.delayed(Duration(milliseconds: 200));
      _currentLoadedUrl = url;

      await safePlay(appService.audioPlayer, url);
    } catch (e) {
      logError('❌ 첫 번째 음악 재생 오류: $e');
      _currentLoadedUrl = null;
    }
  }

  Future<void> safePlay(AudioPlayer player, String url) async {
    try {
      // ✅ 기존 재생되고 있는게 있다면 중단
      if (player.playing) {
        await player.stop();
        logInfo('기존 재생 중단');
      }

      await player.setUrl(url);

      // 준비될 때까지 기다리기
      await Future.doWhile(() async {
        final state = player.playerState.processingState;
        logInfo("🌀 상태: $state");
        if (state == ProcessingState.ready) return false;
        if (state == ProcessingState.idle ||
            state == ProcessingState.completed) {
          throw Exception('❌ player 상태 비정상: $state');
        }
        await Future.delayed(Duration(milliseconds: 100));
        return true;
      });

      // ✅ 개선: 타임아웃 추가
      try {
        logInfo('111나오는거 맞지..?');
        appService.isPlaying.value = true;
        await player.play();
        logInfo('222나오는거 맞지..?');
      } catch (e) {
        print(e);
      }
    } catch (e) {
      logError('safePlay 오류: $e');
    }
  }

  // 음악 재생버튼을 눌렀을 때 발동됨
  Future<void> playMusic() async {
    if (currentMusic.value?.musicUrl != null) {
      try {
        appService.isPlaying.value = true;
        await appService.audioPlayer.play();
      } catch (e) {
        logError('재생 오류: $e');
        _currentLoadedUrl = null;
      }
    }
  }

  // 음악 일시정지
  Future<void> pauseMusic() async {
    try {
      appService.isPlaying.value = false;
      await appService.audioPlayer.pause();
    } catch (e) {
      logError('일시정지 오류: $e');
    }
  }

  // 전체 카테고리중 하나 선택
  Future<void> changeCategory(String newCategory) async {
    try {
      logInfo('카테고리 변경: $newCategory');
      await _safeStop();
      category.value = newCategory;
      await loadMusicByCategory(newCategory);
    } catch (e) {
      logError('카테고리 변경 오류: $e');
    }
  }

  // 안전한 정지(D/BufferPoolAccessor2.0: Destruction 일어남!)
  Future<void> _safeStop() async {
    try {
      if (appService.audioPlayer.playing) {
        await appService.audioPlayer.stop();
        // await appService.audioPlayer.dispose();
        // appService.audioPlayer = AudioPlayer();
      }
      await appService.audioPlayer.seek(Duration.zero);
      await Future.delayed(Duration(milliseconds: 100));
      _currentLoadedUrl = null;
    } catch (e) {
      logError('안전 정지 오류: $e');
    }
  }

  // 동일 카테고리에서 음악을 선택할 경우
  Future<void> selectMusic(Music selectedMusic) async {
    try {
      logInfo('🎯 음악 선택: ${selectedMusic.title}');

      // 1. 현재 재생 중인 음악 정지
      await _safeStop();

      // 2. 상태 갱신
      appService.curMusic.value = selectedMusic;

      // 3. URL 확인 및 재생
      if (selectedMusic.musicUrl == null) {
        throw Exception('선택한 음악의 URL이 없습니다');
      }

      final apiBaseUrl = dotenv.env['DEV_BASE_URL_WT_API'];
      final url = '$apiBaseUrl${selectedMusic.musicUrl}';

      _currentLoadedUrl = url;

      logInfo('🎶 새로운 음악 URL 재생 요청: $url');
      await safePlay(appService.audioPlayer, url);

      logInfo('✅ 음악 선택 완료: ${selectedMusic.title}');
    } catch (e) {
      logError('❌ 음악 선택 오류: $e');
      _currentLoadedUrl = null;
    }
  }
}

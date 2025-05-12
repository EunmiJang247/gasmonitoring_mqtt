import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:safety_check/app/data/models/music.dart';

import '../../routes/app_pages.dart';
import '../../utils/log.dart';
import '../models/base_response.dart';
import '../models/sign_in_response.dart';
import '../models/00_user.dart';
import '../repository/app_repository.dart';
import 'local_app_data_service.dart';

import 'package:just_audio/just_audio.dart';

class AppService extends GetxService {
  final AppRepository _appRepository;
  final LocalAppDataService _localAppDataService;

  final AudioPlayer audioPlayer = AudioPlayer();
  User? user;
  Rx<bool> isOfflineMode = false.obs;
  DateTime? currentBackPressTime;
  RxList<Music> musicList = <Music>[].obs;
  Rx<Music>? curMusic = Music().obs;
  RxBool isPlaying = false.obs;

  AppService({
    required AppRepository appRepository,
    required LocalAppDataService localAppDataService,
  })  : _appRepository = appRepository,
        _localAppDataService = localAppDataService;
  @override
  Future<void> onInit() async {
    super.onInit();
    audioPlayer.playerStateStream.listen((state) {
      isPlaying.value = state.playing;
    });

    final musics = await _getMusicList();
    musicList.value = musics ?? [];
    curMusic?.value = await getRandomMusic();
  }

  Future<Music> getRandomMusic() async {
    if (musicList.isNotEmpty) {
      int randomIndex =
          DateTime.now().millisecondsSinceEpoch % musicList.length;
      return musicList[randomIndex];
    } else {
      return Music();
    }
  }

  void onPop(context) {
    DateTime now = DateTime.now();
    if (currentBackPressTime == null ||
        now.difference(currentBackPressTime!) >
            const Duration(milliseconds: 1500)) {
      currentBackPressTime = now;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("한번 더 누르면 종료됩니다."),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(bottom: 46),
          duration: Duration(milliseconds: 1500),
        ),
      );
    } else {
      SystemNavigator.pop();
    }
  }

  String createId() {
    return DateTime.now().toString().replaceAll(RegExp(r"[\s-:.]"), "");
  }

  Future<String?> signIn({
    required String email,
    required String password,
    required bool offline,
  }) async {
    isOfflineMode.value = offline;
    String? result;
    SignInResponse? response;

    if (offline) {
      user = _localAppDataService.getLastLoginUser();
      // 오프라인이면 로컬에 저장된 마지막 로그인 유저와 데이터 로드

      // if (password != user?.password) {
      //   result = '마지막으로 로그인했던 아이디와 비밀번호를 입력하세요.';
      //   return result;
      // }

      // locationList = _localAppDataService.getLocationList();
    } else {
      await EasyLoading.show(dismissOnTap: true);
      // 로딩 인디케이터 표시
      BaseResponse? baseResponse = await _appRepository.signIn(
        email: email,
        password: password,
      );
      // 서버에 로그인 요청 (→ AppRepository가 실제 API 호출 담당)
      if (baseResponse?.result?.code != 100) {
        // 100번이 아닌 경우 에러 발생한 것임
        result = baseResponse?.result?.message;
      } else {}
    }
    return result;
  }

  Future<String?> logOut() async {
    String? result;
    BaseResponse? baseResponse = await _appRepository.logOut();
    if (baseResponse?.result?.code != 100) {
      result = baseResponse?.result?.message;
    } else {}
    Get.offAllNamed(Routes.LOGIN);
    return result;
  }

  Future<String?> findPw({String? email}) async {
    if (email != null) {
      String? result = await _appRepository.findPw(email: email);
      return result;
    } else {
      return "";
    }
  }

  // 음악 리스트 가져오는 부분
  Future<List<Music>?> _getMusicList() async {
    if (isOfflineMode.value) {
      // 오프라인 일때
      return [];
    } else {
      final musicResult = await _appRepository.searchMusicList();
      return musicResult;
    }
  }
}

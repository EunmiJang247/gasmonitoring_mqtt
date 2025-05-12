import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import "package:path/path.dart";
import 'package:path_provider/path_provider.dart';
import 'package:safety_check/app/constant/constants.dart';
import 'package:safety_check/app/data/models/fault_category.dart';
import 'package:safety_check/app/data/models/music.dart';
import 'package:safety_check/app/widgets/web_3d_view.dart';
import 'package:image/image.dart' as img; // image 패키지

import '../../routes/app_pages.dart';
import '../../utils/log.dart';
import '../models/base_response.dart';
import '../models/sign_in_response.dart';
import '../models/update_history.dart';
import '../models/00_user.dart';
import '../repository/app_repository.dart';
import 'local_app_data_service.dart';

import 'package:just_audio/just_audio.dart';

// 앱의 비즈니스 로직, 상태, 데이터 동기화 등 모든 핵심 기능을 전역적으로 다루는 중앙 서비스 레이어

//  왜 AppService는 Controller랑 분리했을까?
// 	데이터 처리, 비즈니스 로직, 저장소 접근, 유틸 기능
// Service는 앱 전역에서 공통으로 필요한 기능/데이터를 제공해. 예를 들어:
// 로그인 처리
// 오프라인/온라인 모드 분기
// 프로젝트/도면 목록 관리
// 사진 업로드/삭제 로직 등
// → 이걸 다 Controller 안에 넣으면 비대해지고 복잡해져서 유지보수가 어려움.

// AppService는 전역(Global) 상태 및 기능을 담당
// 앱 전체에서 공유되는 상태(예: 현재 로그인한 사용자, 현재 선택된 프로젝트 등)
// 하나만 존재하면 되는 싱글톤 성격의 객체 (extends GetxService 로 선언됨)
// 앱 실행 시 초기화되고, 어디서든 Get.find<AppService>()로 접근 가능

class AppService extends GetxService {
  // GetxService는 싱글톤 서비스야. 즉, 앱 전체에서 딱 하나만 존재하는 객체
  final AppRepository _appRepository;
  final LocalAppDataService _localAppDataService;

  final AudioPlayer audioPlayer = AudioPlayer();
  final RxBool isSliding = false.obs;
  final RxBool isPlaying = false.obs;
  final RxDouble sliderValue = 0.0.obs;
  final Rx<Duration> currentPosition = Duration.zero.obs;

  // 전역 상태 변수
  User? user; // 로그인한 사용자 정보
  List? locationList = [];
  List? statusList = [];
  List? causeList = [];
  // 1차/2차 결함 카테고리
  Map<String, String>? faultCate1;
  Map<String, String>? faultCate2;
  String projectName = "";
  String drawingName = "";
  // String? curProjectSeq;
  // String? curDrawingSeq;

  Map<String, List> faultImageInfo = {};

  // 결함 현황표 관련
  int faultTableCurRowIndex = -1;
  RxBool isFaultSelected = false.obs;
  RxList faultTableGroupingIndexes = [].obs;
  // 화면에 출력중인 결함 (group_fid 같은 것중 하나)
  Map<String, String> displayingFid = {};

  AppService({
    // 외부에서 이 객체를 반드시 전달해야 함 (Dart의 required 키워드 사용)
    required AppRepository appRepository,
    required LocalAppDataService localAppDataService,
  })  : _appRepository =
            appRepository, // 전달받은 객체를 클래스 내부의 private 필드에 할당 (생성자 초기화 리스트)
        // 	클래스 내부에서 쓸 진짜 의존성 필드
        _localAppDataService = localAppDataService;

  Rx<bool> isOfflineMode = false.obs;
  // 오프라인 모드 여부
  // AppService 객체에 붙어있는 속성이라서 어디서든 접근 가능
  Rx<UpdateHistoryItem?> lastUpdateHistory =
      Rx(UpdateHistoryItem(history: [], version: "", update_date: ""));
  DateTime? currentBackPressTime;

  RxList<Music> musicList = <Music>[].obs;
  Rx<Music>? curMusic = Music().obs;

  Future<BaseResponse?> init() async {
    BaseResponse? response = await _appRepository.init();
    return response;
  }

  Future<BaseResponse?> test() async {
    BaseResponse? response = await _appRepository.test();
    return response;
  }

  @override
  Future<void> onInit() async {
    super.onInit();
    getMusicList();
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
    // 단순 로그인뿐 아니라 전역 유저 상태 초기화, 로컬 저장, 서버 데이터 파싱까지 담당한다.
    // 비동기 로그인 함수. 로그인 성공 여부나 에러 메시지를 String?으로 반환
    required String email,
    required String password,
    required bool offline,
  }) async {
    // 로그인하는 서비스!
    // 실제 로그인 로직, 로컬 저장, 서버 요청 등은 다 AppService에 있음
    isOfflineMode.value = offline; // 전역 상태 isOfflineMode를 설정함
    String? result;
    SignInResponse? response;

    if (offline) {
      user = _localAppDataService.getLastLoginUser();
      // 오프라인이면 로컬에 저장된 마지막 로그인 유저와 데이터 로드

      // if (password != user?.password) {
      //   result = '마지막으로 로그인했던 아이디와 비밀번호를 입력하세요.';
      //   return result;
      // }

      locationList = _localAppDataService.getLocationList();
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
  Future<List<Music>?> getMusicList() async {
    List<Music>? musicResult;
    if (isOfflineMode.value) {
      // 오프라인 일때
    } else {
      // 인터넷 연결이 있을 때
      musicResult = await _appRepository.searchMusicList();
      musicList.value = musicResult ?? [];
    }
    return musicResult;
  }
}

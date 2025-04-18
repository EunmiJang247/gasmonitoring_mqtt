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
import 'package:safety_check/app/constant/data_state.dart';
import 'package:safety_check/app/data/models/05_picture.dart';
import 'package:safety_check/app/data/models/06_engineer.dart';
import 'package:safety_check/app/data/models/07_fault_cate1_list.dart';
import 'package:safety_check/app/data/models/08_fault_cate2_list.dart';
import 'package:safety_check/app/data/models/09_appended.dart';
import 'package:safety_check/app/data/models/11_drawing_memo.dart';
import 'package:safety_check/app/data/models/fault_category.dart';
import 'package:safety_check/app/modules/drawing_detail/controllers/drawing_detail_controller.dart';
import 'package:safety_check/app/widgets/web_3d_view.dart';
import 'package:image/image.dart' as img; // image 패키지

import '../../routes/app_pages.dart';
import '../../utils/log.dart';
import '../models/03_marker.dart';
import '../models/04_fault.dart';
import '../models/10_elem_list.dart';
import '../models/base_response.dart';
import '../models/02_drawing.dart';
import '../models/01_project.dart';
import '../models/sign_in_response.dart';
import '../models/update_history.dart';
import '../models/00_user.dart';
import '../repository/app_repository.dart';
import 'local_app_data_service.dart';
import 'local_gallery_data_service.dart';

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
  final LocalGalleryDataService _localGalleryDataService;

  // 전역 상태 변수
  User? user; // 로그인한 사용자 정보
  List? locationList = [];
  List? statusList = [];
  List? causeList = [];
  // 1차/2차 결함 카테고리
  Map<String, String>? faultCate1;
  Map<String, String>? faultCate2;
  List<ElementList>? elements;
  String projectName = "";
  String drawingName = "";
  // String? curProjectSeq;
  // String? curDrawingSeq;

  Rx<Drawing> curDrawing = Drawing().obs; // 현재 선택된 도면, 프로젝트

  Map<String, List> faultImageInfo = {};

  // 결함 현황표 관련
  int faultTableCurRowIndex = -1;
  Rx<Fault> selectedFault = Rx(Fault());
  RxBool isFaultSelected = false.obs;
  RxList faultTableGroupingIndexes = [].obs;
  // 화면에 출력중인 결함 (group_fid 같은 것중 하나)
  Map<String, String> displayingFid = {};

  AppService({
    // 외부에서 이 객체를 반드시 전달해야 함 (Dart의 required 키워드 사용)
    required AppRepository appRepository,
    required LocalAppDataService localAppDataService,
    required LocalGalleryDataService localGalleryDataService,
  })  : _appRepository =
            appRepository, // 전달받은 객체를 클래스 내부의 private 필드에 할당 (생성자 초기화 리스트)
        // 	클래스 내부에서 쓸 진짜 의존성 필드
        _localAppDataService = localAppDataService,
        _localGalleryDataService = localGalleryDataService;

  Rx<bool> isOfflineMode = false.obs;
  // 오프라인 모드 여부
  // AppService 객체에 붙어있는 속성이라서 어디서든 접근 가능
  Rx<UpdateHistoryItem?> lastUpdateHistory =
      Rx(UpdateHistoryItem(history: [], version: "", update_date: ""));
  DateTime? currentBackPressTime;

  RxList<Project> projectList = <Project>[].obs;
  RxList<Drawing> drawingList = <Drawing>[].obs;
  RxList<Marker> markerList = <Marker>[].obs;
  List<Fault> get faultList => markerList
      .map<List<Fault>>(
        (e) => e.fault_list ?? [],
      )
      .expand(
        (element) => element,
      )
      .toList();
  Rx<Project>? curProject = Project().obs;

  Future<BaseResponse?> init() async {
    BaseResponse? response = await _appRepository.init();
    return response;
  }

  Future<BaseResponse?> test() async {
    BaseResponse? response = await _appRepository.test();
    return response;
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
      } else {
        // 정상적으로 로그인한 경우
        response = SignInResponse(
            // 서버 응답 데이터를 model 객체로 파싱
            user: User.fromJson(baseResponse?.data?['user']),
            engineers: (baseResponse?.data?['engineer_list'])
                .map((e) => Engineer.fromJson(e))
                .toList()
                .cast<Engineer>(),
            faultCate1List: FaultCate1List.fromJson(baseResponse?.data),
            faultCate2List: FaultCate2List.fromJson(baseResponse?.data),
            elements: baseResponse?.data?["elem_list"]
                .map((e) => ElementList.fromJson(e))
                .toList()
                .cast<ElementList>(),
            locationList: baseResponse?.data?["location_list"],
            statusList: baseResponse?.data?["status_list"],
            causeList: baseResponse?.data?["cause_list"]);
        // 서버 응답 데이터를 model 객체로 파싱

        if (response.user != null) {
          // 응답에 사용자에 대한 정보가 있다면
          user = response.user!;
          if (user != null) {
            await _localAppDataService.writeLastLoginUser(user!);
            // 로그인 성공 시, Hive의 user_box에 유저 정보를 저장함
          }
          if (response.faultCate1List != null) {
            faultCate1 = FaultCategory.listToMap(
                response.faultCate1List?.fault_cate1_list ?? []);
            // await _localAppDataService.writ
          }
          // 서버에서 1차 결함 카테고리 리스트가 왔다면 이걸 전역 변수 faultCate1에 저장

          if (response.faultCate2List != null) {
            faultCate2 = FaultCategory.listToMap(
                response.faultCate2List?.fault_cate2_list ?? []);
            // await _localAppDataService.writ
          }
          // 서버에서 2차 결함 카테고리 리스트가 왔다면 이걸 전역 변수 faultCate1에 저장

          if (response.elements != null) {
            elements = response.elements;
            // elements는 어떤 구조물의 부재(요소) 리스트일 가능성 높음
            // 서버에서 내려준 리스트를 앱 전역에 저장해서
            // → 이후 드롭다운, 분석, 리스트 UI 등에서 사용 가능
          }
          if (response.locationList != null) {
            locationList = response.locationList;
          }
          // 건물 내부 위치 정보 리스트 역시 전역에 저장해서 이후 페이지에서 반복 사용 가능
          // print(locationList);
          if (response.statusList != null) {
            statusList = response.statusList;
          }
          // 결함 상태 리스트
          // print(statusList);

          if (response.causeList != null) {
            causeList = response.causeList;
          }
          // 결함 원인 리스트
          // print(causeList);
          logSuccess(response.user!.toJson(),
              des: 'AppService.signIn($email / $password)');
          // 로그인 결과를 성공적으로 로그로 남김 (디버깅 or 추적용)
        }
        // if (response.location_List != null) {
        //   location_list = response.location_List!;
        //   await _localAppDataService.putLocationList(location_list!);
        // }
        // await EasyLoading.dismiss();
      }
    }
    return result;
  }

  Future<String?> logOut() async {
    String? result;
    BaseResponse? baseResponse = await _appRepository.logOut();
    if (baseResponse?.result?.code != 100) {
      result = baseResponse?.result?.message;
    } else {}
    isLeftBarOpened.value = false;
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

  Future<List<Project>?> getProjectList({required int my, String? q}) async {
    List<Project>? result;

    if (isOfflineMode.value) {
      // result = _localAppDataService.getProjectList(user!.seq);
    } else {
      result = await _appRepository.searchProjectList(my: my, q: q);
      projectList.value = result ?? [];

      // for (Project prj in projectList) {
      //   // await _localAppDataService.putProject(user!.seq, prj);
      // }
    }
    return result;
  }

  Future<Map?> submitProject(Project project) async {
    Map? result;
    if (isOfflineMode.value) {
      // result = _localAppDataService.getProjectList(user!.seq);
    } else {
      result = await _appRepository.submitProject(project: project);
    }
    return result;
  }

  Future<List<Drawing>?> getDrawingList({required String? projectSeq}) async {
    List<Drawing>? result;

    if (isOfflineMode.value) {
      // result = _localAppDataService.getProjectList(user!.seq);
    } else {
      result = await _appRepository.searchDrawingList(projectSeq: projectSeq);
      drawingList.value = result ?? [];

      // for (Drawing prj in drawingList) {
      //   // await _localAppDataService.putProject(user!.seq, prj);
      // }
    }
    return result;
  }

  // 도면 메모 저장
  Future<DrawingMemo?> submitDrawingMemo(DrawingMemo memo) async {
    DrawingMemo? result;
    if (isOfflineMode.value) {
      // result = _localAppDataService.getProjectList(user!.seq);
    } else {
      result = await _appRepository.submitDrawingMemo(memo: memo);
    }
    return result;
  }

  // 도면 메모 삭제
  Future deleteDrawingMemo(String memoSeq) async {
    if (isOfflineMode.value) {
      // result = _localAppDataService.getProjectList(user!.seq);
    } else {
      await _appRepository.deleteDrawingMemo(memoSeq: memoSeq);
    }
    return null;
  }

  toFloorName(String floor) {
    String floorName = "";
    if (int.parse(floor) < 0) {
      floorName = floor.replaceFirst('-', '지하 ');
    } else if (floor == "127") {
      floorName = "지붕";
    } else if (floor == "126") {
      floorName = "옥상";
    }
    floorName += "층";
    return floorName;
  }

  Future<String?> copyDrawing({required String? seq}) async {
    String? result;

    if (isOfflineMode.value) {
      // result = _localAppDataService.getProjectList(user!.seq);
    } else {
      result = await _appRepository.copyDrawing(seq: seq);
    }
    return result;
  }

  Future<List<Marker>?> getMarkerList({
    String? drawingSeq,
    String? projectSeq,
    String? mid,
  }) async {
    List<Marker>? result;

    if (isOfflineMode.value) {
      result = _localAppDataService.MarkerList;
    } else {
      result = await _appRepository.searchMarkerList(
        projectSeq: projectSeq,
        drawingSeq: drawingSeq,
        mid: mid,
      );
      markerList.value = result ?? [];

      for (Marker marker in markerList) {
        _localAppDataService.putMarker(marker);
        if (marker.fault_list != null) {
          for (Fault flt in marker.fault_list!) {
            if (flt.picture_list != null) {
              for (CustomPicture pic in flt.picture_list!) {
                if (!_localGalleryDataService.isPictureInBox(pic.pid!)) {
                  _localGalleryDataService.addPicture(makeNewPicture(
                    seq: pic.seq!,
                    pid: pic.pid!,
                    projectSeq: pic.project_seq!,
                    fid: pic.fid!,
                    filePath: pic.file_path!,
                    thumb: pic.thumb!,
                    location: pic.location,
                    dong: pic.dong,
                    floorName: pic.floor_name,
                    kind: "결함",
                    no: pic.no,
                  ));
                }
              }
            }
          }
        }
      }
    }
    return result;
  }

  Future<String?> sortMarker({required String? drawingSeq}) async {
    String? result;

    if (isOfflineMode.value) {
      // result = _localAppDataService.getProjectList(user!.seq);
    } else {
      result = await _appRepository.sortMarker(drawingSeq: drawingSeq);
    }
    return result;
  }

  Future<Map?> submitMarker(
      {required bool isNew,
      required Marker marker,
      String? lastFaultSeq,
      String? markerSize}) async {
    Map? result;
    if (isOfflineMode.value) {
      // result = _localAppDataService.getProjectList(user!.seq);
    } else {
      result = await _appRepository.submitMarker(
          isNew: isNew,
          marker: marker,
          lastFaultSeq: lastFaultSeq,
          markerSize: markerSize);
    }
    return result;
  }

  Future<Appended?> deleteMarker(
      {required String markerSeq, String? lastFaultSeq}) async {
    Appended? result;
    if (isOfflineMode.value) {
      // result = _localAppDataService.getProjectList(user!.seq);
    } else {
      result = await _appRepository.deleteMarker(
          seq: markerSeq, lastFaultSeq: lastFaultSeq);
    }
    return result;
  }

  Future<Appended?> overrideMarker(
      {required String fromSeq,
      required String toSeq,
      String? lastFaultSeq}) async {
    Appended? result;
    if (isOfflineMode.value) {
      // result = _localAppDataService.getProjectList(user!.seq);
    } else {
      result = await _appRepository.overrideMarker(
          fromSeq: fromSeq, toSeq: toSeq, lastFaultSeq: lastFaultSeq);
    }
    return result;
  }

  Future<Map?> mergeMarker(
      {required String fromSeq,
      required String toSeq,
      String? lastFaultSeq}) async {
    Map? result;
    if (isOfflineMode.value) {
      // result = _localAppDataService.getProjectList(user!.seq);
    } else {
      // 온라인 일때만
      result = await _appRepository.mergeMarker(
          fromSeq: fromSeq, toSeq: toSeq, lastFaultSeq: lastFaultSeq);
    }
    return result;
  }

  Future<Map?> submitFault({
    required bool isNew,
    required Fault fault,
    String? mid,
    String? lastFaultSeq,
  }) async {
    Map? result;
    if (isOfflineMode.value) {
      // result = _localAppDataService.getProjectList(user!.seq);
    } else {
      result = await _appRepository.submitFault(
          isNew: isNew, fault: fault, mid: mid, lastFaultSeq: lastFaultSeq);
    }
    return result;
  }

  Future<Appended?> deleteFault(
      {required String faultSeq, String? lastFaultSeq}) async {
    Appended? result;
    if (isOfflineMode.value) {
      // result = _localAppDataService.getProjectList(user!.seq);
    } else {
      result = await _appRepository.deleteFault(
          seq: faultSeq, lastFaultSeq: lastFaultSeq);
    }
    return result;
  }

  // 사진 목록 새로고침 (서버에서 사진 불러와 디비에 저장하고 디비 내용 불러옴)
  Future<List<CustomPicture>?> searchPicture(
      {required String? projectSeq}) async {
    List<CustomPicture>? result = [];
    try {
      List<CustomPicture>? pictures =
          await _appRepository.searchPicture(projectSeq: projectSeq) ?? [];
      // 서버에서 사진 리스트를 받아옴

      List pidList = pictures
          .map(
            (e) => e.pid,
          )
          .toList();
      for (CustomPicture pic in _localGalleryDataService.PictureList) {
        // 로컬(Hive)에 저장된 모든 사진들을 하나씩 검사해.
        if (pic.project_seq == projectSeq && // 로컬(Hive)에 저장된 모든 사진들을 하나씩 검사해.
            !pidList.contains(pic.pid) && // 서버에서 내려온 사진 pid 리스트에는 없는 사진이며
            pic.seq != null) {
          // 서버에 한번은 등록됐던 사진임 (즉, 완전한 신규 로컬 임시 사진은 아님)
          _localGalleryDataService.removePicture(pic.pid!);
          // 로컬에만 있고, 서버에서는 이미 삭제된 사진이다 -> 삭제 진행
        }
      }
      for (CustomPicture pic in pictures) {
        // 서버에 있는 사진들을 모두 순회함
        if (!_localGalleryDataService.isPictureInBox(pic.pid!)) {
          // Hive에 이 pid 사진이 없다면 (= 처음 받는 사진이라면),
          // 서버에서 받은 사진 데이터를 makeNewPicture()로 변환해서,
          _localGalleryDataService.addPicture(makeNewPicture(
              // Hive에 새로 추가함 (addPicture() → put(pid, picture) 내부적으로 실행)
              seq: pic.seq!,
              pid: pic.pid!,
              projectSeq: pic.project_seq!,
              fid: pic.fid,
              filePath: pic.file_path!,
              thumb: pic.thumb!,
              kind: pic.fid == null ? "기타" : "결함",
              location: pic.location,
              dong: pic.dong,
              floorName: pic.floor_name,
              no: pic.no));
        } else {
          int? picState = _localGalleryDataService.checkState(pic.pid!);
          if (picState != null &&
              (picState == DataState.EDITED.index ||
                  picState == DataState.DELETED.index)) {
            // Hive에 저장된 이 사진이 EDITED(수정됨) 이거나 DELETED(삭제됨)이면,
            //  "이 사진이 로컬에서 수정되었거나 삭제 표시된 상태면, 서버 데이터로 덮어쓰지 마!"
            // 서버에서 내려온 사진 정보로 덮어쓰지 않고 건너뛴다 (continue)
            // 즉, 서버에 있고, 로컬에서 삭제 표시만 한 사진은 그냥 놔둠
            continue;
          }
          // 이건 앞의 조건에서 continue에 안 걸린 사진들, 즉:
          // Hive에도 있고
          // 로컬에서 EDITED 또는 DELETED 상태가 아니고
          // 서버에서 새로 내려온 사진 데이터가 존재하는 경우
          // 로컬 상태를 최신 서버 상태로 덮어쓰는 로직
          pic.state = DataState.NOT_CHANGED.index;
          // 여기는 NOT_CHANGED or NEW 상태인 사진만 도달함
          // 서버에서 받은 사진(pic)이 현재 로컬에도 있고,
          // 수정되지도 삭제되지도 않았으니,
          // 상태를 "변경 없음"(NOT_CHANGED)으로 리셋해주는 거
          _localGalleryDataService.updatePicture(
              pid: pic.pid!, changedPicture: pic);
        }
      }
    } on Exception catch (e) {
      debugPrint(e.toString());
    }
    result = _localGalleryDataService.PictureList.where((element) =>
        element.project_seq == projectSeq &&
        element.state != DataState.DELETED.index).toList();
    // PictureList : Hive에 저장된 모든 사진을 리스트로 가져오는 getter야.
    // 즉, 현재 로컬에 존재하는 모든 사진 리스트
    // 해당 프로젝트(현장)에 속하고
    // 상태가 DELETED가 아닌 사진만 필터링
    // ==>  즉, 사용자가 보게 될 "정상 사진 목록"을 추리는 필터링 작업
    return result;
  }

  Future<int> uploadPicture({
    required int currentCount,
    required int totalCount,
  }) async {
    List<CustomPicture> pictureList = _localGalleryDataService.PictureList;
    if (pictureList.isEmpty) return 0;

    for (CustomPicture picture in pictureList) {
      if (picture.state == DataState.NEW.index) {
        BaseResponse? response =
            await _appRepository.uploadPicture(newPicture: picture);
        if (response?.result?.code != 100) {
          logError(response?.result?.message,
              des: 'AppService.uploadPicture(pid:${picture.pid})');

          if (response?.result?.code == 400) {
            await _localGalleryDataService.removePicture(picture.pid!);
          }
        } else {
          CustomPicture uploadedPicture =
              CustomPicture.fromJson(response?.data);
          // print(uploadedPicture.no);
          uploadedPicture.state = DataState.NOT_CHANGED.index;
          _localGalleryDataService.updatePicture(
              pid: uploadedPicture.pid!, changedPicture: uploadedPicture);
          if (uploadedPicture.fid != null) {
            for (Marker marker in markerList) {
              for (Fault fault in marker.fault_list ?? []) {
                if (fault.fid == uploadedPicture.fid) {
                  fault.picture_list ??= [];
                  fault.picture_list?.add(uploadedPicture);
                  fault.pic_no = uploadedPicture.no;
                  if (Get.isRegistered<DrawingDetailController>()) {
                    DrawingDetailController drawingDetailController =
                        Get.find();
                    drawingDetailController.countFaults();
                  }
                }
              }
            }
          }
        }
        currentCount++;
        await EasyLoading.showProgress(
          currentCount / totalCount,
          status: '사진 업로드중...\n$currentCount/$totalCount',
          maskType: EasyLoadingMaskType.black,
        );
      }
    }

    return currentCount;
  }

  Future<int> updatePicture({
    required int currentCount,
    required int totalCount,
  }) async {
    List<CustomPicture>? pictureList = _localGalleryDataService.PictureList;
    if (pictureList.isEmpty) return 0;

    for (CustomPicture picture in pictureList) {
      if (picture.state == DataState.EDITED.index) {
        BaseResponse? response;
        if (picture.seq != null) {
          response = await _appRepository.updatePicture(
              pid: picture.pid,
              kind: picture.kind,
              seq: picture.seq!,
              location: picture.location);
        } else {
          response = await _appRepository.uploadPicture(newPicture: picture);
        }
        if (response?.result?.code != 100) {
          logError(response?.result?.message,
              des: 'AppService.updateEditedGallery(pid:${picture.pid})');
          switch (response?.result?.code) {
            case 300:
            case 400:
              _localGalleryDataService.removePicture(picture.pid!);
              break;
          }
        } else {
          _localGalleryDataService.changePictureState(
              pid: picture.pid!, state: DataState.NOT_CHANGED);
        }
        currentCount++;
        await EasyLoading.showProgress(
          currentCount / totalCount,
          status: '사진 수정중...\n$currentCount/$totalCount',
          maskType: EasyLoadingMaskType.black,
        );
      }
    }
    return currentCount;
  }

  Future<int> deletePicture({
    required int currentCount,
    required int totalCount,
  }) async {
    // print("DeletePicture");
    // print(currentCount);
    // print(totalCount);
    List<CustomPicture>? pictureList = _localGalleryDataService.PictureList;
    if (pictureList.isEmpty) return 0;

    for (CustomPicture picture in pictureList) {
      if (picture.state == DataState.DELETED.index) {
        if (picture.seq != null) {
          BaseResponse? response =
              await _appRepository.deletePicture(seq: picture.seq!);
          if (response?.result?.code != 100) {
            logError(response?.result?.message,
                des: 'AppService.updateDeletedGallery(pid:${picture.pid})');
          } else {
            _localGalleryDataService.removePicture(picture.pid!);
          }
        } else {
          _localGalleryDataService.removePicture(picture.pid!);
        }
        currentCount++;
        await EasyLoading.showProgress(
          currentCount / totalCount,
          status: '사진 삭제중...\n$currentCount/$totalCount',
          maskType: EasyLoadingMaskType.black,
        );
      }
    }
    return currentCount;
  }

  Future<int?> addFaultContent(
      {required int type, required String name}) async {
    int? result;
    if (isOfflineMode.value) {
      // result = _localAppDataService.getProjectList(user!.seq);
    } else {
      if (type == 1) {
        result = await _appRepository.addFaultCate1(name: name);
        if (result != null) {
          faultCate1 ??= {};
          faultCate1![result.toString()] = name;
        }
      } else if (type == 2) {
        result = await _appRepository.addFaultCate2(name: name);
        if (result != null) {
          faultCate2 ??= {};
          faultCate2![result.toString()] = name;
        }
      } else {
        result = await _appRepository.addFaultElem(name: name);
      }
    }
    return result;
  }

  bool checkNeedUpdate() {
    bool? result;

    // 변경된 사진 체크
    result = _localGalleryDataService.PictureList.where(
      (element) => element.state != DataState.NOT_CHANGED.index,
    ).isNotEmpty;

    return result;
  }

  Future<void> uploadCompleted() async {
    //Project? project = await _appRepository.submitCompleted(project_seq: project_seq);
    // if (project != null) {
    //   int index = projectList.value.indexWhere((element) => isSameValue(element.seq, project.seq));
    //   if (index != -1) {
    //     projectList.update((val) {
    //       val?[index] = val[index].copyWithAppSubmitTime(project.app_submit_time);
    //     });
    //   }
    // }
    //logInfo(project?.toJson(), des: 'AppService.updateCompleted($project_seq)');
  }

  CustomPicture makeNewPicture(
      // 사진이 Hive에 없다면 (= 처음 받는 사진이라면), Hive에 추가하는 함수
      // 새 사진(CustomPicture)을 생성하고 로컬(Hive)에 등록하는 핵심 팩토리 함수
      {String? seq, // 서버에 저장된 사진일 경우 부여되는 고유 ID
      required String pid, // 로컬에서 생성되는 사진의 고유 식별자 (중복 없는 값)
      required String projectSeq, // 	어떤 현장(프로젝트)에 속한 사진인지
      String? fid,
      required String filePath, // 	원본 사진 경로 (파일 시스템 상 위치)
      required String thumb, // 썸네일 이미지 경로
      required String kind, // 	사진 종류: "전경", "결함", "기타", "현황"
      DataState dataState =
          DataState.NOT_CHANGED, // 초기 상태: NEW, EDITED, NOT_CHANGED 등
      String? dong,
      String? floorName,
      String? no,
      String? location,
      String? cate1Seq,
      List<String>? cate2Seq,
      String? width,
      String? length}) {
    // drawing_seq는 현재 선택된 도면의 ID를 자동으로 넣음
    // state는 enum에서 .index로 변환해서 저장 (Hive는 enum 저장 못하니까 숫자로 저장)
    CustomPicture newPicture = CustomPicture(
      // CustomPicture는 Hive 모델이라, 이 구조 그대로 gallery_box에 저장 가능함
      seq: seq,
      pid: pid,
      file_path: filePath,
      project_seq: projectSeq,
      drawing_seq: curDrawing.value.seq,
      thumb: thumb,
      fid: fid,
      kind: kind,
      no: no,
      dong: dong,
      floor_name: floorName,
      location: location,
      cate1_seq: cate1Seq,
      cate2_seq: cate2Seq,
      width: width,
      length: length,
      state: dataState.index,
    );
    if (curDrawing.value.seq != null) {
      // Drawing curDrawing = drawingList.singleWhere(
      //     (element) => element.seq == curDrawingSeq,
      //     orElse: () => Drawing());
      // Fault curFault = Fault();
      // if (fid != null) {
      //   curFault = faultList.singleWhere((element) => element.fid == fid,
      //       orElse: () => Fault());
      // }
    }
    _localGalleryDataService.addPicture(newPicture);
    // 완성된 사진 모델을 gallery_box에 저장 (key는 pid, value는 CustomPicture)
    // 내부에서는 gallery_box.put(pid, picture) 수행

    // print("NEW PICTURE ADDED!!");
    // print("PRO_SEQ: $projectSeq");
    // print("DRAW_SEQ: $curDrawingSeq");
    return newPicture;
  }

  changeFaultPictureInfo(String pid, Fault fault) {
    CustomPicture? changedPicture =
        _localGalleryDataService.gallery_box.get(pid);
    if (changedPicture != null) {
      changedPicture.floor_name = fault.floor;
      changedPicture.dong = fault.dong;
      changedPicture.location = fault.location;
      changedPicture.cate1_seq = fault.cate1_seq;
      changedPicture.cate2_seq = fault.cate2?.split(", ");
      changedPicture.length = fault.length;
      changedPicture.width = fault.width;
      _localGalleryDataService.updatePicture(
          pid: pid, changedPicture: changedPicture);
    }
  }

  //=========================================== Left Bar Control =============================================

  RxBool isLeftBarOpened = false.obs;
  Rx<List<bool?>> needUpdateCheckList = Rx([]);
  bool isProjectSelected = false;
  // bool isGalleryOpened = false;
  bool isProjectInfoPage = false;
  String liveTourUrl = "";
  List<UpdateHistoryItem>? get updateHistory =>
      Get.find<LocalAppDataService>().getUpdateHistory();
  bool get needUpdate => checkNeedUpdate();

  getUser() {
    return user;
  }

  toggleLeftBarCollapsed() {
    isLeftBarOpened.value = !isLeftBarOpened.value;
  }

  projectSelected() {
    isProjectSelected = true;
  }

  projectClosed() {
    isProjectSelected = false;
  }

  // initUpdateCheckList() {
  //   List<bool?> result = [];
  //   result.add(_appService.checkNeedUpdate());
  //   needUpdateCheckList.value = result;
  // }

  onTapHome() {
    isLeftBarOpened.value = false;
    isProjectSelected = false;
    curDrawing.value = Drawing();
    Get.offAllNamed(Routes.PROJECT_LIST);
  }

  onTapSendDataToServer() async {
    // 서버로 데이터 전송" 버튼을 눌렀을 때 실행되는 함수
    // 앱에서 로컬에 저장된 변경된 데이터를 서버에 동기화(sync) 하는 핵심 함수
    isLeftBarOpened.value = false;
    // Wi-Fi / LTE / Ethernet 연결 여부 확인
    List<ConnectivityResult> connectivityResult =
        await Connectivity().checkConnectivity();
    if (!connectivityResult.contains(ConnectivityResult.wifi) &&
        !connectivityResult.contains(ConnectivityResult.ethernet) &&
        !connectivityResult.contains(ConnectivityResult.mobile)) {
      return await EasyLoading.showInfo('네트워크 연결이 필요합니다.');
    }

    // List<EditedProject> editedProjectList = _localMachineDataService.getEditedProjectList();
    List<CustomPicture> changedPictures =
        _localGalleryDataService.PictureList.where(
      (element) => element.state != DataState.NOT_CHANGED.index,
    ).toList();
    // DataState.NEW, EDITED, DELETED 상태인 사진만 골라냄

    int totalCount = changedPictures.length;
    // print("TOTAL: $totalCount");
    // print("UPLOAD: ${_localGalleryDataService.PictureList.where(
    //   (element) => element.state == DataState.NEW.index,
    // ).length}");
    // print("UPDATE: ${_localGalleryDataService.PictureList.where(
    //   (element) => element.state == DataState.EDITED.index,
    // ).length}");
    // print("DELETE: ${_localGalleryDataService.PictureList.where(
    //   (element) => element.state == DataState.DELETED.index,
    // ).length}");

    print("changedPictures: ${changedPictures.toList()}");
    print("changedPictures: ${changedPictures[0].toJson()}");
    // 새로 추가된 경우 state : 0, 수정된 경우 state : 1, 삭제된 경우 state : 2
    if (totalCount < 1) {
      // initUpdateCheckList();
      // 전송할 게 없으면 바로 리턴
      Fluttertoast.showToast(msg: "변경할 리스트가 없습니다");
      return;
    }

    int currentCount = 0;
    // 진행 상황 표시용 프로그레스 띄움
    await EasyLoading.showProgress(
      currentCount / totalCount,
      status: '서버 전송중...\n$currentCount/$totalCount',
      maskType: EasyLoadingMaskType.black,
    );

    // if (mid == null) {
    //   int updatedEditedProjectCount = await _appService.updateEditedProject(
    //     totalCount: totalCount,
    //     currentCount: currentCount,
    //   );
    //   if (updatedEditedProjectCount >= 0) currentCount += updatedEditedProjectCount;
    // }

    try {
      // 1. 새로 추가된 사진 업로드
      int uploadedPicCount = await uploadPicture(
        totalCount: totalCount,
        currentCount: currentCount,
      );
      if (uploadedPicCount >= 0) currentCount = uploadedPicCount;

      // 2. 수정된 사진 업데이트
      int updatedPicCount = await updatePicture(
        totalCount: totalCount,
        currentCount: currentCount,
      );
      if (updatedPicCount >= 0) currentCount = updatedPicCount;

      // 3. 삭제된 사진 제거
      int deletedPicCount = await deletePicture(
        totalCount: totalCount,
        currentCount: currentCount,
      );
      if (deletedPicCount >= 0) currentCount = deletedPicCount;
    } on Exception catch (e) {
      await EasyLoading.dismiss();
      Fluttertoast.showToast(msg: "전송중 에러가 발생했습니다. $e");
    }

    await uploadCompleted();
    // initUpdateCheckList();
    Fluttertoast.showToast(msg: "전송이 완료되었습니다!");
    // 완료 메시지 표시

    // ProjectGalleryController projectGalleryController = Get.find();
    // projectGalleryController.fetchData();
    isLeftBarOpened.refresh();

    // 좌측 바 상태 갱신 및 갤러리 다시 로드
    LocalGalleryDataService localGalleryDataService =
        Get.find<LocalGalleryDataService>();
    // GetX에서 전역으로 등록된 클래스 인스턴스를 가져오는 의존성 주입(DI) 함수
    // 앱 시작할 때 LocalGalleryDataService를 등록해놨기 때문에 (Get.put(...))
    // 어디서든 Get.find()로 가져와서 사용할 수 있음

    localGalleryDataService.fetchGalleryPictures();
    // 로컬에 저장된 사진들(PictureList 등)을 다시 불러오는 메서드

    await EasyLoading.dismiss();
  }

  onTapGallery() {
    isLeftBarOpened.value = false;
    Get.toNamed(Routes.PROJECT_GALLERY, arguments: curProject);

    // if (!isGalleryOpened) {
    //   _localGalleryDataService.fetchGalleryPictures();
    // } else {
    //   Get.offNamedUntil(
    //       Routes.PROJECT_GALLERY, ModalRoute.withName('/project-gallery'));
    //   Get.back();
    // }
  }

  cameraSelected() async {
    ImagePicker picker = ImagePicker();
    XFile? file = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: imageQuality,
      maxWidth: imageMaxWidth,
    );
    if (file != null) {
      String savedFilePath = await savePhotoToExternal(File(file.path));
      // File resizedFile = await compressImage(file);

      String? floorName;
      if (curDrawing.value.seq != null) {
        Drawing drawing = drawingList.singleWhere(
            (element) => element.seq == curDrawing.value.seq,
            orElse: () => Drawing());
        floorName = drawing.floor_name;
      }
      makeNewPicture(
        pid: createId(),
        projectSeq: curProject!.value.seq!,
        filePath: savedFilePath,
        thumb: savedFilePath,
        kind: curDrawing.value.seq != null ? "현황" : "기타",
        dong: curDrawing.value.dong,
        floorName: floorName,
        dataState: DataState.NEW,
      );

      // await searchPicture(projectSeq: curProject!.value.seq!) ?? [];

      isLeftBarOpened.value = true;
      isLeftBarOpened.value = false;

      // ProjectGalleryController projectGalleryController = Get.find();
      // projectGalleryController.fetchData();
    }
  }

  onTapViewer(BuildContext context, String url) {
    // launchUrl(Uri.parse(liveTourUrl));
    Uri? uri = Uri.tryParse(url);
    if (uri != null && uri.isAbsolute) {
      showDialog(
        // barrierColor: Colors.transparent,
        context: context,
        builder: (context) {
          return Web3dView(
            url: url,
          );
        },
      );
    } else {
      Fluttertoast.showToast(msg: "유효하지 않은 URL입니다");
    }
    isLeftBarOpened.value = false;
  }

  Future<File> compressImage(XFile file) async {
    // 원본 이미지 로드
    final originalImage = File(file.path);
    final bytes = await originalImage.readAsBytes();

    // 이미지 디코딩 및 크기 조정
    final decodedImage = img.decodeImage(bytes);
    final resizedImage = img.copyResize(decodedImage!,
        width: 1200, height: 900); // 원하는 크기로 조정 (300x300)

    // 크기 조정된 이미지 저장
    final resizedBytes = Uint8List.fromList(img.encodeJpg(resizedImage));
    final resizedFile = File(file.path.replaceFirst('.jpg', '_resized.jpg'));
    await resizedFile.writeAsBytes(resizedBytes);
    return resizedFile;
  }

  Future<String> savePhotoToExternal(File photo) async {
    // 사진 저장할 디렉토리 경로 생성
    // 이 함수는 촬영한 사진 파일을 기기 저장소의 특정 폴더에 복사해서 영구 보관하는 역할을 해!
    // 실제로 Android 기기에서 사진을 외부 저장소(=사용자 파일 시스템) 에 저장해두는 로직
    //  photo → 방금 촬영한 사진 파일
    // Future 비동기 함수: 파일 시스템 접근과 디렉토리 생성, 복사 등이 async이기 때문
    final Directory? appPicturesDir = await getExternalStorageDirectory();
    // 외부 저장소 디렉토리 접근
    // getExternalStorageDirectory()는 안드로이드 기준으로 다음 경로를 반환해:
    // /storage/emulated/0/Android/data/com.your.app.name/files
    final String rootPath =
        appPicturesDir!.path.split("/").sublist(0, 4).join('/');
    // 결국 rootPath는: /storage/emulated/0
    final String targetPath = join(rootPath, 'Pictures/Elim/Safety');
    // 이 경로는 실제로 사진이 저장될 경로야:
    // /storage/emulated/0/Pictures/Elim/Safety
    // 사진 앱에서 접근 가능하게 하려는 목적도 있음 (갤러리 앱에서 보이도록)
    final Directory targetDir = Directory(targetPath);

    // 디렉토리가 없으면 생성
    if (!await targetDir.exists()) {
      await targetDir.create(recursive: true);
      // 해당 폴더가 없으면 생성
      // 중간 경로(Pictures, Elim)가 없어도 함께 생성
    }

    // 촬영된 사진 파일 저장
    final String fileName = basename(photo.path); // 원본 파일 이름 가져오기
    // 파일명 추출
    final String savedFilePath = join(targetDir.path, fileName);
    // 이런느낌으로 변한다 -> savedFilePath: /storage/emulated/0/Pictures/Elim/Safety/123456.jpg

    // 파일 복사
    try {
      await File(photo.path).copy(savedFilePath);
    } catch (e) {
      print('파일 저장 중 오류: $e');
      Fluttertoast.showToast(msg: '사진 저장 실패!');
      return ''; // 혹은 적절한 fallback
    }
    Fluttertoast.showToast(msg: "사진이 태블릿에 저장되었습니다.");
    return savedFilePath;
  }
}

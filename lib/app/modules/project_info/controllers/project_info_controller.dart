import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:safety_check/app/constant/constants.dart';
import 'package:safety_check/app/constant/data_state.dart';
import 'package:safety_check/app/data/models/03_marker.dart';
import 'package:safety_check/app/data/models/04_fault.dart';
import 'package:safety_check/app/data/models/05_picture.dart';
import 'package:safety_check/app/data/services/app_service.dart';
import 'package:safety_check/app/data/services/local_gallery_data_service.dart';
import 'package:safety_check/app/modules/check_image/controllers/check_image_controller.dart';
import 'package:safety_check/app/modules/project_gallery/controllers/project_gallery_controller.dart';
import '../../../routes/app_pages.dart';

class ProjectInfoController extends GetxController {
  final AppService appService;
  final LocalGalleryDataService _localGalleryDataService;
  TextEditingController searchController = TextEditingController();

  final requirementTextController = TextEditingController();
  RxBool isRequirementChanged = false.obs;
  late FocusNode requirementFocus = FocusNode();
  RxBool requirementFocused = false.obs;
  RxInt isMyPlace = 0.obs;

  ProjectInfoController(
      {required this.appService,
      required LocalGalleryDataService localGalleryDataService})
      : _localGalleryDataService = localGalleryDataService;

  RxBool isFaultListAll = false.obs;

  RxList<Marker> markerList = <Marker>[].obs;
  List drawingList = [];
  List<Fault> faultList = [];

  RxMap<String, List<Fault>> tableMarkerData = <String, List<Fault>>{}.obs;
  // RxMap 타입 수정 (동이름>층>마커별 결함 목록)
  RxMap<String, Map<int, Map<String, List<Fault>>>> tableData =
      <String, Map<int, Map<String, List<Fault>>>>{}.obs;
  int curRowIndex = -1;

  ScrollController scrollController = ScrollController();

  // 포커스 해제 메서드
  void unfocus() {
    if (requirementFocus.hasFocus) {
      requirementFocus.unfocus();
    }
  }

  @override
  Future<void> onInit() async {
    appService.isProjectInfoPage = true;

    // FocusNode 초기화
    requirementFocus = FocusNode();

    // 3D 버튼 보임 여부
    appService.liveTourUrl = appService.curProject?.value.live_tour_url ?? "";

    requirementFocus.addListener(() {
      requirementFocused.value = requirementFocus.hasFocus;
      if (requirementFocused.value) {
        // 키보드가 올라오면 약간의 딜레이 후 스크롤 조정
        Future.delayed(Duration(milliseconds: 300), () {
          if (scrollController.hasClients) {
            final viewInsets = MediaQuery.of(Get.context!).viewInsets.bottom;
            // 현재 스크롤 위치에서 키보드 높이만큼 추가로 스크롤
            scrollController.animateTo(
              scrollController.offset + viewInsets + 40,
              duration: Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        });
      } else {
        // 키보드가 내려갔을 때
        if (isRequirementChanged.value) {
          appService.curProject!.value.requirement =
              requirementTextController.text;

          // API 호출
          appService.submitProject(appService.curProject!.value);

          isRequirementChanged.value = false;
        }
      }
    });

    requirementTextController.text =
        appService.curProject!.value.requirement ?? "";

    // 텍스트 변경 리스너
    requirementTextController.addListener(() {
      if (requirementTextController.text !=
          appService.curProject!.value.requirement) {
        isRequirementChanged.value = true;
      }
    });

    // requirementFocus.addListener(() {
    //   if (!requirementFocus.hasFocus) {
    //     unfocus();
    //   } else {
    //     final viewInsets = MediaQuery.of(Get.context!).viewInsets.bottom;
    //     scrollController.animateTo(
    //       scrollController.offset + viewInsets * 0.7,
    //       duration: Duration(milliseconds: 300),
    //       curve: Curves.easeOut,
    //     );
    //   }
    // });

    Get.put(ProjectGalleryController(
        appService: Get.find(), localGalleryDataService: Get.find()));

    await EasyLoading.dismiss();

    await fetchData();
    countFaults();

    super.onInit();
  }

  @override
  void dispose() {
    scrollController.dispose();
    requirementTextController.dispose();
    requirementFocus.dispose();
    super.dispose();
  }

  Future fetchData() async {
    await EasyLoading.show();

    // 마커 목록
    markerList.value = await appService.getMarkerList(
            projectSeq: appService.curProject!.value.seq) ??
        [];
    if (markerList.isNotEmpty) {
      markerList.sort(
        (a, b) => int.parse(a.no!).compareTo(int.parse(b.no!)),
      );
    }

    // 결함 목록
    faultList = [];
    for (Marker marker in markerList) {
      faultList.addAll(marker.fault_list ?? []);

      // Load pictures from local gallery for each fault
      for (Fault fault in faultList) {
        List<CustomPicture>? pictures = loadGallery(fault.fid ?? "");
        fault.picture_list = pictures;
      }
    }
    if (faultList.isNotEmpty) {
      appService.selectedFault.value = faultList[0];
    }

    countFaults();

    await EasyLoading.dismiss();
  }

  // 번호별 결함 수 확인
  // 번호별 결함 수 확인 메서드 수정
  void countFaults() {
    String markerNo = "";
    tableMarkerData.value = {};
    appService.displayingFid = {};
    tableData.clear();

    // 동이름과 층별로 마커 그룹화
    Map<String, Map<int, List<Marker>>> markersByDongAndFloor = {};

    for (Marker marker in markerList) {
      String dong = marker.dong ?? "기타";
      int floor = int.parse(marker.floor ?? "0");

      // 동 데이터 초기화
      if (!markersByDongAndFloor.containsKey(dong)) {
        markersByDongAndFloor[dong] = {};
      }

      // 층 데이터 초기화
      if (!markersByDongAndFloor[dong]!.containsKey(floor)) {
        markersByDongAndFloor[dong]![floor] = [];
      }

      // 해당 동과 층에 마커 추가
      markersByDongAndFloor[dong]![floor]!.add(marker);
    }

    // 동이름 키를 오름차순으로 정렬
    List<String> sortedDongNames = markersByDongAndFloor.keys.toList()..sort();

    // 정렬된 동이름 순서대로 처리
    for (var dong in sortedDongNames) {
      var floorMap = markersByDongAndFloor[dong];

      tableData[dong] = {};

      // 층 이름 내림차순으로 정렬
      List<int> sortedFloorNames = floorMap!.keys.toList()
        ..sort((a, b) => b.compareTo(a));

      // 정렬된 층 순서대로 처리
      for (var floor in sortedFloorNames) {
        List<Marker> markers = floorMap[floor]!;

        // 층별 데이터 초기화
        tableData[dong]![floor] = {};

        // 마커별 결함 데이터 처리
        for (Marker marker in markers) {
          markerNo = marker.no ?? "";
          List<Fault> markerFaults = marker.fault_list ?? [];

          // 마커에 결함 데이터 추가

          // 결함 처리 (기존 로직 유지)
          for (Fault fault in markerFaults) {
            // 결함 전체 목록에 추가
            if (!faultList.contains(fault)) {
              faultList.add(fault);
            }

            // 그룹 파울트 ID 처리
            if (appService.displayingFid[fault.group_fid] == null) {
              appService.displayingFid[fault.group_fid!] = fault.fid!;
            }

            if (!tableData[dong]![floor]!.containsKey(markerNo)) {
              tableData[dong]![floor]![markerNo] = [];
            }
            tableData[dong]![floor]![markerNo]!.add(fault);
          }
        }
      }
    }

    // _appService.selectedFault.value = fault;
    appService.isFaultSelected.value = false;
  }

  showImage() {
    List<CustomPicture> pictureList = _localGalleryDataService
        .getPictureInProject(projectSeq: appService.curProject!.value.seq!);
    CustomPicture? pic =
        pictureList.where((pic) => pic.kind == "전경").toList().firstOrNull;
    if (pic != null) Get.toNamed(Routes.CHECK_IMGAGE, arguments: pic);
  }

  // 홈으로
  goHome() {
    requirementFocus.unfocus();
    appService.isProjectSelected = false;
    appService.liveTourUrl = "";
    Get.offAllNamed(Routes.PROJECT_LIST);
  }

  // 도면목록
  goDrawingList() {
    Get.toNamed(Routes.DRAWING_LIST);
  }

  // 현장점검표
  goCheckList() {
    Get.toNamed(Routes.PROJECT_CHECK_LIST);
  }

  List<CustomPicture>? loadGallery(String fid) {
    return _localGalleryDataService.loadGallery(fid);
  }

  // 테이블 결함 선택
  void onTapRow(Fault fault) {
    // _appService.selectedFault.value = fault;
    // _appService.isFaultSelected.value = true;
  }

  // 전경사진 촬영
  takeProjectPicture() async {
    // 👉 사진 파일을 저장하고
    // 👉 Hive에 추가하고
    // 👉 UI 상태를 갱신해서
    // 👉 나중에 서버에 업로드할 수 있도록 DataState.NEW 상태로 등록하는 과정

    final ImagePicker imagePicker = ImagePicker();
    // image_picker 패키지로 카메라 촬영을 시작
    XFile? xFile = await imagePicker.pickImage(
      source: ImageSource.camera,
      imageQuality: imageQuality,
      maxWidth: imageMaxWidth,
    );
    print('여기요!2222');
    // 촬영 완료 시 XFile 객체로 사진 정보 획득
    if (xFile != null) {
      // File file = await appService.compressImage(xImage);
      String savedFilePath =
          await appService.savePhotoToExternal(File(xFile.path));
      print('여기요!3333');
      // 원래 카메라에서 생성된 임시 사진 파일을
      // 앱이 관리하는 디렉토리로 복사 → 파일을 안전하게 관리하기 위함
      //  "savePhotoToExternal()까지가 사진을 파일 시스템에 안전하게 저장하는 과정"

      CustomPicture projectPicture = appService.makeNewPicture(
        pid: appService.createId(),
        projectSeq: appService.curProject!.value.seq!,
        filePath: savedFilePath,
        thumb: xFile.path,
        kind: "전경",
        dong: "",
        floorName: "",
        dataState: DataState.NEW,
      );
      print('여기요!4444');
      appService.curProject!.value.picture = savedFilePath;
      appService.curProject!.value.picture_pid = projectPicture.pid;
      appService.curProject!.value.picture_cnt =
          (int.parse(appService.curProject!.value.picture_cnt!) + 1).toString();

      _localGalleryDataService.loadGalleryFromHive();
      appService.curProject!.refresh();
      appService.projectList.refresh();
      appService.isLeftBarOpened.refresh();
    }
  }
}

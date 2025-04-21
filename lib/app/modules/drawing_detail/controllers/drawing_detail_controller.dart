import 'dart:io';

import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:safety_check/app/constant/constants.dart';
import 'package:safety_check/app/constant/data_state.dart';
import 'package:safety_check/app/data/models/05_picture.dart';
import 'package:safety_check/app/data/models/10_elem_list.dart';
import 'package:safety_check/app/data/models/11_drawing_memo.dart';
import 'package:safety_check/app/data/services/local_gallery_data_service.dart';
import 'package:safety_check/app/modules/drawing_detail/views/drawing_memo.dart';
import 'package:safety_check/app/modules/drawing_list/controllers/drawing_list_controller.dart';

import '../../../data/models/02_drawing.dart';
import '../../../data/models/03_marker.dart';
import '../../../data/models/04_fault.dart';
import '../../../data/models/09_appended.dart';
import '../../../data/services/app_service.dart';
import '../../../routes/app_pages.dart';
import '../views/drawing_help_dialog.dart';

class DrawingDetailController extends GetxController {
  final AppService appService;
  final LocalGalleryDataService _localGalleryDataService;
  final ImagePicker imagePicker = ImagePicker();

  late ScrollController cScrollController;
  late TextEditingController cate1Controller;
  late TextEditingController cate2Controller;
  late TextEditingController memoTextController;

  double lastScreenWidth = 0;
  double lastScreenHeight = 0;

  DrawingDetailController(
      {required AppService appService1,
      required LocalGalleryDataService localGalleryDataService})
      : appService = appService1,
        _localGalleryDataService = localGalleryDataService;

  bool get offlineMode => appService.isOfflineMode.value;

  String? drawingUrl;

  RxBool isDrawingSelected = true.obs;

  RxBool isNumberSelected = false.obs;
  RxBool isPointSelected = false.obs;
  Rx<Marker> selectedMarker = Rx(Marker(no: "1"));
  RxBool clrPickerOpened = false.obs;

  RxBool isGrouping = false.obs;
  RxBool addMemoMode = false.obs;
  Rxn<DrawingMemo> curDrawingMemo = Rxn<DrawingMemo>();
  FocusNode drawingMemoFocusNode = FocusNode();

  RxList<Marker> markerList = <Marker>[].obs;
  List<Fault> faultList = [];

  // RxMap<String, List<Fault>> tableData = <String, List<Fault>>{}.obs;
  RxMap<String, List<Fault>> tableMarkerData = <String, List<Fault>>{}.obs;
  RxMap<String, Map<int, Map<String, List<Fault>>>> tableData =
      <String, Map<int, Map<String, List<Fault>>>>{}.obs;

  RxString tempCate1 = "".obs;
  RxString tempCate2 = "".obs;

  // 번호에 결합된 그룹 (번호에 선 몇 개 이어졌는지 체크용)
  Map<String, List<Fault?>> groupsLinkedToMarker = {};
  double drawingWidth = 0;
  double drawingHeight = 0;
  double drawingX = 0;
  double drawingY = 0;
  double markerSize = 20;
  double faultSize = 8;
  double fontSize = 16;
  RxBool isMarkerColorChanging = false.obs;
  RxBool isBorderColorChanging = false.obs;
  RxBool isMovingNumOrFault = false.obs;
  Rxn<CustomPicture> memoPicture = Rxn<CustomPicture>();

  String get projectName => appService.projectName;
  String get imageDescription => appService.drawingName;
  List<ElementList>? get elements => appService.elements;

  @override
  void onInit() async {
    cScrollController = ScrollController();
    memoTextController = TextEditingController();

    // 텍스트 변경 리스너
    memoTextController.addListener(() {
      // curDrawingMemo.value?.memo = memoTextController.text;
    });

    memoPicture.value = null;

    appService.curDrawing.value = Get.arguments as Drawing;
    drawingUrl = appService.curDrawing.value.file_path;
    markerSize = double.parse(appService.curDrawing.value.marker_size ?? "20");
    await fetchData();
    if (markerList.isNotEmpty) {
      markerSize = double.parse(markerList.first.size ?? "20");
    }
    fontSize = 16 * markerSize / 32;
    faultSize = markerSize / 4;
    countFaults();
    super.onInit();
  }

  @override
  void dispose() {
    cScrollController.dispose();
    memoTextController.dispose();
    drawingMemoFocusNode.dispose();

    super.dispose();
  }

  onTapBack() {
    if (appService.isFaultSelected.value || isNumberSelected.value) {
      appService.isFaultSelected.value = false;
      isNumberSelected.value = false;
    } else {
      Get.back();
    }
  }

  refreshScreen() {
    Get.offNamed(Routes.DRAWING_DETAIL, arguments: appService.curDrawing);
  }

  Future<void> fetchData() async {
    // Jenny 결함 리스트를 불러오는 부분!
    await EasyLoading.show(maskType: EasyLoadingMaskType.clear);
    markerList.value = await appService.getMarkerList(
            drawingSeq: appService.curDrawing.value.seq) ??
        [];
    // print("마커리스트(동그라미 네모) : ${markerList}");
    if (markerList.isNotEmpty) {
      markerList.sort(
        (a, b) => int.parse(a.no!).compareTo(int.parse(b.no!)),
      );
      selectedMarker.value = markerList.first;
    }
    faultList = [];
    for (Marker marker in markerList) {
      faultList.addAll(marker.fault_list ?? []);

      // Load pictures from local gallery for each fault
      for (Fault fault in marker.fault_list ?? []) {
        List<CustomPicture>? pictures = loadGallery(fault.fid ?? "");
        if (pictures?.isNotEmpty ?? false) {
          fault.picture_list = pictures;
        }
      }
    }
    if (faultList.isNotEmpty) {
      appService.selectedFault.value = faultList[0];
    }
    // 설비목록 가져오기
    if (offlineMode) {
      // for (Marker drawing in markerList) {
      //   // appService.reflectAllChangesInProject(project_seq: project.seq!);
      // }
    }
    countFaults();
    EasyLoading.dismiss();
  }

  void openUrl(BuildContext context, String? url) {
    appService.onTapViewer(context, url ?? "");
  }

  bool isKeyboardVisible(BuildContext context) {
    return MediaQuery.of(context).viewInsets.bottom > 0;
  }

  changeNumber(String value) {
    List<Fault>? changingFault = selectedMarker.value.fault_list;
    for (Fault fault in changingFault ?? []) {
      fault.marker_no = value;
      editFault(fault);
    }
    selectedMarker.value.no = value;
    editMarker(selectedMarker.value);
    isNumberSelected.value = false;
  }

  changeMarkerSize(num? value) {
    isNumberSelected.value = false;
    markerSize = value!.toDouble();
    fontSize = 16 * markerSize / 32;
    faultSize = markerSize / 4;
    editMarker(selectedMarker.value);
    isNumberSelected.value = true;
    DrawingListController drawingListController = Get.find();
    drawingListController.drawingList.map(
      (e) => e.marker_size = value.toString(),
    );
  }

  // 번호별 결함 수 확인 메서드 수정
  void countFaults() {
    // 모든 마커를 동 → 층 → 마커 번호 → 결함 목록 구조로 분류하고,
    // 결함들을 그룹핑하며 관련 상태값(faultList, tableData, groupsLinkedToMarker, displayingFid)들을
    // 갱신하는 함수.
    String markerNo = "";
    tableMarkerData.value = {};
    appService.displayingFid = {};
    tableData.clear();
    // 내부에서 쓸 임시 변수 초기화

    // 동이름과 층별로 마커 그룹화
    Map<String, Map<int, List<Marker>>> markersByDongAndFloor = {};
    // 동 → 층 → 마커 리스트 형태로 마커들을 그룹핑할 목적

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

            // 마커에 연결된 그룹 처리
            if (groupsLinkedToMarker[markerNo] == null) {
              groupsLinkedToMarker[markerNo] = [fault];
            } else if (!groupsLinkedToMarker[markerNo]!.contains(fault)) {
              groupsLinkedToMarker[markerNo]!.add(fault);
            }
          }
        }
      }
    }
  }

  Future<void> onLongPress(List<String> position, String mfGap) async {
    String? mid = await addMarker(
        position, mfGap); // 서버에 마커를 생성하고, 그 결과로 마커 ID(mid) 를 리턴함
    await addFault(position, mid);
    // 이어서 addFault() 호출로 결함 추가
    // 이때 위에서 받은 mid를 전달해서 해당 마커에 결함이 붙도록 연결
    // addFault()는 결함 정보를 서버에 전송하고, 로컬 상태에 반영함
  }

  Future<String?> sortMarker() async {
    String drawingSeq = appService.curDrawing.value.seq!;
    String? result = await appService.sortMarker(drawingSeq: drawingSeq);
    fetchData();
    countFaults();
    selectedMarker.value = markerList.first;
    appService.isFaultSelected.value = true;
    appService.isFaultSelected.value = false;
    return result;
  }

  // 마커 추가
  // 도면 위에 새로운 마커(번호) 를 추가할 때 실행되는 코드
  Future<String?> addMarker(List<String> position, String mfGap) async {
    // position: 마커를 추가할 좌표 ([x, y])
    // mfGap: 보정값 (ex: 마커가 아래로 밀리는 현상 방지 등)
    // 반환값: Future<String?>: 새로 생성된 마커의 mid (마커 ID) 혹은 실패 시 null
    var mid =
        appService.createId(); // 고유한 ID를 만들기 위해 AppService에서 현재 시간 기반 ID 생성
    Marker newMarker = Marker(
        drawing_seq: appService
            .curDrawing.value.seq, // drawing_seq: 현재 도면의 ID (이 마커가 어느 도면에 속하는지)
        x: position[0], // 클릭한 위치의 x좌표
        y: (double.parse(position[1]) - double.parse(mfGap)).toString(),
        // y좌표에서 mfGap만큼 보정 (디자인적으로 마커 위치 살짝 위로 올릴 수도 있음)
        mid: mid
        // mid: 위에서 생성한 고유 마커 ID
        );
    String? lastFaultSeq;
    if (faultList.isNotEmpty) {
      lastFaultSeq = faultList.last.seq;
    } // 마지막 결함 번호 가져오기 (병합/정렬용)
    Map? result = await appService.submitMarker(
        isNew: true, marker: newMarker, lastFaultSeq: lastFaultSeq);
    // 서버에 마커 등록 요청
    // isNew: true → 새 마커임을 명시
    if (result != null) {
      // 결과 있으면 → 로컬 상태 반영
      Marker resultMarker = result["marker"];
      // 응답으로 받은 마커 객체를 resultMarker로 파싱
      resultMarker.fault_list = []; // 아직 결함은 없으니 초기화
      resultMarker.fault_cnt = 0; // 아직 결함은 없으니 초기화
      markerList.add(resultMarker); // markerList에 새 마커 추가
      if (result["appended"] != null) {
        applyChanges(result["appended"]);
        // 서버에서 마커 외에도 결함, 사진 등 관련 정보가 추가로 왔다면
        // applyChanges()로 그걸 반영함
      }
      countFaults(); // 마커가 새로 생겼으니 결함 목록을 다시 정리해서 테이블 업데이트

      return result["marker"].mid ?? appService.createId();
      // 마커 ID를 리턴/ 만약 응답에 mid가 없으면 새로 생성
    } else {
      Fluttertoast.showToast(msg: "번호 추가에 실패하였습니다.");
      countFaults();
      return null;
    }
  }

  Future<String?> editMarker(Marker marker) async {
    Marker newMarker = marker;
    String? lastFaultSeq;
    if (faultList.isNotEmpty) {
      lastFaultSeq = faultList.last.seq;
    }
    Map? result = await appService.submitMarker(
        isNew: false,
        marker: newMarker,
        lastFaultSeq: lastFaultSeq,
        markerSize: markerSize.toString());
    if (result != null) {
      if (result["appended"] != null) {
        applyChanges(result["appended"]);
      }
      countFaults();
      return result["marker"].mid ?? appService.createId();
    } else {
      Fluttertoast.showToast(msg: "번호 추가에 실패하였습니다.");
      countFaults();
      return null;
    }
  }

  overrideMarker(BuildContext context, Marker fromM, Marker toM) async {
    Appended? appended;
    if (fromM.seq != null && toM.seq != null) {
      appended = await appService.overrideMarker(
          fromSeq: fromM.seq!,
          toSeq: toM.seq!,
          lastFaultSeq: faultList.last.seq);
      // 덮어쓰기 매커니즘 (fromMarker의 모든 결함을 toMarker의 첫번째 결함의 내용으로 바꾸고 옮긴후 삭제)
      Fault? objFault = fromM.fault_list?.first;
      if (objFault != null) {
        for (Fault fault in toM.fault_list ?? []) {
          Fault newFault = objFault.copyWoPic();
          fault.user_seq = newFault.user_seq;
          fault.location = newFault.location;
          fault.elem_seq = newFault.elem_seq;
          fault.cate1_seq = newFault.cate1_seq;
          fault.width = newFault.width;
          fault.length = newFault.length;
          fault.qty = newFault.qty;
          fault.structure = newFault.structure;
          fault.status = newFault.status;
          fault.deleted = newFault.deleted;
          fault.cause = newFault.cause;
          fault.reg_time = newFault.reg_time;
          fault.update_time = newFault.update_time;
          fault.user_name = newFault.user_name;
          fault.elem = newFault.elem;
          // fault.marker_no = newFault.marker_no;
          fault.drawing_seq = newFault.drawing_seq;
          fault.project_seq = newFault.project_seq;
          fault.dong = newFault.dong;
          fault.floor = newFault.floor;
          fault.cate1_name = newFault.cate1_name;
          fault.cate2 = newFault.cate2;
          fault.cate2_name = newFault.cate2_name;
          fault.pic_no = newFault.pic_no;
        }
      }
      // toM.no = fromM.no;
      isNumberSelected.value = true;
      isNumberSelected.value = false;
    }
    if (appended != null) {
      applyChanges(appended);
    }
    countFaults();
    FocusScope.of(context).unfocus();
  }

  // 마커 합치기 JENNY TODO
  mergeMarker(BuildContext context, Marker fromM, Marker toM) async {
    // fromM의 결함(Fault)을 toM에 통합
    // fromM 마커는 삭제하는 방식의 병합 처리
    // 병합 결과가 있으면 applyChanges()로 반영
    // UI 포커스도 정리함
    Map? result;
    if (fromM.seq != null && toM.seq != null) {
      // 두 마커 모두 서버에 저장된 마커인지 확인 (seq != null)
      // 즉, 아직 저장되지 않은 마커라면 병합이 불가능함 (데이터 무결성 유지)
      result = await appService.mergeMarker(
          fromSeq: fromM.seq!,
          toSeq: toM.seq!,
          lastFaultSeq: faultList.last.seq);
      // 합치기 매커니즘 (fromMarker의 모든 결함을 toMarker로 옮기고 삭제)
      // 서버에는 변경 요청을 이미 보냈지만,
      // 로컬(클라이언트)의 상태도 맞춰줘야 하기 때문이야.
      for (Fault fault in fromM.fault_list ?? []) {
        fault.mid = toM.mid;
        fault.marker_seq = toM.seq;
        fault.marker_no = toM.no;
        toM.fault_list?.add(fault);
      }
      markerList.remove(fromM); // 병합 대상이었던 마커(fromM)를 로컬 마커 리스트에서 삭제함
      // 서버에서 이미 삭제된 마커와 동기화하는 거
      selectedMarker.value = markerList.first;
      // 병합 후에는 기존에 선택되었던 마커(fromM)가 사라졌으므로 → 임시로 첫 번째 마커를 선택
      isNumberSelected.value = true;
      isNumberSelected.value = false;
      // 리셋 효과를 주기 위해 쓰는 방법
    }
    if (result?["appended"] != null) {
      applyChanges(result?["appended"]);
      // result는 AppService.mergeMarker()를 통해 서버에서 받은 병합 결과지.
      // 그 안에 "appended"라는 key가 있다면:
      // 서버에서 추가적으로 업데이트된 데이터가 있다는 뜻이야.
      // 예: 새 마커, 새 결함, 변경된 마커 리스트 등
      // applyChanges()는 그 데이터(Appended)를 클라이언트 로컬 상태에 적용하는 함수
    }
    countFaults(); // 전체 결함 수를 계산해서 상태에 반영
    FocusScope.of(context).unfocus();
  }

  // 마커 분리
  Future<void> detachMarker(BuildContext context) async {
    // 새로운 마커를 추가하는 코드
    Marker originMarker = selectedMarker.value;

    // 1. 그룹화 fid 기준으로 그룹화된 결함 리스트 만들기
    Map<String, List<Fault>> groupedByFid = {};
    for (Fault fault in originMarker.fault_list ?? []) {
      String group_fid = fault.group_fid ?? "";
      if (!groupedByFid.containsKey(group_fid)) {
        groupedByFid[group_fid] = [];
      }
      groupedByFid[group_fid]!.add(fault);
    }
    // print("groupedByFid: $groupedByFid");
    // groupedByFid: {20250414143659101777: [Instance of 'Fault'], 20250415113030942640: [Instance of 'Fault']}

    if (groupedByFid.length == 1) {
      Fluttertoast.showToast(msg: "결함이 한 종류일 땐 분리할 수 없습니다.");
      return;
    }
    // 2. 가장 큰 번호 계산
    // int maxNo = 0;
    // 현재 존재하는 마커들 중에서 가장 큰 번호(max no) 를 계산하는 거
    // for (final marker in markerList) {
    // markerList에 있는 모든 마커를 하나씩 반복
    // int? number = int.tryParse(marker.no ?? "0");
    // if (number != null && number > maxNo) maxNo = number;
    // 숫자가 유효하고(number != null)
    // 지금까지 찾은 최대값보다 크면
    // 그 숫자를 새로운 maxNo로 저장
    // }

    int idx = 0;
    for (String groupFid in groupedByFid.keys) {
      List<Fault> faults = groupedByFid[groupFid]!;
      // groupFid 그룹에 속한 결함 리스트를 가져옴
      // [Instance of 'Fault', Instance of 'Fault', ...]

      // 첫 번째 그룹은 원래 마커에 유지
      if (idx == 0) {
        idx++;
        continue;
      }

      // 4. 새로운 마커 추가
      String newX = (double.tryParse(faults[0].x ?? "0")?.toStringAsFixed(5)) ??
          "0.00000";
      String newY = (((double.tryParse(faults[0].y ?? "0") ?? 0) - 0.05)
              .toStringAsFixed(5)) ??
          "0.00000";
      Marker newMarker = Marker(
        drawing_seq: originMarker.drawing_seq,
        x: newX,
        y: newY,
        mid: appService.createId(),
        // size: originMarker.size,
        // fault_list: [],
        // seq: "",
        // no: (++maxNo).toString(),
      );

      // 마지막 결함 번호 가져오기
      String? lastFaultSeq;
      if (faultList.isNotEmpty) {
        lastFaultSeq = faultList.last.seq;
      }

      Map? result = await appService.submitMarker(
          isNew: true, marker: newMarker, lastFaultSeq: lastFaultSeq);

      if (result != null) {
        // 결과 있으면 → 로컬 상태 반영
        Marker resultMarker = result["marker"];
        // 응답으로 받은 마커 객체를 resultMarker로 파싱
        resultMarker.fault_list = []; // 아직 결함은 없으니 초기화
        resultMarker.fault_cnt = 0; // 아직 결함은 없으니 초기화
        markerList.add(resultMarker); // markerList에 새 마커 추가
        if (result["appended"] != null) {
          applyChanges(result["appended"]);
          // 서버에서 마커 외에도 결함, 사진 등 관련 정보가 추가로 왔다면
          // applyChanges()로 그걸 반영함
        }
        print("resultMarker: ${resultMarker.toJson()}");
        // I/flutter (22093): resultMarker: {seq: 5333, drawing_seq: 832, outline_color: FF0000, foreground_color: FFFFFF, x: 0.95873000, y: 0.45515001, no: 11, live_tour_url: null, reg_time: 2025-04-15 17:40:03, update_time: 2025-04-15 17:40:03, deleted: N, fault_list: [], fault_cnt: 0, mid: 20250415174003132750, project_seq: 217, dong: 101동, floor: null, first_fault_seq: null, size: 16, floor_name: null}

        // return result["marker"].mid ?? appService.createId();
        // 마커 ID를 리턴/ 만약 응답에 mid가 없으면 새로 생성
        // gpt야!
        for (Fault fault in faults) {
          // 1. 기존 마커에서 제거
          originMarker.fault_list?.remove(fault);

          // 2. 결함 정보를 새로운 마커 정보로 업데이트
          fault.mid = resultMarker.mid; // 새로운 마커 ID
          fault.marker_seq = resultMarker.seq; // 새로운 마커 seq
          fault.marker_no = resultMarker.no; // 새로운 마커 번호

          print("fault.seq: ${fault.seq}"); // 6165

          // 3. 서버에도 결함 위치 이동 업데이트
          Map? faultResult = await appService.submitFault(
            isNew: false,
            fault: fault,
            mid: resultMarker.mid,
            lastFaultSeq: lastFaultSeq,
          );
          print(
              "faultResult : ${faultResult}"); // {fault: Instance of 'Fault', appended: Instance of 'Appended'}
          if (faultResult != null) {
            resultMarker.fault_list?.add(fault); // ✅ 중요!
            resultMarker.fault_cnt = resultMarker.fault_list?.length ?? 0;

            if (faultResult["fault"] != null) {
              if (fault.cause != faultResult["fault"].cause) {
                fault.cause = faultResult["fault"].cause;
                appService.isFaultSelected.value = false;
                appService.isFaultSelected.value = true;
              }
            }
            if (faultResult["appended"] != null) {
              applyChanges(faultResult["appended"]);
            }
          }
          countFaults();
          // if (faultResult?["fault"] != null) {
          //   Fault updatedFault = faultResult!["fault"];
          //   faultList.add(updatedFault);

          //   // 새 마커에 결함 추가
          //   resultMarker.fault_list?.add(updatedFault);
          //   resultMarker.fault_cnt = resultMarker.fault_list?.length ?? 0;
          // }
        }
      } else {
        Fluttertoast.showToast(msg: "번호 추가에 실패하였습니다.");
        countFaults();
        return null;
      }

      // 5. 결함 이동
      // for (Fault fault in faults) {
      //   // 기존 마커에서 제거
      //   originMarker.fault_list?.remove(fault);

      //   // 새로운 마커에 연결
      //   fault.mid = newMarker.mid;
      //   fault.marker_seq = newMarker.seq;
      //   fault.marker_no = newMarker.no;

      //   newMarker.fault_list?.add(fault);
      // }
    }
    print("faultList : ${faultList}");
    for (Fault fault in faultList) {
      print("fault: ${fault.toJson()}");
    }
    // selectedMarker.value = markerList.first;
    // countFaults();
    // Fluttertoast.showToast(msg: "마커가 분리되었습니다.");
  }

  Future<void> delMarker() async {
    isNumberSelected.value = false;
    String markerSeq = selectedMarker.value.seq ?? "1";
    String? lastFaultSeq;
    if (faultList.isNotEmpty) {
      lastFaultSeq = faultList.last.seq;
    }
    Appended? appended = await appService.deleteMarker(
        markerSeq: markerSeq, lastFaultSeq: lastFaultSeq);

    if (appended != null) {
      applyChanges(appended);
    }

    markerList.remove(selectedMarker.value);

    if (markerList.isNotEmpty) {
      selectedMarker.value = markerList.first;
    } else {
      selectedMarker.value = Marker();
    }
    countFaults();
  }

  // 테이블 결함 추가
  // TODO Jenny 여기서 결함을 추가하는 것이다!
  Future<void> addFault(List<String> position, String? mid) async {
    // mid: 연결될 마커의 고유 ID
    Fault newFault = Fault(qty: "1");
    // 새로운 결함 객체를 생성하고
    // 기본 개수(qty)는 "1"로 설정
    String? lastFaultSeq;
    if (faultList.isNotEmpty) {
      Fault lastFault = faultList.last;
      newFault = lastFault.copyWoPic();
      // 마지막 결함을 사진 빼고 복사해서 사용 (copyWoPic())
      lastFaultSeq = faultList.last.seq;
    }
    newFault.x = position[0];
    newFault.y = position[1];
    newFault.fid = appService.createId(); // 고유 결함 ID
    newFault.group_fid = newFault.fid; // 그룹 ID도 동일하게 설정
    Map? result = await appService.submitFault(
        // submitFault()를 통해 서버에 새로운 결함 전송
        isNew: true,
        fault: newFault,
        mid: mid,
        lastFaultSeq: lastFaultSeq);
    if (result != null) {
      if (result["marker"] != null) {
        // 백엔드가 결함 저장 과정 중 마커도 함께 업데이트했을 경우에도 포함될 수 있어.
        // "마커가 없었던 경우"뿐 아니라 "있던 마커에 변경사항이 생긴 경우"에도
        // 서버는 최신 마커 상태를 result["marker"]로 보내줄 수 있어
        Marker newMarker = result["marker"];
        newMarker.fault_list = [result["fault"]];
        newMarker.fault_cnt = 1;
        markerList.add(newMarker);
      }
      if (result["fault"] != null) {
        // 서버에서 새 결함 정보가 왔다면
        newFault = result["fault"];
        faultList.add(newFault);
        for (Marker marker in markerList) {
          if (marker.mid == newFault.mid) {
            marker.fault_list?.add(newFault);
            marker.fault_cnt = marker.fault_list?.length ?? 0;
          }
        }
      }
      if (result["appended"] != null) {
        // 서버가 marker/fault 외에 추가 데이터를 함께 보냈으면 로컬에 반영
        applyChanges(result["appended"]);
        // 결함 테이블 갱신
      }
      onTapRow(newFault);
    }
    countFaults();
  }

  // 테이블 결함 수정
  Future<void> editFault(Fault fault) async {
    String? lastFaultSeq;
    if (faultList.isNotEmpty) {
      lastFaultSeq = faultList.last.seq;
    }

    // 결함속 사진 정보 수정
    if (fault.picture_list?.isNotEmpty ?? false) {
      for (CustomPicture pic in fault.picture_list ?? []) {
        appService.changeFaultPictureInfo(pic.pid!, fault);
      }
    }
    Map? result = await appService.submitFault(
        isNew: false, fault: fault, mid: fault.mid, lastFaultSeq: lastFaultSeq);
    if (result != null) {
      if (result["fault"] != null) {
        if (fault.cause != result["fault"].cause) {
          fault.cause = result["fault"].cause;
          appService.isFaultSelected.value = false;
          appService.isFaultSelected.value = true;
        }
      }
      if (result["appended"] != null) {
        applyChanges(result["appended"]);
      }
    }
    countFaults();
  }

  // 테이블 결함 삭제
  Future<void> delFault() async {
    appService.isFaultSelected.value = false;
    Fault objFault = appService.selectedFault.value;
    String faultSeq = objFault.seq!;
    String? lastFaultSeq;
    if (faultList.isNotEmpty) {
      lastFaultSeq = faultList.last.seq;
    }

    // 결함삭제 API 호출
    Appended? appended = await appService.deleteFault(
        faultSeq: faultSeq, lastFaultSeq: lastFaultSeq);
    if (appended != null) {
      applyChanges(appended);
    }

    List<Marker> deletingMarker = [];

    // 결함 목록에서 제거
    faultList.removeWhere((Fault f) => f.seq == faultSeq);

    // 결함이 없는 마커 찾기 (삭제할 마커)
    for (Marker marker in markerList) {
      marker.fault_list!.remove(objFault);
      marker.fault_cnt = marker.fault_list!.length;
      if (marker.fault_list!
          .where(
            (element) => element.mid == marker.mid,
          )
          .isEmpty) {
        deletingMarker.add(marker);
      }
    }

    // 결함이 없는 마커 삭제
    for (Marker marker in deletingMarker) {
      selectedMarker.value = marker;
      delMarker();
    }

    appService.selectedFault.value = faultList.last;

    countFaults();
    appService.isFaultSelected.value = true;
    appService.isFaultSelected.value = false;
  }

  Future<void> cloneFault() async {
    Fault newFault = appService.selectedFault.value.copyWoPic();
    newFault.fid = appService.createId();
    String? lastFaultSeq;
    if (faultList.isNotEmpty) {
      lastFaultSeq = faultList.last.seq;
    }
    Map? result = await appService.submitFault(
        isNew: true,
        fault: newFault,
        mid: selectedMarker.value.mid,
        lastFaultSeq: lastFaultSeq);
    if (result != null) {
      if (result["marker"] != null) {
        Marker newMarker = result["marker"];
        newMarker.fault_list = [result["fault"]];
        newMarker.fault_cnt = 1;
        markerList.add(newMarker);
      }
      if (result["fault"] != null) {
        newFault = result["fault"];
        faultList.add(newFault);
        for (Marker marker in markerList) {
          if (marker.mid == newFault.mid) {
            marker.fault_list?.add(newFault);
            appService.selectedFault.value = marker.fault_list!.last;
            marker.fault_cnt = marker.fault_list?.length ?? 0;
          }
        }
      }
      if (result["appended"] != null) {
        applyChanges(result["appended"]);
      }
      onTapRow(newFault);
    }
    countFaults();
    appService.isFaultSelected.value = false;
    appService.isFaultSelected.value = true;
  }

  void clearFault() {
    appService.selectedFault.value.location = null;
    appService.selectedFault.value.elem = null;
    appService.selectedFault.value.cate1_seq = null;
    appService.selectedFault.value.cate2 = null;
    appService.selectedFault.value.width = null;
    appService.selectedFault.value.length = null;
    appService.selectedFault.value.qty = "1";
    appService.selectedFault.value.structure = "구조";
    appService.selectedFault.value.ing_yn = "Y";
    appService.selectedFault.value.status = null;
    appService.selectedFault.value.cause = null;
  }

  // 그룹화 버튼
  void onTapGroupButton(bool cancel) {
    if (!cancel && isGrouping.value) {
      if (appService.faultTableGroupingIndexes.isNotEmpty) {
        int groupSeq = int.parse(
            faultList[appService.faultTableGroupingIndexes.first].seq!);
        for (var index in appService.faultTableGroupingIndexes) {
          faultList[index].seq = groupSeq.toString();
          faultList.sort(
            (a, b) => int.parse(a.seq!).compareTo(int.parse(b.seq!)),
          );
          countFaults();
        }
      }
    }
    appService.faultTableGroupingIndexes.clear();
    isGrouping.value = !isGrouping.value;
  }

  // 테이블 결함 선택
  void onTapRow(Fault fault) {
    print('Row 클릭됨');
    if (isGrouping.value) {
      // if (groupingIndexes.contains(index)){
      //   groupingIndexes.remove(index);
      // } else{
      //   groupingIndexes.add(index);
      // }
    } else {
      tempCate1.value = "";
      tempCate2.value = "";
      var tempMarkerList = markerList.where(
        (p0) => p0.mid == fault.mid,
      );
      if (tempMarkerList.isNotEmpty) {
        selectedMarker.value = tempMarkerList.first;
      } else {
        selectedMarker.value = markerList.first;
      }
      appService.selectedFault.value = fault;
      appService.isFaultSelected.value = true;
    }
  }

  // void scrollToFocusedField(FocusNode focusNode) {
  //   Future.delayed(Duration(milliseconds: 300), () {
  //     if (focusNode.context == null || focusNode.context!.findRenderObject() == null) {
  //       print('FocusNode context or RenderObject is null');
  //       return;
  //     }
  //
  //     final renderBox = focusNode.context!.findRenderObject() as RenderBox;
  //     final position = renderBox.localToGlobal(Offset.zero).dy;
  //
  //     cScrollController.animateTo(
  //       position - 100,
  //       duration: Duration(milliseconds: 300),
  //       curve: Curves.easeInOut,
  //     );
  //   });
  // }

  void closeFaultDrawer(context) {
    FocusScope.of(context).unfocus();
    clrPickerOpened.value = false;
    tempCate1.value = "";
    tempCate2.value = "";
    appService.isFaultSelected.value = false;
    // isPointSelected.value = false;
  }

  void closeNumberDrawer(context) {
    FocusScope.of(context).unfocus();
    clrPickerOpened.value = false;
    tempCate1.value = "";
    tempCate2.value = "";
    isNumberSelected.value = false;
    isPointSelected.value = false;
  }

  void checkImage(CustomPicture picture) {
    Get.toNamed(Routes.CHECK_IMGAGE, arguments: picture);
  }

  void onClrBtnClicked(bool isMarker, bool isBorder) {
    isMarkerColorChanging.value = isMarker;
    isBorderColorChanging.value = isBorder;
    clrPickerOpened.value = !clrPickerOpened.value;
  }

  void showHelpDialog(context) {
    showDialog(
      context: context,
      builder: (context) => drawingHelpDialog(context),
    );
  }

  void applyChanges(Appended appended) {
    // 마커 병합이나 추가 이후에 서버로부터 전달받은 새로운 마커/결함 데이터를 앱 상태에 반영하는 역할을 해요
    List<Marker> newMarkers = appended.markerList ?? [];
    List<Fault> newFaults = appended.faultList ?? [];

    // 마커가 기존에 있는건지 확인 후 변경 또는 추가
    // 서버에서 보내준 최신 마커와 결함 리스트를 꺼냄
    for (Marker marker in newMarkers) {
      Marker? changed = markerList.firstWhereOrNull(
        (p0) => p0.mid == marker.mid,
      );
      if (changed != null) {
        changed = marker;
      } else {
        marker.fault_list = [];
        marker.fault_cnt = 0;
        markerList.add(marker);
      }
    }
    // 마커 리스트 돌면서 해당 번호를 가진 결함 추가
    for (Fault fault in newFaults) {
      for (Marker marker in markerList) {
        if (marker.no == fault.marker_no) {
          marker.fault_list!.add(fault);
          if (marker.fault_cnt == null) {
            marker.fault_cnt = 1;
          } else {
            marker.fault_cnt = marker.fault_list?.length ?? 0;
          }
        }
      }
    }
    countFaults();
  }

  Future<CustomPicture?> takePicture(Fault? fault) async {
    // 비동기 함수 (사진 촬영과 저장이 포함되어 있기 때문)
    XFile? xFile = await imagePicker.pickImage(
      // image_picker 패키지를 통해 카메라 열기
      source: ImageSource.camera,
      imageQuality: imageQuality,
      maxWidth: imageMaxWidth,
    );
    if (xFile != null) {
      // 사진 촬영 후 처리
      // 촬영된 사진은 XFile로 반환됨
      // File file = await appService.compressImage(xImage);
      String savedFilePath =
          await appService.savePhotoToExternal(File(xFile.path));
      // 사진을 로컬 외부 저장소에 저장
      // 사진을 디바이스의 Pictures/Elim/Safety 같은 경로에 복사해서 저장

      CustomPicture newPicture = appService.makeNewPicture(
        // CustomPicture 객체를 생성 + 내부적으로 로컬 DB(Hive)에도 저장
        // 관련 결함 정보 (fid, dong, location 등)를 사진에 같이 넣음
        // dataState: DataState.NEW로 지정해서 새로운 사진임을 명시함
        // thumb도 지금은 원본 경로 그대로 설정
        pid: appService.createId(),
        projectSeq: appService.curProject!.value.seq!,
        filePath: savedFilePath,
        thumb: savedFilePath,
        kind: "결함",
        fid: fault?.fid,
        dong: fault?.dong,
        floorName: appService.curDrawing.value.floor_name,
        location: fault?.location,
        cate1Seq: fault?.cate1_seq,
        cate2Seq: fault?.cate2?.split(", "),
        width: fault?.width,
        length: fault?.length,
        dataState: DataState.NEW,
      );
      appService.isFaultSelected
          .refresh(); // GetX의 .refresh()를 통해 바인딩된 UI 갱신 트리거
      appService.isLeftBarOpened.refresh();
      appService.curProject?.refresh();
      _localGalleryDataService.loadGalleryFromHive();

      return newPicture;
      // 사진을 찍고 저장하면 → CustomPicture 객체를 반환,
    }
    return null;
  }

  Future<List<CustomPicture>?> takeFromGallery(Fault? fault) async {
    List<XFile> xImages = await imagePicker.pickMultiImage();
    List<CustomPicture>? result = [];
    for (XFile xFile in xImages) {
      File file = await appService.compressImage(xFile);

      CustomPicture newPicture = appService.makeNewPicture(
        pid: appService.createId(),
        projectSeq: appService.curProject!.value.seq!,
        filePath: file.path,
        thumb: file.path,
        kind: "결함",
        fid: fault?.fid,
        dong: fault?.dong,
        floorName: appService.curDrawing.value.floor_name,
        location: fault?.location,
        cate1Seq: fault?.cate1_seq,
        cate2Seq: fault?.cate2?.split(", "),
        width: fault?.width,
        length: fault?.length,
        dataState: DataState.NEW,
      );
      result.add(newPicture);
      appService.isFaultSelected.value = false;
      appService.isFaultSelected.value = true;
    }
    return result;
  }

  List<CustomPicture>? loadGallery(String fid) {
    return _localGalleryDataService.loadGallery(fid);
  }

  memoView(String memoSeq) {
    // 메모 선택
    curDrawingMemo.value = appService.curDrawing.value.memo_list.firstWhere(
      (element) => element.seq == memoSeq,
    );

    if (curDrawingMemo.value != null) {
      // 사진 선택
      memoPicture.value =
          _localGalleryDataService.getPicture(curDrawingMemo.value!.pid ?? "");

      memoTextController.text = curDrawingMemo.value!.memo ?? "";

      Get.dialog(
        GestureDetector(
          onTap: () {
            // 바깥 영역 클릭 시 포커스만 제거
            FocusScope.of(Get.context!).unfocus();
          },
          child: Stack(
            children: [
              // 바깥 영역을 위한 투명한 Positioned.fill
              Positioned.fill(
                child: Container(
                  color: Colors.transparent,
                ),
              ),
              // 실제 다이얼로그
              DrawingMemoView(),
            ],
          ),
        ),
        barrierDismissible: false,
      );
    }
  }

  // 메모 사진 촬영
  takeMemoPicture() async {
    XFile? xFile = await imagePicker.pickImage(
      source: ImageSource.camera,
      imageQuality: imageQuality,
      maxWidth: imageMaxWidth,
    );
    if (xFile != null) {
      // File file = await appService.compressImage(xImage);
      String savedFilePath =
          await appService.savePhotoToExternal(File(xFile.path));

      memoPicture.value = appService.makeNewPicture(
        pid: appService.createId(),
        projectSeq: appService.curProject!.value.seq!,
        filePath: savedFilePath,
        thumb: xFile.path,
        kind: "기타",
        dong: appService.curDrawing.value.dong,
        floorName: appService.curDrawing.value.floor_name,
        dataState: DataState.NEW,
      );
      curDrawingMemo.value!.pid = memoPicture.value!.pid;

      appService.isLeftBarOpened.refresh();
      _localGalleryDataService.loadGalleryFromHive();
    }
  }

  // 메모 저장
  submitDrawingMemo() {
    if (curDrawingMemo.value != null) {
      curDrawingMemo.value!.memo = memoTextController.text;
      appService.submitDrawingMemo(curDrawingMemo.value!);
      drawingMemoFocusNode.unfocus();
    }
  }

  // 메모 삭제
  deleteMemo() {
    if (curDrawingMemo.value != null) {
      // 도면 메모 목록에서 삭제
      appService.curDrawing.value.memo_list.remove(curDrawingMemo.value);

      appService.deleteDrawingMemo(curDrawingMemo.value!.seq!);
      Get.back();
    }
  }

  // 메모 사진 삭제
  deleteMemoPicture() {
    // 사진 삭제
    if (memoPicture.value != null) {
      _localGalleryDataService.changePictureState(
        pid: memoPicture.value!.pid!,
        state: DataState.DELETED,
      );
      memoPicture.value!.state = DataState.DELETED.index;
      curDrawingMemo.value!.pid = null;
    }

    memoPicture.value = null;
  }

  // 메모 사진 보기
  memoPictureView() {
    if (memoPicture.value != null) {
      Get.toNamed(Routes.CHECK_IMGAGE, arguments: memoPicture.value);
    }
  }

  // 메모 추가
  makeNewDrawingMemo(String x, y) async {
    DrawingMemo newMemo = DrawingMemo(
      seq: "",
      drawing_seq: appService.curDrawing.value.seq,
      pid: "",
      memo: "",
      x: x,
      y: y,
    );

    curDrawingMemo.value = await appService.submitDrawingMemo(newMemo);
    if (curDrawingMemo.value != null) {
      appService.curDrawing.value.memo_list.add(curDrawingMemo.value!);
      addMemoMode.value = false;
      memoView(curDrawingMemo.value!.seq!);
    }
  }

  // 메모 닫기
  closeDrawingMemo() {
    // addMemoMode.value = false;
    // memoTextController.text = curDrawingMemo.value?.memo ?? "";
    curDrawingMemo.value = null;
    // memoPicture.value = null;
    Get.back();
  }
}

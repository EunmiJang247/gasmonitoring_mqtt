import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:safety_check/app/constant/app_color.dart';
import 'package:safety_check/app/constant/data_state.dart';
import 'package:safety_check/app/constant/gaps.dart';
import 'package:safety_check/app/data/models/05_picture.dart';
import 'package:safety_check/app/data/models/site_check_form.dart';
import 'package:safety_check/app/data/services/app_service.dart';
import 'package:safety_check/app/data/services/local_gallery_data_service.dart';
import 'package:safety_check/app/modules/project_checks/controllers/project_checks_controller.dart';
import 'package:safety_check/app/utils/log.dart';
import 'package:safety_check/app/widgets/two_button_dialog.dart';

import '../../project_gallery/controllers/project_gallery_controller.dart';

class CheckImageController extends GetxController {
  final AppService _appService;
  final LocalGalleryDataService _localGalleryDataService;

  CheckImageController({
    required AppService appService,
    required LocalGalleryDataService localGalleryDataService,
  })  : _appService = appService,
        _localGalleryDataService = localGalleryDataService;

  TransformationController transformationController1 =
      TransformationController();
  TransformationController transformationController2 =
      TransformationController();
  RxBool isCompareMode = false.obs;
  CustomPicture? original;
  CustomPicture? compare;
  String projectName = "";
  String drawingName = "";

  List<String> kind = ["기타", "전경"];
  RxString curKind = "".obs;
  RxString curLocation = "".obs;

  @override
  void onInit() {
    original = Get.arguments as CustomPicture;
    if (original?.dong != null) {
      projectName += (original?.dong)!;
    }
    if (original?.floor_name != null) {
      if (projectName != "") {
        projectName += " ";
      }
      projectName += (original?.floor_name)!;
    }
    if (original?.location != null) {
      if (projectName != "") {
        projectName += " ";
      }
      projectName += (original?.location)!;
    }
    if (projectName == "") {
      projectName = "사진 정보 없음";
    }

    if (original?.cate1_seq != null || original?.cate2_seq != null) {
      String cate = makeCateString(original?.cate1_seq, original?.cate2_seq);
      if (projectName != "" && cate != "") {
        projectName += " / ";
      }
      projectName += cate;
    }

    if (original?.width != null) {
      if (projectName != "") {
        projectName += " / ";
      }
      projectName += "폭 ${original?.width!}mm";
    }
    if (original?.length != null) {
      if (projectName != "") {
        projectName += " / ";
      }
      projectName += "길이 ${original?.length!}m";
    }

    drawingName = _appService.drawingName;
    compare = original?.before_picture;
    curLocation.value = original?.location ?? "부위 없음";

    curKind.value = original?.kind == "결함" ? "기타" : original?.kind ?? "기타";
    if (canChangeToCurrent() || original?.kind == "현황") {
      kind.add("현황");
    }
    // print(canChangeToCurrent());
    // print(kind);
    super.onInit();
  }

  onDoubleTap(bool isOriginal) {
    if (isOriginal) {
      transformationController2.value = Matrix4.identity();
    } else {
      transformationController1.value = Matrix4.identity();
    }
  }

  onClickCompareSwitch(bool value) {
    if (compare != null) {
      transformationController1.value = Matrix4.identity();
      transformationController2.value = Matrix4.identity();
      isCompareMode.value = value;
    } else {
      Fluttertoast.showToast(msg: "비교할 사진이 없습니다!");
    }
  }

  canChangeToCurrent() {
    if (original!.drawing_seq == null) return false;
    return true;
  }

  changeKind(String newKind) {
    // 사진의 종류(kind)를 변경하는 사용자 액션을 처리하는 함수
    // 사용자가 어떤 사진의 종류를 "현황" / "기타" / "전경" 중 하나로 변경할 때,
    // 유효성 체크하고 로컬 상태를 변경하고  상태를 EDITED로 바꿔서 서버 동기화 대상으로 만든다.
    // 유효성 검사 → 로컬(Hive) 상태 변경 → 상태를 EDITED로 바꾸고 → UI/서버 동기화를 유도하는 작업을 수행
    if (original!.kind != "현황" && // 사진 종류가 원래 현황이 아니고
        original!.drawing_seq ==
            null && // 이 사진에 연결된 도면이 없고 (drawing_seq == null)
        newKind == "현황") {
      // 근데 사용자가 "현황"으로 바꾸려 한다면?
      Fluttertoast.showToast(msg: "해당 사진은 현황 사진으로 변경할 수 없습니다!");
      // drawing_seq == null이면 도면 없음 → 현황 변경 불가
      // "현황 사진은 도면이 연결되어 있어야 한다"는 도메인 로직이 적용된 조건!
      return;
    }
    _localGalleryDataService.changePictureKind(
      // Hive에 저장된 사진의 kind 값을 새 값으로 변경
      // Hive에 저장된 CustomPicture 객체의 kind 값을 새로 바꿈 (예: "기타" → "전경")
      pid: original!.pid!,
      kind: newKind,
    );
    _localGalleryDataService.changePictureState(
      // 사진 상태를 EDITED로 변경
      pid: original!.pid!,
      state: DataState.EDITED,
    );
    _localGalleryDataService.loadGalleryFromHive();

    original?.kind = newKind;
    curKind.value = newKind;

    _appService.isLeftBarOpened.refresh();
    //  현재 객체에도 값 반영 + UI 갱신
  }

  String makeCateString(String? cate1Seq, List<String>? cate2Seq) {
    String cate1 = _appService.faultCate1?[cate1Seq] ?? "";
    String cate2 = cate2Seq
            ?.map(
              (e) => _appService.faultCate2?[e] ?? "",
            )
            .join(", ") ??
        "";
    String result = "$cate1 $cate2";
    if (cate1 == "" || cate2 == "") {
      result = result.trim();
    }
    return result;
  }

  void changeLocation(String selectedLocation) {
    _localGalleryDataService.changePictureLocation(
        pid: original!.pid!, location: selectedLocation);
    _localGalleryDataService.changePictureState(
        pid: original!.pid!, state: DataState.EDITED);
    original?.location = selectedLocation;
    curLocation.value = selectedLocation;
    // print(selectedLocation);
    _appService.isLeftBarOpened.value = true;
    _appService.isLeftBarOpened.value = false;
    ProjectGalleryController projectGalleryController = Get.find();
    _localGalleryDataService.loadGalleryFromHive();
  }

  deletePicture() async {
    EasyLoading.show(dismissOnTap: true);
    await _localGalleryDataService.changePictureState(
        pid: original!.pid!, state: DataState.DELETED);

    // 갤러리 새로고침
    _localGalleryDataService.loadGalleryFromHive();

    // 결함에서 사진 제거
    _appService.selectedFault.value.picture_list?.removeWhere(
      (element) => element.pid == original?.pid,
    );
    _appService.selectedFault.refresh();

    // 성능점검표의 사진에 해당한다면, 서버에서도 삭제되도록
    // final form = _appService.curProject?.value.site_check_form;
    // if (form == null) {
    //   EasyLoading.showError('폼이 없습니다.');
    //   return;
    // }

    // // 삭제 대상 사진을 가진 child와 data를 추적하기 위한 임시 변수
    // List<InspectionData> dataToRemove = [];

    // for (var data in form.data) {
    //   List<Children> childrenToRemove = [];
    //   for (var child in data.children) {
    //     child.pictures.removeWhere((picture) => picture.pid == original?.pid);
    //   }
    // }
    // _appService.submitProject(_appService.curProject!.value);
    logInfo('original: ${original?.toJson()}');

    // if (original?.kind == "현황") {
    //   // 알림창에서 확인 클릭 시 삭제.
    //   // ✅ 현장점검표 갱신
    //   if (Get.isRegistered<ProjectChecksController>()) {
    //     final checksController = Get.find<ProjectChecksController>();
    //     checksController.onDeletePicture(original);
    //   }
    // }
    if (original?.kind == "현황") {
      showDialog(
        context: Get.context!,
        builder: (context) {
          return TwoButtonDialog(
            height: 200,
            content: Column(
              children: [
                Text(
                  "사진 삭제",
                  style: TextStyle(
                      fontFamily: "Pretendard",
                      color: AppColors.c1,
                      fontWeight: FontWeight.bold,
                      fontSize: 22),
                ),
                Gaps.h16,
                Text(
                  "현장점검표의 사진의 경우 \n 보고서에서도 삭제됩니다.",
                  style: TextStyle(
                    fontFamily: "Pretendard",
                    fontSize: 18,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            yes: "삭제",
            no: "취소",
            onYes: () {
              if (Get.isRegistered<ProjectChecksController>()) {
                final checksController = Get.find<ProjectChecksController>();
                checksController.onDeletePicture(original!);
                Get.back(); // 다이얼로그 닫기
              }
              Get.back(); // 다이얼로그 닫기
            },
            onNo: () => Get.back(),
          );
        },
      );
    } else {
      Get.back();
    }

    _localGalleryDataService.loadGalleryFromHive();
    EasyLoading.dismiss();
  }
}

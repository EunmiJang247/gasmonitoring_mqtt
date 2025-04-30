import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:safety_check/app/constant/constants.dart';
import 'package:safety_check/app/constant/data_state.dart';
import 'package:safety_check/app/data/models/01_project.dart';
import 'package:safety_check/app/data/models/05_picture.dart';
import 'package:safety_check/app/data/models/site_check_form.dart';
import 'package:safety_check/app/data/services/app_service.dart';
import 'package:safety_check/app/data/services/local_gallery_data_service.dart';
import 'package:safety_check/app/utils/log.dart';
import '../../../routes/app_pages.dart';

class ProjectChecksController extends GetxController {
  final curProject = Rx<Project?>(null);
  final AppService appService;
  final LocalGalleryDataService
      _localGalleryDataService; // Initialized in the constructor
  final ImagePicker imagePicker = ImagePicker();

  TextEditingController inspectorNameController = TextEditingController();
  TextEditingController remarkController = TextEditingController();

  late FocusNode inspectorNameFocus = FocusNode();

  ProjectChecksController({
    required this.appService,
    required LocalGalleryDataService localGalleryDataService,
  }) : _localGalleryDataService = localGalleryDataService;

  @override
  void onInit() {
    curProject.value = appService.curProject?.value;
    super.onInit(); // 부모가 준비해놓은 기본 세팅까지 포함해서 초기화함(필수는 아니지만 하면 좋음)
    logInfo("데이터! : ${curProject.value?.site_check_form?.toJson()}");

    if (curProject.value?.site_check_form == null) {
      appService.curProject?.value.site_check_form = SiteCheckForm(
        inspectorName: "",
        inspectionDate: "",
        data: [],
      );
    }

    inspectorNameFocus.addListener(() {
      if (!inspectorNameFocus.hasFocus) {
        _onFieldUnfocused('inspectorName', inspectorNameController.text);
      }
    });
  }

  void _onFieldUnfocused(String fieldName, String value) async {
    try {
      switch (fieldName) {
        case 'inspectorName':
          appService.curProject?.value.site_check_form?.inspectorName = value;
          break;
      }

      appService.submitProject(appService.curProject!.value);
      logInfo("!!!");
    } catch (e) {
      EasyLoading.showError('$fieldName 저장 실패');
    }
  }

  // 도면목록
  goDrawingList() {
    Get.toNamed(Routes.DRAWING_LIST);
  }

  takePictureAndSet(String cate, String child, String pic) async {
    try {
      CustomPicture? newImage = await _takePicture();
      if (newImage == null) {
        EasyLoading.showToast("사진 촬영 실패");
        return;
      }

      final form = appService.curProject?.value.site_check_form;
      //  site_check_form: {"inspectorName":"ㄱ","inspectionDate":"ㄴ","data":[]}}]
      if (form == null) {
        EasyLoading.showToast("양식을 찾을 수 없습니다");
        return;
      }

      bool isUpdated = await _updatePictureInForm(
        form: form,
        category: cate,
        childKind: child,
        pictureTitle: pic,
        newPicture: newImage,
      );

      if (isUpdated) {
        EasyLoading.showSuccess("사진이 저장되었습니다");
        _localGalleryDataService.loadGalleryFromHive();
      } else {
        EasyLoading.showError("해당 위치를 찾을 수 없습니다");
      }
    } catch (e) {
      logError("사진 저장 중 오류가 발생했습니다: $e");
      EasyLoading.showError("사진 저장 중 오류가 발생했습니다: $e");
    }
  }

  Future<bool> _updatePictureInForm({
    required SiteCheckForm form,
    required String category,
    required String childKind,
    required String pictureTitle,
    required CustomPicture newPicture,
  }) async {
    // 카테고리 찾기 또는 생성
    InspectionData? targetData = form.data.firstWhereOrNull(
      (data) => data.caption == category,
    );

    if (targetData == null) {
      targetData = InspectionData(
        caption: category,
        children: [],
      );
      form.data.add(targetData);
    }

    // 자식 항목 찾기 또는 생성
    Children? targetChild = targetData.children.firstWhereOrNull(
      (child) => child.kind == childKind,
    );

    if (targetChild == null) {
      targetChild = Children(
        kind: childKind,
        pictures: [],
        remark: '',
      );
      targetData.children.add(targetChild);
    }

    // ✅ 같은 제목으로 시작하는 사진이 몇 개인지 카운트
    int sameTitleCount = targetChild.pictures
        .where((pic) => pic.title.startsWith(pictureTitle))
        .length;

    // ✅ 제목 중복 시 번호 붙이기
    String finalTitle = pictureTitle;
    if (sameTitleCount > 0) {
      finalTitle = '$pictureTitle${sameTitleCount + 1}';
    }

    // ✅ 새 사진 생성 및 추가
    Picture newPic = Picture(
      title: finalTitle,
      pid: newPicture.pid,
      remark: '',
    );

    targetChild.pictures.add(newPic);

    // 로그 및 저장
    logInfo("바로여기: ${appService.curProject?.value.site_check_form?.toJson()}");
    appService.submitProject(appService.curProject!.value);
    curProject.refresh();

    return true;
  }

  Future<CustomPicture?> _takePicture() async {
    XFile? xFile = await imagePicker.pickImage(
      // image_picker 패키지를 통해 카메라 열기
      source: ImageSource.camera,
      imageQuality: imageQuality,
      maxWidth: imageMaxWidth,
    );
    if (xFile != null) {
      // 사진 촬영 후 처리
      String savedFilePath =
          await appService.savePhotoToExternal(File(xFile.path));
      // 디바이스의 사진 갤러리 또는 앱 외부 저장소 경로로 복사한 다음, 그 파일의 경로를 리턴할 거

      CustomPicture newPicture = appService.makeNewPicture(
        pid: appService.createId(),
        projectSeq: appService.curProject!.value.seq!,
        filePath: savedFilePath,
        thumb: savedFilePath,
        kind: "현황",
        dataState: DataState.NEW,
      );
      return newPicture;
    }
    return null;
  }

  Future<void> onRemarkSubmit(
      CustomPicture targetPicture, String newRemark) async {
    if (targetPicture.pid == null) {
      EasyLoading.showError('사진 정보가 없습니다.');
      return;
    }

    try {
      logInfo('사진 pid: ${targetPicture.pid}, 메모: $newRemark');

      final form = appService.curProject?.value.site_check_form;

      if (form == null) {
        EasyLoading.showError('폼이 없습니다.');
        return;
      }

      bool updated = false;

      for (var data in form.data) {
        for (var child in data.children) {
          for (var picture in child.pictures) {
            if (picture.pid == targetPicture.pid) {
              picture.remark = newRemark; // remark 업데이트!
              updated = true;
              break;
            }
          }
          if (updated) break;
        }
        if (updated) break;
      }

      if (updated) {
        logInfo(
            "바로여기222: ${appService.curProject?.value.site_check_form?.toJson()}");
        EasyLoading.showSuccess('메모 저장 완료');
        appService.submitProject(appService.curProject!.value);
        curProject.refresh(); // UI 갱신
      } else {
        EasyLoading.showError('해당 사진을 찾을 수 없습니다.');
      }
    } catch (e) {
      EasyLoading.showError('메모 저장 실패: $e');
      rethrow;
    }
  }

  onDeletePicture(targetPicture) async {
    logInfo('onDeletePicture');
    // 1. 먼저 Hive 상태 삭제 처리
    try {
      await _localGalleryDataService.changePictureState(
          pid: targetPicture.pid, state: DataState.DELETED);
    } catch (e) {
      logInfo('사진 삭제 실패');
    }

    // 2. 서버 및 현장점검 데이터 구조 반영
    final form = appService.curProject?.value.site_check_form;
    if (form == null) {
      EasyLoading.showError('폼이 없습니다.');
      return;
    }

    // 삭제 대상 사진을 가진 child와 data를 추적하기 위한 임시 변수
    List<InspectionData> dataToRemove = [];

    for (var data in form.data) {
      List<Children> childrenToRemove = [];
      for (var child in data.children) {
        child.pictures
            .removeWhere((picture) => picture.pid == targetPicture.pid);

        // 2-1. picture가 모두 삭제되었으면 children에서도 삭제 대상에 추가
        if (child.pictures.isEmpty) {
          childrenToRemove.add(child);
        }
      }

      // 2-2. 빈 children 제거
      for (var child in childrenToRemove) {
        data.children.remove(child);
      }

      // 2-3. data 내 children이 없으면 data도 제거 대상
      if (data.children.isEmpty) {
        dataToRemove.add(data);
      }
    }

    // 2-4. 빈 카테고리 제거
    for (var data in dataToRemove) {
      form.data.remove(data);
    }

    // 3. 서버 전송 및 상태 반영
    appService.submitProject(appService.curProject!.value);
    _localGalleryDataService.loadGalleryFromHive();
    curProject.refresh();

    // 4. 닫기
    Get.back();
  }

  void onDateChange(DateTime date) {
    final formatted = DateFormat('yyyy-MM-dd').format(date);
    appService.curProject?.value.site_check_form?.inspectionDate = formatted;
    appService.submitProject(appService.curProject!.value);
  }
}

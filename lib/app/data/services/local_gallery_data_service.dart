// ignore_for_file: non_constant_identifier_names

// 이 클래스는 Hive 로컬 DB (gallery_box)를 직접 다루는 서비스로,
// 사진(CustomPicture)의 저장, 수정, 삭제, 종류 변경, 위치 변경 등
// 모든 변경 사항을 Hive에 반영하는 코드야.

import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:safety_check/app/data/models/05_picture.dart';
import 'package:safety_check/app/data/services/app_service.dart';

import '../../constant/data_state.dart';
import '../../utils/converter.dart';

class LocalGalleryDataService extends GetxService {
  late Box<CustomPicture> gallery_box;

  RxList<CustomPicture> faultPictures = <CustomPicture>[].obs;
  RxList<CustomPicture> bgPictures = <CustomPicture>[].obs;
  RxList<CustomPicture> etcPictures = <CustomPicture>[].obs;
  RxList<CustomPicture> curPictures = <CustomPicture>[].obs;
  RxList<RxList<CustomPicture>> GalleryPictures = <RxList<CustomPicture>>[].obs;

  @override
  Future<void> onInit() async {
    await Hive.initFlutter();

    Hive.registerAdapter(CustomPictureAdapter());
    gallery_box = await Hive.openBox<CustomPicture>('gallery_box_1_0_0');

    // await new_gallery_box.deleteFromDisk();
    // await edited_gallery_box.deleteFromDisk();
    // await deleted_gallery_box.deleteFromDisk();

    super.onInit();
  }

  //  getter 함수
  List<CustomPicture> get PictureList =>
      gallery_box.values.cast<CustomPicture>().toList();
  // gallery_box라는 Hive Box에 저장된 모든 CustomPicture들을 꺼내서 List로 반환하는 역할을 한다

  // pid 로 사진 가져오기
  CustomPicture? getPicture(String pid) => gallery_box.get(pid);

  // 사진이 갤러리박스에 있는지 체크
  bool isPictureInBox(String pid) {
    bool result = false;
    result = gallery_box.containsKey(pid);
    return result;
  }

  // 사진 상태 체크
  int? checkState(String pid) {
    int? result = DataState.NOT_CHANGED.index;
    result = gallery_box.get(pid)?.state;
    return result;
  }

  // 사진을 갤러리박스에 추가
  Future<void> addPicture(CustomPicture Picture) async =>
      await gallery_box.put(Picture.pid, Picture);

  // 사진 수정
  Future<void> updatePicture({
    required String pid,
    required CustomPicture changedPicture,
  }) async {
    await gallery_box.put(pid, changedPicture);
  }

  Future<void> updatePictureWithProjectSeq({
    required String pid,
    required String projectSeq,
  }) async {
    int index =
        PictureList.indexWhere((element) => isSameValue(element.pid, pid));
    if (index != -1) {
      CustomPicture updatedPicture =
          CustomPicture.fromJson(PictureList[index].toJson());
      updatedPicture.project_seq = projectSeq;
      await gallery_box.putAt(index, updatedPicture);
    }
  }

  Future<void> updatePictureWithNewFilePath({
    required String pid,
    required String newFilePath,
  }) async {
    int index =
        PictureList.indexWhere((element) => isSameValue(element.pid, pid));
    if (index != -1) {
      CustomPicture updatedPicture =
          CustomPicture.fromJson(PictureList[index].toJson());
      updatedPicture.file_path = newFilePath;
      await gallery_box.putAt(index, updatedPicture);
    }
  }

  // 프로젝트의 사진 목록을 가져옴
  List<CustomPicture> getPictureInProject({
    required String projectSeq,
  }) =>
      PictureList.where((element) => element.project_seq == projectSeq)
          .toList();

  // 사진 삭제
  Future<void> removePicture(String pid) async {
    // var idx =
    //     PictureList.indexWhere((element) => isSameValue(element.pid, pid));
    // if (idx > -1) {
    //   await gallery_box.deleteAt(idx);
    // }
    await gallery_box.delete(pid);
    PictureList.removeWhere((element) => isSameValue(element.pid, pid));
  }

  // 프로젝트의 모든 사진 삭제
  Future<void> removeAllProjectPicture(String project_seq) async {
    // var idx = PictureList.indexWhere(
    //     (element) => isSameValue(element.project_seq, project_seq));
    // if (idx > -1) {
    //   await gallery_box.deleteAt(idx);
    // }
    await gallery_box.deleteAll(
      PictureList.where(
              (element) => isSameValue(element.project_seq, project_seq))
          .map((e) => e.pid),
    );
    PictureList.removeWhere(
        (element) => isSameValue(element.project_seq, project_seq));
  }

  // 사진 상태 변경
  Future<void> changePictureState(
      {required String pid, required DataState state}) async {
    CustomPicture? updatedPicture = gallery_box.get(pid);
    if (updatedPicture == null) {
      return;
    }
    updatedPicture.state = state.index;
    await gallery_box.put(pid, updatedPicture);

    // 삭제된 사진이 전경 사진이면 프로젝트의 전경사진 정보도 삭제
    if (updatedPicture.kind == "전경" && state == DataState.DELETED) {
      // 프로젝트의 전경사진 정보 삭제
      AppService appService = Get.find<AppService>();
      if (appService.curProject != null) {
        appService.curProject!.value.picture = "";
        appService.curProject!.value.picture_pid = "";
        appService.curProject!.value.picture_cnt =
            (int.parse(appService.curProject!.value.picture_cnt!) - 1)
                .toString();
        appService.curProject!.refresh();
      }
    }

    return;
  }

  // 사진 종류 변경 (전경, 현황, 기타)
  Future<void> changePictureKind(
      // 사진의 종류(kind)를 바꾸고,
      // 필요하면 프로젝트 썸네일(대표사진)도 갱신하고,
      // 로컬에 저장된 데이터를 갱신하며,
      // 갤러리도 새로고침 하는 거야.

      // 유저가 프로젝트 대표 사진을 변경하려고 함
      // 사진을 눌러 "전경"으로 바꾸면 → 대표 사진으로 반영됨
      // "전경"을 "기타"로 바꾸면 → 대표 사진 제거되거ㄴ나 다른 "전경"으로 대체됨
      {required String pid,
      required String kind}) async {
    AppService appService = Get.find<AppService>();

    CustomPicture? updatedPicture = getPicture(pid);
    // pid로 특정 사진 찾기
    if (updatedPicture == null) {
      return;
    }

    if (updatedPicture.kind == "전경") {
      // 현재 종류가 "전경"인 경우
      updatedPicture.kind = kind; // 종류 변경 (예: "기타", "현황")

      List<CustomPicture> projectPictures = PictureList.where(
        (element) =>
            element.project_seq == updatedPicture.project_seq &&
            element.kind == "전경",
      ).toList();
      // 같은 프로젝트 내 "전경" 사진들 리스트를 다시 구함

      if (projectPictures.isEmpty) {
        // 만약 "전경"이 아예 없어졌다면: 프로젝트의 대표사진도 없애버림
        if (appService.curProject?.value.picture != "") {
          appService.curProject?.value.picture = "";
          appService.curProject?.value.picture_pid = "";
          appService.curProject?.value.picture_cnt =
              (int.parse(appService.curProject?.value.picture_cnt ?? "0") - 1)
                  .toString();
        }
      } else {
        // 아직 다른 "전경" 사진이 있으면:
        appService.curProject?.value.picture = projectPictures.first.file_path;
        appService.curProject?.value.picture_pid = projectPictures.first.pid;
      }

      appService.curProject?.refresh();
      appService.projectList.refresh();
      // .refresh()를 통해 GetX 상태 반영해줌!
    }

    if (kind == "전경") {
      // 반대로, 새로 "전경"으로 바꾸는 경우
      if (appService.curProject?.value.picture == "") {
        appService.curProject?.value.picture = updatedPicture.file_path;
        appService.curProject?.value.picture_pid = updatedPicture.pid;
        appService.curProject?.refresh();
        appService.projectList.refresh();
      }
    }

    updatedPicture.kind = kind;
    print('?오죠?');
    await gallery_box.put(updatedPicture.pid, updatedPicture);
  }

  // 사진 위치 변경
  Future<void> changePictureLocation(
      {required String pid, required String location}) async {
    CustomPicture? updatedPicture = gallery_box.get(pid);
    if (updatedPicture == null) {
      return;
    }
    updatedPicture.location = location;
    await gallery_box.put(pid, updatedPicture);
  }

  // 결함의 사진 목록을 가져옴
  List<CustomPicture>? loadGallery(String fid) {
    List<CustomPicture> galleryInBox = PictureList.where(
      (element) =>
          element.fid == fid && element.state != DataState.DELETED.index,
    ).toList();
    galleryInBox.sort(
      (a, b) => b.pid!.compareTo(a.pid!),
    );
    return galleryInBox;
  }

  // 전경/ 기타사진을 지정
  void fetchGalleryPictures() async {
    // TODO
    AppService appService = Get.find<AppService>();
    List<CustomPicture>? searchResult = await appService.searchPicture(
        projectSeq: appService.curProject?.value.seq ?? "");

    if (searchResult == null) {
      faultPictures.value = [];
      bgPictures.value = [];
      etcPictures.value = [];
      curPictures.value = [];
      GalleryPictures.value = [];
      GalleryPictures.refresh();
      return;
    }

    searchResult.map(
      (e) => gallery_box.put(e.pid, e),
    );

    // 전경사진 찾기
    CustomPicture? projectPicture = searchResult
        .where(
          (p0) => p0.kind == "전경",
        )
        .firstOrNull;

    // 전경사진의 상태가 삭제일 경우 curProject.value.picture = "" 로 초기화
    if (projectPicture != null &&
        projectPicture.state == DataState.DELETED.index) {
      appService.curProject?.value.picture = "";
      appService.curProject?.value.picture_pid = "";
      appService.curProject?.refresh();
    }

    // 삭제된 사진은 제외
    searchResult.removeWhere(
      (element) => element.state == DataState.DELETED.index,
    );

    // 결함사진
    faultPictures.value = searchResult
        .where(
          (p0) => p0.kind == "결함",
        )
        .toList();
    faultPictures.sort(
      (a, b) => int.parse(a.no ?? "0").compareTo(int.parse(b.no ?? "0")),
    );

    // 전경사진
    bgPictures.value = searchResult
        .where(
          (p0) => p0.kind == "전경",
        )
        .toList();
    bgPictures.sort(
      (a, b) => int.parse(a.no ?? "0").compareTo(int.parse(b.no ?? "0")),
    );

    // 기타사진
    etcPictures.value = searchResult
        .where(
          (p0) => p0.kind == "기타",
        )
        .toList();
    etcPictures.sort(
      (a, b) => int.parse(a.no ?? "0").compareTo(int.parse(b.no ?? "0")),
    );

    // 현황사진
    curPictures.value = searchResult
        .where(
          (p0) => p0.kind == "현황",
        )
        .toList();
    curPictures.sort(
      (a, b) => int.parse(a.no ?? "0").compareTo(int.parse(b.no ?? "0")),
    );
    GalleryPictures.value = [
      bgPictures,
      curPictures,
      etcPictures,
      faultPictures
    ];
    GalleryPictures.refresh();
  }
}

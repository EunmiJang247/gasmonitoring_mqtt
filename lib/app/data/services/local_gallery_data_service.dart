// ignore_for_file: non_constant_identifier_names

// 이 클래스는 Hive 로컬 DB (gallery_box)를 직접 다루는 서비스로,
// 사진(CustomPicture)의 저장, 수정, 삭제, 종류 변경, 위치 변경 등
// 모든 변경 사항을 Hive에 반영하는 코드야.
// 그리고 어떤 원리로 로컬과 서버를 동기화하는지 이해하기!

import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart'; // 로컬 DB
import 'package:safety_check/app/data/models/05_picture.dart';
import 'package:safety_check/app/data/services/app_service.dart';

import '../../constant/data_state.dart';
import '../../utils/converter.dart';
import 'package:flutter/foundation.dart';
// CustomPicture, AppService, DataState: 앱 내 도메인 모델과 서비스

class LocalGalleryDataService extends GetxService {
  // GetxService를 상속해서 앱 전체에서 쉽게 접근 가능한 singleton 서비스 클래스를 만드는 중.
  late Box<CustomPicture> gallery_box;
  // Hive에서 열리는 사진 데이터 저장소. late 키워드로 나중에 초기화됨.

  RxList<CustomPicture> faultPictures = <CustomPicture>[].obs;
  // RxList는 GetX에서 상태 관리를 위해 사용. 리스트가 변경되면 자동으로 UI에 반영됨.
  RxList<CustomPicture> bgPictures = <CustomPicture>[].obs;
  RxList<CustomPicture> etcPictures = <CustomPicture>[].obs;
  RxList<CustomPicture> curPictures = <CustomPicture>[].obs;
  // faultPictures, bgPictures, etcPictures, curPictures: 각각 사진의 종류별 리스트
  RxList<RxList<CustomPicture>> GalleryPictures = <RxList<CustomPicture>>[].obs;
  // 위 네 가지 리스트를 한 데 묶어서 보여줄 때 사용.

  @override
  Future<void> onInit() async {
    // Hive를 초기화하고, CustomPicture 모델을 사용할 수 있도록 어댑터 등록
    await Hive.initFlutter();

    Hive.registerAdapter(CustomPictureAdapter());
    gallery_box = await Hive.openBox<CustomPicture>('gallery_box_1_0_0');
    // gallery_box_1_0_0 이름으로 박스를 오픈해서 로컬 DB를 준비

    // await new_gallery_box.deleteFromDisk();
    // await edited_gallery_box.deleteFromDisk();
    // await deleted_gallery_box.deleteFromDisk();
    for (var pic in gallery_box.values) {
      print(pic.toJson());
    }
    print("총 사진 수: ${gallery_box.length}");
    // 특정 사진을 보고싶으면: print(gallery_box.get('pid123')?.toJson());

    super.onInit();
    fetchGalleryPictures();
  }

  //  getter 함수
  List<CustomPicture> get PictureList =>
      gallery_box.values.cast<CustomPicture>().toList();
  // gallery_box라는 Hive Box에 저장된 모든 CustomPicture들을 꺼내서 List로 반환하는 역할을 한다
  // Hive Box에 저장된 모든 사진 데이터를 리스트로 반환

  // pid 로 사진 가져오기
  CustomPicture? getPicture(String pid) => gallery_box.get(pid);
  // 특정 pid를 가진 사진을 조회

  // 사진이 갤러리박스에 있는지 체크
  bool isPictureInBox(String pid) {
    // 해당 pid가 DB에 있는지 확인
    bool result = false;
    result = gallery_box.containsKey(pid);
    return result;
  }

  // 사진 상태 체크
  int? checkState(String pid) {
    // 사진의 상태(state)를 가져옴. 예: 변경됨, 삭제됨 등
    int? result = DataState.NOT_CHANGED.index;
    result = gallery_box.get(pid)?.state;
    return result;
  }

  // 사진을 갤러리박스에 추가
  // 사진을 pid 키로 저장
  Future<void> addPicture(CustomPicture Picture) async =>
      await gallery_box.put(Picture.pid, Picture);

  // 사진 수정
  Future<void> updatePicture({
    required String pid,
    required CustomPicture changedPicture,
  }) async {
    await gallery_box.put(pid, changedPicture);
    // 이건 Hive DB에 서버에서 받은 pic 정보를 저장(덮어쓰기)하는 거야
    // 이 때 state = NOT_CHANGED로 설정한 것도 함께 저장돼.
  }

  // 특정 사진의 프로젝트 ID만 업데이트
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
    // 특정 프로젝트에 속한 사진들 반환
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

    // 만약 삭제 대상이 '전경 사진'이라면, 해당 프로젝트 대표사진도 null 처리
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
      // "전경"을 "기타"로 바꾸면 → 대표 사진 제거되거나 다른 "전경"으로 대체됨
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
    await gallery_box.put(updatedPicture.pid, updatedPicture);
    loadGalleryFromHive();
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
    // 특정 결함(fid)에 해당하는 사진들 반환 (삭제 안된 것만), 최신 pid 순으로 정렬
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
    // 서버에서 현재 프로젝트의 사진들을 받아와서 Hive에 저장
    // 전경/기타/결함/현황 사진으로 분류해서 각각 리스트에 저장
    // GalleryPictures를 구성해 UI에서 접근할 수 있도록 함
    AppService appService = Get.find<AppService>();
    List<CustomPicture>? searchResult = await appService.searchPicture(
        projectSeq: appService.curProject?.value.seq ?? "");
    print(
        "appService.curProject?.value.seq: ${appService.curProject?.value.seq}");
    // searchPicture의 역할:
    // ├─ 서버에서 사진 리스트 받음
    // ├─ 로컬에만 있는 사진 제거 (서버엔 없는 사진들)
    // ├─ 서버 사진을 로컬에 반영 (추가 or 업데이트)
    // └─ 로컬에서 삭제되지 않은 사진들만 리턴 ⬅️ 바로 여기!

    if (searchResult == null) {
      // hive에 아무사진도 없을 경우 갤러리상태 모두 초기화
      faultPictures.value = [];
      bgPictures.value = [];
      etcPictures.value = [];
      curPictures.value = [];
      GalleryPictures.value = [];
      GalleryPictures.refresh();
      return;
    }
    print("searchResult.length: ${searchResult.length}");
    print("searchResult: ${searchResult}");

    // searchResult.map(
    //   // 서버에서 내려온 사진 리스트(searchResult)를 Hive 로컬 DB(gallery_box)에 저장하는 작업이야
    //   (e) => gallery_box.put(e.pid, e),
    // );

    await Future.wait(
      // 비동기 처리를 제대로 하려면 Future.wait() + await를 써야 한다
      // no가 실제 UI에서 사용되는 건 여기서야:
      searchResult.map((e) => gallery_box.put(e.pid, e)),
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
    // .value를 바꾸긴 했지만 내부의 RxList가 변했을 수도 있기 때문에,
    // 명시적으로 상태 갱신을 강제(trigger) 하려는 용도
  }

  void loadGalleryFromHive() {
    AppService appService = Get.find<AppService>();
    String projectSeq = appService.curProject?.value.seq ?? "";
    // 삭제된 사진은 제외하고, 종류별로 분류하여 UI 바인딩
    // print("projectSeq: $projectSeq");
    final localPictures = PictureList.where(
      (pic) =>
          pic.project_seq == projectSeq && pic.state != DataState.DELETED.index,
    ).toList();

    faultPictures.value = localPictures.where((p) => p.kind == "결함").toList()
      ..sort(
          (a, b) => int.parse(a.no ?? "0").compareTo(int.parse(b.no ?? "0")));

    bgPictures.value = localPictures.where((p) => p.kind == "전경").toList()
      ..sort(
          (a, b) => int.parse(a.no ?? "0").compareTo(int.parse(b.no ?? "0")));

    etcPictures.value = localPictures.where((p) => p.kind == "기타").toList()
      ..sort(
          (a, b) => int.parse(a.no ?? "0").compareTo(int.parse(b.no ?? "0")));

    curPictures.value = localPictures.where((p) => p.kind == "현황").toList()
      ..sort(
          (a, b) => int.parse(a.no ?? "0").compareTo(int.parse(b.no ?? "0")));

    GalleryPictures.value = [
      bgPictures,
      curPictures,
      etcPictures,
      faultPictures
    ];
    GalleryPictures.refresh();
  }
}

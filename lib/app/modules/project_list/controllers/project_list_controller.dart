import 'package:flutter/cupertino.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:safety_check/app/constant/data_state.dart';
import 'package:safety_check/app/data/models/05_picture.dart';
import 'package:safety_check/app/data/services/app_service.dart';
import 'package:safety_check/app/data/services/local_gallery_data_service.dart';

import '../../../routes/app_pages.dart';

class ProjectListController extends GetxController {
  final AppService appService;
  final LocalGalleryDataService localLocalGalleryDataService =
      Get.find<LocalGalleryDataService>();
  TextEditingController searchController = TextEditingController();
  late FocusNode searchFocus = FocusNode();
  RxInt isMyPlace = 0.obs;
  String searchKeyword = "";

  bool get offlineMode => appService.isOfflineMode.value;
  ProjectListController({required this.appService});

  ScrollController scrollController = ScrollController();

  @override
  Future<void> onInit() async {
    appService.isProjectInfoPage = false;
    // searchFocus.unfocus();
    await fetchData();
    super.onInit();
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  void onClose() {
    // searchFocus.dispose();
    super.onClose();
  }

  Future fetchData() async {
    // 전체현장 리스트에서 데이터 가져오는 부분임
    // 서버에서 전체 현장 리스트 받아옴 → appService.projectList 갱신
    await EasyLoading.show();
    appService.projectList.value = await appService.getProjectList(
            // 서버에서 전체 현장 리스트 (Project 목록) 를 받아옴
            my: isMyPlace.value,
            q: searchKeyword) ??
        [];
    print(appService.projectList[0].toJson());

    // 전경사진이 삭제된 상태면 프로젝트에서 삭제
    bool pictureDeleted = false;
    for (var project in appService.projectList) {
      if (project.picture_pid == "") {
        // 프로젝트에 전경사진이 없으면
        print('와요!');
        List<CustomPicture> pictures = localLocalGalleryDataService
            .getPictureInProject(projectSeq: project.seq!);
        // hive에있는 사진 중에서 같은 프로젝트 seq를 가진 사진들만 가져옴
        print(pictures);

        // 전경사진 찾기
        CustomPicture? projectPicture =
            pictures.where((element) => element.kind == "전경").firstOrNull;

        if (projectPicture != null) {
          print("projectPicture ? : ${projectPicture.toJson()}");
          project.picture = projectPicture.file_path;
          project.picture_pid = projectPicture.pid;
          // project에 사진과 pid를 강제로 넣음
        }
      } else {
        // 프로젝트에 전경사진이 있으면
        CustomPicture? picture =
            localLocalGalleryDataService.getPicture(project.picture_pid!);
        if (picture != null) {
          if (picture.kind != "전경" ||
              picture.state == DataState.DELETED.index) {
            project.picture = "";
            project.picture_pid = "";
            pictureDeleted = true;
          }
        }
      }
    }

    if (pictureDeleted) {
      appService.projectList.refresh();
    }

    // 설비목록 가져오기
    if (offlineMode) {
      // for (Project project in projectList.value) {
      //   // appService.reflectAllChangesInProject(project_seq: project.seq!);
      // }
    }

    await EasyLoading.dismiss();
  }

  // 전체현장, 내현장 전환
  changePlace(int value) async {
    isMyPlace.value = value;
    fetchData();
  }

  // 검색
  search(String keyword) async {
    searchKeyword = keyword;
    fetchData();
  }

  // 새로고침
  reloadProjects() async {
    fetchData();
  }

  // 프로젝트 선택 = > 프로젝트 정보 페이지로 이동
  onTapProject(index) {
    appService.isProjectSelected = true;
    appService.curProject?.value = appService.projectList[index];
    Get.toNamed(Routes.PROJECT_INFO);
  }
}

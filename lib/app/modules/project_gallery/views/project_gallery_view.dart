import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:safety_check/app/constant/constants.dart';
import 'package:safety_check/app/modules/project_gallery/controllers/project_gallery_controller.dart';
import 'package:safety_check/app/modules/project_gallery/views/widgets/gallery_app_bar.dart';
import 'package:safety_check/app/modules/project_gallery/views/widgets/category_section.dart';
import 'package:safety_check/app/widgets/left_menu_bar.dart';

class ProjectGalleryView extends GetView<ProjectGalleryController> {
  const ProjectGalleryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() => PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) {
            if (!didPop) {
              controller.onTapBack();
            }
          },
          child: Scaffold(
            backgroundColor: Colors.black,
            body: SafeArea(
              child: Stack(
                children: [
                  // 앱바 위젯 (프로젝트 정보 및 카테고리 선택)
                  GalleryAppBar(
                    projectName: controller.projectInfo?.name ?? "",
                    onBackPressed: () => controller.onTapBack(),
                    categories: controller.imageCates,
                    currentCategory: controller.curCate.value,
                    onCategoryChanged: (value) {
                      controller.curCate.value = value.toString();
                      controller.scrollController.jumpTo(0.0); // 맨 위로 이동
                    },
                  ),

                  // 메인 컨텐츠 영역
                  Container(
                      padding: EdgeInsets.only(
                          left: leftBarWidth, top: appBarHeight),
                      child: Scrollbar(
                        controller: controller.scrollController,
                        child: Container(
                          color: Color(0xff646D78),
                          padding: const EdgeInsets.only(
                            left: 16,
                            right: 16.0,
                            top: 16,
                          ),
                          width: MediaQuery.of(context).size.width,
                          child: SingleChildScrollView(
                            controller: controller.scrollController,
                            child: ListView.builder(
                              physics: NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: controller.localGalleryDataService
                                  .GalleryPictures.length,
                              itemBuilder: (context, index) {
                                // 카테고리 섹션 (전경, 현황, 기타, 결함)
                                return CategorySection(
                                  index: index,
                                  currentCategory: controller.curCate.value,
                                  pictures: controller.localGalleryDataService
                                      .GalleryPictures[index],
                                  controller: controller,
                                );
                              },
                            ),
                          ),
                        ),
                      )),

                  // 왼쪽 메뉴바
                  LeftMenuBar(),
                ],
              ),
            ),
          ),
        ));
  }
}

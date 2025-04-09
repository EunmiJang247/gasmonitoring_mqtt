import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:safety_check/app/constant/gaps.dart';
import 'package:safety_check/app/data/models/05_picture.dart';
import 'package:safety_check/app/modules/project_gallery/controllers/project_gallery_controller.dart';
import 'package:safety_check/app/modules/project_gallery/views/widgets/photo_grid_view.dart';

class CategorySection extends StatelessWidget {
  final int index;
  final String currentCategory;
  // final RxList specificPictures;
  final ProjectGalleryController controller;
  final RxList<CustomPicture> pictures;

  const CategorySection({
    super.key,
    required this.index,
    required this.currentCategory,
    required this.pictures,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    // 카테고리 이름 결정
    final String categoryName = _getCategoryName();

    // 이 카테고리를 표시할지 결정
    final bool isVisible = _isVisibleCategory();

    // 결함인 경우 추가 공간 필요
    final double extraExtent = index == 3 ? 44 : 20;

    return Column(
      children: [
        Visibility(
          visible: isVisible,
          child: Column(
            children: [
              // 카테고리 제목
              _buildCategoryHeader(categoryName),

              Gaps.h16,

              // 사진 그리드 뷰
              PhotoGridView(
                pictures: pictures,
                controller: controller,
                extraExtent: extraExtent,
                categoryIndex: index,
              ),
            ],
          ),
        ),

        // "전체" 카테고리에서는 구분선 표시
        Visibility(
          visible: currentCategory == "전체" &&
              index <
                  controller.localGalleryDataService.GalleryPictures.length - 1,
          child: Column(
            children: [
              Divider(color: Colors.white30),
              Gaps.h16,
            ],
          ),
        ),
      ],
    );
  }

  // 카테고리 헤더 위젯
  Widget _buildCategoryHeader(String categoryName) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        categoryName,
        style: TextStyle(
          color: Colors.white,
          fontFamily: "Pretendard",
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // 카테고리 이름 결정 메서드
  String _getCategoryName() {
    switch (index) {
      case 0:
        return "전경";
      case 1:
        return "현황";
      case 2:
        return "기타";
      case 3:
        return "결함";
      default:
        return "";
    }
  }

  // 현재 카테고리가 표시되어야 하는지 결정하는 메서드
  bool _isVisibleCategory() {
    if (currentCategory == "전체") return true;

    switch (index) {
      case 0:
        return currentCategory == "전경";
      case 1:
        return currentCategory == "현황";
      case 2:
        return currentCategory == "기타";
      case 3:
        return currentCategory == "결함";
      default:
        return false;
    }
  }
}

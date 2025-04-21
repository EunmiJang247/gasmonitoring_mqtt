import 'package:flutter/material.dart';
import 'package:safety_check/app/constant/constants.dart';
import 'package:safety_check/app/widgets/custom_app_bar.dart';

// JENNY TODO
// 갤러리 상단에 위치하는 앱 바(Tabs 상단 or 그 자체) 역할을 하는 커스텀 AppBar 위젯
class GalleryAppBar extends StatelessWidget {
  final String projectName;
  final VoidCallback onBackPressed;
  final List<String> categories;
  final String currentCategory;
  final Function(String?) onCategoryChanged;

  const GalleryAppBar({
    super.key,
    required this.projectName,
    required this.onBackPressed,
    required this.categories,
    required this.currentCategory,
    required this.onCategoryChanged,
  });

  @override
  Widget build(BuildContext context) {
    return CustomAppBar(
      // 프로젝트명 + 뒤로 가기 버튼
      leftSide: Stack(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: EdgeInsets.only(left: 48),
              width: 520,
              child: Text(
                projectName,
                style: TextStyle(
                  fontFamily: "Pretendard",
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          InkWell(
            onTap: onBackPressed,
            child: Container(
              margin: EdgeInsets.only(right: 44),
              height: appBarHeight,
              width: 44,
              child: Icon(
                Icons.arrow_back_ios_new,
                size: 28,
              ),
            ),
          ),
        ],
      ),
      rightSide: Row(
        // 카테고리 선택용 드롭다운 (전경, 결함 등등)
        children: [
          _buildCategoryDropdown(),
        ],
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    // 카테고리 선택용 드롭다운 (전경, 결함 등등)
    return Container(
      width: 110,
      height: 40,
      padding: EdgeInsets.only(left: 8),
      margin: EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: DropdownButton(
          value: currentCategory,
          items: List.generate(
            categories.length,
            (index) {
              return DropdownMenuItem(
                value: categories[index],
                child: Text(
                  categories[index],
                  style: TextStyle(
                    color: currentCategory == categories[index]
                        ? Colors.redAccent
                        : Colors.black,
                  ),
                ),
              );
            },
          ),
          onChanged: onCategoryChanged,
          selectedItemBuilder: (context) {
            return List.generate(
              categories.length,
              (index) => DropdownMenuItem(
                value: categories[index],
                child: Text(
                  categories[index],
                  style: TextStyle(color: Colors.black),
                ),
              ),
            );
          },
          style: TextStyle(
            fontFamily: "Pretendard",
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
          dropdownColor: Colors.white,
          elevation: 2,
          borderRadius: BorderRadius.circular(8),
          underline: Container(),
          icon: Icon(Icons.keyboard_arrow_down_rounded),
          isDense: true,
          isExpanded: true,
          menuWidth: 110,
        ),
      ),
    );
  }
}

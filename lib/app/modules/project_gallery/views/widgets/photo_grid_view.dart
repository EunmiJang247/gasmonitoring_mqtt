import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:safety_check/app/data/models/05_picture.dart';
import 'package:safety_check/app/modules/project_gallery/controllers/project_gallery_controller.dart';
import 'photo_grid_item.dart';

class PhotoGridView extends StatelessWidget {
  final RxList<CustomPicture> pictures;
  final ProjectGalleryController controller;
  final double extraExtent;
  final int categoryIndex;

  const PhotoGridView({
    super.key,
    required this.pictures,
    required this.controller,
    required this.extraExtent,
    required this.categoryIndex,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      double gridWidth = constraints.maxWidth;
      double itemWidth = (gridWidth -
              (controller.crossAxisSpacing * (controller.gridColumn - 1))) /
          controller.gridColumn;

      return GridView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: controller.gridColumn,
          crossAxisSpacing: controller.crossAxisSpacing,
          mainAxisExtent: controller.mainAxisExtent + extraExtent,
        ),
        itemCount: pictures.length,
        itemBuilder: (context, index) {
          return PhotoGridItem(
            picture: pictures[index],
            controller: controller,
            itemWidth: itemWidth,
            categoryIndex: categoryIndex,
          );
        },
      );
    });
  }
}

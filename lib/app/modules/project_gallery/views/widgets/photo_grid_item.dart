import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:safety_check/app/constant/app_color.dart';
import 'package:safety_check/app/constant/gaps.dart';
import 'package:safety_check/app/modules/project_gallery/controllers/project_gallery_controller.dart';
import 'package:safety_check/app/widgets/photo.dart';
import 'package:safety_check/app/widgets/two_button_dialog.dart';
import 'photo_info.dart';

class PhotoGridItem extends StatefulWidget {
  final dynamic picture;
  final ProjectGalleryController controller;
  final double itemWidth;
  final int categoryIndex;

  const PhotoGridItem({
    super.key,
    required this.picture,
    required this.controller,
    required this.itemWidth,
    required this.categoryIndex,
  });

  @override
  State<PhotoGridItem> createState() => _PhotoGridItemState();
}

class _PhotoGridItemState extends State<PhotoGridItem> {
  bool isDeleting = false;

  @override
  Widget build(BuildContext context) {
    // 사진 정보 가져오기
    final photoInfo = PhotoInfoData.fromPicture(
        picture: widget.picture,
        categoryIndex: widget.categoryIndex,
        controller: widget.controller);

    return IntrinsicHeight(
      child: Column(
        children: [
          // 이미지와 삭제 UI
          _buildPhotoWithDeleteOption(),

          // 사진 정보 표시
          PhotoInfo(
            photoNo: widget.picture.no,
            locationInfo: photoInfo.locationInfo,
            extraInfo: photoInfo.extraInfo,
            isDefect: widget.categoryIndex == 3,
          ),
        ],
      ),
    );
  }

  // 이미지와 삭제 옵션을 포함한 스택
  Widget _buildPhotoWithDeleteOption() {
    return Stack(
      children: [
        // 사진 표시 영역
        GestureDetector(
          onTap: () => widget.controller.checkImage(widget.picture),
          onLongPress: () => setState(() => isDeleting = true),
          child: Container(
            height: widget.controller.imageHeight,
            decoration: BoxDecoration(boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  offset: Offset(0, 4),
                  blurRadius: 6,
                  spreadRadius: -4),
              BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  offset: Offset(0, 10),
                  blurRadius: 15,
                  spreadRadius: -3),
            ]),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Photo(
                boxFit: BoxFit.cover,
                imageUrl: widget.picture.thumb,
                width: 300,
              ),
            ),
          ),
        ),

        // 삭제 옵션 UI
        _buildDeleteOptions(),
      ],
    );
  }

  // 삭제 옵션 UI
  Widget _buildDeleteOptions() {
    return AnimatedPositioned(
      duration: Duration(milliseconds: 200),
      left: isDeleting ? 0 : widget.itemWidth,
      curve: Curves.easeIn,
      child: SizedBox(
        height: widget.controller.imageHeight,
        width: widget.itemWidth,
        child: Row(
          children: [
            // 취소 버튼
            Expanded(
              child: InkWell(
                onTap: () => setState(() => isDeleting = false),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.8),
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(8),
                        topLeft: Radius.circular(8)),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.close_rounded,
                      color: Colors.white,
                      size: 36,
                    ),
                  ),
                ),
              ),
            ),

            // 삭제 버튼
            Expanded(
              child: InkWell(
                onTap: () {
                  setState(() => isDeleting = false);
                  _showDeleteConfirmationDialog();
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.8),
                    borderRadius: BorderRadius.only(
                        bottomRight: Radius.circular(8),
                        topRight: Radius.circular(8)),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.delete,
                      color: Colors.white,
                      size: 36,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 삭제 확인 대화상자
  void _showDeleteConfirmationDialog() {
    showDialog(
      context: context,
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
                "사진을 삭제하시겠습니까?\n삭제하면 복구 할 수 없습니다.",
                style: TextStyle(
                  fontFamily: "Pretendard",
                  fontSize: 18,
                ),
                textAlign: TextAlign.center,
              )
            ],
          ),
          yes: "삭제",
          no: "취소",
          onYes: () {
            Get.back();
            widget.controller.deletePicture(widget.picture.pid);
          },
          onNo: () => Get.back(),
        );
      },
    );
  }
}

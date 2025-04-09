import 'package:flutter/material.dart';
import 'package:safety_check/app/constant/data_state.dart';
import 'package:safety_check/app/modules/project_gallery/controllers/project_gallery_controller.dart';

class PhotoInfo extends StatelessWidget {
  final String? photoNo;
  final String locationInfo;
  final String extraInfo;
  final bool isDefect;

  const PhotoInfo({
    super.key,
    required this.photoNo,
    required this.locationInfo,
    required this.extraInfo,
    this.isDefect = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 사진 번호
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text(
            photoNo ?? "사진 업로드 필요",
            style: TextStyle(
              fontFamily: "Pretendard",
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: photoNo == null ? Color(0xffff6060) : Colors.white,
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
        ),

        // 위치 정보
        Text(
          locationInfo,
          style: TextStyle(
            fontFamily: "Pretendard",
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Colors.white70,
          ),
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
        ),

        // 결함 추가 정보 (결함인 경우만 표시)
        if (isDefect && extraInfo.isNotEmpty)
          Text(
            extraInfo,
            style: TextStyle(
              fontFamily: "Pretendard",
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.white70,
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
      ],
    );
  }
}

// 사진 정보를 담는 클래스
class PhotoInfoData {
  final String locationInfo;
  final String extraInfo;

  PhotoInfoData({
    required this.locationInfo,
    this.extraInfo = '',
  });

  // 사진 정보 생성 팩토리 메소드
  static PhotoInfoData fromPicture({
    required dynamic picture,
    required int categoryIndex,
    required ProjectGalleryController controller,
  }) {
    String locationInfo = '';
    String extraInfo = '';

    if (categoryIndex < 3) {
      // 일반 사진 정보 (전경, 현황, 기타)
      if (picture.dong != null) {
        locationInfo += picture.dong!;
      }
      if (picture.floor_name != null) {
        if (locationInfo.isNotEmpty) locationInfo += ' ';
        locationInfo += picture.floor_name!;
      }
      if (picture.location != null) {
        if (locationInfo.isNotEmpty) locationInfo += ' ';
        locationInfo += picture.location!;
      }

      if (locationInfo.isEmpty) {
        locationInfo = "사진 정보 없음";
      }
    } else if (categoryIndex == 3) {
      // 결함 사진 정보
      if (picture.dong != null) {
        locationInfo += picture.dong!;
      }
      if (picture.floor_name != null) {
        if (locationInfo.isNotEmpty) locationInfo += ' ';
        locationInfo += picture.floor_name!;
      }
      if (picture.location != null) {
        if (locationInfo.isNotEmpty) locationInfo += ' ';
        locationInfo += picture.location!;
      }

      if (locationInfo.isEmpty) {
        if (controller.checkPictureState(picture.pid!) == DataState.NEW.index) {
          locationInfo = "사진 업로드 필요";
        } else {
          locationInfo = "사진 정보 없음";
        }
      }

      // 결함 추가 정보
      if (picture.cate1_seq != null || picture.cate2_seq != null) {
        extraInfo +=
            controller.makeCateString(picture.cate1_seq, picture.cate2_seq);
      }
      if (picture.width != null) {
        if (extraInfo.isNotEmpty) extraInfo += ' ';
        extraInfo += "${picture.width!}mm";
      }
      if (picture.length != null) {
        if (extraInfo.isNotEmpty) extraInfo += ' ';
        extraInfo += "${picture.length!}m";
      }
    }

    return PhotoInfoData(
      locationInfo: locationInfo,
      extraInfo: extraInfo,
    );
  }
}

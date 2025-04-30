import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:io';
import 'package:safety_check/app/data/models/05_picture.dart';
import 'package:safety_check/app/data/services/local_gallery_data_service.dart';
import 'package:safety_check/app/modules/project_checks/view/widget/photo_detail_modal.dart';
import 'package:safety_check/app/utils/log.dart';

class PhotoBox extends StatelessWidget {
  final String? title;
  final String? pid;
  final String? remark;

  const PhotoBox({
    super.key,
    this.title,
    this.pid,
    this.remark,
  });

  // 하이브에서 pid에 해당하는 사진 가져오기
  Future<CustomPicture?> _getImageFromGallery() async {
    if (pid == null) return null;

    try {
      final galleryService = Get.find<LocalGalleryDataService>();
      logInfo("사진은요: ${galleryService.getPicture(pid!)?.file_path}");
      return galleryService.getPicture(pid!);
    } catch (e) {
      debugPrint('Error loading image from gallery: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (title != null)
          Text(
            title!,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        SizedBox(height: 4),
        GestureDetector(
          onTap: () {
            _getImageFromGallery().then((picture) {
              showDialog(
                context: context,
                builder: (context) => PhotoDetailModal(
                  picture: picture ?? CustomPicture(),
                  title: title,
                  remark: remark,
                ),
              );
            });
          },
          child: Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: FutureBuilder<CustomPicture?>(
              future: _getImageFromGallery(),
              builder: (context, snapshot) {
                logInfo("snapshot: ${snapshot}");
                logInfo("snapshot.hasData: ${snapshot.hasData}");
                logInfo("snapshot.data: ${snapshot.data?.toJson()}");
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasData && snapshot.data != null) {
                  final imagePath = snapshot.data!.file_path;
                  if (imagePath != null) {
                    logInfo("imagePath $imagePath");

                    if (imagePath.startsWith('http')) {
                      // 인터넷 URL이면 Image.network
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          imagePath,
                          fit: BoxFit.cover,
                          width: 150,
                          height: 150,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(Icons.error);
                          },
                        ),
                      );
                    } else {
                      // 로컬 파일이면 Image.file
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          File(imagePath),
                          fit: BoxFit.cover,
                          width: 150,
                          height: 150,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(Icons.error);
                          },
                        ),
                      );
                    }
                  }
                }

                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.photo_outlined,
                        size: 48,
                        color: Colors.grey[400],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
        SizedBox(height: 4),
        SizedBox(
          width: 150,
          height: 32,
          child: Text(
            remark ?? '',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        )
      ],
    );
  }
}

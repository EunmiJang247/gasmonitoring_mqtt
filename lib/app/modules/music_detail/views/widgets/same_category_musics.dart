import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:meditation_friend/app/constant/app_color.dart';
import 'package:meditation_friend/app/modules/music_detail/controllers/music_detail_controller.dart';
import 'package:meditation_friend/app/utils/log.dart';

class SameCategoryMusics extends StatelessWidget {
  final MusicDetailController controller; // controller 매개변수 추가

  const SameCategoryMusics({
    super.key,
    required this.controller, // required로 설정
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Obx로 감싸서 musicList 변화 감지
        Obx(() {
          final musicList = controller.appService.musicList;
          if (musicList.isEmpty) {
            return SizedBox(
              height: 100.h,
              child: Center(
                child: Text(
                  '음악이 없습니다',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14.sp,
                  ),
                ),
              ),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "동일 카테고리",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12.sp,
                ),
              ),
              SizedBox(height: 4.h),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: AppColors.kBrighBlue,
                    width: 0.5.w,
                  ),
                  borderRadius: BorderRadius.circular(10.w), // 선택 사항
                ),
                height: 110.h,
                child: SingleChildScrollView(
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 1,
                      mainAxisSpacing: 4.h,
                      crossAxisSpacing: 8.w,
                      childAspectRatio: 8,
                    ),
                    itemCount: musicList.length,
                    itemBuilder: (context, index) {
                      final music = musicList[index];
                      return GestureDetector(
                        onTap: () {
                          controller.selectMusic(music);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.kDark.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10.w),
                            boxShadow: [
                              BoxShadow(color: Colors.black12, blurRadius: 4),
                            ],
                            border: Border.all(
                              color: Colors.white.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          padding: EdgeInsets.symmetric(
                              horizontal: 10.w, vertical: 2.h),
                          child: Row(
                            children: [
                              Text(
                                music.title ?? "?",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        }),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:meditation_friend/app/constant/app_color.dart';
import 'package:meditation_friend/app/data/models/music.dart';

class OtherCategoryMusics extends StatelessWidget {
  OtherCategoryMusics({Key? key}) : super(key: key);

  final List<Music> items = List.generate(
    10,
    (index) => Music(
        imageUrl:
            'https://via.placeholder.com/100x100.png?text=Image+${index + 1}',
        title: 'Button ${index + 1}',
        onTap: () {
          // 클릭 이벤트 처리
          print("버튼 ${index + 1} 클릭됨");
        }),
  );

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 제목 추가
        Padding(
          padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 10.w),
          child: Text(
            "다른 카테고리",
            style: TextStyle(
              color: Colors.white,
              fontSize: 14.sp,
              fontWeight: FontWeight.normal,
            ),
          ),
        ),

        // 그리드뷰 수정
        GridView.builder(
          physics: NeverScrollableScrollPhysics(), // 스크롤 비활성화
          shrinkWrap: true, // 내용에 맞게 크기 조정
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 8.h,
            crossAxisSpacing: 8.w,
            childAspectRatio: 2.5, // 가로:세로 비율 조정 (직사각형)
          ),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return GestureDetector(
              onTap: () {
                // 클릭 이벤트 추가
                item.onTap?.call();
              },
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.kDark.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(10.w),
                  boxShadow: [
                    BoxShadow(color: Colors.black12, blurRadius: 4),
                  ],
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Image.network(
                      item.imageUrl ?? '',
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 60,
                          height: 60,
                          color: Colors.grey,
                          child: Icon(Icons.image_not_supported,
                              color: Colors.white),
                        );
                      },
                    ),
                    SizedBox(width: 10.w),
                    Text(
                      item.title ?? '',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          },
        ),

        // 하단 여백 추가
        SizedBox(height: 80.h),
      ],
    );
  }
}

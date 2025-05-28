import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:meditation_friend/app/constant/app_color.dart';
import 'package:meditation_friend/app/modules/music_detail/controllers/music_detail_controller.dart';

class OtherCategoryMusics extends StatelessWidget {
  final MusicDetailController controller; // controller 매개변수 추가

  const OtherCategoryMusics({
    super.key,
    required this.controller, // required로 설정
  });

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> items = [
      {
        'imageUrl': 'assets/images/pic1.png',
        'title': '바디스캐닝',
        'category': '바디스캐닝',
      },
      {
        'imageUrl': 'assets/images/pic2.png',
        'title': '호흡 명상',
        'category': '호흡',
      },
      {
        'imageUrl': 'assets/images/pic3.png',
        'title': '동기부여',
        'category': '동기부여',
      },
      {
        'imageUrl': 'assets/images/pic4.png',
        'title': '스트레스해소',
        'category': '스트레스해소',
      },
      {
        'imageUrl': 'assets/images/pic5.png',
        'title': '상상 명상',
        'category': '상상',
      },
      {
        'imageUrl': 'assets/images/pic6.png',
        'title': '질문 명상',
        'category': '질문',
      },
    ];

    return Column(
      children: [
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
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
                // 전달받은 controller 사용
                controller.changeCategory(item['category']);
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
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
                child: Row(
                  children: [
                    Image.asset(
                      item['imageUrl'],
                      width: 35,
                      height: 35,
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
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        item['title'],
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        SizedBox(height: 80.h),
      ],
    );
  }
}

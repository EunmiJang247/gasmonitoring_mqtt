import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_image_slideshow/flutter_image_slideshow.dart';
import 'package:meditation_friend/app/constant/app_color.dart';
import 'package:meditation_friend/app/constant/constants.dart';

class QuoteSlider extends StatelessWidget {
  const QuoteSlider({super.key});

  @override
  Widget build(BuildContext context) {
    return ImageSlideshow(
        indicatorBackgroundColor: Colors.transparent,
        indicatorColor: Colors.transparent,
        onPageChanged: (page) {},
        autoPlayInterval: 5000,
        isLoop: true,
        children: List.generate(quotes.length, (i) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 0.h),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(quotes[i].quote,
                    maxLines: 2, // 최대 2줄까지만 표시
                    overflow: TextOverflow.ellipsis, // 초과 시 ... 처리
                    textAlign: TextAlign.left,
                    style: TextStyle(
                        color: AppColors.kWhite,
                        fontSize: 20.sp,
                        letterSpacing: 0.5)),
                SizedBox(height: 4),
                Text('- ${quotes[i].author}',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      color: AppColors.kWhite,
                      fontSize: 14.sp,
                    )),
              ],
            ),
          );
        }));
  }
}

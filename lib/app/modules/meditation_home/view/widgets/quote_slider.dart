import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_image_slideshow/flutter_image_slideshow.dart';
import 'package:meditation_friend/app/constant/constants.dart';

class QuoteSlider extends StatelessWidget {
  const QuoteSlider({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: ImageSlideshow(
        indicatorBackgroundColor: Colors.transparent,
        indicatorColor: Colors.transparent,
        onPageChanged: (page) {},
        autoPlayInterval: 5000,
        isLoop: true,
        children: List.generate(quotes.length, (i) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 1.h),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(quotes[i].quote,
                    maxLines: 2, // 최대 2줄까지만 표시
                    overflow: TextOverflow.ellipsis, // 초과 시 ... 처리
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFFFFFF00), // Namaste 텍스트 색상
                      fontSize: 16,
                    )),
                SizedBox(height: 4),
                Text(
                  '- ${quotes[i].author}',
                  textAlign: TextAlign.start,
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

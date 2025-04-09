import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../../constant/app_color.dart';

Dialog drawingHelpDialog(BuildContext context) {
  List<Image> helpImages = [
    Image.asset("assets/images/help1.png",),
    Image.asset("assets/images/help2.png",),
    Image.asset("assets/images/help3.png",),
  ];
  int carouselIndex = 0;
  return Dialog(
    backgroundColor: Colors.black38,
    insetPadding: EdgeInsets.zero,
    shape: LinearBorder(),
    child: InkWell(
      onTap: () {
        Get.back();
        FocusScope.of(context).unfocus();
      },
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        color: Colors.black12,
        child: StatefulBuilder(
          builder: (context, setState) {
            return Stack(
              children: [
                CarouselSlider(
                    items: helpImages,
                    options: CarouselOptions(
                      height: MediaQuery.of(context).size.height,
                      padEnds: false,
                      pageSnapping: true,
                      enableInfiniteScroll: false,
                      viewportFraction: 1,
                      enlargeCenterPage: false,
                      onPageChanged: (index, reason) {
                        setState(() {
                          carouselIndex = index;
                        });
                      },
                    )
                ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 24.0),
                  child: AnimatedSmoothIndicator(
                    activeIndex: carouselIndex,
                    count: helpImages.length,
                    effect: WormEffect(
                      dotWidth: 8.0,
                      dotHeight: 8.0,
                      activeDotColor: AppColors.c4,
                      dotColor: Colors.grey,
                    ),
                    // onDotClicked: (index) {
                    //   _controller.animateToPage(index);
                    // },
                  ),
                ),
              ),
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: EdgeInsets.all(8.w),
                    child: Icon(
                      Icons.close_rounded,
                      color: Colors.white,
                      size: 10.w,
                    ),
                  ),
                )
              ],
            );
          }
        ),
      ),
    ),
  );
}
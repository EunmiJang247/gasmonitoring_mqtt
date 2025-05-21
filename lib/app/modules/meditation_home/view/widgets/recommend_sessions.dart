import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:meditation_friend/app/constant/app_color.dart';
import 'package:get/get.dart';
import 'package:meditation_friend/app/constant/constants.dart';
import 'package:meditation_friend/app/modules/meditation_home/controllers/home_controller.dart';
import 'package:meditation_friend/app/modules/mypage/views/widgets/gradient_button.dart';

class RecommendSessions extends GetView<HomeController> {
  const RecommendSessions({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "추천 세션",
          style: TextStyle(color: AppColors.kBrighYellow),
        ),
        SizedBox(
          width: ScreenUtil().screenWidth - 40,
          child: Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () {
                    controller.onMusicListen();
                  },
                  child: Card(
                    color: AppColors.kDark,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: AppColors.kBrighYellow,
                        width: 1.0,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(Icons.abc,
                              color: AppColors.kBrighYellow, size: 30),
                          Text("스트레스 해소",
                              style: TextStyle(color: AppColors.kBrighYellow))
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: InkWell(
                  onTap: () {
                    controller.onMusicListen();
                  },
                  child: Card(
                    color: AppColors.kDark,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: AppColors.kBrighYellow,
                        width: 1.0,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(Icons.abc,
                              color: AppColors.kBrighYellow, size: 30),
                          Text("스트레스 해소",
                              style: TextStyle(color: AppColors.kBrighYellow))
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          width: ScreenUtil().screenWidth - 40,
          child: Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () {
                    controller.onMusicListen();
                  },
                  child: Card(
                    color: AppColors.kDark,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: AppColors.kBrighYellow,
                        width: 1.0,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(Icons.abc,
                              color: AppColors.kBrighYellow, size: 30),
                          Text("스트레스 해소",
                              style: TextStyle(color: AppColors.kBrighYellow))
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: InkWell(
                  onTap: () {
                    controller.onMusicListen();
                  },
                  child: Card(
                    color: AppColors.kDark,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: AppColors.kBrighYellow,
                        width: 1.0,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(Icons.abc,
                              color: AppColors.kBrighYellow, size: 30),
                          Text("스트레스 해소",
                              style: TextStyle(color: AppColors.kBrighYellow))
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

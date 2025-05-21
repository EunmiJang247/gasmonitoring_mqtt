import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:meditation_friend/app/constant/app_color.dart';
import 'package:get/get.dart';
import 'package:meditation_friend/app/constant/constants.dart';
import 'package:meditation_friend/app/modules/meditation_home/controllers/home_controller.dart';
import 'package:meditation_friend/app/modules/mypage/views/widgets/gradient_button.dart';

class StartMeditationPlayerBtn extends GetView<HomeController> {
  const StartMeditationPlayerBtn({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "오늘의 명상 시작하기",
          style: TextStyle(color: AppColors.kBrighYellow),
        ),
        SizedBox(
          width: ScreenUtil().screenWidth - 40,
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
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.abc,
                            color: AppColors.kBrighYellow, size: 30),
                        SizedBox(width: 10.w),
                        Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("명상 음악 듣기",
                                  style:
                                      TextStyle(color: AppColors.kBrighYellow)),
                              Text("명상 음악을 들어보세요",
                                  style:
                                      TextStyle(color: AppColors.kBrighYellow))
                            ]),
                      ],
                    ),
                    GradientBtn(
                      text: "시작",
                      textColor: AppColors.kDark,
                      btnColor: AppColors.kBrighYellow,
                      borderColor: AppColors.kBrighYellow,
                      btnWidth: 100,
                      btnHieght: 45,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

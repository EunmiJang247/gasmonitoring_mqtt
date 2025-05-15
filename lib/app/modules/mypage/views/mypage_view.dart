import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:meditation_friend/app/constant/app_color.dart';
import 'package:meditation_friend/app/modules/mypage/controllers/mypage_controller.dart';
import 'package:meditation_friend/app/modules/mypage/views/widgets/gradient_button.dart';
import 'package:meditation_friend/app/modules/mypage/views/widgets/meditation_alarm_time_sheet.dart';
import 'package:meditation_friend/app/modules/mypage/views/widgets/meditation_duration_sheet.dart';
import 'package:meditation_friend/app/modules/mypage/views/widgets/meditation_gender_bottom_sheet.dart';
import 'package:meditation_friend/app/modules/mypage/views/widgets/meditation_kind_bottom_sheet.dart';
import 'package:meditation_friend/app/modules/mypage/views/widgets/tile_widget.dart';
import 'package:meditation_friend/app/widgets/under_tab_bar.dart';

class MypageView extends GetView<MypageController> {
  const MypageView({super.key});

  @override
  Widget build(BuildContext context) {
    // if (controller.appService.user.value != null) {
    if (true) {
      // 로그인 개발하고 위에꺼로 바꾸기, 아래꺼 주석 풀기
      return Scaffold(
        backgroundColor: AppColors.kSkyBlue,
        body: PopScope(
          canPop: true,
          onPopInvoked: (didPop) {
            if (didPop) return;

            controller.appService.onPop(context);
          },
          child: SafeArea(
            child: Stack(
              fit: StackFit.expand, // Stack이 전체 화면을 차지하도록
              children: [
                Column(children: [
                  const SizedBox(height: 20),
                  const CircleAvatar(
                    radius: 50,
                    backgroundColor: AppColors.kOffWhite,
                  ),
                  const SizedBox(height: 20),
                  // ReusableText(
                  //   text: user!.id.toString(),
                  //   style: appStyle(11, AppColors.kDark, FontWeight.w600),
                  // ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    // Text(
                    //   user.username.toString(),
                    // ),
                    // child: ReusableText(
                    //   text:
                    //   style: appStyle(14, AppColors.kDark, FontWeight.w600),
                    // ),
                  ),
                  SizedBox(height: 20.h),
                  Container(
                    color: AppColors.kSkyBlue,
                    child: Column(
                      children: [
                        ProfileTileWidget(
                          title: "선호하는 명상종류",
                          leading: Icons.check,
                          onTap: () => meditationKindBottomSheet(context),
                        ),
                        ProfileTileWidget(
                          title: "명상 길이 설정",
                          leading: Icons.timelapse,
                          onTap: () => meditationDurationBottomSheet(context),
                        ),
                        ProfileTileWidget(
                          title: "명상 알림 시간 설정",
                          leading: Icons.lock_clock,
                          onTap: () => meditationAlramTimeBottomSheet(context),
                        ),
                        ProfileTileWidget(
                          title: "선호하는 성별",
                          leading: Icons.accessibility,
                          onTap: () => meditationGenderBottomSheet(context),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20.h),
                  Padding(
                      padding: const EdgeInsets.all(14.0),
                      child: GradientBtn(
                          text: "로그아웃",
                          textColor: AppColors.kWhite,
                          btnColor: AppColors.kOrange,
                          btnWidth: ScreenUtil().screenWidth - 40,
                          btnHieght: 45,
                          onTap: () {
                            controller.appService.logOut();
                          })),
                  Padding(
                      padding: const EdgeInsets.all(14.0),
                      child: GradientBtn(
                          text: "기기토큰 보내기",
                          textColor: AppColors.kWhite,
                          btnColor: AppColors.kOrange,
                          btnWidth: ScreenUtil().screenWidth - 40,
                          btnHieght: 45,
                          onTap: () {
                            controller.appService.sendFirebaseToken();
                          })),
                  Padding(
                      padding: const EdgeInsets.all(14.0),
                      child: GradientBtn(
                          text: "알림 보내기",
                          textColor: AppColors.kWhite,
                          btnColor: AppColors.kOrange,
                          btnWidth: ScreenUtil().screenWidth - 40,
                          btnHieght: 45,
                          onTap: () {
                            controller.appService.sendAlaram();
                          }))
                ]),
                UnderTabBar(),
              ],
            ),
          ),
        ),
      );
    }
    return Scaffold(
      backgroundColor: AppColors.kSkyBlue,
      body: PopScope(
        canPop: true,
        onPopInvoked: (didPop) {
          if (didPop) return;

          controller.appService.onPop(context);
        },
        child: SafeArea(
          child: Stack(
            fit: StackFit.expand, // Stack이 전체 화면을 차지하도록
            children: [
              Center(
                child: GestureDetector(
                  onTap: () async {
                    await controller.onKakaoLogin();
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    width: MediaQuery.of(context).size.width * 0.8,
                    height: 48,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      image: const DecorationImage(
                        image:
                            AssetImage('assets/images/kakao_login_button.png'),
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ),
              UnderTabBar(),
            ],
          ),
        ),
      ),
    );
  }
}

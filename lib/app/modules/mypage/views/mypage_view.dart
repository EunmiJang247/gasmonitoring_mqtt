import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:meditation_friend/app/constant/app_color.dart';
import 'package:meditation_friend/app/constant/constants.dart';
import 'package:meditation_friend/app/modules/mypage/controllers/mypage_controller.dart';
import 'package:meditation_friend/app/modules/mypage/views/widgets/gradient_button.dart';
import 'package:meditation_friend/app/modules/mypage/views/widgets/meditation_alarm_time_sheet.dart';
import 'package:meditation_friend/app/modules/mypage/views/widgets/tile_widget.dart';
import 'package:meditation_friend/app/widgets/custom_img_button.dart';
import 'package:meditation_friend/app/widgets/under_tab_bar.dart';

class MypageView extends GetView<MypageController> {
  const MypageView({super.key});

  @override
  Widget build(BuildContext context) {
    if (controller.appService.user.value != null) {
      return Scaffold(
        backgroundColor: AppColors.kSkyBlue,
        body: PopScope(
          canPop: false,
          onPopInvoked: (bool didPop) {
            controller.appService.currentIndex.value = 0;
            Get.offNamed('/meditation-home');
          },
          child: SafeArea(
            child: Stack(
              fit: StackFit.expand, // Stack이 전체 화면을 차지하도록
              children: [
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xFF161538), // 위쪽 색상
                        Color(0xFF11002A), // 아래쪽 색상
                      ],
                    ),
                  ),
                ),
                // 2. 배경 이미지
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Image.asset(
                    HOME_BG,
                    width: ScreenUtil().screenWidth, // 핸드폰 전체 너비로
                    fit: BoxFit.cover, // 너비에 맞추기
                  ),
                ),
                // 3. 뒤로가기 버튼 - 왼쪽 상단에 위치
                Positioned(
                  top: 16.h,
                  left: 16.w,
                  child: CustomImgButton(
                    imagePath: 'assets/images/back_btn.png', // 실제 이미지 경로
                    onPressed: () {
                      controller.appService.currentIndex.value = 0;
                      Get.offNamed('/meditation-home');
                    },
                    // 선택적 매개변수
                    size: 45.w, // 크기 조정 (원하는 경우)
                    borderRadius: 25.r, // 둥글기 조정 (원하는 경우)
                  ),
                ),
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: AppColors.kOffWhite,
                    backgroundImage: controller
                                .appService.user.value?.profileImageUrl !=
                            null
                        ? NetworkImage(
                            controller.appService.user.value!.profileImageUrl)
                        : null,
                    child: controller.appService.user.value?.profileImageUrl ==
                            null
                        ? Icon(Icons.person, size: 50, color: Colors.grey)
                        : null,
                  ),
                  const SizedBox(height: 8),
                  Text(controller.appService.user.value!.nickname,
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.normal,
                          color: AppColors.kWhite)),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Column(
                    children: [
                      //       ProfileTileWidget(
                      //         title: "선호하는 명상종류",
                      //         leading: Icons.check,
                      //         onTap: () => meditationKindBottomSheet(context),
                      //       ),
                      //       SizedBox(height: 4.h),
                      //       ProfileTileWidget(
                      //         title: "명상 길이 설정",
                      //         leading: Icons.timelapse,
                      //         onTap: () => meditationDurationBottomSheet(context),
                      //       ),
                      //       SizedBox(height: 4.h),
                      ProfileTileWidget(
                          title: "명상 알람 시간 설정",
                          leading: Icons.lock_clock,
                          onTap: () => meditationAlramTimeBottomSheet(context)),
                      //       SizedBox(height: 4.h),
                      //       ProfileTileWidget(
                      //         title: "선호하는 성별",
                      //         leading: Icons.accessibility,
                      //         onTap: () => meditationGenderBottomSheet(context),
                      //       ),
                    ],
                  ),
                  // SizedBox(height: 20.h),
                  Padding(
                      padding: const EdgeInsets.all(14.0),
                      child: GradientBtn(
                          text: "로그아웃",
                          textColor: AppColors.kWhite,
                          btnColor: Colors.transparent,
                          borderColor: AppColors.kBrighBlue,
                          btnWidth: ScreenUtil().screenWidth - 40,
                          btnHieght: 45,
                          onTap: () {
                            controller.appService.logOut();
                          })),
                  // Padding(
                  //     padding: const EdgeInsets.all(14.0),
                  //     child: GradientBtn(
                  //         text: "기기토큰 보내기",
                  //         textColor: AppColors.kWhite,
                  //         btnColor: AppColors.kOrange,
                  //         btnWidth: ScreenUtil().screenWidth - 40,
                  //         btnHieght: 45,
                  //         onTap: () {
                  //           controller.appService.sendFirebaseToken();
                  //         })),

                  // Padding(
                  //     padding: const EdgeInsets.all(14.0),
                  //     child: GradientBtn(
                  //         text: "알림 보내기",
                  //         textColor: AppColors.kWhite,
                  //         btnColor: AppColors.kOrange,
                  //         btnWidth: ScreenUtil().screenWidth - 40,
                  //         btnHieght: 45,
                  //         onTap: () {
                  //           controller.appService.sendAlaram();
                  //         }))
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
            fit: StackFit.expand,
            children: [
              // 1. 배경 그라데이션
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFF161538), // 위쪽 색상
                      AppColors.kDark, // 아래쪽 색상
                    ],
                  ),
                ),
              ),

              // 2. 배경 이미지
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Image.asset(
                  HOME_BG,
                  fit: BoxFit.cover, // 너비에 맞추기
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "명상친구",
                    style: TextStyle(
                      fontSize: 28.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    "내면의 평화를 찾아 떠나는 여행",
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: Colors.white70,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20.h),
                  GestureDetector(
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
                          image: AssetImage(
                              'assets/images/kakao_login_button.png'),
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  )
                ],
              ),
              UnderTabBar(),
            ],
          ),
        ),
      ),
    );
  }
}

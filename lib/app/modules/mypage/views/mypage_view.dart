import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:safety_check/app/constant/app_color.dart';
import 'package:safety_check/app/modules/mypage/controllers/mypage_controller.dart';
import 'package:safety_check/app/widgets/under_tab_bar.dart';

class MypageView extends GetView<MypageController> {
  const MypageView({super.key});

  @override
  Widget build(BuildContext context) {
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
                  onTap: () {
                    print('카카오 로그인 클릭!');
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    // 가로 크기를 화면의 80%로 설정
                    width: MediaQuery.of(context).size.width * 0.8,
                    // 세로 크기를 48로 고정
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
              const UnderTabBar(),
            ],
          ),
        ),
      ),
    );
  }
}

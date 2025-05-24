import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:meditation_friend/app/constant/app_color.dart';
import 'package:meditation_friend/app/data/services/app_service.dart';

class UnderTabBar extends StatelessWidget {
  final AppService _appService = Get.find();

  UnderTabBar({super.key});

  void _onItemTapped(int index) {
    switch (index) {
      case 0:
        _appService.currentIndex.value = 0;
        Get.offNamed('/meditation-home');
        break;
      case 1:
        _appService.currentIndex.value = 1;
        // 이미 재생 중인 음악이 있는지 확인
        final currentMusic = _appService.curMusic?.value;

        if (currentMusic != null && currentMusic.musicUrl != null) {
          // 이미 재생 중인 음악이 있으면 해당 음악 정보와 함께 페이지 이동
          Get.toNamed('/music-detail', arguments: {
            'category': currentMusic.category ?? '',
            'continue_current': true, // 현재 음악 계속 재생 플래그
          });
        } else {
          // 재생 중인 음악이 없으면 빈 카테고리로 페이지 이동 (랜덤 음악 로드)
          Get.toNamed('/music-detail', arguments: {
            'category': '',
            'continue_current': false,
          });
        }
        break;
      case 2:
        _appService.currentIndex.value = 2;
        Get.offNamed('/mypage');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.kDark,
              border: Border(
                top: BorderSide(
                  color: AppColors.kBrighBlue,
                  width: 1.0,
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Obx(
              () => BottomNavigationBar(
                backgroundColor: AppColors.kDark,
                elevation: 0,
                currentIndex: _appService.currentIndex.value,
                type: BottomNavigationBarType.fixed,
                selectedItemColor: AppColors.kBrighBlue,
                unselectedItemColor: Colors.grey,
                items: [
                  BottomNavigationBarItem(
                    icon: Icon(
                      Icons.home,
                      color: _appService.currentIndex.value == 0
                          ? AppColors.kBrighBlue
                          : Colors.grey,
                    ),
                    label: '홈',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(
                      Icons.music_note,
                      color: _appService.currentIndex.value == 1
                          ? AppColors.kBrighBlue
                          : Colors.grey,
                    ),
                    label: '명상하기',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(
                      Icons.person,
                      color: _appService.currentIndex.value == 2
                          ? AppColors.kBrighBlue
                          : Colors.grey,
                    ),
                    label: '마이페이지',
                  ),
                ],
                onTap: _onItemTapped,
              ),
            ),
          ),
          // SafeArea 하단 여백만큼 패딩 추가
          Container(
            height: bottomPadding,
            color: AppColors.kDark,
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:safety_check/app/constant/app_color.dart';

class UnderTabBar extends StatefulWidget {
  const UnderTabBar({super.key});

  @override
  State<UnderTabBar> createState() => _UnderTabBarState();
}

class _UnderTabBarState extends State<UnderTabBar> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        Get.offNamed('/meditation-home'); // 홈 화면
        break;
      case 1:
        Get.toNamed('/music-detail'); // 음악 목록 화면
        break;
      case 2:
        Get.toNamed('/mypage'); // 마이페이지
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    // MediaQuery를 사용하여 하단 여백 계산
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
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: BottomNavigationBar(
              backgroundColor: Colors.white,
              elevation: 0,
              currentIndex: _selectedIndex,
              type: BottomNavigationBarType.fixed,
              selectedItemColor: AppColors.kOrange,
              unselectedItemColor: Colors.grey,
              items: [
                BottomNavigationBarItem(
                  icon: Icon(
                    Icons.home,
                    color:
                        _selectedIndex == 0 ? AppColors.kOrange : Colors.grey,
                  ),
                  label: '홈',
                ),
                BottomNavigationBarItem(
                  icon: Icon(
                    Icons.music_note,
                    color:
                        _selectedIndex == 1 ? AppColors.kOrange : Colors.grey,
                  ),
                  label: '명상하기',
                ),
                BottomNavigationBarItem(
                  icon: Icon(
                    Icons.person,
                    color:
                        _selectedIndex == 2 ? AppColors.kOrange : Colors.grey,
                  ),
                  label: '마이페이지',
                ),
              ],
              onTap: _onItemTapped,
            ),
          ),
          // SafeArea 하단 여백만큼 패딩 추가
          Container(
            height: bottomPadding,
            color: Colors.white,
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:meditation_friend/app/data/services/app_service.dart';
import 'package:meditation_friend/app/widgets/two_button_dialog.dart';

import '../constant/app_color.dart';
import '../constant/gaps.dart';
import '../data/models/00_user.dart';
import 'photo.dart';

// 아이콘 크기 상수 정의
const double kIconSize = 38;
const double kFontSize = 28;
const double avatarSize = 80;

class LeftMenuBar extends StatefulWidget {
  const LeftMenuBar({super.key});

  @override
  State<LeftMenuBar> createState() => _LeftMenuBarState();
}

class _LeftMenuBarState extends State<LeftMenuBar> {
  final AppService _appService = Get.find();
  User? user;
  Duration changeDuration = Duration(milliseconds: 200);

  @override
  void initState() {
    user = _appService.user.value;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // JENNY 갤러리를 열었을 때 왼쪽에 메뉴바! TODO

    return Obx(() {
      // double menuPaddingV = _appService.isLeftBarOpened.value ? 10 : 13;

      return Row(
        children: [
          GestureDetector(
            onHorizontalDragUpdate: (details) {
              if (details.primaryDelta! > 0) {
                // _appService.isLeftBarOpened.value = true;
              } else if (details.primaryDelta! < 0) {
                // _appService.isLeftBarOpened.value = false;
              }
            },
            child: AnimatedContainer(
              duration: changeDuration,
              curve: Curves.easeIn,
              color: AppColors.c4,
              // width: _appService.isLeftBarOpened.value ? 240 : leftBarWidth,
              height: MediaQuery.of(context).size.height,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                      minHeight: MediaQuery.of(context).size.height),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 사용자 프로필 섹션
                          // UserProfileSection(
                          //   user: user,
                          //   isMenuOpen: _appService.isLeftBarOpened.value,
                          //   onToggleMenu: () =>
                          //       _appService.toggleLeftBarCollapsed(),
                          //   onLogout: () => _appService.logOut(),
                          //   duration: changeDuration,
                          // ),
                        ],
                      ),
                      // 메뉴 아이템 섹션
                      // MenuItemsSection(
                      //   isMenuOpen: _appService.isLeftBarOpened.value,
                      //   isProjectSelected: _appService.isProjectSelected,
                      //   verticalPadding: menuPaddingV,
                      //   appService: _appService,
                      //   duration: changeDuration,
                      // ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // 오버레이 영역
          // if (_appService.isLeftBarOpened.value)
          //   Expanded(
          //     child: GestureDetector(
          //       onTap: () => _appService.isLeftBarOpened.value = false,
          //       child: Container(color: Colors.black38),
          //     ),
          //   ),
        ],
      );
    });
  }
}

// 사용자 프로필 섹션 위젯
class UserProfileSection extends StatelessWidget {
  final User? user;
  final bool isMenuOpen;
  final VoidCallback onToggleMenu;
  final VoidCallback onLogout;
  final Duration duration;

  const UserProfileSection({
    super.key,
    required this.user,
    required this.isMenuOpen,
    required this.onToggleMenu,
    required this.onLogout,
    required this.duration,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 헤더 영역 (프로필)
        InkWell(
          onTap: onToggleMenu,
          child: Padding(
            padding: EdgeInsets.only(
              top: isMenuOpen ? 25.h : 10.h,
              bottom: 10.0,
            ),
            child: Center(
              child: AnimatedCrossFade(
                duration: duration,
                firstChild: _buildExpandedProfile(),
                secondChild: Container(),
                crossFadeState: isMenuOpen
                    ? CrossFadeState.showFirst
                    : CrossFadeState.showSecond,
              ),
            ),
          ),
        ),
        // 축소된 메뉴일 때 프로필 아이콘
        Padding(
            padding: EdgeInsets.symmetric(vertical: isMenuOpen ? 10.h : 13.h),
            child: AnimatedCrossFade(
              duration: duration,
              firstChild: Container(),
              secondChild: Center(
                child: InkWell(
                  onTap: onToggleMenu,
                  child: Stack(
                    children: [
                      Icon(
                        Icons.account_circle_outlined,
                        color: Colors.white,
                        size: kIconSize.h,
                      ),
                    ],
                  ),
                ),
              ),
              crossFadeState: isMenuOpen
                  ? CrossFadeState.showFirst
                  : CrossFadeState.showSecond,
            )),
      ],
    );
  }

  Widget _buildExpandedProfile() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                      height: avatarSize.h,
                      width: avatarSize.h,
                      child: Photo(
                        height: avatarSize.h,
                        width: avatarSize.h,
                        boxFit: BoxFit.contain,
                        imageUrl: user?.avatar_file,
                      )),
                ],
              ),
              SizedBox(height: 10.h),
              Text(
                user?.name ?? "홍길동",
                style: TextStyle(
                    fontFamily: "Pretendard",
                    fontSize: 30.h,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                user?.email ?? "gildong@elimsafety.com",
                style: TextStyle(
                    fontFamily: "Pretendard",
                    fontSize: 26.h,
                    color: Colors.white),
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                "[${user?.machine_engineer_grade}] ${user?.machine_engineer_license_no}",
                style: TextStyle(
                    fontFamily: "Pretendard",
                    fontSize: 26.h,
                    color: Colors.white),
                overflow: TextOverflow.ellipsis,
              ),
              if (user?.role == "관리자")
                Text(
                  user?.role ?? "",
                  style: TextStyle(
                      fontFamily: "Pretendard",
                      fontSize: 26.h,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                  overflow: TextOverflow.ellipsis,
                ),
              Gaps.h12,
              // 로그아웃 버튼
              InkWell(
                onTap: () {
                  showDialog(
                    context: Get.context!,
                    builder: (context) {
                      return TwoButtonDialog(
                        content: Column(
                          children: [
                            Text(
                              "알림",
                              style: TextStyle(
                                  fontFamily: "Pretendard",
                                  color: AppColors.c1,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 22),
                            ),
                            Gaps.h16,
                            Text(
                              "로그아웃 하시겠습니까?",
                              style: TextStyle(
                                fontFamily: "Pretendard",
                                fontSize: 18,
                              ),
                              textAlign: TextAlign.center,
                            )
                          ],
                        ),
                        yes: "로그아웃",
                        no: "취소",
                        onYes: () {
                          Get.back();
                          onLogout();
                        },
                        onNo: () => Get.back(),
                      );
                    },
                  );
                },
                child: Container(
                  width: 40.w,
                  height: 50.h,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12)),
                  child: Center(
                    child: Text(
                      "로그아웃",
                      style: TextStyle(
                          fontFamily: "Pretendard",
                          fontSize: 26.h,
                          color: AppColors.c4,
                          fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        // 닫기 아이콘
        Row(
          children: [
            Icon(
              Icons.close_rounded,
              color: Colors.white,
              size: kIconSize.h,
            ),
          ],
        )
      ],
    );
  }
}

// 메뉴 아이템 섹션 위젯
class MenuItemsSection extends StatelessWidget {
  final bool isMenuOpen;
  final bool isProjectSelected;
  final double verticalPadding;
  final AppService appService;
  final Duration duration;

  const MenuItemsSection({
    super.key,
    required this.isMenuOpen,
    required this.isProjectSelected,
    required this.verticalPadding,
    required this.appService,
    required this.duration,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 홈 메뉴 아이템
        // if (isProjectSelected)
        //   MenuItem(
        //     icon: Icons.home,
        //     label: "초기 화면",
        //     isMenuOpen: isMenuOpen,
        //     verticalPadding: verticalPadding,
        //     onTap: () => appService.onTapHome(),
        //     duration: duration,
        //   ),

        // 프로젝트 선택된 경우에만 표시되는 메뉴들
        if (isProjectSelected)
          ProjectMenuItems(
            isMenuOpen: isMenuOpen,
            verticalPadding: verticalPadding,
            appService: appService,
            duration: duration,
          ),

        // 파일 업로드 메뉴 아이템
        FileUploadMenuItem(
          isMenuOpen: isMenuOpen,
          verticalPadding: verticalPadding,
          appService: appService,
          duration: duration,
        ),

        // 앱 정보 메뉴 아이템
        // MenuItem(
        //   icon: Icons.info_outline,
        //   label: "업데이트 정보",
        //   isMenuOpen: isMenuOpen,
        //   verticalPadding: verticalPadding,
        //   bottomPadding: 20,
        //   onTap: () {
        //     appService.test();
        //     // showDialog(
        //     //   context: context,
        //     //   builder: (context) =>
        //     // AppInfoDialog(updateHistory: appService.updateHistory),
        //     // );
        //   },
        //   duration: duration,
        // ),
      ],
    );
  }
}

// 프로젝트 관련 메뉴 아이템들
class ProjectMenuItems extends StatelessWidget {
  final bool isMenuOpen;
  final double verticalPadding;
  final AppService appService;
  final Duration duration;

  const ProjectMenuItems({
    super.key,
    required this.isMenuOpen,
    required this.verticalPadding,
    required this.appService,
    required this.duration,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Divider(
          color: Colors.white,
          thickness: 0.5,
          height: 20,
        ),
        // 촬영 메뉴 아이템
        MenuItem(
          icon: Icons.camera_alt_outlined,
          label: "촬영",
          isMenuOpen: isMenuOpen,
          verticalPadding: verticalPadding,
          onTap: () async {
            // await appService.cameraSelected();
          },
          duration: duration,
        ),
        // 갤러리 메뉴 아이템
        // MenuItem(
        //   icon: Icons.photo_outlined,
        //   label: "갤러리",
        //   isMenuOpen: isMenuOpen,
        //   verticalPadding: verticalPadding,
        //   onTap: () => appService.onTapGallery(),
        //   duration: duration,
        // ),
        // // 3D 투어 메뉴 아이템
        // if (appService.liveTourUrl.isNotEmpty)
        //   LiveTourMenuItem(
        //     isMenuOpen: isMenuOpen,
        //     verticalPadding: verticalPadding,
        //     appService: appService,
        //     duration: duration,
        //   ),

        Divider(
          color: Colors.white,
          thickness: 0.5,
          height: 20,
        ),
      ],
    );
  }
}

// 3D 라이브 투어 메뉴 아이템
class LiveTourMenuItem extends StatelessWidget {
  final bool isMenuOpen;
  final double verticalPadding;
  final AppService appService;
  final Duration duration;

  const LiveTourMenuItem({
    super.key,
    required this.isMenuOpen,
    required this.verticalPadding,
    required this.appService,
    required this.duration,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      // onTap: () => appService.onTapViewer(context, appService.liveTourUrl),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: verticalPadding.h),
        child: AnimatedCrossFade(
          duration: duration,
          firstChild: Row(
            children: [
              Text(
                "3D",
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: (kIconSize - 10).h,
                  color: Colors.white,
                ),
              ),
              Gaps.w17,
              Expanded(
                child: Text(
                  "라이브 투어",
                  style: TextStyle(
                      fontFamily: "Pretendard",
                      fontSize: kFontSize.h,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                  overflow: TextOverflow.ellipsis,
                ),
              )
            ],
          ),
          secondChild: Center(
              child: Text(
            "3D",
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: (kIconSize - 10).h,
              color: Colors.white,
            ),
          )),
          crossFadeState:
              isMenuOpen ? CrossFadeState.showFirst : CrossFadeState.showSecond,
        ),
      ),
    );
  }
}

// 파일 업로드 메뉴 아이템
class FileUploadMenuItem extends StatelessWidget {
  final bool isMenuOpen;
  final double verticalPadding;
  final AppService appService;
  final Duration duration;

  const FileUploadMenuItem({
    super.key,
    required this.isMenuOpen,
    required this.verticalPadding,
    required this.appService,
    required this.duration,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // appService.onTapSendDataToServer();
      },
      child: Padding(
          padding: EdgeInsets.symmetric(vertical: verticalPadding.h),
          child: AnimatedCrossFade(
            duration: duration,
            firstChild: Row(
              children: [
                SizedBox(
                  width: kIconSize.h,
                  height: 24,
                  child: Stack(
                    children: [
                      Center(
                          child: FaIcon(
                        FontAwesomeIcons.arrowUpFromBracket,
                        size: (kIconSize - 5).h,
                        color: Colors.white,
                      )),
                    ],
                  ),
                ),
                Gaps.w16,
                Gaps.w1,
                Expanded(
                  child: Text(
                    "파일 업로드",
                    style: TextStyle(
                        fontFamily: "Pretendard",
                        fontSize: kFontSize.h,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                    overflow: TextOverflow.ellipsis,
                  ),
                )
              ],
            ),
            secondChild: Center(
              child: Stack(
                children: [
                  Center(
                      child: FaIcon(
                    FontAwesomeIcons.arrowUpFromBracket,
                    size: (kIconSize - 5).h,
                    color: Colors.white,
                  )),
                ],
              ),
            ),
            crossFadeState: isMenuOpen
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
          )),
    );
  }
}

// 일반 메뉴 아이템 (아이콘 + 텍스트)
class MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isMenuOpen;
  final double verticalPadding;
  final double? bottomPadding;
  final VoidCallback onTap;
  final Duration duration;

  const MenuItem({
    super.key,
    required this.icon,
    required this.label,
    required this.isMenuOpen,
    required this.verticalPadding,
    this.bottomPadding,
    required this.onTap,
    required this.duration,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.only(
            top: verticalPadding.h,
            bottom: bottomPadding?.h ?? verticalPadding.h),
        child: AnimatedCrossFade(
          duration: duration,
          firstChild: Row(
            children: [
              Icon(
                icon,
                size: kIconSize.h,
                color: Colors.white,
              ),
              Gaps.w16,
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                      fontFamily: "Pretendard",
                      fontSize: kFontSize.h,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                  overflow: TextOverflow.ellipsis,
                ),
              )
            ],
          ),
          secondChild: Center(
              child: Icon(
            icon,
            size: kIconSize.h,
            color: Colors.white,
          )),
          crossFadeState:
              isMenuOpen ? CrossFadeState.showFirst : CrossFadeState.showSecond,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:meditation_friend/app/constant/app_color.dart';
import 'package:meditation_friend/app/constant/constants.dart';
import 'package:meditation_friend/app/modules/music_detail/controllers/music_detail_controller.dart';
import 'package:meditation_friend/app/modules/music_detail/views/widgets/other_category_musics.dart';
import 'package:meditation_friend/app/utils/log.dart';
import 'package:meditation_friend/app/widgets/custom_img_button.dart';
import 'package:meditation_friend/app/widgets/under_tab_bar.dart';

class MusicDetailView extends GetView<MusicDetailController> {
  const MusicDetailView({super.key});

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.kAppBackgroundColor,
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
                child: Opacity(
                  opacity: 0.4, // 투명도 조절
                  child: Image.asset(
                    ASSETS_IMAGES_MUSICPLAYING_BG, // 배경 이미지 경로
                    width: MediaQuery.of(context).size.width,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              // 3. 뒤로가기 버튼 - 왼쪽 상단에 위치
              Positioned(
                top: 16.h,
                left: 16.w,
                child: CustomImgButton(
                  imagePath: 'assets/images/back_btn.png', // 실제 이미지 경로
                  onPressed: () {
                    Get.offNamed('/meditation-home');
                    controller.appService.currentIndex.value = 0;
                  },
                  // 선택적 매개변수
                  size: 45.w, // 크기 조정 (원하는 경우)
                  borderRadius: 25.r, // 둥글기 조정 (원하는 경우)
                ),
              ),
              SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Obx(() {
                    final music = controller.currentMusic.value;

                    if (music == null) {
                      return const Text('음악이 없어요!');
                    }

                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: 80,
                        ),
                        if (music.musicUrl != null && (music.duration ?? 0) > 0)
                          Image.asset(
                            MUSICPLAYING,
                            width: 300,
                            height: 300,
                            fit: BoxFit.cover,
                          ),
                        const SizedBox(height: 20),

                        // 음악 제목
                        Text(
                          music.title ?? '본 카테고리의 음악이 없습니다',
                          style: TextStyle(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.normal,
                              color: AppColors.kWhite),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          music.description ?? '다른 카테고리를 시도해보세요',
                          style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w100,
                              color: AppColors.kGray),
                        ),

                        // 슬라이더
                        if (music.musicUrl != null && (music.duration ?? 0) > 0)
                          StreamBuilder<Duration>(
                            stream: controller
                                .appService.audioPlayer.positionStream,
                            builder: (context, snapshot) {
                              final position = snapshot.data ?? Duration.zero;
                              final duration = Duration(
                                  seconds:
                                      controller.currentMusic.value?.duration ??
                                          0);

                              return Column(
                                children: [
                                  // 시간 표시
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          _formatDuration(position),
                                          style: const TextStyle(
                                              color: AppColors.kWhite,
                                              fontSize: 12),
                                        ),
                                        Text(
                                          _formatDuration(duration),
                                          style: const TextStyle(
                                              color: AppColors.kWhite,
                                              fontSize: 12),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 10.h),
                                  // 슬라이더
                                  SizedBox(
                                    width: 300.w,
                                    child: SliderTheme(
                                      data: SliderThemeData(
                                        thumbShape: SliderComponentShape
                                            .noThumb, // 원(thumb) 제거
                                        trackHeight: 4.0, // 트랙 높이 조정
                                        activeTrackColor: AppColors.kWhite,
                                        inactiveTrackColor:
                                            const Color(0xFF2E2F37),
                                        overlayShape: SliderComponentShape
                                            .noOverlay, // 오버레이도 제거
                                      ),
                                      child: Slider(
                                        value: position.inSeconds
                                            .toDouble()
                                            .clamp(0,
                                                duration.inSeconds.toDouble()),
                                        min: 0,
                                        max: duration.inSeconds.toDouble(),
                                        onChanged: (value) {
                                          controller.appService.audioPlayer
                                              .seek(Duration(
                                                  seconds: value.toInt()));
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        const SizedBox(height: 10),
                        // 재생 컨트롤
                        if (music.musicUrl != null && (music.duration ?? 0) > 0)
                          SizedBox(
                            width: MediaQuery.of(context).size.width,
                            height: 60.h, // 적절한 높이 설정
                            child: Stack(
                              children: [
                                // 중앙 재생/일시정지 버튼
                                Center(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Obx(() {
                                        final playing =
                                            controller.isPlaying.value;
                                        final musicTitle = controller
                                                .currentMusic.value?.title ??
                                            '';
                                        logInfo(
                                            'UI 재생 상태: $playing, 현재 음악: $musicTitle');

                                        return playing
                                            ? IconButton(
                                                icon: const Icon(
                                                  Icons.pause,
                                                  size: 36,
                                                  color: AppColors.kGray,
                                                ),
                                                onPressed: () {
                                                  logInfo(
                                                      '일시정지 버튼 클릭 - 현재 상태: $playing');
                                                  controller.pauseMusic();
                                                },
                                              )
                                            : CustomImgButton(
                                                imagePath:
                                                    "assets/images/play_btn.png",
                                                size: 48.w,
                                                onPressed: () async {
                                                  logInfo(
                                                      '재생 버튼 클릭 - 현재 상태: $playing');
                                                  try {
                                                    await controller
                                                        .playMusic();
                                                  } catch (e) {
                                                    logInfo(
                                                        'Error playing music: $e');
                                                  }
                                                },
                                              );
                                      }),
                                    ],
                                  ),
                                ),
                                // 오른쪽 끝 다음곡 버튼
                                // Positioned(
                                //   right: 16.w,
                                //   top: 0,
                                //   bottom: 0,
                                //   child: Center(
                                //     child: CustomImgButton(
                                //       imagePath:
                                //           "assets/images/play_btn.png", // 다음곡 버튼 이미지
                                //       size: 40.w,
                                //       onPressed: () async {
                                //         try {
                                //           await controller.playNextMusic();
                                //         } catch (e) {
                                //           logInfo(
                                //               'Error playing next music: $e');
                                //         }
                                //       },
                                //     ),
                                //   ),
                                // ),
                              ],
                            ),
                          ),

                        OtherCategoryMusics(),
                      ],
                    );
                  }),
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

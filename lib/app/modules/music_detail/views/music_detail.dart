import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:meditation_friend/app/constant/app_color.dart';
import 'package:meditation_friend/app/constant/constants.dart';
import 'package:meditation_friend/app/modules/music_detail/controllers/music_detail_controller.dart';
import 'package:meditation_friend/app/widgets/under_tab_bar.dart';

class MusicDetailView extends GetView<MusicDetailController> {
  const MusicDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    String _formatDuration(Duration duration) {
      String twoDigits(int n) => n.toString().padLeft(2, '0');
      final minutes = twoDigits(duration.inMinutes.remainder(60));
      final seconds = twoDigits(duration.inSeconds.remainder(60));
      return "$minutes:$seconds";
    }

    return Scaffold(
      backgroundColor: AppColors.kSkyBlue,
      appBar: AppBar(
        backgroundColor: AppColors.kSkyBlue,
        title: const Text('명상음악 재생'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
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
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Obx(() {
                    final music = controller.currentMusic.value;
                    final isPlaying = controller.isPlaying;

                    if (music == null) {
                      return const Text('음악이 없어요!');
                    }

                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // 음악 이미지
                        music.imageUrl?.isNotEmpty == true
                            ? CachedNetworkImage(
                                imageUrl: music.imageUrl!,
                                width: 300,
                                height: 300,
                                fit: BoxFit.cover,
                              )
                            : Image.asset(
                                MUSICPLAYING,
                                width: 300,
                                height: 300,
                                fit: BoxFit.cover,
                              ),
                        const SizedBox(height: 20),

                        // 음악 제목
                        Text(
                          music.title ?? '제목 없음',
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),

                        // 슬라이더
                        StreamBuilder<Duration>(
                          stream:
                              controller.appService.audioPlayer.positionStream,
                          builder: (context, snapshot) {
                            final position = snapshot.data ?? Duration.zero;
                            final duration = Duration(
                                seconds:
                                    controller.currentMusic.value?.duration ??
                                        0);

                            return Column(
                              children: [
                                // 슬라이더
                                Slider(
                                  value: position.inSeconds
                                      .toDouble()
                                      .clamp(0, duration.inSeconds.toDouble()),
                                  min: 0,
                                  max: duration.inSeconds.toDouble(),
                                  onChanged: (value) {
                                    controller.appService.audioPlayer
                                        .seek(Duration(seconds: value.toInt()));
                                  },
                                  activeColor: AppColors.kOrange,
                                  inactiveColor: Colors.grey,
                                ),

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
                                            color: Colors.black54),
                                      ),
                                      Text(
                                        _formatDuration(duration),
                                        style: const TextStyle(
                                            color: Colors.black54),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          },
                        ),

                        // 재생 컨트롤
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                                icon: const Icon(Icons.skip_previous, size: 48),
                                onPressed: () async {
                                  try {
                                    await controller.playNextMusic();
                                  } catch (e) {
                                    print('Error playing music: $e');
                                  }
                                }),
                            if (!isPlaying.value!)
                              IconButton(
                                  icon: const Icon(Icons.play_arrow, size: 48),
                                  onPressed: () async {
                                    try {
                                      await controller.playMusic();
                                    } catch (e) {
                                      print('Error playing music: $e');
                                    }
                                  }),
                            if (isPlaying.value)
                              IconButton(
                                icon: const Icon(Icons.pause, size: 48),
                                onPressed: controller.pauseMusic,
                              ),
                            IconButton(
                              icon: const Icon(Icons.stop, size: 48),
                              onPressed: controller.stopMusic,
                            ),
                          ],
                        ),
                      ],
                    );
                  }),
                ),
              ),
              const UnderTabBar(
                initialIndex: 1,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

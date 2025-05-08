import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:safety_check/app/constant/app_color.dart';
import 'package:safety_check/app/constant/constants.dart';
import 'package:safety_check/app/data/models/music.dart';
import 'package:safety_check/app/modules/music_detail/controllers/music_detail_controller.dart';
import 'package:safety_check/app/utils/log.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class MusicDetailView extends GetView<MusicDetailController> {
  const MusicDetailView({super.key});
  @override
  Widget build(BuildContext context) {
    final apiBaseUrl = dotenv.env['DEV_BASE_URL_WT_API'];
    Music randomMusic = controller.appService.musicList[0];
    logInfo(randomMusic.imageUrl);
    print(randomMusic.toJson());
    if (controller.appService.musicList.isEmpty) {
      return Center(child: Text('음악이 없어요!'));
    }
    return Scaffold(
      backgroundColor: AppColors.kSkyBlue,
      appBar: AppBar(
        backgroundColor: AppColors.kSkyBlue,
        title: const Text('명상음악 재생'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (randomMusic.imageUrl != "")
                  CachedNetworkImage(
                    imageUrl: randomMusic.imageUrl!,
                    fit: BoxFit.cover,
                    width: 300,
                    height: 300,
                  )
                else
                  Image.asset(
                    MUSICPLAYING,
                    width: 300,
                    height: 300,
                    fit: BoxFit.cover,
                  ),
                const SizedBox(height: 24),
                Text(randomMusic.title!),
                const SizedBox(height: 8),
                Text(
                  randomMusic.description!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
                // 뮤직플레이어 자리!
                StreamBuilder<PlayerState>(
                  stream: controller.appService.audioPlayer.playerStateStream,
                  builder: (context, snapshot) {
                    final playerState = snapshot.data;
                    final isPlaying = playerState?.playing ?? false;

                    return Column(
                      children: [
                        // 슬라이더 (위치 제어)
                        StreamBuilder<Duration>(
                          stream:
                              controller.appService.audioPlayer.positionStream,
                          builder: (context, snapshot) {
                            final position = snapshot.data ?? Duration.zero;
                            final duration =
                                Duration(seconds: randomMusic.duration ?? 0);

                            return Slider(
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
                            );
                          },
                        ),
                        // 재생/일시정지 버튼
                        IconButton(
                          icon: Icon(
                            isPlaying ? Icons.pause : Icons.play_arrow,
                            size: 48,
                          ),
                          onPressed: () async {
                            if (isPlaying) {
                              await controller.appService.audioPlayer.pause();
                            } else {
                              final url =
                                  '${apiBaseUrl}${randomMusic.musicUrl!}';
                              await controller.appService.audioPlayer
                                  .setUrl(url);
                              await controller.appService.audioPlayer.play();
                            }
                          },
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

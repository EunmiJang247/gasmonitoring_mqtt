import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:meditation_friend/app/modules/meditation_home/controllers/home_controller.dart';
import 'package:meditation_friend/app/modules/meditation_home/view/widgets/meditation_card.dart';

class StartMeditationPlayerBtn extends GetView<HomeController> {
  const StartMeditationPlayerBtn({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: MeditationCard(
              onTap: () async {
                Get.toNamed('/music-detail', arguments: {
                  'category': '바디스캐닝',
                });
              },
              title: "나를 \n바라보는 \n바디스캐닝",
              duration: "15 min",
              color: Color.fromRGBO(108, 99, 255, 0.75),
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: MeditationCard(
              onTap: () async {
                Get.toNamed('/music-detail', arguments: {
                  'category': '호흡',
                });
              },
              title: "마음이 \n편해지는 \n호흡명상",
              duration: "10 min",
              color: Color.fromRGBO(47, 47, 79, 0.75), // 반투명 남색
            ),
          ),
        ],
      ),
    );
  }
}

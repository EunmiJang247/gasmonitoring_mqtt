import 'package:flutter/material.dart';
import 'package:safety_check/app/constant/app_color.dart';
import 'package:get/get.dart';
import 'package:safety_check/app/modules/meditation_home/controllers/home_controller.dart';
import 'package:safety_check/app/modules/meditation_home/view/widgets/quote_slider.dart';
import 'package:safety_check/app/modules/meditation_home/view/widgets/start_meditation_player_btn.dart';
import 'package:safety_check/app/modules/meditation_home/view/widgets/top_image.dart';

class MeditationHome extends GetView<HomeController> {
  const MeditationHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.kSkyBlue,
      body: SafeArea(
        child: Column(
          children: [
            TopImage(),
            SizedBox(height: 10),
            QuoteSlider(),
            SizedBox(height: 10),
            StartMeditationPlayerBtn(),
            SizedBox(height: 10),
            // AttendanceCheck(),
            // SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}

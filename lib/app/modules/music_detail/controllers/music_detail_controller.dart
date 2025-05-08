import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:safety_check/app/data/services/app_service.dart';
import 'package:safety_check/app/utils/log.dart';

class MusicDetailController extends GetxController {
  MusicDetailController({required this.appService});
  final AppService appService;

  late final String currentUrl;

  @override
  void onInit() {
    super.onInit();

    // 예시용 기본 URL (view에서 전달받도록 확장 가능)
    currentUrl =
        '${dotenv.env['DEV_BASE_URL_WT_API']}${appService.musicList.first.musicUrl}';
  }
}

import 'package:dio/dio.dart';
import 'package:safety_check/app/data/models/music.dart';

import '../../utils/log.dart';
import '../api/app_api.dart';
import '../models/base_response.dart';
import 'dart:convert';

// AppRepository 은 API 호출을 전담하는 계층

class AppRepository {
  // AppRepository는 Repository 패턴을 적용한 클래스
  // Service나 Controller와 API 또는 로컬 DB(Hive 등) 사이의 중간 다리 역할
  AppRepository({required AppAPI appAPI}) : _appAPI = appAPI;
  // 생성자에서 AppAPI를 주입받아 _appAPI 필드에 저장.
  final AppAPI _appAPI;

  // Map<String, dynamic> readAndroidBuildData() {
  //   return <String, dynamic>{
  //     'platformVersion': DeviceInformation.platformVersion,
  //     'apiLevel': DeviceInformation.apiLevel,
  //     'cpuName': DeviceInformation.cpuName,
  //     'deviceIMEINumber': DeviceInformation.deviceIMEINumber,
  //     'deviceManufacturer': DeviceInformation.deviceManufacturer,
  //     'deviceModel': DeviceInformation.deviceModel,
  //     'deviceName': DeviceInformation.deviceName,
  //     'hardware': DeviceInformation.hardware,
  //     'productName': DeviceInformation.productName,
  //   };
  // }

  // 시작
  Future<BaseResponse?> init() async {
    BaseResponse? response;
    try {
      var body = <String, dynamic>{};
      response = await _appAPI.client.init(body);
    } catch (err) {
      logError(err, des: 'AppRepository.init()');
    }
    return response;
  }

  Future<BaseResponse?> test() async {
    BaseResponse? response;
    try {
      var body = <String, dynamic>{};
      response = await _appAPI.client.test(body);
    } catch (err) {
      logError(err, des: 'AppRepository.test()');
    }
    return response;
  }

  // 카카오 로그인
  Future<BaseResponse?> signIn({
    required String kakaoToken,
  }) async {
    //String sha1Pw = sha1Encode(password);
    BaseResponse? response;
    try {
      Map<String, dynamic> body = {
        "kakaoToken": kakaoToken,
      };
      response = await _appAPI.client.signIn(body);
    } catch (err) {
      logError(err, des: 'AppRepository.signIn(email:$kakaoToken)');
    }
    return response;
  }

  // 로그아웃
  Future<BaseResponse?> logOut() async {
    BaseResponse? response;
    try {
      response = await _appAPI.client.logOut();
    } catch (err) {
      logError(err, des: 'AppRepository.logOut()');
    }
    return response;
  }

  // 비밀번호 찾기
  Future<String?> findPw({
    required String email,
  }) async {
    String? result;
    try {
      Map<String, dynamic> body = {
        "email": email,
      };
      BaseResponse? response = await _appAPI.client.findPw(body);
      result = response?.result?.message;
    } catch (err) {
      logError(err, des: 'AppRepository.findPw(email:$email)');
    }
    return result;
  }

  // 음악리스트 불러오기
  Future<List<Music>?> searchMusicList() async {
    try {
      final response = await _appAPI.client.getMusicList();
      final data = response?.data;
      final musicListRaw = data['music_list'] as List<dynamic>;
      final musicList = musicListRaw
          .map((e) => Music.fromJson(e as Map<String, dynamic>))
          .toList();
      return musicList;
    } catch (err, stack) {
      logError(err, des: 'searchMusicList Error!');
      logError(stack);
      return null;
    }
  }
}

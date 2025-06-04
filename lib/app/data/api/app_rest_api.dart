import 'package:dio/dio.dart';
import 'package:meditation_friend/app/data/models/base_response.dart';
import 'package:retrofit/retrofit.dart';

part 'app_rest_api.g.dart';

@RestApi()
abstract class AppRestAPI {
  factory AppRestAPI(Dio dio, {String baseUrl}) = _AppRestAPI;

  @POST("/setting/signin-using-kakao")
  Future<BaseResponse?> signInUsingKakao(@Body() Map<String, dynamic> body);

  @POST("/notification/save-alarm")
  Future<BaseResponse?> saveAlarmSettings(@Body() Map<String, dynamic> body);

  @POST("/logout")
  Future<BaseResponse?> logOut();

  @POST("/find_pw")
  Future<BaseResponse?> findPw(@Queries() Map<String, dynamic> queries);

  @GET("/meditation-musics/list")
  Future<BaseResponse?> getMusicList();

  @POST('/notification/send-firebase-token')
  Future<BaseResponse?> sendFirebaseToken(@Body() Map<String, dynamic> body);

  @POST("/notification/send-firebase-alarm")
  Future<BaseResponse?> sendFirebaseAlarm();

  @POST("/setting/attendance-check")
  Future<BaseResponse?> attendanceCheck();

  @GET("/setting/get-attendance-check")
  Future<BaseResponse?> getAttendanceCheck();

  @GET("/notification/get-notification-settings")
  Future<BaseResponse?> getNotificationSettings();
}

import 'package:dio/dio.dart';
import 'package:meditation_friend/app/data/models/base_response.dart';
import 'package:retrofit/retrofit.dart';

part 'app_rest_api.g.dart';

@RestApi()
abstract class AppRestAPI {
  factory AppRestAPI(Dio dio, {String baseUrl}) = _AppRestAPI;

  @GET("/safety/init")
  Future<BaseResponse?> init(@Queries() Map<String, dynamic> queries);

  @GET("/safety/test")
  Future<BaseResponse?> test(@Queries() Map<String, dynamic> queries);

  @POST("/safety/signin")
  Future<BaseResponse?> signIn(@Queries() Map<String, dynamic> queries);

  @POST("/logout")
  Future<BaseResponse?> logOut();

  @POST("/find_pw")
  Future<BaseResponse?> findPw(@Queries() Map<String, dynamic> queries);

  @GET("/meditation-muics/list")
  Future<BaseResponse?> getMusicList();
}

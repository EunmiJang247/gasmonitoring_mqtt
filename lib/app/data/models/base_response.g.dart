// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'base_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BaseResponse _$BaseResponseFromJson(Map<String, dynamic> json) => BaseResponse(
      result: json['result'] == null
          ? null
          : BaseResult.fromJson(json['result'] as Map<String, dynamic>),
      data: json['data'],
      headers: json['headers'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$BaseResponseToJson(BaseResponse instance) =>
    <String, dynamic>{
      'result': instance.result,
      'data': instance.data,
      'headers': instance.headers,
    };

BaseResult _$BaseResultFromJson(Map<String, dynamic> json) => BaseResult(
      code: (json['code'] as num).toInt(),
      message: json['message'] as String,
    );

Map<String, dynamic> _$BaseResultToJson(BaseResult instance) =>
    <String, dynamic>{
      'code': instance.code,
      'message': instance.message,
    };

import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part '00_user.g.dart';

@JsonSerializable()
@HiveType(typeId: 0)
class MeditationFriendUser {
  @HiveField(0)
  String id; // 카카오 회원번호

  @HiveField(1)
  String nickname; // 카카오 닉네임

  @HiveField(2)
  String profileImageUrl; // 프로필 이미지 URL

  @HiveField(3)
  String thumbnailImageUrl; // 썸네일 이미지 URL

  @HiveField(4)
  DateTime? connectedAt; // 연결 일시

  MeditationFriendUser({
    required this.id,
    required this.nickname,
    required this.profileImageUrl,
    required this.thumbnailImageUrl,
    this.connectedAt,
  });

  factory MeditationFriendUser.fromKakaoAccount(Map<String, dynamic> json) {
    return MeditationFriendUser(
      id: json['id'].toString(),
      nickname: json['properties']['nickname'] ?? '',
      profileImageUrl: json['properties']['profile_image'] ?? '',
      thumbnailImageUrl: json['properties']['thumbnail_image'] ?? '',
      connectedAt: json['connected_at'] != null
          ? DateTime.parse(json['connected_at'])
          : null,
    );
  }

  factory MeditationFriendUser.fromJson(Map<String, dynamic> json) =>
      _$MeditationFriendUserFromJson(json);
  Map<String, dynamic> toJson() => _$MeditationFriendUserToJson(this);
}

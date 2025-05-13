// GENERATED CODE - DO NOT MODIFY BY HAND

part of '00_user.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MeditationFriendUserAdapter extends TypeAdapter<MeditationFriendUser> {
  @override
  final int typeId = 0;

  @override
  MeditationFriendUser read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MeditationFriendUser(
      id: fields[0] as String,
      nickname: fields[1] as String,
      profileImageUrl: fields[2] as String,
      thumbnailImageUrl: fields[3] as String,
      connectedAt: fields[4] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, MeditationFriendUser obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.nickname)
      ..writeByte(2)
      ..write(obj.profileImageUrl)
      ..writeByte(3)
      ..write(obj.thumbnailImageUrl)
      ..writeByte(4)
      ..write(obj.connectedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MeditationFriendUserAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MeditationFriendUser _$MeditationFriendUserFromJson(
        Map<String, dynamic> json) =>
    MeditationFriendUser(
      id: json['id'] as String,
      nickname: json['nickname'] as String,
      profileImageUrl: json['profileImageUrl'] as String,
      thumbnailImageUrl: json['thumbnailImageUrl'] as String,
      connectedAt: json['connectedAt'] == null
          ? null
          : DateTime.parse(json['connectedAt'] as String),
    );

Map<String, dynamic> _$MeditationFriendUserToJson(
        MeditationFriendUser instance) =>
    <String, dynamic>{
      'id': instance.id,
      'nickname': instance.nickname,
      'profileImageUrl': instance.profileImageUrl,
      'thumbnailImageUrl': instance.thumbnailImageUrl,
      'connectedAt': instance.connectedAt?.toIso8601String(),
    };

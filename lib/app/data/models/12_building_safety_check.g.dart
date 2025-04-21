// GENERATED CODE - DO NOT MODIFY BY HAND

part of '12_building_safety_check.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BuildingSafetyCheckAdapter extends TypeAdapter<BuildingSafetyCheck> {
  @override
  final int typeId = 12;

  @override
  BuildingSafetyCheck read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BuildingSafetyCheck(
      inspectorName: fields[0] as String?,
      inspectionDate: fields[1] as String?,
      buildingName: fields[2] as String?,
      type: fields[3] as String?,
      inspectionItem: fields[4] as String?,
      data: (fields[5] as List?)?.cast<BuildingCardInfo>(),
    );
  }

  @override
  void write(BinaryWriter writer, BuildingSafetyCheck obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.inspectorName)
      ..writeByte(1)
      ..write(obj.inspectionDate)
      ..writeByte(2)
      ..write(obj.buildingName)
      ..writeByte(3)
      ..write(obj.type)
      ..writeByte(4)
      ..write(obj.inspectionItem)
      ..writeByte(5)
      ..write(obj.data);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BuildingSafetyCheckAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class BuildingCardInfoAdapter extends TypeAdapter<BuildingCardInfo> {
  @override
  final int typeId = 13;

  @override
  BuildingCardInfo read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BuildingCardInfo(
      caption: fields[0] as String?,
      children: (fields[1] as List?)?.cast<BuildingCardChild>(),
    );
  }

  @override
  void write(BinaryWriter writer, BuildingCardInfo obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.caption)
      ..writeByte(1)
      ..write(obj.children);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BuildingCardInfoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class BuildingCardChildAdapter extends TypeAdapter<BuildingCardChild> {
  @override
  final int typeId = 14;

  @override
  BuildingCardChild read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BuildingCardChild(
      kind: fields[0] as String?,
      pictures: (fields[1] as List?)?.cast<BuildingCardPicture>(),
      remark: fields[2] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, BuildingCardChild obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.kind)
      ..writeByte(1)
      ..write(obj.pictures)
      ..writeByte(2)
      ..write(obj.remark);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BuildingCardChildAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class BuildingCardPictureAdapter extends TypeAdapter<BuildingCardPicture> {
  @override
  final int typeId = 15;

  @override
  BuildingCardPicture read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BuildingCardPicture(
      title: fields[0] as String?,
      pid: fields[1] as String?,
      remark: fields[2] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, BuildingCardPicture obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.pid)
      ..writeByte(2)
      ..write(obj.remark);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BuildingCardPictureAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BuildingSafetyCheck _$BuildingSafetyCheckFromJson(Map<String, dynamic> json) =>
    BuildingSafetyCheck(
      inspectorName: json['inspectorName'] as String?,
      inspectionDate: json['inspectionDate'] as String?,
      buildingName: json['buildingName'] as String?,
      type: json['type'] as String?,
      inspectionItem: json['inspectionItem'] as String?,
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => BuildingCardInfo.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$BuildingSafetyCheckToJson(
        BuildingSafetyCheck instance) =>
    <String, dynamic>{
      'inspectorName': instance.inspectorName,
      'inspectionDate': instance.inspectionDate,
      'buildingName': instance.buildingName,
      'type': instance.type,
      'inspectionItem': instance.inspectionItem,
      'data': instance.data,
    };

BuildingCardInfo _$BuildingCardInfoFromJson(Map<String, dynamic> json) =>
    BuildingCardInfo(
      caption: json['caption'] as String?,
      children: (json['children'] as List<dynamic>?)
          ?.map((e) => BuildingCardChild.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$BuildingCardInfoToJson(BuildingCardInfo instance) =>
    <String, dynamic>{
      'caption': instance.caption,
      'children': instance.children,
    };

BuildingCardChild _$BuildingCardChildFromJson(Map<String, dynamic> json) =>
    BuildingCardChild(
      kind: json['kind'] as String?,
      pictures: (json['pictures'] as List<dynamic>?)
          ?.map((e) => BuildingCardPicture.fromJson(e as Map<String, dynamic>))
          .toList(),
      remark: json['remark'] as String?,
    );

Map<String, dynamic> _$BuildingCardChildToJson(BuildingCardChild instance) =>
    <String, dynamic>{
      'kind': instance.kind,
      'pictures': instance.pictures,
      'remark': instance.remark,
    };

BuildingCardPicture _$BuildingCardPictureFromJson(Map<String, dynamic> json) =>
    BuildingCardPicture(
      title: json['title'] as String?,
      pid: json['pid'] as String?,
      remark: json['remark'] as String?,
    );

Map<String, dynamic> _$BuildingCardPictureToJson(
        BuildingCardPicture instance) =>
    <String, dynamic>{
      'title': instance.title,
      'pid': instance.pid,
      'remark': instance.remark,
    };

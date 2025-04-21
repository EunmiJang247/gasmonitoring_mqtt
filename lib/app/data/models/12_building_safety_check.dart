// ignore_for_file: non_constant_identifier_names

import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part '12_building_safety_check.g.dart';

@JsonSerializable()
@HiveType(typeId: 12)
class BuildingSafetyCheck {
  @HiveField(0)
  String? inspectorName;

  @HiveField(1)
  String? inspectionDate;

  @HiveField(2)
  String? buildingName;

  @HiveField(3)
  String? type;

  @HiveField(4)
  String? inspectionItem; // 🔄 리스트에서 문자열로 수정됨

  @HiveField(5)
  List<BuildingCardInfo>? data; // 🔄 필드명 'children' → 'data'로 변경됨

  BuildingSafetyCheck({
    this.inspectorName,
    this.inspectionDate,
    this.buildingName,
    this.type,
    this.inspectionItem,
    this.data,
  });

  factory BuildingSafetyCheck.fromJson(Map<String, dynamic> json) =>
      _$BuildingSafetyCheckFromJson(json);

  Map<String, dynamic> toJson() => _$BuildingSafetyCheckToJson(this);
}

@JsonSerializable()
@HiveType(typeId: 13)
class BuildingCardInfo {
  @HiveField(0)
  String? caption;

  @HiveField(1)
  List<BuildingCardChild>? children;

  BuildingCardInfo({
    this.caption,
    this.children,
  });

  factory BuildingCardInfo.fromJson(Map<String, dynamic> json) =>
      _$BuildingCardInfoFromJson(json);
  Map<String, dynamic> toJson() => _$BuildingCardInfoToJson(this);
}

@JsonSerializable()
@HiveType(typeId: 14)
class BuildingCardChild {
  @HiveField(0)
  String? kind;

  @HiveField(1)
  List<BuildingCardPicture>? pictures;

  @HiveField(2)
  String? remark;

  BuildingCardChild({
    this.kind,
    this.pictures,
    this.remark,
  });

  factory BuildingCardChild.fromJson(Map<String, dynamic> json) =>
      _$BuildingCardChildFromJson(json);
  Map<String, dynamic> toJson() => _$BuildingCardChildToJson(this);
}

@JsonSerializable()
@HiveType(typeId: 15)
class BuildingCardPicture {
  @HiveField(0)
  String? title;

  @HiveField(1)
  String? pid;

  @HiveField(2)
  String? remark;

  BuildingCardPicture({
    this.title,
    this.pid,
    this.remark,
  });

  factory BuildingCardPicture.fromJson(Map<String, dynamic> json) =>
      _$BuildingCardPictureFromJson(json);
  Map<String, dynamic> toJson() => _$BuildingCardPictureToJson(this);
}

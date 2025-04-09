// ignore_for_file: non_constant_identifier_names

import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

import '03_marker.dart';
import '04_fault.dart';

part '09_appended.g.dart';

@JsonSerializable()
@HiveType(typeId: 9)
class Appended {
  @HiveField(0)
  List<Marker>? markerList;
  @HiveField(1)
  List<Fault>? faultList;

  Appended({
    this.markerList,
    this.faultList
  });


  factory Appended.fromJson(Map<String, dynamic> json) => _$AppendedFromJson(json);
  Map<String, dynamic> toJson() => _$AppendedToJson(this);
}
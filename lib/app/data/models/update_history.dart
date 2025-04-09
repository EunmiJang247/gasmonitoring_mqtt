// ignore_for_file: non_constant_identifier_names
import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'update_history.g.dart';

@JsonSerializable()
@HiveType(typeId: 19)
class UpdateHistoryItem {
  @HiveField(0)
  String version;
  @HiveField(1)
  List<String> history;
  @HiveField(2)
  String update_date;
  UpdateHistoryItem({
    required this.version,
    required this.history,
    required this.update_date,
  });

  factory UpdateHistoryItem.fromJson(Map<String, dynamic> json) => _$UpdateHistoryItemFromJson(json);
  Map<String, dynamic> toJson() => _$UpdateHistoryItemToJson(this);
}

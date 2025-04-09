// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_history.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UpdateHistoryItemAdapter extends TypeAdapter<UpdateHistoryItem> {
  @override
  final int typeId = 19;

  @override
  UpdateHistoryItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UpdateHistoryItem(
      version: fields[0] as String,
      history: (fields[1] as List).cast<String>(),
      update_date: fields[2] as String,
    );
  }

  @override
  void write(BinaryWriter writer, UpdateHistoryItem obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.version)
      ..writeByte(1)
      ..write(obj.history)
      ..writeByte(2)
      ..write(obj.update_date);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UpdateHistoryItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpdateHistoryItem _$UpdateHistoryItemFromJson(Map<String, dynamic> json) =>
    UpdateHistoryItem(
      version: json['version'] as String,
      history:
          (json['history'] as List<dynamic>).map((e) => e as String).toList(),
      update_date: json['update_date'] as String,
    );

Map<String, dynamic> _$UpdateHistoryItemToJson(UpdateHistoryItem instance) =>
    <String, dynamic>{
      'version': instance.version,
      'history': instance.history,
      'update_date': instance.update_date,
    };

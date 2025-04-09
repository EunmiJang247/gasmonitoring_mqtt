// GENERATED CODE - DO NOT MODIFY BY HAND

part of '11_drawing_memo.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DrawingMemoAdapter extends TypeAdapter<DrawingMemo> {
  @override
  final int typeId = 11;

  @override
  DrawingMemo read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DrawingMemo(
      seq: fields[0] as String?,
      drawing_seq: fields[1] as String?,
      pid: fields[2] as String?,
      memo: fields[3] as String?,
      x: fields[4] as String?,
      y: fields[5] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, DrawingMemo obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.seq)
      ..writeByte(1)
      ..write(obj.drawing_seq)
      ..writeByte(2)
      ..write(obj.pid)
      ..writeByte(3)
      ..write(obj.memo)
      ..writeByte(4)
      ..write(obj.x)
      ..writeByte(5)
      ..write(obj.y);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DrawingMemoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DrawingMemo _$DrawingMemoFromJson(Map<String, dynamic> json) => DrawingMemo(
      seq: json['seq'] as String?,
      drawing_seq: json['drawing_seq'] as String?,
      pid: json['pid'] as String?,
      memo: json['memo'] as String?,
      x: json['x'] as String?,
      y: json['y'] as String?,
    );

Map<String, dynamic> _$DrawingMemoToJson(DrawingMemo instance) =>
    <String, dynamic>{
      'seq': instance.seq,
      'drawing_seq': instance.drawing_seq,
      'pid': instance.pid,
      'memo': instance.memo,
      'x': instance.x,
      'y': instance.y,
    };

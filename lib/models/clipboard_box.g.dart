// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'clipboard_box.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ClipboardItemAdapter extends TypeAdapter<ClipboardItem> {
  @override
  final int typeId = 0;

  @override
  ClipboardItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ClipboardItem()
      ..content = fields[0] as dynamic
      ..type = fields[1] == null
          ? ClipBoardItemTypes.text
          : fields[1] as ClipBoardItemTypes
      ..timestamp = fields[2] as DateTime;
  }

  @override
  void write(BinaryWriter writer, ClipboardItem obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.content)
      ..writeByte(1)
      ..write(obj.type)
      ..writeByte(2)
      ..write(obj.timestamp);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ClipboardItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ClipBoardItemTypesAdapter extends TypeAdapter<ClipBoardItemTypes> {
  @override
  final int typeId = 1;

  @override
  ClipBoardItemTypes read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ClipBoardItemTypes.text;
      case 1:
        return ClipBoardItemTypes.image;
      case 2:
        return ClipBoardItemTypes.file;
      default:
        return ClipBoardItemTypes.text;
    }
  }

  @override
  void write(BinaryWriter writer, ClipBoardItemTypes obj) {
    switch (obj) {
      case ClipBoardItemTypes.text:
        writer.writeByte(0);
        break;
      case ClipBoardItemTypes.image:
        writer.writeByte(1);
        break;
      case ClipBoardItemTypes.file:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ClipBoardItemTypesAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

import 'package:hive/hive.dart';

part 'clipboard_box.g.dart';

@HiveType(typeId: 0)
class ClipboardItem extends HiveObject {
  @HiveField(0)
  late dynamic content;

  @HiveField(1, defaultValue: ClipBoardItemTypes.text)
  late ClipBoardItemTypes type;

  @HiveField(2)
  late DateTime timestamp;
}

@HiveType(typeId: 1)
enum ClipBoardItemTypes {
  @HiveField(0)
  text,
  @HiveField(1)
  image,
  @HiveField(2)
  file
}

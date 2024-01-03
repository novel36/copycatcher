import 'package:hive/hive.dart';

part 'clipboard_box.g.dart';

@HiveType(typeId: 0)
class ClipboardItem extends HiveObject {
  @HiveField(0)
  String? content;

  @HiveField(1, defaultValue: ClipBoardItemTypes.text)
  ClipBoardItemTypes? type;

  @HiveField(2)
  String? createdAt;

  @HiveField(3)
  String? deviceName;

  @HiveField(4)
  String? userId;

  @HiveField(5)
  String? userEmail;

  @HiveField(6, defaultValue: false)
  bool? isFavorite;

  @HiveField(7, defaultValue: [])
  List<String>? tags;

  @HiveField(8)
  String? id;
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

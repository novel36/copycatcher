import 'package:copycatcher/models/clipboard_box.dart';
import 'package:hive/hive.dart';

// class Boxs {
//   static Box<ClipboardItem> getClipboardItem() =>
//       Hive.box<ClipboardItem>('clipboarditems');
// }

import 'dart:async';

class Boxs {
  static Future<Box<ClipboardItem>> getClipboardItem() async {
    // Open the box asynchronously
    final box = await Hive.openBox<ClipboardItem>('clipboarditems');

    return box;
  }
}

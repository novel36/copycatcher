import 'package:appwrite/models.dart';
import 'package:appwrite_auth_kit/appwrite_auth_kit.dart';
import 'package:copycatcher/constant/app_constants.dart';
import 'package:copycatcher/models/boxs.dart';
import 'package:copycatcher/models/clipboard_box.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';

class ClipboardSyncLogic {
  late Databases databases;
  String? previousClipboardData;
  bool hasContentChanged(String? newContent) {
    return previousClipboardData != newContent;
  }

  DateTime extractTimestamp() {
    return DateTime.now();
  }

  Future<void> addItems(DocumentList documentList) async {
    final box = await Boxs.getClipboardItem();

    for (final itemContent in documentList.documents) {
      final clipboardItem = ClipboardItem()
        ..content = itemContent.data['text']
        ..createdAt = itemContent.$createdAt
        ..deviceName = itemContent.data['device']
        ..userEmail = itemContent.data['useremail']
        ..userId = itemContent.data['user_id']
        ..id = itemContent.$id;

      await box.add(clipboardItem);
    }
  }

  void addTextToDeviceClipboard(String clipBoardText) async {
    await Clipboard.setData(ClipboardData(text: clipBoardText))
        .then((value) => print("Clipboardvalue is Added"));
  }

  Future<String?> getNewClipboardContent() async {
    try {
      ClipboardData? newClipboardData =
          await Clipboard.getData(Clipboard.kTextPlain);

      return newClipboardData?.text;
    } on PlatformException catch (e) {
      if (kDebugMode) {
        print('Error retrieving clipboard data: ${e.message}');
      }
      return null;
    }
  }

  Future addClipboardItem(
      String clipboardcontent,
      String deviceName,
      String userName,
      String userId,
      String createdAt,
      String documentID) async {
    final clipboardItem = ClipboardItem()
      ..content = clipboardcontent.trim()
      ..createdAt = createdAt
      ..type = ClipBoardItemTypes.text
      ..deviceName = deviceName
      ..userEmail = userName
      ..userId = userId
      ..id = documentID;
    final box = await Boxs.getClipboardItem();
    await box.add(clipboardItem);

    return clipboardcontent;
  }

  Future<void> clearClipboardHistory() async {
    ;
    final clipboardItems = await Boxs.getClipboardItem();
    clipboardItems.clear();
  }
}

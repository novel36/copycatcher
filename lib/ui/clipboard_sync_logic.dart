import 'package:appwrite/models.dart';
import 'package:appwrite_auth_kit/appwrite_auth_kit.dart';
import 'package:copycatcher/models/boxs.dart';
import 'package:copycatcher/models/clipboard_box.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';

class ClipboardSyncLogic {
  late AuthNotifier _authNotifier;
  String? previousClipboardData;
  bool hasContentChanged(String? newContent) {
    return previousClipboardData != newContent;
  }

  DateTime extractTimestamp() {
    return DateTime.now();
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

  Future addClipboardItem(String clipboardcontent, DateTime timestamp) async {
    final currentDateTime = DateTime.now();
    final timestamp = DateTime(currentDateTime.year, currentDateTime.month,
        currentDateTime.day, currentDateTime.hour, currentDateTime.minute);

    final clipboardItem = ClipboardItem()
      ..content = clipboardcontent.trim()
      ..timestamp = timestamp
      ..type = ClipBoardItemTypes.text;
    final box = await Boxs.getClipboardItem();
    box.add(clipboardItem);
    for (var element in box.values) {
      if (kDebugMode) {
        print(element.content);
      }
    }
  }

  Future<Document> createDocument(String clipBoardText, Databases database,
      String deviceName, AuthNotifier authNotifier) {
    _authNotifier = authNotifier;
    return database.createDocument(
        databaseId: '6584aef719720dc26580',
        collectionId: '6584b0173849af3a96e5',
        documentId: ID.unique(),
        data: {
          "text": clipBoardText,
          'device': deviceName,
          'user_id': _authNotifier.user!.$id
        },
        permissions: [
          Permission.read(Role.user(_authNotifier.user!.$id)),
          Permission.write(Role.user(_authNotifier.user!.$id)),
          Permission.delete(Role.user(_authNotifier.user!.$id)),
          Permission.update(Role.user(_authNotifier.user!.$id)),
        ]);
  }

  Future<void> clearClipboardHistory() async {
    ;
    final clipboardItems = await Boxs.getClipboardItem();
    clipboardItems.clear();
  }
}

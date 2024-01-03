// ignore_for_file: file_names

import 'package:appwrite/models.dart';
import 'package:appwrite_auth_kit/appwrite_auth_kit.dart';
import 'package:copycatcher/constant/app_constants.dart';
import 'package:copycatcher/helper/getDeviceName.dart';
import 'package:copycatcher/ui/clipboard_sync_logic.dart';
import 'package:flutter/foundation.dart';

class AppwriteClipboardLogic {
  late Databases _databases;
  final AuthNotifier _authNotifier;

  RealtimeSubscription? _subscription;
  RealtimeSubscription? get subscription => _subscription;
  final clipboardLogic = ClipboardSyncLogic();

  AppwriteClipboardLogic(this._authNotifier) {
    _databases = Databases(_authNotifier.client);
  }

  syncNow() async {
    try {
      final response = await _databases.listDocuments(
          databaseId: Appconstants.databaseID,
          collectionId: Appconstants.clipBoardCollectionID,
          queries: []);
      if (kDebugMode) {
        print("Total Value is ${response.total}");
      }
      if (response.documents.isNotEmpty) {
        clipboardLogic
            .addTextToDeviceClipboard(response.documents.last.data['text']);
        await clipboardLogic.clearClipboardHistory();
        await clipboardLogic.addItems(response);
      } else {
        if (kDebugMode) {
          print("The list is empty");
        }
      }
    } catch (e, s) {
      // Handle the exception 'e' and stack trace 's'
      if (kDebugMode) {
        print('Exception: $e');
      }
      if (kDebugMode) {
        print('Stack Trace: $s');
      }
    }
  }

  Future<List<Document>?> fetchData() async {
    try {
      final response = await _databases.listDocuments(
          databaseId: Appconstants.databaseID,
          collectionId: Appconstants.clipBoardCollectionID,
          queries: []);
      if (kDebugMode) {
        print("Total Value is ${response.total}");
      }
      if (response.documents.isNotEmpty) {
        // response.documents.last.data
        clipboardLogic
            .addTextToDeviceClipboard(response.documents.last.data['text']);
        await clipboardLogic.clearClipboardHistory();
        await clipboardLogic.addItems(response);

        return response.documents;
      } else {
        return [];
      }
    } catch (e, s) {
      // Handle the exception 'e' and stack trace 's'
      if (kDebugMode) {
        print('Exception: $e');
      }
      if (kDebugMode) {
        print('Stack Trace: $s');
      }
      return [];
    }
  }

  void subscribe() {
    final realtime = Realtime(_databases.client);

    _subscription = realtime.subscribe([
      'databases.${Appconstants.databaseID}.collections.${Appconstants.clipBoardCollectionID}.documents'
    ]);

    // listen to changes
    _subscription?.stream.listen((data) async {
      fetchData();
    });
  }

  Future<dynamic> deleteDocument(String? documentID) async {
    try {
      await _databases.deleteDocument(
          databaseId: Appconstants.databaseID,
          collectionId: Appconstants.clipBoardCollectionID,
          documentId: documentID!);
    } on AppwriteException catch (e) {
      if (e.type == 'document_not_found') {
        if (kDebugMode) {
          print("Document Not Found");
        }
      }
    }
  }

  Future<Document> createDocument(String clipBoardText) async {
    final String deviceName = await getDeviceName();

    final userID = _authNotifier.user!.$id;
    final userEmail = _authNotifier.user!.email;
    final payload = {
      "text": clipBoardText.trim(),
      'device': deviceName,
      'user_id': userID,
      'useremail': userEmail
    };

    Document document = await _databases.createDocument(
        databaseId: Appconstants.databaseID,
        collectionId: Appconstants.clipBoardCollectionID,
        documentId: ID.unique(),
        data: payload,
        permissions: [
          Permission.read(Role.user(userID)),
          Permission.write(Role.user(userID)),
        ]);
    return document;
  }
}

// ignore_for_file: file_names

import 'package:appwrite/models.dart';
import 'package:appwrite_auth_kit/appwrite_auth_kit.dart';
import 'package:copycatcher/constant/app_constants.dart';
import 'package:flutter/foundation.dart';

class DocumentsProvider extends ChangeNotifier {
  final AuthNotifier _authNotifier;
  late Databases _databases;
  String databaseId = Appconstants.databaseID;
  String collectionId = Appconstants.clipBoardCollectionID;

  List<Document>? _documents;

  DocumentsProvider({
    required AuthNotifier authNotifier,
  }) : _authNotifier = authNotifier {
    _databases = Databases(authNotifier.client);
    _subscribe();
    fetchDocuments();
  }

  List<Document>? get documents => _documents;

  void _subscribe() {
    final realtime = Realtime(_authNotifier.client);

    final subscription = realtime.subscribe(
        ['databases.$databaseId.collections.$collectionId.documents']);

    // Listen to changes
    subscription.stream.listen((data) async {
      // Check if the widget is still mounted before calling fetchData
      fetchDocuments();
    });
  }

  Future<void> fetchDocuments() async {
    try {
      final response = await _databases.listDocuments(
        databaseId: databaseId,
        collectionId: collectionId,
        queries: [],
      );

      _documents = response.documents;
      notifyListeners();
    } catch (e, s) {
      if (kDebugMode) {
        print('Exception: $e');
      }
      if (kDebugMode) {
        print('Stack Trace: $s');
      }
      // Handle error
    }
  }

  Future<void> addDocument(Document document) async {
    try {
      final response = await _databases.createDocument(
        databaseId: databaseId,
        collectionId: collectionId,
        documentId: ID.unique(),
        data: {},
      );

      _documents?.add(response);
      notifyListeners();
    } catch (e, s) {
      if (kDebugMode) {
        print('Exception: $e');
      }
      if (kDebugMode) {
        print('Stack Trace: $s');
      }
      // Handle error
    }
  }

  Future<void> updateDocument(Document document, String documentID) async {
    try {
      await _databases.updateDocument(
          databaseId: databaseId,
          collectionId: collectionId,
          documentId: documentID,
          data: {});

      final index = _documents?.indexWhere((doc) => doc.$id == document.$id);
      if (index != null) {
        _documents?[index] = document;
        notifyListeners();
      }
    } catch (e, s) {
      if (kDebugMode) {
        if (kDebugMode) {}
        print('Exception: $e');
      }
      if (kDebugMode) {
        print('Stack Trace: $s');
      }
      // Handle error
    }
  }

  Future<void> deleteDocument(Document document, String documentID) async {
    try {
      await _databases.deleteDocument(
        databaseId: databaseId,
        collectionId: collectionId,
        documentId: documentID,
      );

      _documents?.removeWhere((doc) => doc.$id == document.$id);
      notifyListeners();
    } catch (e, s) {
      if (kDebugMode) {
        print('Exception: $e');
      }
      if (kDebugMode) {
        print('Stack Trace: $s');
      }
      // Handle error
    }
  }
}

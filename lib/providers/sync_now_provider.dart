// providers/sync_now_provider.dart

import 'package:flutter/foundation.dart';

class SyncNowProvider extends ChangeNotifier {
  String _syncText = "Sync Now";

  String get syncnow => _syncText;

  Future<void> updateText() async {
    // Implement actual sync logic here (e.g., using a cloud storage API)
    _syncText = "Syncing...";
    notifyListeners();

    // Update _syncText based on sync success or failure
    await Future.delayed(const Duration(seconds: 2), () {
      _syncText = "Sync Complete";
      notifyListeners();
    });
  }

  void revert() {
    _syncText = "Sync Now";
    notifyListeners();
  }
}

// providers/autosync_provider.dart

import 'package:flutter/foundation.dart';

class AutoSyncProvider extends ChangeNotifier {
  bool _isAutoSyncOn = false;

  bool get isAutoSyncOn => _isAutoSyncOn;

  void turnOnAutoSync() {
    _isAutoSyncOn = true;
    notifyListeners();
  }

  void turnoffAutoSync() {
    _isAutoSyncOn = false;
    notifyListeners();
  }
}

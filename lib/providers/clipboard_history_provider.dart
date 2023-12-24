// providers/clipboard_history_provider.dart

import 'package:clipboard_watcher/clipboard_watcher.dart';
import 'package:copycatcher/models/clipboard_box.dart';
import 'package:flutter/foundation.dart';

class ClipboardHistoryProvider extends ChangeNotifier {
  final List<ClipboardItem> _history = [];

  List<ClipboardItem> get history => _history;

  ClipboardHistoryProvider() {
    _listenForClipboardChanges();
  }

  void _listenForClipboardChanges() async {
    await clipboardWatcher.start();
  }
}

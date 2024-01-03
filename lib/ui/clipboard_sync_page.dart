// ui/clipboard_sync_page.dart

// ignore_for_file: unused_local_variable

import 'dart:async';

import 'package:appwrite/models.dart';
import 'package:appwrite_auth_kit/appwrite_auth_kit.dart';
import 'package:clipboard_watcher/clipboard_watcher.dart';
import 'package:copycatcher/models/boxs.dart';
import 'package:copycatcher/models/clipboard_box.dart';
import 'package:copycatcher/providers/autosync_provider.dart';
import 'package:copycatcher/providers/clipboard_history_provider.dart';
import 'package:copycatcher/providers/sync_now_provider.dart';
import 'package:copycatcher/ui/AppwriteClipboardLogic.dart';
import 'package:copycatcher/ui/clipboard_sync_logic.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
// ui/clipboard_sync_page.dart

class ClipboardSyncPage extends StatefulWidget {
  final AuthNotifier authNotifier;
  const ClipboardSyncPage({super.key, required this.authNotifier});

  @override
  State<ClipboardSyncPage> createState() => _ClipboardSyncPageState();
}

class _ClipboardSyncPageState extends State<ClipboardSyncPage>
    with ClipboardListener {
  late final AuthNotifier _authNotifier;
  Databases? databases;
  final clipboardLogic = ClipboardSyncLogic();
  List<String>? fetchList = [];
  List<Document>? documents = [];

  late final AppwriteClipboardLogic appwriteLogic;

  @override
  void initState() {
    appwriteLogic = AppwriteClipboardLogic(widget.authNotifier);
    appwriteLogic.subscribe();
    appwriteLogic.fetchData();
    // realtime = Realtime(widget.authNotifier.client);
    clipboardWatcher.addListener(this);
    // start watch
    clipboardWatcher.start();
    super.initState();
  }

  @override
  void dispose() {
    clipboardWatcher.removeListener(this);
    // stop watch
    clipboardWatcher.stop();
    Hive.close();
    appwriteLogic.subscription?.close;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final historyProvider = Provider.of<ClipboardHistoryProvider>(context);
    final autosyncProvider = Provider.of<AutoSyncProvider>(context);
    final syncNowProvider = Provider.of<SyncNowProvider>(context);

    return FutureBuilder<Box<ClipboardItem>>(
        future: Boxs.getClipboardItem(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final clipboardItems = snapshot.data!;
            return Scaffold(
              body: SafeArea(
                  child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      autosyncProvider.isAutoSyncOn
                          ? 'Auto sync is on'
                          : 'Auto sync is off',
                      style: const TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
// Sync controls
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          await appwriteLogic.fetchData();
                        },
                        child: Text(syncNowProvider.syncnow),
                      ),
                      const SizedBox(width: 16.0),
                      Switch(
                        value: autosyncProvider.isAutoSyncOn,
                        onChanged: (value) {
                          if (value) {
                            autosyncProvider.turnOnAutoSync();
                            appwriteLogic.syncNow();
                          } else {
                            autosyncProvider.turnoffAutoSync();
                          }
                        },
                        activeColor: Colors.blue,
                        activeTrackColor: Colors.blueAccent,
                      ),
                      const Text('Auto Sync'),
                    ],
                  ),

                  // Search bar
                  const SizedBox(height: 16.0),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: const TextField(
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Search Clipboard History',
                      ),
                    ),
                  ),

                  const SizedBox(height: 45.0),

                  // Clipboard history list
                  Expanded(
                    flex: 1,
                    child: ValueListenableBuilder<Box<ClipboardItem>>(
                      valueListenable: clipboardItems.listenable(),
                      builder: (context, clipboardItems, child) {
                        print('Clipboard Length is ${clipboardItems.length}');
                        return ListView.separated(
                          itemCount: clipboardItems.length,
                          itemBuilder: (context, index) {
                            final item = clipboardItems.getAt(index)!;
                            return Slidable(
                                endActionPane: ActionPane(
                                    motion: const ScrollMotion(),
                                    children: [
                                      SlidableAction(
                                        onPressed: (context) {
                                          // clipboardItems.deleteAt(index);
                                          item.delete();
                                        },
                                        backgroundColor:
                                            const Color(0xFFFE4A49),
                                        foregroundColor: Colors.white,
                                        icon: Icons.delete,
                                        label: 'Delete',
                                      ),
                                    ]),
                                startActionPane: ActionPane(
                                    motion: const ScrollMotion(),
                                    children: [
                                      SlidableAction(
                                        onPressed: (context) {},
                                        backgroundColor:
                                            const Color(0xFF21B7CA),
                                        foregroundColor: Colors.white,
                                        icon: Icons.share,
                                        label: 'Share',
                                      ),
                                    ]),
                                child: Container(
                                  height: 75,
                                  decoration: const BoxDecoration(),
                                  child: ListTile(
                                    subtitle: Text(item.createdAt!),
                                    leading:
                                        const Icon(Icons.text_snippet_outlined),
                                    trailing: TextButton.icon(
                                        onPressed: () {
                                          clipboardItems.deleteAt(index);
                                          appwriteLogic.deleteDocument(item.id);
                                          print('item ID is ${item.id}');
                                        },
                                        icon: Icon(Icons.delete,
                                            color: Colors.red.shade200),
                                        label: Text(
                                          "Deleted",
                                          style: TextStyle(
                                              color: Colors.red.shade200),
                                        ),
                                        style: const ButtonStyle(
                                            minimumSize:
                                                MaterialStatePropertyAll(
                                                    Size(10, 10)),
                                            tapTargetSize: MaterialTapTargetSize
                                                .shrinkWrap,
                                            padding: MaterialStatePropertyAll(
                                                EdgeInsets.all(8.0)))),
                                    mouseCursor: SystemMouseCursors.click,
                                    title: Text(
                                      item.content.toString(),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    // title: Text(item.content.toString()),
                                  ),
                                ));
                          },
                          separatorBuilder: (BuildContext context, int index) =>
                              const Divider(),
                        );
                      },
                    ),
                  )
                ],
              )),
              floatingActionButton: FloatingActionButton(
                  onPressed: () {
                    clipboardLogic.clearClipboardHistory();
                  },
                  child: Icon(Icons.remove)),
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        });
  }

  @override
  void onClipboardChanged() async {
    final newContent = await clipboardLogic.getNewClipboardContent();
    if (newContent != null && clipboardLogic.hasContentChanged(newContent)) {
      clipboardLogic.previousClipboardData = newContent;
      final timestamp = clipboardLogic.extractTimestamp();

      appwriteLogic.createDocument(newContent).then((value) {
        if (value.data.isNotEmpty) {
          clipboardLogic.addClipboardItem(
              value.data['text'],
              value.data['device'],
              value.data['useremail'],
              value.data['user_id'],
              value.$createdAt,
              value.$id);
        } else {
          print("Error");
        }
      }).onError((error, stackTrace) {
        print("some Error Ocured");
      });
    }
  }

  Future<List<ClipboardItem>> _fetchClipboardItems() async {
    final box = await Hive.openBox(
        'clipboardItems'); // Open the Hive box for clipboard items
    final items =
        box.values.toList(); // Retrieve all clipboard items from the box
    return items.cast<
        ClipboardItem>(); // Cast the items to the ClipboardItem type and return as a list
  }
}

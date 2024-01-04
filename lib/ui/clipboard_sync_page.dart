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
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

class ClipboardSyncPage extends StatefulWidget {
  final AuthNotifier authNotifier;
  const ClipboardSyncPage({super.key, required this.authNotifier});

  @override
  State<ClipboardSyncPage> createState() => _ClipboardSyncPageState();
}

class _ClipboardSyncPageState extends State<ClipboardSyncPage>
    with ClipboardListener {
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
              appBar: AppBar(
                actions: [
                  TextButton.icon(onPressed: () async{
                    await context.authNotifier.deleteSessions();
                    
                  }, icon: Icon(Icons.logout), label: Text("Logout"))
                ],
              ),
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
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: TextField(
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
                        if (kDebugMode) {
                          print('Clipboard Length is ${clipboardItems.length}');
                        }
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
                                          if (kDebugMode) {
                                            print('item ID is ${item.id}');
                                          }
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
                  child: const Icon(Icons.remove)),
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
          if (kDebugMode) {
            print("Error");
          }
        }
      }).onError((error, stackTrace) {
        if (kDebugMode) {
          print("some Error Ocured");
        }
      });
    }
  }
}

// ui/clipboard_sync_page.dart

// ignore_for_file: unused_local_variable

import 'package:appwrite/models.dart';
import 'package:appwrite_auth_kit/appwrite_auth_kit.dart';
import 'package:clipboard_watcher/clipboard_watcher.dart';
import 'package:copycatcher/helper/getDeviceName.dart';
import 'package:copycatcher/models/boxs.dart';
import 'package:copycatcher/models/clipboard_box.dart';
import 'package:copycatcher/providers/autosync_provider.dart';
import 'package:copycatcher/providers/clipboard_history_provider.dart';
import 'package:copycatcher/providers/sync_now_provider.dart';
import 'package:copycatcher/ui/clipboard_sync_logic.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
// ui/clipboard_sync_page.dart

class ClipboardSyncPage extends StatefulWidget {
  const ClipboardSyncPage({super.key});

  @override
  State<ClipboardSyncPage> createState() => _ClipboardSyncPageState();
}

class _ClipboardSyncPageState extends State<ClipboardSyncPage>
    with ClipboardListener {
  late final AuthNotifier _authNotifier;
  final logic = ClipboardSyncLogic();
  @override
  void initState() {
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.authNotifier;
    _authNotifier = user;
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
                title: const Text('Clipboard Sync'),
                actions: [
                  TextButton.icon(
                    onPressed: () async {
                      await user.deleteSessions();
                    },
                    icon: Icon(Icons.logout),
                    label: Text("Logout"),
                    style: ButtonStyle(
                        foregroundColor:
                            MaterialStatePropertyAll(Colors.white)),
                  )
                ],
              ),
              body: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      // Sync status indicator
                      Text(
                        autosyncProvider.isAutoSyncOn
                            ? 'Auto sync is on'
                            : 'Auto sync is off',
                        style: const TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      // Sync controls
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: syncNowProvider.updateText,
                            child: Text(syncNowProvider.syncnow),
                          ),
                          const SizedBox(width: 16.0),
                          Switch(
                            value: autosyncProvider.isAutoSyncOn,
                            onChanged: (value) {
                              if (value) {
                                autosyncProvider.turnOnAutoSync();
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
                      const TextField(
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'Search Clipboard History',
                        ),
                      ),

                      const SizedBox(height: 16.0),

                      // Clipboard history list

                      Expanded(
                        child: ValueListenableBuilder<Box<ClipboardItem>>(
                          valueListenable: clipboardItems.listenable(),
                          builder: (context, clipboardItems, child) {
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
                                              clipboardItems.deleteAt(index);
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
                                        subtitle:
                                            Text(item.timestamp.toString()),
                                        leading: const Icon(
                                            Icons.text_snippet_outlined),
                                        trailing: TextButton.icon(
                                            onPressed: () {
                                              clipboardItems.deleteAt(index);
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
                                                tapTargetSize:
                                                    MaterialTapTargetSize
                                                        .shrinkWrap,
                                                padding:
                                                    MaterialStatePropertyAll(
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
                              separatorBuilder:
                                  (BuildContext context, int index) =>
                                      const Divider(),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              floatingActionButton: FloatingActionButton(
                  backgroundColor: Colors.red.shade400,
                  hoverColor: Colors.red.shade900,
                  onPressed: () async {
                    await clipboardItems.clear();
                    // logic.addClipboardItem("clipboardcontent", DateTime.now());
                  },
                  child: const Icon(Icons.clear_all)),
            );
          } else {
            return const Center(
                child: CircularProgressIndicator()); // Loading indicator
          }
        });
  }

  @override
  void onClipboardChanged() async {
    final deviceName = await getDeviceName();
    if (kDebugMode) {
      print("device name is $deviceName");
    }
    final newContent = await logic.getNewClipboardContent();
    if (newContent != null && logic.hasContentChanged(newContent)) {
      final database = Databases(_authNotifier.client);

      logic.previousClipboardData = newContent;
      final timestamp = logic.extractTimestamp();
      logic.addClipboardItem(newContent, timestamp);
      final _create = await logic.createDocument(
          newContent, database, deviceName, _authNotifier);
      print(_authNotifier.user!.$id);
      // Update UI or handle successful addition within logic class
    } else if (kDebugMode) {
      print("No change in clipboard content.");
    }
  }
}

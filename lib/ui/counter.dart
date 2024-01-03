import 'dart:async';

import 'package:appwrite/appwrite.dart';
import 'package:appwrite_auth_kit/appwrite_auth_kit.dart';
import 'package:copycatcher/constant/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:easy_debounce/easy_debounce.dart';

class MyCounterScreen extends StatefulWidget {
  final Client client;
  final AuthNotifier authNotifier;

  const MyCounterScreen(
      {super.key, required this.client, required this.authNotifier});
  @override
  _MyCounterScreenState createState() => _MyCounterScreenState();
}

class _MyCounterScreenState extends State<MyCounterScreen> {
  late Realtime realtime;
  late Databases databases;

  late StreamSubscription<RealtimeMessage> subscription;
  late int counter = 0;

  @override
  void initState() {
    realtime = Realtime(widget.client);
    databases = Databases(widget.client);
    subscribe();
    getCounter();
    super.initState();
  }

  @override
  void dispose() {
    subscription.cancel();

    realtime.closeCode;

    super.dispose();
  }

  void getCounter() async {
    final documentId = 'count${widget.authNotifier.user?.$id}';

    try {
      final response = await databases.getDocument(
        databaseId: Appconstants.databaseID,
        collectionId: Appconstants.countCollectionID,
        documentId: documentId,
      );

      if (response.data != null && response.data.containsKey('count')) {
        setState(() {
          counter = response.data['count'] as int;
        });
      }
    } catch (e) {
      // Document doesn't exist, create it with an initial count of 0
    }
  }

  void subscribe() {
    EasyDebounce.debounce('subscribe', Duration(milliseconds: 2), () {
      subscription = realtime
          .subscribe([
            'databases.${Appconstants.databaseID}.collections.${Appconstants.countCollectionID}.documents.count${widget.authNotifier.user?.$id}'
          ])
          .stream
          .listen((event) {
            setState(() {
              counter = event.payload['count'] as int;
            });
          });
    });
  }

  void incrementCounter() {
    EasyDebounce.debounce('incrementCounter', Duration(milliseconds: 2), () {
      databases.updateDocument(
          databaseId: Appconstants.databaseID,
          collectionId: Appconstants.countCollectionID,
          documentId: 'count${widget.authNotifier.user?.$id}',
          data: {"count": ++counter});
    });
  }

  void decrementCounter() {
    EasyDebounce.debounce('decrementCounter', Duration(milliseconds: 2), () {
      databases.updateDocument(
          databaseId: Appconstants.databaseID,
          collectionId: Appconstants.countCollectionID,
          documentId: 'count${widget.authNotifier.user?.$id}',
          data: {"count": --counter});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clipboard Sync'),
        actions: [
          TextButton.icon(
            onPressed: () async {
              await widget.authNotifier.deleteSessions();
            },
            icon: Icon(Icons.logout),
            label: Text("Logout"),
            style: ButtonStyle(
                foregroundColor: MaterialStatePropertyAll(Colors.white)),
          )
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Counter Value:',
              style: TextStyle(fontSize: 20),
            ),
            Text(
              '$counter',
              style: TextStyle(fontSize: 50),
            ),
          ],
        ),
      ),
      floatingActionButton: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: incrementCounter,
            child: Icon(Icons.add),
          ),
          SizedBox(height: 10),
          FloatingActionButton(
            onPressed: decrementCounter,
            child: Icon(Icons.remove),
          ),
        ],
      ),
    );
  }
}

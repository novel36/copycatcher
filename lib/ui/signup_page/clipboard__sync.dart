import 'package:copycatcher/providers/DocumentsProvider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

class ClipboardSyncPages extends StatefulWidget {
  const ClipboardSyncPages({super.key});

  @override
  State<ClipboardSyncPages> createState() => _ClipboardSyncPagesState();
}

class _ClipboardSyncPagesState extends State<ClipboardSyncPages> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final documentsProvider =
        Provider.of<DocumentsProvider>(context, listen: false);
    documentsProvider.fetchDocuments();
  }

  @override
  Widget build(BuildContext context) {
    final documentsProvider =
        Provider.of<DocumentsProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text('Clipboard Sync'),
      ),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () async {
              // final clipboardData =
              //     await Clipboard.getData(Clipboard.kTextPlain);
              // if (clipboardData != null && clipboardData.text != null) {
              //   final text = clipboardData.text!;
              //   documentsProvider.addDocument(text);
              // }
            },
            child: Text('Sync Clipboard'),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: documentsProvider.documents?.length ?? 0,
              itemBuilder: (context, index) {
                final document = documentsProvider.documents![index];
                return ListTile(
                  title: Text(document.data['text']),
                  subtitle: Text(document.$createdAt),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

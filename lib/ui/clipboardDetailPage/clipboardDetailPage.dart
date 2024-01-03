// ignore_for_file: file_names

import 'package:flutter/material.dart';

class ClipboardDetailPage extends StatelessWidget {
  final String text;
  final List<String> tags;
  final bool favorites;
  final String device;

  const ClipboardDetailPage({
    super.key,
    required this.text,
    required this.tags,
    required this.favorites,
    required this.device,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clipboard Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Text:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(text),
            // ... display other details in a similar manner ...
            const Text(
              'Tags:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Wrap(
              spacing: 8.0,
              children: [for (final tag in tags) Chip(label: Text(tag))],
            ),
            const Text(
              'Favorite:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(favorites ? 'Yes' : 'No'),
            const Text(
              'Device:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(device),
          ],
        ),
      ),
    );
  }
}

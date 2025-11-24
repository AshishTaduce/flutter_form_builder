import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class JsonPreviewDialog extends StatelessWidget {
  final String jsonString;

  const JsonPreviewDialog({super.key, required this.jsonString});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Generated JSON"),
      content: SizedBox(
        width: 600,
        height: 400,
        child: SingleChildScrollView(
          child: SelectableText(jsonString),
        ),
      ),
      actions: [
        TextButton.icon(
          icon: const Icon(Icons.copy),
          label: const Text("Copy"),
          onPressed: () {
            Clipboard.setData(ClipboardData(text: jsonString));
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Copied to clipboard")),
            );
          },
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Close"),
        ),
      ],
    );
  }
}

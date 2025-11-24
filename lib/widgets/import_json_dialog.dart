import 'package:flutter/material.dart';

class ImportJsonDialog extends StatefulWidget {
  final Function(String jsonString) onImport;

  const ImportJsonDialog({super.key, required this.onImport});

  @override
  State<ImportJsonDialog> createState() => _ImportJsonDialogState();
}

class _ImportJsonDialogState extends State<ImportJsonDialog> {
  final _controller = TextEditingController();
  String? _error;

  void _handleImport() {
    if (_controller.text.isEmpty) {
      setState(() => _error = "Please enter JSON data");
      return;
    }

    widget.onImport(_controller.text);
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 600,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "Import Form JSON",
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            const Text(
              "Paste your form configuration JSON below. This will replace the current form.",
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _controller,
              maxLines: 15,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                hintText: '{\n  "title": "My Form",\n  "fields": [...]\n}',
                errorText: _error,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _handleImport,
                  child: const Text("Import"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class FormSettingsDialog extends StatefulWidget {
  final String title;
  final Map<String, dynamic>? submitAction;
  final bool enableReset;
  final String? exitMessage;
  final Function(String, Map<String, dynamic>?, bool, String?) onSave;

  const FormSettingsDialog({
    super.key,
    required this.title,
    this.submitAction,
    this.enableReset = false,
    this.exitMessage,
    required this.onSave,
  });

  @override
  State<FormSettingsDialog> createState() => _FormSettingsDialogState();
}

class _FormSettingsDialogState extends State<FormSettingsDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _exitMsgController;

  // Submit Action
  bool _enableSubmit = true;
  bool _enableReset = false;
  String _method = 'POST';
  late TextEditingController _urlController;
  late TextEditingController _successMsgController;
  late TextEditingController _errorMsgController;
  late TextEditingController _labelController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.title);
    _exitMsgController = TextEditingController(text: widget.exitMessage);
    _enableReset = widget.enableReset;

    if (widget.submitAction != null) {
      _enableSubmit = true;
      _labelController = TextEditingController(
        text: widget.submitAction!['label'] ?? 'Submit',
      );
      final action = widget.submitAction!['action'];
      if (action != null) {
        _method = action['method'] ?? 'POST';
        _urlController = TextEditingController(text: action['url']);
        _successMsgController = TextEditingController(
          text: action['success_message'],
        );
        _errorMsgController = TextEditingController(
          text: action['error_message'],
        );
      } else {
        _initEmptyAction();
      }
    } else {
      _enableSubmit = false;
      _initEmptyAction();
    }
  }

  void _initEmptyAction() {
    _labelController = TextEditingController(text: 'Submit');
    _urlController = TextEditingController();
    _successMsgController = TextEditingController();
    _errorMsgController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _exitMsgController.dispose();
    _urlController.dispose();
    _successMsgController.dispose();
    _errorMsgController.dispose();
    _labelController.dispose();
    super.dispose();
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      Map<String, dynamic>? submitData;
      if (_enableSubmit) {
        submitData = {
          "label": _labelController.text,
          "action": {
            "type": "api_call",
            "method": _method,
            "url": _urlController.text,
            "success_message": _successMsgController.text,
            "error_message": _errorMsgController.text,
          },
        };
      }
      widget.onSave(
        _titleController.text,
        submitData,
        _enableReset,
        _exitMsgController.text.isNotEmpty ? _exitMsgController.text : null,
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                "Form Settings",
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          labelText: "Form Title",
                        ),
                        validator: (val) => val!.isEmpty ? "Required" : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _exitMsgController,
                        decoration: const InputDecoration(
                          labelText: "Exit Confirmation Message",
                          hintText: "Leave empty for default",
                        ),
                      ),
                      const SizedBox(height: 16),
                      CheckboxListTile(
                        title: const Text("Enable Reset Button"),
                        value: _enableReset,
                        onChanged: (val) => setState(() => _enableReset = val!),
                        contentPadding: EdgeInsets.zero,
                      ),
                      const Divider(),
                      CheckboxListTile(
                        title: const Text("Enable Submit Button"),
                        value: _enableSubmit,
                        onChanged: (val) =>
                            setState(() => _enableSubmit = val!),
                        contentPadding: EdgeInsets.zero,
                      ),
                      if (_enableSubmit) ...[
                        TextFormField(
                          controller: _labelController,
                          decoration: const InputDecoration(
                            labelText: "Button Label",
                          ),
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: _method,
                          decoration: const InputDecoration(
                            labelText: "HTTP Method",
                          ),
                          items: ['GET', 'POST', 'PUT', 'DELETE'].map((e) {
                            return DropdownMenuItem(value: e, child: Text(e));
                          }).toList(),
                          onChanged: (val) => setState(() => _method = val!),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _urlController,
                          decoration: const InputDecoration(
                            labelText: "API URL",
                          ),
                          validator: (val) => val!.isEmpty ? "Required" : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _successMsgController,
                          decoration: const InputDecoration(
                            labelText: "Success Message",
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _errorMsgController,
                          decoration: const InputDecoration(
                            labelText: "Error Message",
                          ),
                        ),
                      ],
                    ],
                  ),
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
                  ElevatedButton(onPressed: _save, child: const Text("Save")),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

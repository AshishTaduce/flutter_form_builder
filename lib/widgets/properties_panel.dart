import 'package:flutter/material.dart';

class PropertiesPanel extends StatefulWidget {
  final Map<String, dynamic>? fieldData;
  final Function(Map<String, dynamic>) onUpdate;
  final VoidCallback onDelete;

  const PropertiesPanel({
    super.key,
    required this.fieldData,
    required this.onUpdate,
    required this.onDelete,
  });

  @override
  State<PropertiesPanel> createState() => _PropertiesPanelState();
}

class _PropertiesPanelState extends State<PropertiesPanel> {
  late TextEditingController _labelController;
  late TextEditingController _nameController;
  late TextEditingController _placeholderController;
  late TextEditingController _hintController;
  late TextEditingController _tooltipController;

  @override
  void initState() {
    super.initState();
    _initControllers();
  }

  @override
  void didUpdateWidget(covariant PropertiesPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.fieldData != oldWidget.fieldData) {
      _initControllers();
    }
  }

  void _initControllers() {
    if (widget.fieldData != null) {
      _labelController = TextEditingController(text: widget.fieldData!['label']);
      _nameController = TextEditingController(text: widget.fieldData!['name']);
      _placeholderController =
          TextEditingController(text: widget.fieldData!['placeholder']);
      _hintController = TextEditingController(text: widget.fieldData!['hint']);
      _tooltipController =
          TextEditingController(text: widget.fieldData!['tooltip']);
    }
  }

  @override
  void dispose() {
    if (widget.fieldData != null) {
      _labelController.dispose();
      _nameController.dispose();
      _placeholderController.dispose();
      _hintController.dispose();
      _tooltipController.dispose();
    }
    super.dispose();
  }

  void _updateField(String key, dynamic value) {
    final newData = Map<String, dynamic>.from(widget.fieldData!);
    if (value == null || (value is String && value.isEmpty)) {
      newData.remove(key);
    } else {
      newData[key] = value;
    }
    widget.onUpdate(newData);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.fieldData == null) {
      return const Center(child: Text("Select a field to edit properties"));
    }

    return Container(
      padding: const EdgeInsets.all(16.0),
      color: Colors.white,
      child: ListView(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Properties",
                style: Theme.of(context).textTheme.titleLarge,
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: widget.onDelete,
              ),
            ],
          ),
          const Divider(),
          TextField(
            controller: _labelController,
            decoration: const InputDecoration(labelText: "Label"),
            onChanged: (val) => _updateField('label', val),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: "Name (Key)"),
            onChanged: (val) => _updateField('name', val),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _placeholderController,
            decoration: const InputDecoration(labelText: "Placeholder"),
            onChanged: (val) => _updateField('placeholder', val),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _hintController,
            decoration: const InputDecoration(labelText: "Hint (Helper Text)"),
            onChanged: (val) => _updateField('hint', val),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _tooltipController,
            decoration: const InputDecoration(labelText: "Tooltip"),
            onChanged: (val) => _updateField('tooltip', val),
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            title: const Text("Required"),
            value: widget.fieldData!['required'] ?? false,
            onChanged: (val) => _updateField('required', val),
          ),
          if (widget.fieldData!['type'] == 'dropdown') ...[
             const SizedBox(height: 16),
             SwitchListTile(
              title: const Text("Searchable"),
              value: widget.fieldData!['isSearchable'] ?? false,
              onChanged: (val) => _updateField('isSearchable', val),
            ),
          ],
          const SizedBox(height: 24),
          const Text("Validation & Logic", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          // Simplified Dependent Logic Editor
          ExpansionTile(
            title: const Text("Enable Logic (enabledIf)"),
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    TextField(
                      decoration: const InputDecoration(labelText: "Depends on Field"),
                      controller: TextEditingController(
                          text: widget.fieldData!['enabledIf']?['field']),
                      onChanged: (val) {
                        final current =
                            Map<String, dynamic>.from(widget.fieldData!['enabledIf'] ?? {});
                        current['field'] = val;
                        // Default operator if missing
                        if (current['operator'] == null) current['operator'] = '==';
                         _updateField('enabledIf', current);
                      },
                    ),
                    TextField(
                      decoration: const InputDecoration(labelText: "Value"),
                      controller: TextEditingController(
                          text: widget.fieldData!['enabledIf']?['value']?.toString()),
                      onChanged: (val) {
                         final current =
                            Map<String, dynamic>.from(widget.fieldData!['enabledIf'] ?? {});
                        current['value'] = val;
                         _updateField('enabledIf', current);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

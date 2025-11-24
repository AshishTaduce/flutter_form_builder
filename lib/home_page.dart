import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_form_generator/flutter_form_generator.dart';
import 'widgets/field_dialog.dart';
import 'widgets/form_settings_dialog.dart';
import 'widgets/json_preview_dialog.dart';
import 'widgets/import_json_dialog.dart';

class FormRow {
  final String id;
  List<Map<String, dynamic>> fields;

  FormRow({required this.id, required this.fields});
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _formTitle = "My Form";
  Map<String, dynamic>? _submitAction;
  bool _enableReset = false;
  String? _exitMessage;

  // Internal state for rows with unique IDs for ReorderableListView
  final List<FormRow> _rows = [];

  @override
  void initState() {
    super.initState();
    // Start with one empty row
    _addRow();
  }

  void _addRow() {
    setState(() {
      _rows.add(
        FormRow(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          fields: [],
        ),
      );
    });
  }

  void _deleteRow(int index) {
    // Check if any field in this row is a dependency for others
    final fieldsInRow = _rows[index].fields;
    final dependentFields = <String>[];

    for (var field in fieldsInRow) {
      final deps = _findDependents(field['name']);
      if (deps.isNotEmpty) {
        dependentFields.addAll(deps);
      }
    }

    if (dependentFields.isNotEmpty) {
      _showDeleteWarning(dependentFields.toSet().toList(), () {
        setState(() {
          _rows.removeAt(index);
        });
      });
    } else {
      setState(() {
        _rows.removeAt(index);
      });
    }
  }

  void _addField(int rowIndex) {
    showDialog(
      context: context,
      builder: (context) => FieldDialog(
        existingFields: _getAllFields(),
        onSave: (fieldData) {
          setState(() {
            _rows[rowIndex].fields.add(fieldData);
          });
        },
      ),
    );
  }

  void _editField(int rowIndex, int fieldIndex) {
    showDialog(
      context: context,
      builder: (context) => FieldDialog(
        fieldData: _rows[rowIndex].fields[fieldIndex],
        existingFields: _getAllFields(),
        onSave: (fieldData) {
          setState(() {
            _rows[rowIndex].fields[fieldIndex] = fieldData;
          });
        },
      ),
    );
  }

  void _deleteField(int rowIndex, int fieldIndex) {
    final fieldName = _rows[rowIndex].fields[fieldIndex]['name'];
    final dependents = _findDependents(fieldName);

    if (dependents.isNotEmpty) {
      _showDeleteWarning(dependents, () {
        setState(() {
          _rows[rowIndex].fields.removeAt(fieldIndex);
        });
      });
    } else {
      setState(() {
        _rows[rowIndex].fields.removeAt(fieldIndex);
      });
    }
  }

  List<String> _findDependents(String fieldName) {
    final dependents = <String>[];
    for (var row in _rows) {
      for (var field in row.fields) {
        if (field['enabledIf'] != null &&
            field['enabledIf']['field'] == fieldName) {
          dependents.add(field['label'] ?? field['name']);
        }
      }
    }
    return dependents;
  }

  void _showDeleteWarning(List<String> dependents, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Warning: Dependent Fields"),
        content: Text(
          "Deleting this field will affect the following fields which depend on it:\n\n"
          "${dependents.join(', ')}\n\n"
          "Are you sure you want to proceed?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
            child: const Text(
              "Delete Anyway",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _moveField(int rowIndex, int fieldIndex, int direction) {
    setState(() {
      final fields = _rows[rowIndex].fields;
      final newIndex = fieldIndex + direction;
      if (newIndex >= 0 && newIndex < fields.length) {
        final item = fields.removeAt(fieldIndex);
        fields.insert(newIndex, item);
      }
    });
  }

  List<Map<String, dynamic>> _getAllFields() {
    final fields = <Map<String, dynamic>>[];
    for (var row in _rows) {
      fields.addAll(row.fields);
    }
    return fields;
  }

  void _openSettings() {
    showDialog(
      context: context,
      builder: (context) => FormSettingsDialog(
        title: _formTitle,
        submitAction: _submitAction,
        enableReset: _enableReset,
        exitMessage: _exitMessage,
        onSave: (title, action, reset, exitMsg) {
          setState(() {
            _formTitle = title;
            _submitAction = action;
            _enableReset = reset;
            _exitMessage = exitMsg;
          });
        },
      ),
    );
  }

  void _showJsonPreview() {
    final List<List<Map<String, dynamic>>> exportRows = _rows
        .map((r) => r.fields)
        .toList();

    // Remove empty rows from export
    exportRows.removeWhere((r) => r.isEmpty);

    final Map<String, dynamic> formJson = {
      "title": _formTitle,
      "fields": exportRows,
      "submit": _submitAction,
    };

    if (_enableReset) formJson["reset"] = true;
    if (_exitMessage != null) formJson["exit_message"] = _exitMessage;

    final jsonString = const JsonEncoder.withIndent('  ').convert(formJson);

    showDialog(
      context: context,
      builder: (context) => JsonPreviewDialog(jsonString: jsonString),
    );
  }

  void _importJson() {
    showDialog(
      context: context,
      builder: (context) => ImportJsonDialog(
        onImport: (jsonString) {
          try {
            final Map<String, dynamic> data = jsonDecode(jsonString);

            if (!data.containsKey('fields') || data['fields'] is! List) {
              throw const FormatException(
                "Invalid JSON: Missing 'fields' list",
              );
            }

            final List<FormRow> newRows = [];
            final fieldsList = data['fields'] as List;

            for (var item in fieldsList) {
              if (item is List) {
                // Multi-column row
                newRows.add(
                  FormRow(
                    id:
                        DateTime.now().millisecondsSinceEpoch.toString() +
                        newRows.length.toString(),
                    fields: List<Map<String, dynamic>>.from(item),
                  ),
                );
              } else if (item is Map) {
                // Single column row
                newRows.add(
                  FormRow(
                    id:
                        DateTime.now().millisecondsSinceEpoch.toString() +
                        newRows.length.toString(),
                    fields: [Map<String, dynamic>.from(item)],
                  ),
                );
              }
            }

            setState(() {
              _formTitle = data['title'] ?? "Imported Form";
              _submitAction = data['submit'];
              _enableReset = data['reset'] ?? false;
              _exitMessage = data['exit_message'];
              _rows.clear();
              _rows.addAll(newRows);
            });

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Form imported successfully")),
            );
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Import failed: ${e.toString()}")),
            );
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_formTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.upload_file),
            onPressed: _importJson,
            tooltip: "Import JSON",
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _openSettings,
            tooltip: "Form Settings",
          ),
        ],
      ),
      body: ReorderableListView(
        padding: const EdgeInsets.only(bottom: 80),
        buildDefaultDragHandles: false,
        onReorder: (oldIndex, newIndex) {
          setState(() {
            if (oldIndex < newIndex) {
              newIndex -= 1;
            }
            final item = _rows.removeAt(oldIndex);
            _rows.insert(newIndex, item);
          });
        },
        children: [
          for (int i = 0; i < _rows.length; i++)
            Card(
              key: ValueKey(_rows[i].id),
              margin: const EdgeInsets.all(8.0),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Row Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            ReorderableDragStartListener(
                              index: i,
                              child: const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Icon(
                                  Icons.drag_handle,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "Row ${i + 1}",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.add, color: Colors.blue),
                              onPressed: () => _addField(i),
                              tooltip: "Add Field to Row",
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteRow(i),
                              tooltip: "Delete Row",
                            ),
                          ],
                        ),
                      ],
                    ),
                    const Divider(),
                    // Row Content (Fields)
                    if (_rows[i].fields.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Center(
                          child: Text("No fields in this row. Click + to add."),
                        ),
                      )
                    else
                      Wrap(
                        spacing: 8.0,
                        runSpacing: 8.0,
                        children: [
                          for (int j = 0; j < _rows[i].fields.length; j++)
                            _buildFieldCard(i, j, _rows[i].fields[j]),
                        ],
                      ),
                  ],
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: "add_row",
            onPressed: _addRow,
            child: const Icon(Icons.add_road), // Add Row icon
            tooltip: "Add New Row",
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            heroTag: "preview",
            onPressed: _showJsonPreview,
            child: const Icon(Icons.code),
            tooltip: "View JSON",
          ),
        ],
      ),
    );
  }

  Widget _buildFieldCard(
    int rowIndex,
    int fieldIndex,
    Map<String, dynamic> fieldData,
  ) {
    return Container(
      width: 300, // Fixed width for preview card
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
      ),
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  fieldData['label'] ?? 'Field',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, size: 16),
                    onPressed: fieldIndex > 0
                        ? () => _moveField(rowIndex, fieldIndex, -1)
                        : null,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    icon: const Icon(Icons.arrow_forward, size: 16),
                    onPressed: fieldIndex < _rows[rowIndex].fields.length - 1
                        ? () => _moveField(rowIndex, fieldIndex, 1)
                        : null,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ],
          ),
          Text(
            "${fieldData['type']} | ${fieldData['name']}",
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          // Preview of the field (disabled)
          AbsorbPointer(
            child: SizedBox(
              height: 60, // Limit height for preview
              child: FormGenerator(
                formData: {
                  "fields": [fieldData],
                  "submit": null,
                },
                onSuccess: (_) {},
              ),
            ),
          ),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                icon: const Icon(Icons.edit, size: 16),
                label: const Text("Edit"),
                onPressed: () => _editField(rowIndex, fieldIndex),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
              ),
              TextButton.icon(
                icon: const Icon(Icons.delete, size: 16, color: Colors.red),
                label: const Text(
                  "Delete",
                  style: TextStyle(color: Colors.red),
                ),
                onPressed: () => _deleteField(rowIndex, fieldIndex),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

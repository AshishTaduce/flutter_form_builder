import 'package:flutter/material.dart';
import 'package:flutter_form_generator/flutter_form_generator.dart';

class FieldDialog extends StatefulWidget {
  final Map<String, dynamic>? fieldData;
  final List<Map<String, dynamic>> existingFields;
  final Function(Map<String, dynamic>) onSave;

  const FieldDialog({
    super.key,
    this.fieldData,
    required this.existingFields,
    required this.onSave,
  });

  @override
  State<FieldDialog> createState() => _FieldDialogState();
}

class _FieldDialogState extends State<FieldDialog> {
  final _formKey = GlobalKey<FormState>();
  late String _selectedType;
  late TextEditingController _labelController;
  late TextEditingController _nameController;
  late TextEditingController _placeholderController;
  late TextEditingController _hintController;
  late TextEditingController _tooltipController;

  // Initial Value
  late TextEditingController _initialValueController;
  bool? _initialValueBool;

  // Validation
  late TextEditingController _minLengthController;
  late TextEditingController _maxLengthController;
  late TextEditingController _minController;
  late TextEditingController _maxController;

  // Multiple Validations
  List<Map<String, String>> _validations = [];

  // Options (for Dropdown/Radio)
  List<Map<String, String>> _options = [];

  // Dependency
  String? _depField;
  String _depOperator = '==';
  late TextEditingController _depValueController;
  String? _depValueDropdown;
  bool _depValueBool = true;

  bool _isRequired = false;
  bool _isSearchable = false;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.fieldData?['type'] ?? 'text_input';
    _labelController = TextEditingController(text: widget.fieldData?['label']);
    _nameController = TextEditingController(text: widget.fieldData?['name']);
    _placeholderController = TextEditingController(
      text: widget.fieldData?['placeholder'],
    );
    _hintController = TextEditingController(text: widget.fieldData?['hint']);
    _tooltipController = TextEditingController(
      text: widget.fieldData?['tooltip'],
    );

    // Initial Value
    if (widget.fieldData?['defaultValue'] is bool) {
      _initialValueBool = widget.fieldData?['defaultValue'];
    } else {
      _initialValueController = TextEditingController(
        text: widget.fieldData?['defaultValue']?.toString(),
      );
    }
    // Default for checkbox if null
    if (_initialValueBool == null && _selectedType == 'checkbox') {
      _initialValueBool = false;
    }
    // Ensure controller is initialized even if bool is used
    if (widget.fieldData?['defaultValue'] is! bool) {
      _initialValueController = TextEditingController(
        text: widget.fieldData?['defaultValue']?.toString(),
      );
    } else {
      _initialValueController = TextEditingController();
    }

    _minLengthController = TextEditingController(
      text: widget.fieldData?['minLength']?.toString(),
    );
    _maxLengthController = TextEditingController(
      text: widget.fieldData?['maxLength']?.toString(),
    );
    _minController = TextEditingController(
      text: widget.fieldData?['min']?.toString(),
    );
    _maxController = TextEditingController(
      text: widget.fieldData?['max']?.toString(),
    );

    // Validations
    if (widget.fieldData?['validations'] != null) {
      _validations = List<Map<String, String>>.from(
        (widget.fieldData!['validations'] as List).map(
          (e) => Map<String, String>.from(e),
        ),
      );
    }

    // Options
    if (widget.fieldData?['options'] != null) {
      _options = (widget.fieldData!['options'] as List)
          .map(
            (e) => {
              "label": e['label'].toString(),
              "value": e['value'].toString(),
            },
          )
          .toList();
    }

    // Dependency
    if (widget.fieldData?['enabledIf'] != null) {
      _depField = widget.fieldData!['enabledIf']['field'];
      _depOperator = widget.fieldData!['enabledIf']['operator'] ?? '==';
      final val = widget.fieldData!['enabledIf']['value'];

      _depValueController = TextEditingController(text: val?.toString());
      if (val is bool) _depValueBool = val;
      if (val is String) _depValueDropdown = val;
      if (val is num) _depValueController.text = val.toString();
    } else {
      _depValueController = TextEditingController();
    }

    _isRequired = widget.fieldData?['required'] ?? false;
    _isSearchable = widget.fieldData?['isSearchable'] ?? false;
  }

  @override
  void dispose() {
    _labelController.dispose();
    _nameController.dispose();
    _placeholderController.dispose();
    _hintController.dispose();
    _tooltipController.dispose();
    _initialValueController.dispose();
    _minLengthController.dispose();
    _maxLengthController.dispose();
    _minController.dispose();
    _maxController.dispose();
    _depValueController.dispose();
    super.dispose();
  }

  void _addValidation() {
    final regexCtrl = TextEditingController();
    final msgCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add Validation"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: regexCtrl,
              decoration: const InputDecoration(labelText: "Regex Pattern"),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: msgCtrl,
              decoration: const InputDecoration(labelText: "Error Message"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              if (regexCtrl.text.isNotEmpty) {
                setState(() {
                  _validations.add({
                    "regex": regexCtrl.text,
                    "error_message": msgCtrl.text.isEmpty
                        ? "Invalid format"
                        : msgCtrl.text,
                  });
                });
                Navigator.pop(context);
              }
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  void _addOption() {
    setState(() {
      _options.add({"label": "", "value": ""});
    });
  }

  void _removeOption(int index) {
    setState(() {
      _options.removeAt(index);
    });
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      final Map<String, dynamic> data = {
        "type": _selectedType,
        "name": _nameController.text,
        "label": _labelController.text,
        "required": _isRequired,
      };

      if (_placeholderController.text.isNotEmpty)
        data["placeholder"] = _placeholderController.text;
      if (_hintController.text.isNotEmpty) data["hint"] = _hintController.text;
      if (_tooltipController.text.isNotEmpty)
        data["tooltip"] = _tooltipController.text;

      // Initial Value
      if (_selectedType == 'checkbox') {
        if (_initialValueBool != null) data["defaultValue"] = _initialValueBool;
      } else if (_selectedType == 'number_input') {
        if (_initialValueController.text.isNotEmpty) {
          data["defaultValue"] = num.tryParse(_initialValueController.text);
        }
      } else {
        if (_initialValueController.text.isNotEmpty) {
          data["defaultValue"] = _initialValueController.text;
        }
      }

      // Type specific
      if ([
        'text_input',
        'email_input',
        'password_input',
        'text_area',
      ].contains(_selectedType)) {
        if (_minLengthController.text.isNotEmpty)
          data["minLength"] = int.tryParse(_minLengthController.text);
        if (_maxLengthController.text.isNotEmpty)
          data["maxLength"] = int.tryParse(_maxLengthController.text);
        if (_validations.isNotEmpty) {
          data["validations"] = _validations;
        }
      }

      if (['number_input'].contains(_selectedType)) {
        if (_minController.text.isNotEmpty)
          data["min"] = num.tryParse(_minController.text);
        if (_maxController.text.isNotEmpty)
          data["max"] = num.tryParse(_maxController.text);
      }

      if (['date'].contains(_selectedType)) {
        if (_minController.text.isNotEmpty)
          data["minDate"] = _minController.text;
        if (_maxController.text.isNotEmpty)
          data["maxDate"] = _maxController.text;
      }

      if (['dropdown', 'radio'].contains(_selectedType)) {
        data["options"] = _options;
        if (_selectedType == 'dropdown') {
          data["isSearchable"] = _isSearchable;
        }
      }

      // Dependency
      if (_depField != null && _depField!.isNotEmpty) {
        dynamic value;

        final depFieldInfo = widget.existingFields.firstWhere(
          (f) => f['name'] == _depField,
          orElse: () => {},
        );

        if (depFieldInfo.isNotEmpty) {
          final type = depFieldInfo['type'];
          if (type == 'checkbox') {
            value = _depValueBool;
          } else if (['dropdown', 'radio'].contains(type)) {
            value = _depValueDropdown;
          } else if (type == 'number_input') {
            value = num.tryParse(_depValueController.text);
          } else {
            value = _depValueController.text;
          }
        }

        if (value != null) {
          data["enabledIf"] = {
            "field": _depField,
            "operator": _depOperator,
            "value": value,
          };
        }
      }

      widget.onSave(data);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.fieldData != null;

    return Dialog(
      child: Container(
        width: 700,
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                isEditing ? "Edit Field" : "Add Field",
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Type Selection
                      DropdownButtonFormField<String>(
                        value: _selectedType,
                        decoration: const InputDecoration(
                          labelText: "Field Type",
                        ),
                        items: FieldType.values.map((e) {
                          return DropdownMenuItem(
                            value: e.value,
                            child: Text(e.toString()),
                          );
                        }).toList(),
                        onChanged: isEditing
                            ? null
                            : (val) {
                                setState(() {
                                  _selectedType = val!;
                                  // Reset initial value bool for checkbox
                                  if (_selectedType == 'checkbox') {
                                    _initialValueBool = false;
                                  } else {
                                    _initialValueBool = null;
                                  }
                                });
                              },
                      ),
                      const SizedBox(height: 16),

                      // Common Properties
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _labelController,
                              decoration: const InputDecoration(
                                labelText: "Label",
                              ),
                              validator: (val) =>
                                  val!.isEmpty ? "Required" : null,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _nameController,
                              decoration: const InputDecoration(
                                labelText: "Name (Key)",
                              ),
                              enabled: !isEditing,
                              validator: (val) {
                                if (val!.isEmpty) return "Required";
                                if (!isEditing &&
                                    widget.existingFields.any(
                                      (f) => f['name'] == val,
                                    )) {
                                  return "Must be unique";
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Initial Value
                      if (_selectedType == 'checkbox')
                        DropdownButtonFormField<bool>(
                          value: _initialValueBool,
                          decoration: const InputDecoration(
                            labelText: "Initial Value",
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: true,
                              child: Text("Checked (True)"),
                            ),
                            DropdownMenuItem(
                              value: false,
                              child: Text("Unchecked (False)"),
                            ),
                          ],
                          onChanged: (val) =>
                              setState(() => _initialValueBool = val),
                        )
                      else
                        TextFormField(
                          controller: _initialValueController,
                          decoration: const InputDecoration(
                            labelText: "Initial Value",
                          ),
                          keyboardType: _selectedType == 'number_input'
                              ? TextInputType.number
                              : TextInputType.text,
                        ),
                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _hintController,
                              decoration: const InputDecoration(
                                labelText: "Hint",
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _tooltipController,
                              decoration: const InputDecoration(
                                labelText: "Tooltip",
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      CheckboxListTile(
                        title: const Text("Required"),
                        value: _isRequired,
                        onChanged: (val) => setState(() => _isRequired = val!),
                        contentPadding: EdgeInsets.zero,
                      ),

                      // Type Specific - Text/Number
                      if ([
                        'text_input',
                        'email_input',
                        'password_input',
                        'text_area',
                        'number_input',
                      ].contains(_selectedType)) ...[
                        const Divider(),
                        const Text(
                          "Validation & Constraints",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _placeholderController,
                          decoration: const InputDecoration(
                            labelText: "Placeholder",
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],

                      if ([
                        'text_input',
                        'email_input',
                        'password_input',
                        'text_area',
                      ].contains(_selectedType)) ...[
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _minLengthController,
                                decoration: const InputDecoration(
                                  labelText: "Min Length",
                                ),
                                keyboardType: TextInputType.number,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextFormField(
                                controller: _maxLengthController,
                                decoration: const InputDecoration(
                                  labelText: "Max Length",
                                ),
                                keyboardType: TextInputType.number,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Regex Validations",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextButton.icon(
                              icon: const Icon(Icons.add),
                              label: const Text("Add"),
                              onPressed: _addValidation,
                            ),
                          ],
                        ),
                        if (_validations.isNotEmpty)
                          Wrap(
                            spacing: 8,
                            children: _validations.asMap().entries.map((e) {
                              return Chip(
                                label: Text(e.value['regex']!),
                                onDeleted: () {
                                  setState(() {
                                    _validations.removeAt(e.key);
                                  });
                                },
                              );
                            }).toList(),
                          ),
                      ],

                      if (['number_input'].contains(_selectedType)) ...[
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _minController,
                                decoration: const InputDecoration(
                                  labelText: "Min Value",
                                ),
                                keyboardType: TextInputType.number,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextFormField(
                                controller: _maxController,
                                decoration: const InputDecoration(
                                  labelText: "Max Value",
                                ),
                                keyboardType: TextInputType.number,
                              ),
                            ),
                          ],
                        ),
                      ],

                      if (['date'].contains(_selectedType)) ...[
                        const Divider(),
                        const Text(
                          "Date Constraints",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _minController,
                                decoration: const InputDecoration(
                                  labelText: "Min Date (yyyy-MM-dd)",
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextFormField(
                                controller: _maxController,
                                decoration: const InputDecoration(
                                  labelText: "Max Date (yyyy-MM-dd)",
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],

                      // Type Specific - Options
                      if (['dropdown', 'radio'].contains(_selectedType)) ...[
                        const Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Options",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextButton.icon(
                              icon: const Icon(Icons.add),
                              label: const Text("Add Option"),
                              onPressed: _addOption,
                            ),
                          ],
                        ),
                        if (_selectedType == 'dropdown')
                          CheckboxListTile(
                            title: const Text("Searchable"),
                            value: _isSearchable,
                            onChanged: (val) =>
                                setState(() => _isSearchable = val!),
                            contentPadding: EdgeInsets.zero,
                          ),
                        ..._options.asMap().entries.map((entry) {
                          final index = entry.key;
                          final option = entry.value;
                          return Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  initialValue: option['label'],
                                  decoration: const InputDecoration(
                                    labelText: "Label",
                                  ),
                                  onChanged: (val) =>
                                      _options[index]['label'] = val,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextFormField(
                                  initialValue: option['value'],
                                  decoration: const InputDecoration(
                                    labelText: "Value",
                                  ),
                                  onChanged: (val) =>
                                      _options[index]['value'] = val,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () => _removeOption(index),
                              ),
                            ],
                          );
                        }),
                      ],

                      // Dependencies
                      const Divider(),
                      const Text(
                        "Dependency (enabledIf)",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _depField,
                              decoration: const InputDecoration(
                                labelText: "Depends on Field",
                              ),
                              items: [
                                const DropdownMenuItem(
                                  value: null,
                                  child: Text("None"),
                                ),
                                ...widget.existingFields
                                    .where(
                                      (f) =>
                                          f['name'] != _nameController.text &&
                                          f['type'] != 'file',
                                    ) // Avoid self-dependency and file type
                                    .map(
                                      (f) => DropdownMenuItem(
                                        value: f['name'] as String,
                                        child: Text(
                                          "${f['label']} (${f['name']})",
                                        ),
                                      ),
                                    ),
                              ],
                              onChanged: (val) {
                                setState(() {
                                  _depField = val;
                                  _depValueDropdown = null; // Reset value
                                  _depValueController.clear();
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          SizedBox(
                            width: 80,
                            child: DropdownButtonFormField<String>(
                              value: _depOperator,
                              items: _getValidOperators().map((e) {
                                return DropdownMenuItem(
                                  value: e,
                                  child: Center(child: Text(e)),
                                );
                              }).toList(),
                              onChanged: (val) =>
                                  setState(() => _depOperator = val!),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(child: _buildDependencyValueInput()),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
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

  List<String> _getValidOperators() {
    if (_depField == null) return ['==', '!='];

    final depFieldInfo = widget.existingFields.firstWhere(
      (f) => f['name'] == _depField,
      orElse: () => {},
    );

    if (depFieldInfo.isEmpty) return ['==', '!='];

    final type = depFieldInfo['type'];

    if (['number_input', 'date'].contains(type)) {
      return ['==', '!=', '>', '<', '>=', '<='];
    }

    return ['==', '!='];
  }

  Widget _buildDependencyValueInput() {
    if (_depField == null) return const SizedBox();

    final depFieldInfo = widget.existingFields.firstWhere(
      (f) => f['name'] == _depField,
      orElse: () => {},
    );

    if (depFieldInfo.isEmpty) return const SizedBox();

    final type = depFieldInfo['type'];

    if (type == 'checkbox') {
      return DropdownButtonFormField<bool>(
        value: _depValueBool,
        decoration: const InputDecoration(labelText: "Value"),
        items: const [
          DropdownMenuItem(value: true, child: Text("Checked")),
          DropdownMenuItem(value: false, child: Text("Unchecked")),
        ],
        onChanged: (val) => setState(() => _depValueBool = val!),
      );
    } else if (['dropdown', 'radio'].contains(type)) {
      final options = (depFieldInfo['options'] as List?) ?? [];
      return DropdownButtonFormField<String>(
        value: _depValueDropdown,
        decoration: const InputDecoration(labelText: "Value"),
        items: options.map((o) {
          return DropdownMenuItem(
            value: o['value'].toString(),
            child: Text(o['label'].toString()),
          );
        }).toList(),
        onChanged: (val) => setState(() => _depValueDropdown = val),
      );
    } else if (type == 'number_input') {
      return TextFormField(
        controller: _depValueController,
        decoration: const InputDecoration(labelText: "Value (Number)"),
        keyboardType: TextInputType.number,
      );
    } else {
      return TextFormField(
        controller: _depValueController,
        decoration: const InputDecoration(labelText: "Value"),
      );
    }
  }
}

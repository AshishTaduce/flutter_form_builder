import 'package:flutter/material.dart';
import 'package:flutter_form_generator/flutter_form_generator.dart';

class FormCanvas extends StatelessWidget {
  final String title;
  final List<List<Map<String, dynamic>>> rows;
  final int? selectedRowIndex;
  final int? selectedColIndex;
  final Function(int, int) onSelectField;
  final Function(String) onTitleChanged;

  const FormCanvas({
    super.key,
    required this.title,
    required this.rows,
    required this.selectedRowIndex,
    required this.selectedColIndex,
    required this.onSelectField,
    required this.onTitleChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[100],
      padding: const EdgeInsets.all(32.0),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          padding: const EdgeInsets.all(24.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  initialValue: title,
                  decoration: const InputDecoration(
                    labelText: "Form Title",
                    border: UnderlineInputBorder(),
                  ),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  onChanged: onTitleChanged,
                ),
                const SizedBox(height: 24),
                if (rows.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Text("Add fields from the left sidebar"),
                    ),
                  ),
                ...List.generate(rows.length, (rowIndex) {
                  final row = rows[rowIndex];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: List.generate(row.length, (colIndex) {
                        final fieldData = row[colIndex];
                        final isSelected =
                            rowIndex == selectedRowIndex && colIndex == selectedColIndex;

                        return Expanded(
                          child: GestureDetector(
                            onTap: () => onSelectField(rowIndex, colIndex),
                            child: Container(
                              decoration: BoxDecoration(
                                border: isSelected
                                    ? Border.all(color: Colors.blue, width: 2)
                                    : Border.all(color: Colors.transparent),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              padding: const EdgeInsets.all(8.0),
                              child: AbsorbPointer(
                                // Prevent interaction with the actual form field
                                child: FormGenerator(
                                  formData: {
                                    "fields": [fieldData],
                                    // Dummy submit to satisfy requirement, not shown here
                                    "submit": null 
                                  },
                                  onSuccess: (_) {},
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

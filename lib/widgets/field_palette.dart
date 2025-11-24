import 'package:flutter/material.dart';
import 'package:flutter_form_generator/flutter_form_generator.dart';

class FieldPalette extends StatelessWidget {
  final Function(String) onAddField;

  const FieldPalette({super.key, required this.onAddField});

  @override
  Widget build(BuildContext context) {
    final fieldTypes = FieldType.values;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            "Fields",
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: fieldTypes.length,
            itemBuilder: (context, index) {
              final type = fieldTypes[index];
              return ListTile(
                title: Text(type.toString()),
                leading: const Icon(Icons.add_circle_outline),
                onTap: () => onAddField(type.value),
              );
            },
          ),
        ),
      ],
    );
  }
}

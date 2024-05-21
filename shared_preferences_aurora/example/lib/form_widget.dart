// SPDX-FileCopyrightText: Copyright 2024 Open Mobile Platform LLC <community@omp.ru>
// SPDX-License-Identifier: BSD-3-Clause
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:internal_aurora/list_button.dart';
import 'package:internal_aurora/list_item_data.dart';
import 'package:internal_aurora/theme/colors.dart';

import 'plugin_impl.dart';

/// Form focus input
class FormWidget extends StatefulWidget {
  const FormWidget({super.key, required this.impl});

  final PluginImpl impl;

  @override
  State<FormWidget> createState() => _FormWidgetState();
}

class _FormWidgetState extends State<FormWidget> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _stringEdit = TextEditingController();
  final TextEditingController _intEdit = TextEditingController();
  final TextEditingController _doubleEdit = TextEditingController();

  bool _boolValue = true;
  List<bool> _listValues = [false, false];

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Field ValueKeys.string
          TextFormField(
            controller: _stringEdit,
            decoration: InputDecoration(
              labelText: 'Specify type "${ValueKeys.string.name}"',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'The parameter "${ValueKeys.string.name}" not must be empty.';
              }
              if (value.length > 10) {
                return 'The parameter "${ValueKeys.string.name}" max length 10 symbols.';
              }
              return null;
            },
          ),
          const SizedBox(height: 16.0),

          /// Field ValueKeys.int
          TextFormField(
            controller: _intEdit,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Specify type "${ValueKeys.int.name}"',
            ),
            validator: (value) {
              if (int.tryParse(value ?? '') == null) {
                return 'The parameter type must be "${ValueKeys.int.name}"';
              }
              return null;
            },
          ),
          const SizedBox(height: 16.0),

          /// Field ValueKeys.double
          TextFormField(
            controller: _doubleEdit,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Specify type "${ValueKeys.double.name}"',
            ),
            validator: (value) {
              if (double.tryParse(value?.replaceAll(',', '.') ?? '') == null) {
                return 'The parameter type must be "${ValueKeys.double.name}"';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          /// Field ValueKeys.bool
          ListItemData(
            'Specify type "${ValueKeys.bool.name}"',
            InternalColors.blue,
            builder: (value) {
              return Card(
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: ['True', 'False']
                      .map((e) => RadioListTile(
                            title: Text(e.toString()),
                            value: bool.parse(e.toLowerCase()),
                            groupValue: _boolValue,
                            onChanged: (bool? value) =>
                                setState(() => _boolValue = value ?? false),
                          ))
                      .toList(),
                ),
              );
            },
          ),
          const SizedBox(height: 16),

          /// Field ValueKeys.list
          ListItemData(
            'Specify type "${ValueKeys.list.name}"',
            InternalColors.blue,
            builder: (value) {
              return Card(
                clipBehavior: Clip.antiAlias,
                child: Column(
                    children: _listValues
                        .mapIndexed((index, e) => CheckboxListTile(
                              title: Text('Value ${index + 1}'),
                              value: e,
                              onChanged: (bool? value) => setState(
                                  () => _listValues[index] = value ?? false),
                            ))
                        .toList()),
              );
            },
          ),
          const SizedBox(height: 16),

          /// Button submit
          ListButton(
            'Save data',
            InternalColors.green,
            onPressed: () async => setState(() async {
              if (_formKey.currentState?.validate() == true) {
                // Get values
                final valueInt = int.parse(_intEdit.text);
                final valueBool = _boolValue;
                final valueString = _stringEdit.text;
                final valueDouble =
                    double.parse(_doubleEdit.text.replaceAll(',', '.'));
                final valueList = _listValues
                    .mapIndexed((index, e) => e ? 'val${index + 1}' : null)
                    .whereNotNull()
                    .toList();

                // Save values
                await widget.impl.setValue(ValueKeys.int, valueInt);
                await widget.impl.setValue(ValueKeys.bool, valueBool);
                await widget.impl.setValue(ValueKeys.string, valueString);
                await widget.impl.setValue(ValueKeys.double, valueDouble);
                await widget.impl.setValue(ValueKeys.list, valueList);

                // Clear form
                _stringEdit.clear();
                _intEdit.clear();
                _doubleEdit.clear();
                _boolValue = true;
                _listValues = [false, false];

                // Close keyboard
                FocusScope.of(context).unfocus();
              }
            }),
          ),
        ],
      ),
    );
  }
}

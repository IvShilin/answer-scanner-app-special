// SPDX-FileCopyrightText: Copyright 2024 Open Mobile Platform LLC <community@omp.ru>
// SPDX-License-Identifier: BSD-3-Clause
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:internal_aurora/list_button.dart';
import 'package:internal_aurora/list_item_data.dart';
import 'package:internal_aurora/list_item_form_success.dart';
import 'package:internal_aurora/list_item_info.dart';
import 'package:internal_aurora/list_separated.dart';
import 'package:internal_aurora/theme/colors.dart';
import 'package:internal_aurora/theme/theme.dart';

import 'form_widget.dart';
import 'plugin_impl.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final PluginImpl _impl = PluginImpl();
  ScrollController _scroll = ScrollController();
  bool? _dataIsEmpty = null;
  bool? _showSuccess = null;

  @override
  void initState() {
    super.initState();
    _impl.isEmptyStream().listen((event) {
      // Update data is empty
      setState(() => _dataIsEmpty = event);
      // Check is not init show success
      if (_showSuccess != null) {
        setState(() {
          _showSuccess = true;
          _scroll.animateTo(
            _scroll.position.minScrollExtent,
            curve: Curves.easeOut,
            duration: const Duration(milliseconds: 500),
          );
          Future.delayed(const Duration(seconds: 2),
              () => setState(() => _showSuccess = false));
        });
      } else {
        _showSuccess = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: internalTheme,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Shared preferences'),
        ),
        body: ListSeparated(
          controller: _scroll,
          children: [
            const ListItemInfo("""
            A lightweight data storage tool with the ability to write
            asynchronously to disk.
            """),

            /// Success update data
            if (_showSuccess == true)
              ListItemFormSuccess('Data updated successfully!'),

            /// Button for clear SharedPreferences
            if (_dataIsEmpty == false && _showSuccess != true)
              ListButton(
                'Clear data',
                InternalColors.coal,
                onPressed: () async => await _impl.clear(),
              ),

            /// Show list date SharedPreferences
            ListItemData(
              'Save Data',
              InternalColors.purple,
              description: 'Data saved via form in SharedPreferences.',
              value: _dataIsEmpty,
              builder: (value) {
                if (value == true) {
                  return 'EMPTY';
                }
                return SizedBox(
                  width: double.infinity,
                  child: Card(
                    child: DataTable(
                      horizontalMargin: 16,
                      columnSpacing: 6,
                      columns: ['Name', 'Value']
                          .map((name) => DataColumn(
                                label: Expanded(
                                  child: Text(name,
                                      style: TextStyle(
                                          fontStyle: FontStyle.italic)),
                                ),
                              ))
                          .toList(),
                      rows: [
                        for (final key in ValueKeys.values)
                          DataRow(
                            cells: <DataCell>[
                              DataCell(Text(key.name)),
                              DataCell(
                                Container(
                                  child: FutureBuilder<dynamic>(
                                    future: _impl.getValue(key),
                                    builder: (
                                      BuildContext context,
                                      AsyncSnapshot<dynamic> snapshot,
                                    ) =>
                                        Text(snapshot.data.toString()),
                                  ),
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),

            Divider(),

            const ListItemInfo("""
            Save data of all available types in Shared Preferences using a form.
            """),

            /// For SharedPreferences
            FormWidget(impl: _impl),
          ],
        ),
      ),
    );
  }
}

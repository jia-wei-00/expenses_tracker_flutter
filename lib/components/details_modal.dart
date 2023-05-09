import 'package:expenses_tracker/components/text.dart';
import 'package:expenses_tracker/cubit/auth/auth_cubit.dart';
import 'package:expenses_tracker/cubit/firestore/firestore_cubit.dart';
import 'package:flutter/material.dart';

AlertDialog detailsModal(
    BuildContext context, AuthCubit cubit, Expense expenses) {
  List<Map<String, String>> tableData = [
    {'title': 'Name', 'value': expenses.name},
    {'title': 'Type', 'value': expenses.type},
    {'title': 'Category', 'value': expenses.category},
    {'title': 'Amount', 'value': expenses.amount},
    {'title': 'Date', 'value': expenses.timestamp.toString()},
  ];

  return AlertDialog(
    title: bigFont('Details'),
    content: DataTable(
      dividerThickness: 1.5,
      headingRowHeight: 10,
      horizontalMargin: 0,
      columns: const [
        DataColumn(label: SizedBox()), // Empty column for titles
        DataColumn(label: SizedBox()), // Empty column for values
      ],
      // crossAxisAlignment: CrossAxisAlignment.start,
      rows: tableData.map((entry) {
        final title = entry['title']!;
        final value = entry['value']!;

        return DataRow(
          cells: [
            DataCell(
              Container(
                color: Colors.black,
                padding: const EdgeInsets.all(8.0),
                alignment: Alignment.centerLeft,
                child: Text(
                  title,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
            DataCell(
              Container(
                padding: const EdgeInsets.all(8.0),
                alignment: Alignment.centerLeft,
                child: Text(value),
              ),
            ),
          ],
        );
      }).toList(),
    ),
    actions: <Widget>[
      ElevatedButton(
        onPressed: () => Navigator.pop(context, 'Cancel'),
        child: mediumFont('Cancel'),
      ),
    ],
  );
}

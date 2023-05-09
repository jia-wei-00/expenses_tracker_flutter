import 'package:expenses_tracker/components/text.dart';
import 'package:expenses_tracker/cubit/auth/auth_cubit.dart';
import 'package:expenses_tracker/cubit/firestore/firestore_cubit.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

AlertDialog detailsModal(
    BuildContext context, AuthCubit cubit, Expense expenses) {
  List<Map<String, String>> tableData = [
    {'title': 'Name', 'value': expenses.name},
    {'title': 'Type', 'value': expenses.type},
    {'title': 'Category', 'value': expenses.category},
    {'title': 'Amount', 'value': expenses.amount},
    {
      'title': 'Date',
      'value': DateFormat('EEEE, MMMM d, y h:mm a').format(expenses.timestamp)
    },
  ];

  return AlertDialog(
    title: bigFont('Details'),
    content: DataTable(
      dividerThickness: 1.5,
      headingRowHeight: 10,
      horizontalMargin: 0,
      dataRowHeight: 60,
      columns: const [
        DataColumn(label: SizedBox()), // Empty column for titles
        DataColumn(label: SizedBox()),
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
                width: 100,
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
                child: Expanded(
                  child: Text(value),
                ),
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

AlertDialog modal(Expense expenses) {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _typeController = TextEditingController();
  final _amountController = TextEditingController();
  String _selectedType;

  List<String> _types = [
    'Food',
    'Transport',
    'Healthcare',
    'Entertainment',
    'Household',
    'Others'
  ];

  return AlertDialog(
    title: bigFont("Edit Details"),
    content: Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Name'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a name';
              }
              return null;
            },
          ),
          Expanded(
            child: DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Type'),
              value: expenses.category,
              items: _types.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type),
                );
              }).toList(),
              onChanged: (value) {
                _selectedType = value!;
              },
            ),
          ),
          TextFormField(
            controller: _amountController,
            decoration: const InputDecoration(labelText: 'Amount'),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter an amount';
              }
              try {
                double.parse(value);
              } catch (e) {
                return 'Please enter a valid number';
              }
              return null;
            },
          ),
          ElevatedButton(
            onPressed: () {
              // if (_formKey.currentState!.validate()) {
              //   _formKey.currentState!.save();
              //   // Do something with the form data
              //   print('Name: $_name');
              //   print('Type: $_type');
              //   print('Amount: $_amount');
              // }
            },
            child: Text('Submit'),
          ),
        ],
      ),
    ),
  );
}

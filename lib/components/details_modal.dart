import 'package:expenses_tracker/components/text.dart';
import 'package:expenses_tracker/cubit/auth/auth_cubit.dart';
import 'package:expenses_tracker/cubit/firestore/firestore_cubit.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

AlertDialog modal(User user, List<Expense> expenses, int index,
    FirestoreCubit firestore, FirestoreState state) {
  final _formKey = GlobalKey<FormState>();
  String _name = expenses[index].name;
  String _type = expenses[index].type;
  num _amount = num.parse(expenses[index].amount);
  String _selectedType = expenses[index].category;

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
      child: SizedBox(
        height: 250,
        child: Column(
          children: [
            TextFormField(
              decoration: const InputDecoration(labelText: 'Name'),
              initialValue: expenses[index].name,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a name';
                }
                return null;
              },
              onChanged: (value) {
                // Save the form value
                _name = value;
              },
            ),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Type'),
              value: expenses[index].category,
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
            TextFormField(
              initialValue: _amount.toString(),
              decoration: const InputDecoration(labelText: 'Amount'),
              keyboardType: TextInputType.number,
              onChanged: (value) => _amount = num.parse(value),
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
            const SizedBox(
              height: 30,
            ),
            ElevatedButton(
              onPressed: () {
                // print("hello");

                final tmp = Expense(
                  id: expenses[index].id,
                  amount: _amount.toString(),
                  name: _name,
                  type: _type,
                  category: _selectedType,
                  timestamp: expenses[index].timestamp,
                );

                firestore.updateData(user, tmp, index);
                // if (_formKey.currentState!.validate()) {
                //   _formKey.currentState!.save();
                //   // Do something with the form data
                //   print('Name: $_name');
                //   print('Type: $_type');
                //   print('Amount: $_amount');
                // }
              },
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    ),
  );
}

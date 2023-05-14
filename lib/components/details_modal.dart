import 'package:expenses_tracker/components/text.dart';
import 'package:expenses_tracker/cubit/auth/auth_cubit.dart';
import 'package:expenses_tracker/cubit/firestore/firestore_cubit.dart';
import 'package:expenses_tracker/cubit/todo/todo_cubit.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

List<String> _typesExpense = [
  'Food',
  'Transportation',
  'Healthcare',
  'Entertainment',
  'Household',
  'Living',
  'Others'
];

List<String> _typesIncome = ['Salary', 'Others'];

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
      // dataRowHeight: 100,
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
                child: smallFont(title, color: Colors.white),
              ),
            ),
            DataCell(
              Container(
                padding: const EdgeInsets.all(8.0),
                alignment: Alignment.centerLeft,
                child: smallFont(value, color: Colors.white),
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

AlertDialog editModal(User user, List<Expense> expenses, int index,
    FirestoreCubit firestore, FirestoreState state) {
  final _formKey = GlobalKey<FormState>();
  String _name = expenses[index].name;
  String _type = expenses[index].type;
  num _amount = num.parse(expenses[index].amount);
  String _selectedType = expenses[index].category;

  List<String> tmpList =
      expenses[index].type == "expense" ? _typesExpense : _typesIncome;

  return AlertDialog(
    title: bigFont("Edit Details"),
    content: Form(
      key: _formKey,
      child: IntrinsicHeight(
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
              value: _selectedType,
              items: tmpList.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type),
                );
              }).toList(),
              onChanged: (value) {
                _selectedType = value!;
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please choose a type of $_type';
                }
                return null;
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
            BlocBuilder<FirestoreCubit, FirestoreState>(
              builder: (context, state) {
                if (state is FirestoreUpdateLoading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else {
                  return ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        final tmp = Expense(
                          id: expenses[index].id,
                          amount: _amount.toString(),
                          name: _name,
                          type: _type,
                          category: _selectedType,
                          timestamp: expenses[index].timestamp,
                        );

                        await firestore.updateData(
                          user,
                          tmp,
                          index,
                          context.read<ExpensesBloc>(),
                        );
                        Navigator.pop(context, 'Cancel');
                      }
                    },
                    child: const Text('Submit'),
                  );
                }
              },
            ),
          ],
        ),
      ),
    ),
  );
}

AlertDialog addTransactionModal(
    User user, FirestoreCubit firestore, String type) {
  final _formKey = GlobalKey<FormState>();
  String _name = "";
  num _amount = 0;
  String _selectedType = type == "expense" ? "Food" : "Salary";

  List<String> tmpList = type == "expense" ? _typesExpense : _typesIncome;

  return AlertDialog(
    title: bigFont(type == "expense" ? "Add Expenses" : "Add Income"),
    content: Form(
      key: _formKey,
      child: IntrinsicHeight(
        child: Column(
          children: [
            TextFormField(
              initialValue: _name,
              decoration: const InputDecoration(labelText: 'Name'),
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
              // value: _selectedType,
              items: tmpList.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type),
                );
              }).toList(),
              onChanged: (value) {
                _selectedType = value!;
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please choose a type of $type';
                }
                return null;
              },
            ),
            TextFormField(
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
            BlocBuilder<FirestoreCubit, FirestoreState>(
              builder: (context, state) {
                if (state is FirestoreUpdateLoading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else {
                  return ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        final tmp = ExpenseNoID(
                            amount: _amount.toString(),
                            name: _name,
                            type: type,
                            category: _selectedType,
                            timestamp: DateTime.now());

                        await firestore.addTransaction(
                            user, tmp, context.read<ExpensesBloc>());
                        Navigator.pop(context, 'Cancel');
                      }
                    },
                    child: const Text('Submit'),
                  );
                }
              },
            ),
          ],
        ),
      ),
    ),
  );
}

AlertDialog addTodoModal(User user, TodoCubit todoCubit, TodoBloc bloc) {
  final _formKey = GlobalKey<FormState>();
  String _todo = "";

  return AlertDialog(
    title: bigFont("Add Todo"),
    content: Form(
      key: _formKey,
      child: IntrinsicHeight(
        child: Column(
          children: [
            TextFormField(
              // maxLines: 5,
              initialValue: _todo,
              decoration: const InputDecoration(labelText: 'Todo'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your todo';
                }
                return null;
              },
              onChanged: (value) {
                // Save the form value
                _todo = value;
              },
            ),
            const SizedBox(
              height: 30,
            ),
            BlocBuilder<TodoCubit, TodoState>(
              builder: (context, state) {
                if (state is TodoLoading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else {
                  return ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        final Todo todo =
                            Todo(text: _todo, timestamp: DateTime.now());
                        await todoCubit.addTodo(user, bloc, todo);
                        Navigator.pop(context, 'Cancel');
                      }
                    },
                    child: const Text('Submit'),
                  );
                }
              },
            ),
          ],
        ),
      ),
    ),
  );
}

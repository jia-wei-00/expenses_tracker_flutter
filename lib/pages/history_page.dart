import 'package:expenses_tracker/components/charts/bar_chart.dart';
import 'package:expenses_tracker/components/charts/expenses_pie_chart.dart';
import 'package:expenses_tracker/components/charts/income_pie_chart.dart';
import 'package:expenses_tracker/components/charts/line_chart.dart';
import 'package:expenses_tracker/components/details_modal.dart';
import 'package:expenses_tracker/components/divider.dart';
import 'package:expenses_tracker/components/snackbar.dart';
import 'package:expenses_tracker/components/text.dart';
import 'package:expenses_tracker/cubit/auth/auth_cubit.dart';
import 'package:expenses_tracker/cubit/firestore/firestore_cubit.dart';
import 'package:expenses_tracker/cubit/todo/todo_cubit.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:intl/intl.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

num balance(List<Expense> expenses) {
  if (expenses.isNotEmpty) {
    return expenses
        .map((expense) => expense.type == "expense"
            ? -num.parse(expense.amount)
            : num.parse(expense.amount))
        .reduce((value, element) => value + element);
  }

  return 0;
}

num? income(List<Expense> expenses) {
  if (expenses.isNotEmpty) {
    final income = expenses.where((e) => e.type == "income");
    if (income.isEmpty) return null;
    return income
        .map((e) => num.parse(e.amount))
        .reduce((value, element) => value + element);
  }
  return 0;
}

num? expense(List<Expense> expenses) {
  if (expenses.isNotEmpty) {
    final incomeExpenses = expenses.where((e) => e.type == "expense");
    if (incomeExpenses.isEmpty) return null;
    return incomeExpenses
        .map((e) => num.parse(e.amount))
        .reduce((value, element) => value + element);
  }

  return 0;
}

class _HistoryPageState extends State<HistoryPage> {
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();
  List<Expense> expenses = [];
  String dropdownValue = 'All'; // set the initial value

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  DateTime _selected = DateTime.now();

  @override
  Widget build(BuildContext context) {
    Future<void> _onPressed(
        {required BuildContext context,
        required DateTime date,
        required bool runOnce,
        String? locale,
        required User user}) async {
      final localeObj = locale != null ? Locale(locale) : null;
      final selected = await showMonthPicker(
        context: context,
        initialDate: date,
        headerColor: Colors.black,
        unselectedMonthTextColor: Colors.white,
        selectedMonthBackgroundColor: Colors.white,
        dismissible: true,
        cancelWidget: mediumFont("Cancel"),
        confirmWidget: mediumFont("OK"),
        firstDate: DateTime(2022),
        lastDate: DateTime.now(),
        locale: localeObj,
      );
      if (selected != null) {
        setState(() {
          _selected = selected;
        });

        if (DateFormat('MMMM yyyy').format(selected) !=
            DateFormat('MMMM yyyy').format(date)) {
          context.read<FirestoreCubit>().fetchHistoryData(
              user,
              context.read<ExpensesBloc>(),
              context.read<ExpensesHistoryBloc>(),
              DateFormat('MMMM yyyy').format(selected),
              runOnce,
              context.read<RunOnce>());
        }
      }
    }

    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        final user = state is AuthSuccess ? state.user : null;
        final expensesHistoryBloc = context.watch<ExpensesHistoryBloc>();
        final runOnce = context.watch<RunOnce>().state;

        if (expensesHistoryBloc.state.isEmpty) {
          // if (runOnce) {
          context.read<FirestoreCubit>().fetchHistoryData(
              user!,
              context.read<ExpensesBloc>(),
              context.read<ExpensesHistoryBloc>(),
              DateFormat('MMMM yyyy').format(DateTime.now()),
              runOnce,
              context.read<RunOnce>());
          // }
        }

        return GestureDetector(
          onTap: () {
            // Unfocus the search input when the user taps outside
            _focusNode.unfocus();
          },
          child: Scaffold(
            body: Container(
              padding: const EdgeInsets.all(12),
              child: BlocConsumer<FirestoreCubit, FirestoreState>(
                listener: (context, state) {
                  if (state is FirestoreLoading) {
                    EasyLoading.show(status: 'loading...');
                  }

                  if (state is FirestoreSuccess) {
                    EasyLoading.dismiss();
                    // snackBar(
                    //     state.message, Colors.green, Colors.white, context);
                  }

                  if (state is FirestoreError) {
                    EasyLoading.dismiss();
                    snackBar(state.error, Colors.red, Colors.white, context);
                  }
                },
                builder: (context, state) {
                  expenses = expensesHistoryBloc.state;
                  var filteredCategory = expenses
                      .where((element) =>
                          dropdownValue.toLowerCase() == "all" ||
                          element.category
                              .toLowerCase()
                              .contains(dropdownValue.toLowerCase()))
                      .toList();
                  var filteredExpenses = filteredCategory
                      .where((element) =>
                          element.name
                              .toLowerCase()
                              .contains(_searchController.text.toLowerCase()) ||
                          element.amount
                              .toString()
                              .toLowerCase()
                              .contains(_searchController.text.toLowerCase()))
                      .toList();

                  return SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    bigFont("Balance"),
                                    const SizedBox(width: 5),
                                    mediumFont(expensesHistoryBloc.state.isEmpty
                                        ? "(${DateFormat('MMMM yyyy').format(DateTime.now())})"
                                        : "(${DateFormat('MMMM yyyy').format(expensesHistoryBloc.state[0].timestamp)})")
                                  ],
                                ),
                                mediumFont(
                                    "RM${balance(expenses).toStringAsFixed(2)}"),
                              ],
                            ),
                            IconButton(
                                onPressed: () {
                                  _onPressed(
                                      context: context,
                                      user: user!,
                                      date: expensesHistoryBloc
                                          .state[0].timestamp,
                                      runOnce: runOnce);
                                },
                                icon: const Icon(
                                  Icons.date_range_rounded,
                                  size: 25,
                                ))
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(16.0),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                child: Column(
                                  children: [
                                    bigFont("EXPENSES", color: Colors.black),
                                    mediumFont(
                                        "RM${expense(expenses) == null ? 0 : expense(expenses)!.toStringAsFixed(2)}",
                                        color: Colors.red),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 5),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(16.0),
                                margin: const EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                child: Column(
                                  children: [
                                    bigFont("INCOME", color: Colors.black),
                                    mediumFont(
                                        "RM${income(expenses)?.toStringAsFixed(2) ?? "0"}",
                                        color: Colors.green),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        mediumFont("Chart"),
                        divider(),
                        const SizedBox(height: 5),
                        Chart(expenses: expensesHistoryBloc.state),
                        Padding(
                          padding: const EdgeInsets.only(top: 5, bottom: 5),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              mediumFont("History"),
                              SizedBox(
                                height: 35,
                                width: 200, // Set the desired width here
                                child: Expanded(
                                  child: TextField(
                                    focusNode: _focusNode,
                                    controller: _searchController,
                                    decoration: const InputDecoration(
                                      hintText: 'Search...',
                                      contentPadding:
                                          EdgeInsets.only(bottom: 3),
                                      hintStyle: TextStyle(fontSize: 13),
                                      prefixIcon: Icon(
                                        Icons.search,
                                        size: 20,
                                        color: Colors.white,
                                      ),
                                      prefixIconConstraints: BoxConstraints(
                                        minWidth: 30,
                                        minHeight: 40,
                                      ),
                                    ),
                                    style: const TextStyle(fontSize: 15),
                                    onChanged: (value) {
                                      setState(
                                          () {}); // Trigger re-render when the search input changes
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        divider(),
                        // Dropdown for filter category
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 5),
                                child: smallFont(
                                    "RM${expense(filteredExpenses)?.toStringAsFixed(2) ?? '0'}")),
                            Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 5),
                              child: DropdownButton<String>(
                                value: dropdownValue,
                                items: <String>[
                                  'All',
                                  'Food',
                                  'Transportation',
                                  'Healthcare',
                                  'Entertainment',
                                  'Household',
                                  'Living',
                                  'Salary',
                                  'Others'
                                ].map<DropdownMenuItem<String>>((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: smallFont(value),
                                  );
                                }).toList(),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    dropdownValue = newValue!;
                                  });
                                },
                                dropdownColor: Colors.grey[800],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 350,
                          child: ListView.builder(
                            itemCount: filteredExpenses.length,
                            itemBuilder: (BuildContext context, int index) {
                              var transaction = filteredExpenses[index];
                              var isExpense = transaction.type == "expense";
                              var amountColor =
                                  isExpense ? Colors.red : Colors.green;

                              return Padding(
                                padding:
                                    const EdgeInsets.only(top: 4, bottom: 4),
                                child: InkWell(
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) =>
                                          detailsModal(
                                              context,
                                              context.read<AuthCubit>(),
                                              transaction),
                                    );
                                  },
                                  child: Container(
                                    margin: EdgeInsets.zero,
                                    child: ClipRRect(
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(10)),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          border: Border(
                                            left: BorderSide(
                                                color: amountColor, width: 5),
                                          ),
                                        ),
                                        child: ListTile(
                                          title: mediumFont(transaction.name,
                                              color: Colors.black),
                                          subtitle: mediumFont(
                                              "RM${transaction.amount.toString()}",
                                              color: Colors.black
                                                  .withOpacity(0.6)),
                                          trailing: mediumFont(
                                              transaction.category,
                                              color: Colors.black54),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        divider(),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}

class Chart extends StatefulWidget {
  final List<Expense> expenses;

  const Chart({Key? key, required this.expenses}) : super(key: key);

  @override
  State<Chart> createState() => _ChartState();
}

class _ChartState extends State<Chart> {
  bool expenseChart = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TextButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(
                      expenseChart ? Colors.white : Colors.transparent),
                ),
                onPressed: () {
                  setState(() => expenseChart = true);
                },
                child: mediumFont("Expenses",
                    color: expenseChart ? Colors.black : Colors.white),
              ),
            ),
            Expanded(
              child: TextButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(
                      !expenseChart ? Colors.white : Colors.transparent),
                ),
                onPressed: () {
                  setState(() => expenseChart = false);
                },
                child: mediumFont("Income",
                    color: expenseChart ? Colors.white : Colors.black),
              ),
            ),
          ],
        ),
        expenseChart == true
            ? expense(widget.expenses) == null
                ? SizedBox(
                    height: 298,
                    child: Center(
                      child: mediumFont(
                        "No data available",
                      ),
                    ),
                  )
                : const ExpensesChart()
            : income(widget.expenses) != null
                ? const IncomeChart()
                : SizedBox(
                    height: 298,
                    child: Center(
                      child: mediumFont(
                        "No data available",
                      ),
                    ),
                  ),
      ],
    );
  }
}

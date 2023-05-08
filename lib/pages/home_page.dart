import 'package:expenses_tracker/components/divider.dart';
import 'package:expenses_tracker/components/text.dart';
import 'package:expenses_tracker/cubit/auth/auth_cubit.dart';
import 'package:expenses_tracker/cubit/firestore/firestore_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
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

class _HomePageState extends State<HomePage> {
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        final user = state is AuthSuccess ? state.user : null;
        context.read<FirestoreCubit>().fetchData(user!);
        return GestureDetector(
          onTap: () {
            // Unfocus the search input when the user taps outside
            _focusNode.unfocus();
          },
          child: Scaffold(
            body: Container(
              padding: const EdgeInsets.all(12),
              child: BlocBuilder<FirestoreCubit, FirestoreState>(
                builder: (context, state) {
                  final List<Expense> expenses =
                      state is FirestoreRecordLoaded ? state.expenses : [];
                  if (state is FirestoreRecordLoaded) {
                    final List<Expense> expenses = state.expenses;
                    return Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            bigFont("Balance"),
                            const SizedBox(width: 5),
                            mediumFont(
                                "(${DateFormat('MMMM yyyy').format(DateTime.now())})"),
                          ],
                        ),
                        mediumFont("RM${balance(expenses)}"),
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
                                        "RM${expense(expenses).toString()}",
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
                                        "RM${income(expenses).toString()}",
                                        color: Colors.green),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
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
                                    onSubmitted: (value) {
                                      if (value != "") {
                                        print("object");
                                      }
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        divider(),
                        Expanded(
                          child: ListView.builder(
                            itemCount: expenses.length,
                            itemBuilder: (BuildContext context, int index) {
                              final transaction = expenses[index];
                              final isExpense = transaction.type == "expense";
                              final amountColor =
                                  isExpense ? Colors.red : Colors.green;

                              return Container(
                                decoration: BoxDecoration(
                                  border: Border(
                                    left: BorderSide(
                                        color: amountColor, width: 5),
                                  ),
                                ),
                                child: ListTile(
                                  title: Text(transaction.name),
                                  subtitle:
                                      Text(transaction.timestamp.toString()),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                          icon: const Icon(Icons.edit),
                                          onPressed: () {}),
                                      IconButton(
                                          icon: const Icon(Icons.delete),
                                          onPressed: () {}),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  } else {
                    return const CircularProgressIndicator();
                  }
                },
              ),
            ),
          ),
        );
      },
    );
  }
}

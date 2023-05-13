import 'package:expenses_tracker/components/details_modal.dart';
import 'package:expenses_tracker/components/dialog.dart';
import 'package:expenses_tracker/components/divider.dart';
import 'package:expenses_tracker/components/snackbar.dart';
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
  List<Expense> expenses = [];

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
        final expensesBloc = context.watch<ExpensesBloc>();
        if (expensesBloc.state.isEmpty) {
          context.read<FirestoreCubit>().fetchData(
              user!,
              context.read<ExpensesBloc>(),
              context.read<ExpensesHistoryBloc>());
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
                  if (state is FirestoreSuccess) {
                    snackBar(
                        state.message, Colors.green, Colors.white, context);
                  }
                },
                builder: (context, state) {
                  expenses = expensesBloc.state;
                  if (state is FirestoreLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
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
                                        "RM${expense(expenses) == null ? 0 : expense(expenses).toString()}",
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
                                        "RM${income(expenses) == null ? 0 : income(expenses).toString()}",
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
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        divider(),
                        Expanded(
                          child: ValueListenableBuilder(
                            valueListenable: _searchController,
                            builder: (BuildContext context, _, __) {
                              var filteredExpenses = expenses
                                  .where((element) =>
                                      element.name.toLowerCase().contains(
                                          _searchController.text
                                              .toLowerCase()) ||
                                      element.amount.contains(
                                          _searchController.text.toLowerCase()))
                                  .toList();

                              return ListView.builder(
                                itemCount: filteredExpenses.length,
                                itemBuilder: (BuildContext context, int index) {
                                  var transaction = filteredExpenses[index];
                                  var isExpense = transaction.type == "expense";
                                  var amountColor =
                                      isExpense ? Colors.red : Colors.green;

                                  return Padding(
                                    padding: const EdgeInsets.only(
                                        top: 4, bottom: 4),
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
                                                    color: amountColor,
                                                    width: 5),
                                              ),
                                            ),
                                            child: ListTile(
                                              title: mediumFont(
                                                  transaction.name,
                                                  color: Colors.black),
                                              subtitle: mediumFont(
                                                  "RM${transaction.amount.toString()}",
                                                  color: Colors.black
                                                      .withOpacity(0.6)),
                                              trailing: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  IconButton(
                                                    padding:
                                                        const EdgeInsets.all(0),
                                                    color: Colors.black
                                                        .withOpacity(0.7),
                                                    icon:
                                                        const Icon(Icons.edit),
                                                    onPressed: () {
                                                      showDialog(
                                                        context: context,
                                                        builder: (BuildContext
                                                                context) =>
                                                            editModal(
                                                                user!,
                                                                expenses,
                                                                index,
                                                                context.read<
                                                                    FirestoreCubit>(),
                                                                state),
                                                      );
                                                    },
                                                  ),
                                                  IconButton(
                                                    padding:
                                                        const EdgeInsets.all(0),
                                                    color: Colors.black
                                                        .withOpacity(0.7),
                                                    icon: const Icon(
                                                        Icons.delete_forever),
                                                    onPressed: () {
                                                      showDialog(
                                                        context: context,
                                                        builder: (BuildContext
                                                                context) =>
                                                            alertDeleteDialog(
                                                                context,
                                                                context.read<
                                                                    FirestoreCubit>(),
                                                                user!,
                                                                transaction,
                                                                index),
                                                      );
                                                    },
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                        divider(),
                        Row(
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) =>
                                      addTransactionModal(
                                          user!,
                                          context.read<FirestoreCubit>(),
                                          'expense'),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                              ),
                              child: mediumFont('Add Expense'),
                            ),
                            const SizedBox(
                              width: 8,
                            ),
                            ElevatedButton(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) =>
                                      addTransactionModal(
                                          user!,
                                          context.read<FirestoreCubit>(),
                                          'income'),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                              ),
                              child: const Text('Add Income'),
                            ),
                          ],
                        )
                      ],
                    );
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

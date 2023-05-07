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
  return expenses
      .map((expense) => expense.type == "expense"
          ? -num.parse(expense.amount)
          : num.parse(expense.amount))
      .reduce((value, element) => value + element);
}

num? income(List<Expense> expenses) {
  final income = expenses.where((e) => e.type == "income");
  if (income.isEmpty) return null;
  return income
      .map((e) => num.parse(e.amount))
      .reduce((value, element) => value + element);
}

num? expense(List<Expense> expenses) {
  final incomeExpenses = expenses.where((e) => e.type == "expense");
  if (incomeExpenses.isEmpty) return null;
  return incomeExpenses
      .map((e) => num.parse(e.amount))
      .reduce((value, element) => value + element);
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        final user = state is AuthSuccess ? state.user : null;
        context.read<FirestoreCubit>().fetchData(user!);
        return Scaffold(
          body: Center(
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
                              margin: const EdgeInsets.all(5.0),
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
                                  mediumFont("RM${income(expenses).toString()}",
                                      color: Colors.green),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                } else {
                  return const CircularProgressIndicator();
                }
              },
            ),
          ),
        );
      },
    );
  }
}

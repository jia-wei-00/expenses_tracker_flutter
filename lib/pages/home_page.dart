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

num income(List<Expense> expenses) {
  num income = 0;

  expenses.map((e) {
    if (e.type == "income") {
      income += num.parse(e.amount);
    }
  });

  return income;
}

num expense(List<Expense> expenses) {
  num expense = 0;

  expenses.map((e) {
    if (e.type == "expense") {
      expense += num.parse(e.amount);
    }
  });

  return expense;
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
                    state is FirestoreRecordLoaded
                        ? mediumFont("RM${balance(expenses)}")
                        : const SizedBox.shrink(),
                    Row(
                      children: [
                        Container(
                          child: Column(
                            children: [
                              bigFont("INCOME"),
                            ],
                          ),
                        ),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: () =>
                          context.read<FirestoreCubit>().fetchData(user),
                      child: const Text("Testing Button"),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }
}

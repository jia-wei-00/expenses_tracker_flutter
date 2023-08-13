import 'package:expenses_tracker/components/text.dart';
import 'package:expenses_tracker/cubit/auth/auth_cubit.dart';
import 'package:expenses_tracker/cubit/firestore/firestore_cubit.dart';
import 'package:expenses_tracker/cubit/loan/loan_cubit.dart';
import 'package:expenses_tracker/cubit/todo/todo_cubit.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

AlertDialog alertDialog(BuildContext context, AuthCubit cubit) {
  final runOnce = context.watch<RunOnce>();
  return AlertDialog(
    title: bigFont('Alert'),
    content: mediumFont('Do you want to logout?'),
    actions: <Widget>[
      Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context, 'Cancel'),
            child: mediumFont('Cancel'),
          ),
          const SizedBox(width: 5),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              cubit.logOut(
                context.read<ExpensesBloc>(),
                context.read<ExpensesHistoryBloc>(),
                context.read<TodoBloc>(),
                runOnce,
              );
              Navigator.pop(context, 'Cancel');
            },
            child: mediumFont('Logout'),
          ),
        ],
      )
    ],
  );
}

AlertDialog alertDeleteDialog(BuildContext context, FirestoreCubit cubit,
    User user, Expense transaction) {
  return AlertDialog(
    title: bigFont('Alert'),
    content: mediumFont('Do you want to Delete?'),
    actions: <Widget>[
      BlocBuilder<FirestoreCubit, FirestoreState>(
        builder: (context, state) {
          if (state is FirestoreUpdateLoading) {
            return const CircularProgressIndicator();
          } else {
            return Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, 'Cancel'),
                  child: mediumFont('Cancel'),
                ),
                const SizedBox(width: 5),
                ElevatedButton(
                  onPressed: () {
                    cubit.deleteData(
                        user, transaction, context.read<ExpensesBloc>());
                    Navigator.pop(context, 'Cancel');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  child: mediumFont('Confirm'),
                ),
              ],
            );
          }
        },
      )
    ],
  );
}

AlertDialog alertDeleteDialogLoan(
    BuildContext context, User user, String name) {
  return AlertDialog(
    title: bigFont('Alert'),
    content: mediumFont('Do you want to Delete?'),
    actions: <Widget>[
      BlocBuilder<FirestoreCubit, FirestoreState>(
        builder: (context, state) {
          if (state is FirestoreUpdateLoading) {
            return const CircularProgressIndicator();
          } else {
            return Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, 'Cancel'),
                  child: mediumFont('Cancel'),
                ),
                const SizedBox(width: 5),
                ElevatedButton(
                  onPressed: () {
                    context.read<LoanCubit>().deleteLoan(user, name);
                    Navigator.pop(context, 'Cancel');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  child: mediumFont('Confirm'),
                ),
              ],
            );
          }
        },
      )
    ],
  );
}

AlertDialog alertDeleteTodoDialog(BuildContext context, TodoCubit cubit,
    User user, DateTime timestamp, int index) {
  return AlertDialog(
    title: bigFont('Alert'),
    content: mediumFont('Do you want to delete todo No.${index + 1}?'),
    actions: <Widget>[
      BlocBuilder<FirestoreCubit, FirestoreState>(
        builder: (context, state) {
          if (state is TodoLoading) {
            return const CircularProgressIndicator();
          } else {
            return Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, 'Cancel'),
                  child: mediumFont('Cancel'),
                ),
                const SizedBox(width: 5),
                ElevatedButton(
                  onPressed: () async {
                    await cubit.deleteTodo(
                        user, context.read<TodoBloc>(), timestamp);
                    Navigator.pop(context, 'Cancel');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  child: mediumFont('Confirm'),
                ),
              ],
            );
          }
        },
      )
    ],
  );
}

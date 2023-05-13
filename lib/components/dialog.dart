import 'package:expenses_tracker/components/text.dart';
import 'package:expenses_tracker/cubit/auth/auth_cubit.dart';
import 'package:expenses_tracker/cubit/firestore/firestore_cubit.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

AlertDialog alertDialog(BuildContext context, AuthCubit cubit) {
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
    User user, Expense transaction, int index) {
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
                        user, transaction, index, context.read<ExpensesBloc>());
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

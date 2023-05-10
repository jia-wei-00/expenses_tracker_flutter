import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:intl/intl.dart';

part 'firestore_state.dart';

class ExpensesBloc extends Cubit<List<Expense>> {
  ExpensesBloc() : super([]);

  void setExpenses(List<Expense> expenses) {
    emit(expenses);
  }
}

class FirestoreCubit extends Cubit<FirestoreState> {
  FirestoreCubit() : super(FirestoreInitial());

  List<Expense> data_list = [];

  final db = FirebaseFirestore.instance;

  String getMonth() {
    DateTime now = DateTime.now();
    return DateFormat('MMMM yyyy').format(now);
  }

  Future<void> fetchData(User user, ExpensesBloc bloc) async {
    emit(FirestoreLoading());

    try {
      final querySnapshot = await db
          .collection("expense__tracker")
          .doc(user.email)
          .collection(getMonth())
          .orderBy("timestamp", descending: true)
          .get();

      final List<Expense> payload = querySnapshot.docs.map((doc) {
        final data = doc.data();
        return Expense(
          id: doc.id,
          amount: data['amount'].toString(),
          name: data['name'],
          type: data['type'],
          category: data['category'],
          timestamp: (data['timestamp'] as Timestamp).toDate(),
        );
      }).toList();

      data_list = payload;

      bloc.setExpenses(payload);

      emit(FirestoreRecordLoaded());
    } catch (e) {
      emit(FirestoreError(error: e.toString()));
    }
  }

  Future<void> updateData(
      User user, Expense expenses, int index, ExpensesBloc bloc) async {
    emit(FirestoreUpdateLoading());
    try {
      await db
          .collection("expense__tracker")
          .doc(user.email)
          .collection(DateFormat('MMMM yyyy').format(expenses.timestamp))
          .doc(expenses.id)
          .update({
        'amount': expenses.amount,
        'name': expenses.name,
        'type': expenses.type,
        'category': expenses.category,
        'timestamp': expenses.timestamp,
      });

      data_list[index] = Expense(
          id: expenses.id,
          amount: expenses.amount,
          name: expenses.name,
          type: expenses.type,
          category: expenses.category,
          timestamp: expenses.timestamp);

      bloc.setExpenses(data_list);
      emit(FirestoreRecordLoaded());
    } catch (e) {
      emit(FirestoreError(error: e.toString()));
    }
  }

  Future<void> deleteData(
      User user, Expense expenses, int index, ExpensesBloc bloc) async {
    emit(FirestoreUpdateLoading());
    try {
      final querySnapshot = await db
          .collection("expense__tracker")
          .doc(user.email)
          .collection(DateFormat('MMMM yyyy').format(expenses.timestamp))
          .doc(expenses.id)
          .delete();

      data_list.removeAt(index);
      bloc.setExpenses(data_list);
      emit(FirestoreRecordLoaded());
    } catch (e) {
      emit(FirestoreError(error: e.toString()));
    }
  }

  Future<void> addTransaction(
      User user, ExpenseNoID expenses, ExpensesBloc bloc) async {
    emit(FirestoreUpdateLoading());
    try {
      final querySnapshot = await db
          .collection("expense__tracker")
          .doc(user.email)
          .collection(DateFormat('MMMM yyyy').format(DateTime.now()))
          .add({
        "type": expenses.type,
        "name": expenses.name,
        "amount": expenses.amount,
        "category": expenses.category,
        "timestamp": expenses.timestamp,
      });

      final tmp = Expense(
          id: querySnapshot.id,
          amount: expenses.amount,
          name: expenses.name,
          type: expenses.type,
          category: expenses.category,
          timestamp: expenses.timestamp);

      data_list.add(tmp);
      bloc.setExpenses(data_list);
      emit(FirestoreRecordLoaded());
    } catch (e) {
      emit(FirestoreError(error: e.toString()));
    }
  }

// export function postRecord(payload) {
//   return (dispatch) => {
//     const id = toast.loading("Please wait...");
//     dispatch(setLoading(true));

//     db.collection("expense__tracker")
//       .doc(payload.user)
//       .collection(payload.date)
//       .add({
//         type: payload.type,
//         name: payload.name,
//         amount: payload.amount,
//         category: payload.category,
//         timestamp: payload.timestamp,
//       })
//       .then((success) => {
//         toast.update(id, {
//           render: "Successfully Add Data",
//           type: "success",
//           isLoading: false,
//           autoClose: 5000,
//         });
//         dispatch(setLoading(false));
//       })
//       .catch((error) => {
//         toast.update(id, {
//           render: error.message,
//           type: "error",
//           isLoading: false,
//           autoClose: 5000,
//         });
//         dispatch(setLoading(false));
//       });
//   };
// }
}

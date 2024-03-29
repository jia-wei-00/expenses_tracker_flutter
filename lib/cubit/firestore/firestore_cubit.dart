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

class ExpensesHistoryBloc extends Cubit<List<Expense>> {
  ExpensesHistoryBloc() : super([]);

  void setExpensesHistory(List<Expense> expenses) {
    emit(expenses);
  }
}

class RunOnce extends Cubit<bool> {
  RunOnce() : super(true);

  void setRunOnce(bool set) {
    emit(set);
  }
}

class FirestoreCubit extends Cubit<FirestoreState> {
  FirestoreCubit() : super(FirestoreInitial());

  // List<Expense> data_list = [];

  final db = FirebaseFirestore.instance;

  String getMonth() {
    DateTime now = DateTime.now();
    return DateFormat('MMMM yyyy').format(now);
  }

  Future<void> fetchData(
      User user, ExpensesBloc bloc, ExpensesHistoryBloc historyBloc) async {
    emit(FirestoreLoading());

    try {
      db
          .collection("expense__tracker")
          .doc(user.email)
          .collection(getMonth())
          .orderBy("timestamp", descending: true)
          .snapshots()
          .listen((querySnapshot) {
        if (querySnapshot.size != 0) {
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

          bloc.setExpenses(payload);
          historyBloc.setExpensesHistory(payload);

          emit(FirestoreSuccess());
        } else {
          emit(FirestoreError(error: "Empty Data"));
        }
      });
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

      // final dataList = bloc.state;

      // dataList[index] = Expense(
      //     id: expenses.id,
      //     amount: expenses.amount,
      //     name: expenses.name,
      //     type: expenses.type,
      //     category: expenses.category,
      //     timestamp: expenses.timestamp);

      // bloc.setExpenses(dataList);
      emit(FirestoreSuccess("Update Success!"));
    } catch (e) {
      emit(FirestoreError(error: e.toString()));
    }
  }

  Future<void> deleteData(
      User user, Expense expenses, ExpensesBloc bloc) async {
    emit(FirestoreUpdateLoading());

    // final dataList = bloc.state;

    // int index = dataList
    //     .indexWhere((expense) => expense.timestamp == expenses.timestamp);
    try {
      await db
          .collection("expense__tracker")
          .doc(user.email)
          .collection(DateFormat('MMMM yyyy').format(expenses.timestamp))
          .doc(expenses.id)
          .delete();

      // dataList.removeAt(index);
      // bloc.setExpenses(dataList);
      emit(FirestoreSuccess("Delete Success!"));
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

      final dataList = bloc.state;

      // dataList.insert(0, tmp);
      bloc.setExpenses(dataList);
      emit(FirestoreSuccess("Add ${expenses.type} success!"));
    } catch (e) {
      emit(FirestoreError(error: e.toString()));
    }
  }

  Future<void> fetchHistoryData(
      User user,
      ExpensesBloc bloc,
      ExpensesHistoryBloc historyBloc,
      String month,
      bool runOnce,
      RunOnce setRunOnce) async {
    emit(FirestoreLoading());

    try {
      db
          .collection("expense__tracker")
          .doc(user.email)
          .collection(month)
          .orderBy("timestamp", descending: true)
          .snapshots()
          .listen((querySnapshot) {
        if (querySnapshot.size != 0) {
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

          historyBloc.setExpensesHistory(payload);

          emit(FirestoreSuccess());
        } else {
          emit(FirestoreError(error: "Empty data for $month"));
        }
      });
    } catch (e) {
      emit(FirestoreError(error: e.toString()));
    }
  }
}

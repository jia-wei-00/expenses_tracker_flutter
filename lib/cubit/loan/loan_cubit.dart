import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meta/meta.dart';

part 'loan_state.dart';

class Loan {
  final String name;
  final String total;
  final num remain;
  final num paid;
  final List<LoanDetails> history;

  Loan(
      {required this.name,
      required this.total,
      required this.history,
      required this.remain,
      required this.paid});

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'total': total,
      'history': history,
    };
  }
}

class RunOnceLoan extends Cubit<bool> {
  RunOnceLoan() : super(true);

  void setRunOnceLoan(bool set) {
    emit(set);
  }
}

class LoanBloc extends Cubit<List<Loan>> {
  LoanBloc() : super([]);

  void setLoan(List<Loan> todo) {
    emit(todo);
  }
}

class LoanCubit extends Cubit<LoanState> {
  LoanCubit() : super(LoanInitial());

  final db = FirebaseFirestore.instance;

  Future<void> fetchLoan(User user, LoanBloc bloc) async {
    emit(LoanLoading());

    List<Loan> loans = [];

    try {
      db
          .collection("expense__tracker")
          .doc(user.email)
          .collection("loan__list")
          .snapshots()
          .listen((querySnapshot) {
        if (querySnapshot.size != 0) {
          final List<Loan> payload = querySnapshot.docs.map((doc) {
            final data = doc.data();
            num paid = 0;
            num remain = data['total'];

            final List<Map<String, dynamic>> historyData =
                List<Map<String, dynamic>>.from(data['history']);

            final List<LoanDetails> history = historyData.map((historyMap) {
              remain -= historyMap['amount'];
              paid += historyMap['amount'];

              return LoanDetails(
                amount: historyMap['amount'],
                timestamp: historyMap['timestamp'].toDate(),
              );
            }).toList();

            return Loan(
              name: doc.id,
              total: data['total'].toString(),
              remain: remain,
              paid: paid,
              history: history,
            );
          }).toList();

          bloc.setLoan(payload);
        }
      });
    } catch (e) {
      emit(LoanFailed(message: e.toString()));
    }
  }

  Future<void> addLoan(User user, LoanBloc bloc, Loan todo) async {
    emit(LoanLoading());

    try {
      final docRef = await db
          .collection("expense__tracker")
          .doc(user.email)
          .collection("todo__list")
          .doc("todo__array");

      final tmpTodo = bloc.state;

      tmpTodo.add(todo);

      // Convert the list of Todo objects to a list of JSON objects
      final jsonList = tmpTodo.map((todo) => todo.toJson()).toList();

      await docRef.update({"todo__array": jsonList});

      bloc.setLoan(tmpTodo);
      emit(LoanSuccess(message: "Added Successfully"));
    } catch (e) {
      emit(LoanFailed(message: e.toString()));
    }
  }

  Future<void> updateTodo(User user, LoanBloc bloc, List<Loan> todo) async {
    emit(LoanLoading());

    try {
      final docRef = await db
          .collection("expense__tracker")
          .doc(user.email)
          .collection("todo__list")
          .doc("todo__array");

      // Convert the list of Todo objects to a list of JSON objects
      final jsonList = bloc.state.map((todo) => todo.toJson()).toList();

      await docRef.update({"todo__array": jsonList});

      bloc.setLoan(bloc.state);
      emit(LoanSuccess(message: "Updated Successfully"));
    } catch (e) {
      emit(LoanFailed(message: e.toString()));
    }
  }

  // Future<void> editTodo(
  //     User user, LoanBloc bloc, Loan todo, DateTime timestamp) async {
  //   emit(LoanLoading());
  //   int index = bloc.state.indexWhere((todo) => todo.timestamp == timestamp);
  //   try {
  //     final docRef = await db
  //         .collection("expense__tracker")
  //         .doc(user.email)
  //         .collection("todo__list")
  //         .doc("todo__array");

  //     final tmpTodo = bloc.state;

  //     tmpTodo[index] = todo;

  //     // Convert the list of Todo objects to a list of JSON objects
  //     final jsonList = tmpTodo.map((todo) => todo.toJson()).toList();

  //     await docRef.update({"todo__array": jsonList});

  //     bloc.setLoan(tmpTodo);
  //     emit(LoanSuccess(message: "Updated Successfully"));
  //   } catch (e) {
  //     emit(LoanFailed(message: e.toString()));
  //   }
  // }

  // Future<void> deleteTodo(User user, LoanBloc bloc, DateTime timestamp) async {
  //   emit(LoanLoading());

  //   final tmpTodo = bloc.state;
  //   int index = tmpTodo.indexWhere((todo) => todo.timestamp == timestamp);
  //   try {
  //     final docRef = await db
  //         .collection("expense__tracker")
  //         .doc(user.email)
  //         .collection("todo__list")
  //         .doc("todo__array");

  //     tmpTodo.removeAt(index);

  //     // Convert the list of Todo objects to a list of JSON objects
  //     final jsonList = tmpTodo.map((todo) => todo.toJson()).toList();

  //     await docRef.update({"todo__array": jsonList});

  //     bloc.setLoan(tmpTodo);
  //     emit(LoanSuccess(message: "Updated Successfully"));
  //   } catch (e) {
  //     emit(LoanFailed(message: e.toString()));
  //   }
  // }
}

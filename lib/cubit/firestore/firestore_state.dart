part of 'firestore_cubit.dart';

@immutable
abstract class FirestoreState {}

class FirestoreInitial extends FirestoreState {}

class FirestoreLoading extends FirestoreState {}

class FirestoreUpdateLoading extends FirestoreState {}

class FirestoreUpdateSuccess extends FirestoreState {}

class FirestoreSuccess extends FirestoreState {
  final String message;

  FirestoreSuccess({required this.message});
}

class FirestoreError extends FirestoreState {
  final String error;

  FirestoreError({required this.error});
}

class FirestoreRecordLoaded extends FirestoreState {
  // final List<Expense> expenses;

  // FirestoreRecordLoaded({required this.expenses});
}

class Expense {
  final String id;
  final String amount;
  final String name;
  final String type;
  final String category;
  final DateTime timestamp;

  Expense(
      {required this.id,
      required this.amount,
      required this.name,
      required this.type,
      required this.category,
      required this.timestamp});
}

class ExpenseNoID {
  final String amount;
  final String name;
  final String type;
  final String category;
  final DateTime timestamp;

  ExpenseNoID(
      {required this.amount,
      required this.name,
      required this.type,
      required this.category,
      required this.timestamp});
}

part of 'firestore_cubit.dart';

@immutable
abstract class FirestoreState {}

class FirestoreInitial extends FirestoreState {}

class FirestoreSuccess extends FirestoreState {
  final String message;
  final List<Expense> expenses;

  FirestoreSuccess({required this.message, required this.expenses});
}

class FirestoreError extends FirestoreState {}

class Expense {
  final num amount;
  final String category;
  final String name;
  final DateTime timestamp;
  final String type;

  Expense(
      {required this.amount,
      required this.category,
      required this.name,
      required this.timestamp,
      required this.type});
}

part of 'loan_cubit.dart';

@immutable
abstract class LoanState {}

class LoanInitial extends LoanState {}

class LoanFailed extends LoanState {
  final String message;

  LoanFailed({required this.message});
}

class LoanSuccess extends LoanState {
  final String message;

  LoanSuccess({required this.message});
}

class LoanLoading extends LoanState {}

class LoanDetails {
  final num amount;
  final DateTime timestamp;

  LoanDetails({required this.amount, required this.timestamp});
}

class LoanPayment {
  final num amount;

  LoanPayment({required this.amount});
}

part of 'auth_cubit.dart';

@immutable
abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthSuccess extends AuthState {
  final User user;

  AuthSuccess({required this.user});
}

class AuthFailed extends AuthState {
  final String error;

  AuthFailed({required this.error});
}

class AuthLoading extends AuthState {}

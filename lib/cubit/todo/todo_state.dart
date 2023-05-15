part of 'todo_cubit.dart';

@immutable
abstract class TodoState {}

class TodoInitial extends TodoState {}

class TodoFailed extends TodoState {
  final String message;

  TodoFailed({required this.message});
}

class TodoSuccess extends TodoState {
  final String message;

  TodoSuccess({required this.message});
}

class TodoLoading extends TodoState {}

class TodoSuccessReorder extends TodoState {}

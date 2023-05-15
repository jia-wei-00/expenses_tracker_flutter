import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meta/meta.dart';

part 'todo_state.dart';

class Todo {
  final String text;
  final DateTime timestamp;

  Todo({
    required this.text,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}

class TodoBloc extends Cubit<List<Todo>> {
  TodoBloc() : super([]);

  void setTodo(List<Todo> todo) {
    emit(todo);
  }
}

class TodoCubit extends Cubit<TodoState> {
  TodoCubit() : super(TodoInitial());

  final db = FirebaseFirestore.instance;
  List<Todo> _todo = [];

  Future<void> fetchTodo(User user, TodoBloc bloc) async {
    emit(TodoLoading());

    try {
      final querySnapshot = await db
          .collection("expense__tracker")
          .doc(user.email)
          .collection("todo__list")
          .doc("todo__array")
          .get();

      if (querySnapshot.exists) {
        final data = (querySnapshot.data()!["todo__array"] as List<dynamic>)
            .map((item) => Todo(
                  text: item["text"],
                  timestamp: item["timestamp"].toDate(),
                ))
            .toList();

        _todo = data;
        bloc.setTodo(_todo);
        emit(TodoSuccess(message: "Fetch Successfully!"));
      } else {
        emit(TodoFailed(message: "Empty Data!"));
      }
    } catch (e) {
      emit(TodoFailed(message: e.toString()));
    }
  }

  Future<void> addTodo(User user, TodoBloc bloc, Todo todo) async {
    emit(TodoLoading());

    try {
      final docRef = await db
          .collection("expense__tracker")
          .doc(user.email)
          .collection("todo__list")
          .doc("todo__array");

      _todo.add(todo);

      // Convert the list of Todo objects to a list of JSON objects
      final jsonList = _todo.map((todo) => todo.toJson()).toList();

      await docRef.update({"todo__array": jsonList});

      bloc.setTodo(_todo);
      emit(TodoSuccess(message: "Added Successfully"));
    } catch (e) {
      emit(TodoFailed(message: e.toString()));
    }
  }

  Future<void> updateTodo(User user, TodoBloc bloc, List<Todo> todo) async {
    emit(TodoLoading());

    try {
      final docRef = await db
          .collection("expense__tracker")
          .doc(user.email)
          .collection("todo__list")
          .doc("todo__array");

      _todo = todo;

      // Convert the list of Todo objects to a list of JSON objects
      final jsonList = _todo.map((todo) => todo.toJson()).toList();

      await docRef.update({"todo__array": jsonList});

      bloc.setTodo(_todo);
      emit(TodoSuccess(message: "Updated Successfully"));
    } catch (e) {
      emit(TodoFailed(message: e.toString()));
    }
  }

  Future<void> editTodo(User user, TodoBloc bloc, Todo todo, int index) async {
    emit(TodoLoading());

    try {
      final docRef = await db
          .collection("expense__tracker")
          .doc(user.email)
          .collection("todo__list")
          .doc("todo__array");

      _todo[index] = todo;

      // Convert the list of Todo objects to a list of JSON objects
      final jsonList = _todo.map((todo) => todo.toJson()).toList();

      await docRef.update({"todo__array": jsonList});

      bloc.setTodo(_todo);
      emit(TodoSuccess(message: "Updated Successfully"));
    } catch (e) {
      emit(TodoFailed(message: e.toString()));
    }
  }

  Future<void> deleteTodo(User user, TodoBloc bloc, int index) async {
    emit(TodoLoading());

    try {
      final docRef = await db
          .collection("expense__tracker")
          .doc(user.email)
          .collection("todo__list")
          .doc("todo__array");

      _todo.removeAt(index);

      // Convert the list of Todo objects to a list of JSON objects
      final jsonList = _todo.map((todo) => todo.toJson()).toList();

      await docRef.update({"todo__array": jsonList});

      bloc.setTodo(_todo);
      emit(TodoSuccess(message: "Updated Successfully"));
    } catch (e) {
      emit(TodoFailed(message: e.toString()));
    }
  }
}

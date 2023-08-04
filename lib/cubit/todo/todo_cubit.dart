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

class RunOnceTodo extends Cubit<bool> {
  RunOnceTodo() : super(true);

  void setRunOnceTodo(bool set) {
    emit(set);
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
  // List<Todo> _todo = [];

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

        bloc.setTodo(data);
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

      final tmpTodo = bloc.state;

      tmpTodo.add(todo);

      // Convert the list of Todo objects to a list of JSON objects
      final jsonList = tmpTodo.map((todo) => todo.toJson()).toList();

      await docRef.update({"todo__array": jsonList});

      bloc.setTodo(tmpTodo);
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

      // Convert the list of Todo objects to a list of JSON objects
      final jsonList = bloc.state.map((todo) => todo.toJson()).toList();

      await docRef.update({"todo__array": jsonList});

      bloc.setTodo(bloc.state);
      emit(TodoSuccess(message: "Updated Successfully"));
    } catch (e) {
      emit(TodoFailed(message: e.toString()));
    }
  }

  Future<void> editTodo(
      User user, TodoBloc bloc, Todo todo, DateTime timestamp) async {
    emit(TodoLoading());
    int index = bloc.state.indexWhere((todo) => todo.timestamp == timestamp);
    try {
      final docRef = await db
          .collection("expense__tracker")
          .doc(user.email)
          .collection("todo__list")
          .doc("todo__array");

      final tmpTodo = bloc.state;

      tmpTodo[index] = todo;

      // Convert the list of Todo objects to a list of JSON objects
      final jsonList = tmpTodo.map((todo) => todo.toJson()).toList();

      await docRef.update({"todo__array": jsonList});

      bloc.setTodo(tmpTodo);
      emit(TodoSuccess(message: "Updated Successfully"));
    } catch (e) {
      emit(TodoFailed(message: e.toString()));
    }
  }

  Future<void> deleteTodo(User user, TodoBloc bloc, DateTime timestamp) async {
    emit(TodoLoading());

    final tmpTodo = bloc.state;
    int index = tmpTodo.indexWhere((todo) => todo.timestamp == timestamp);
    try {
      final docRef = await db
          .collection("expense__tracker")
          .doc(user.email)
          .collection("todo__list")
          .doc("todo__array");

      tmpTodo.removeAt(index);

      // Convert the list of Todo objects to a list of JSON objects
      final jsonList = tmpTodo.map((todo) => todo.toJson()).toList();

      await docRef.update({"todo__array": jsonList});

      bloc.setTodo(tmpTodo);
      emit(TodoSuccess(message: "Updated Successfully"));
    } catch (e) {
      emit(TodoFailed(message: e.toString()));
    }
  }
}

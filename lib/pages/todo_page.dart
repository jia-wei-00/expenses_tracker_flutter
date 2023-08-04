import 'package:expenses_tracker/components/details_modal.dart';
import 'package:expenses_tracker/components/dialog.dart';
import 'package:expenses_tracker/components/divider.dart';
import 'package:expenses_tracker/components/snackbar.dart';
import 'package:expenses_tracker/components/text.dart';
import 'package:expenses_tracker/cubit/auth/auth_cubit.dart';
import 'package:expenses_tracker/cubit/firestore/firestore_cubit.dart';
import 'package:expenses_tracker/cubit/todo/todo_cubit.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:intl/intl.dart';

class TodoPage extends StatefulWidget {
  const TodoPage({super.key});

  @override
  State<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();
  List<Todo> todoBeforeFilter = [];
  List<Todo> todo = [];
  User? user;

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    // updateTodo();
    super.dispose();
  }

  void updateTodo() {
    context
        .read<TodoCubit>()
        .updateTodo(user!, context.read<TodoBloc>(), todoBeforeFilter);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        user = state is AuthSuccess ? state.user : null;
        final todoBloc = context.watch<TodoBloc>();
        final runOnce = context.watch<RunOnceTodo>();
        if (todoBloc.state.isEmpty && runOnce.state) {
          context.read<TodoCubit>().fetchTodo(user!, context.read<TodoBloc>());
          context.read<RunOnceTodo>().setRunOnceTodo(false);
        }
        return GestureDetector(
          onTap: () {
            // Unfocus the search input when the user taps outside
            _focusNode.unfocus();
          },
          child: Scaffold(
            body: Container(
              padding: const EdgeInsets.all(12),
              child: BlocConsumer<TodoCubit, TodoState>(
                listener: (context, state) {
                  if (state is TodoFailed) {
                    snackBar(state.message, Colors.red, Colors.white, context);
                  }
                },
                builder: (context, state) {
                  // EasyLoading.init();
                  todoBeforeFilter = todoBloc.state;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 5, bottom: 5),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            mediumFont("Record"),
                            SizedBox(
                              height: 35,
                              width: 200, // Set the desired width here
                              child: Expanded(
                                child: TextField(
                                  focusNode: _focusNode,
                                  controller: _searchController,
                                  onChanged: (value) {
                                    setState(() {
                                      todo = todoBeforeFilter
                                          .where((element) => element.text
                                              .toLowerCase()
                                              .contains(value.toLowerCase()))
                                          .toList();
                                    });
                                  },
                                  decoration: const InputDecoration(
                                    hintText: 'Search...',
                                    contentPadding: EdgeInsets.only(bottom: 3),
                                    hintStyle: TextStyle(fontSize: 13),
                                    prefixIcon: Icon(
                                      Icons.search,
                                      size: 20,
                                      color: Colors.white,
                                    ),
                                    prefixIconConstraints: BoxConstraints(
                                      minWidth: 30,
                                      minHeight: 40,
                                    ),
                                  ),
                                  style: const TextStyle(fontSize: 15),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      divider(),
                      Expanded(
                        child: Builder(builder: (context) {
                          var todo = todoBeforeFilter
                              .where((element) => element.text
                                  .toLowerCase()
                                  .contains(
                                      _searchController.text.toLowerCase()))
                              .toList();
                          if (state is TodoLoading) {
                            EasyLoading.show(status: 'loading...');
                          }
                          if (state is TodoSuccess) {
                            EasyLoading.dismiss();
                          }
                          if (state is TodoFailed) {
                            EasyLoading.dismiss();
                          }
                          return ReorderableListView(
                            children: <Widget>[
                              for (int index = 0; index < todo.length; index++)
                                InkWell(
                                  key: ValueKey(index),
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) =>
                                          todoModal(
                                              context,
                                              context.read<AuthCubit>(),
                                              todo[index]),
                                    );
                                  },
                                  child: ClipRRect(
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(10)),
                                    child: Container(
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                        border: Border(
                                          left: BorderSide(
                                              color: Colors.orange, width: 5),
                                        ),
                                      ),
                                      margin: const EdgeInsets.symmetric(
                                          vertical: 4),
                                      child: ClipRRect(
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(10)),
                                        child: ListTile(
                                          title: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              SizedBox(
                                                width: 25,
                                                child: CircleAvatar(
                                                  backgroundColor: Colors.black,
                                                  child: Container(
                                                      alignment:
                                                          Alignment.center,
                                                      child: smallFont(
                                                          (index + 1)
                                                              .toString())),
                                                ),
                                              ),
                                              const SizedBox(
                                                width: 10,
                                              ),
                                              Expanded(
                                                child: mediumFont(
                                                    todo[index].text,
                                                    color: Colors.black),
                                              ),
                                            ],
                                          ),
                                          trailing: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              IconButton(
                                                padding:
                                                    const EdgeInsets.all(0),
                                                color: Colors.black
                                                    .withOpacity(0.7),
                                                icon: const Icon(Icons.edit),
                                                onPressed: () {
                                                  showDialog(
                                                    context: context,
                                                    builder: (BuildContext
                                                            context) =>
                                                        editTodoModal(
                                                      user!,
                                                      todo[index],
                                                      index,
                                                      context.read<TodoCubit>(),
                                                    ),
                                                  );
                                                },
                                              ),
                                              IconButton(
                                                padding:
                                                    const EdgeInsets.all(0),
                                                color: Colors.black
                                                    .withOpacity(0.7),
                                                icon: const Icon(
                                                    Icons.delete_forever),
                                                onPressed: () {
                                                  showDialog(
                                                      context: context,
                                                      builder: (BuildContext context) =>
                                                          alertDeleteTodoDialog(
                                                              context,
                                                              context.read<
                                                                  TodoCubit>(),
                                                              user!,
                                                              todo[index]
                                                                  .timestamp,
                                                              index));
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                            onReorder: (int oldIndex, int newIndex) {
                              setState(() {
                                if (oldIndex < newIndex) {
                                  newIndex -= 1;
                                }
                                final Todo item =
                                    todoBeforeFilter.removeAt(oldIndex);
                                todoBeforeFilter.insert(newIndex, item);
                                context.read<TodoCubit>().updateTodo(user!,
                                    context.read<TodoBloc>(), todoBeforeFilter);
                              });
                            },
                          );
                          // }
                        }),
                      ),
                      divider(),
                      ElevatedButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) => addTodoModal(
                                user!,
                                context.read<TodoCubit>(),
                                context.read<TodoBloc>()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                        ),
                        child: const Text('Add Record'),
                      )
                    ],
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}

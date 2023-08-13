import 'package:expenses_tracker/components/details_modal.dart';
import 'package:expenses_tracker/components/dialog.dart';
import 'package:expenses_tracker/components/divider.dart';
import 'package:expenses_tracker/components/snackbar.dart';
import 'package:expenses_tracker/components/text.dart';
import 'package:expenses_tracker/cubit/auth/auth_cubit.dart';
import 'package:expenses_tracker/cubit/loan/loan_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class LoanPage extends StatefulWidget {
  const LoanPage({super.key});

  @override
  State<LoanPage> createState() => _LoanPageState();
}

class _LoanPageState extends State<LoanPage> {
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();
  List<Loan> loan = [];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        final user = state is AuthSuccess ? state.user : null;
        final loanBloc = context.watch<LoanBloc>();

        if (loanBloc.state.isEmpty) {
          context.read<LoanCubit>().fetchLoan(user!, context.read<LoanBloc>());
        }

        return GestureDetector(
          onTap: () {
            // Unfocus the search input when the user taps outside
            _focusNode.unfocus();
          },
          child: Scaffold(
            body: Container(
              padding: const EdgeInsets.all(12),
              child: BlocConsumer<LoanCubit, LoanState>(
                listener: (context, state) {
                  if (state is LoanSuccess) {
                    EasyLoading.dismiss();
                    snackBar(
                        state.message, Colors.green, Colors.white, context);
                  }

                  if (state is LoanLoading) {
                    EasyLoading.show(status: 'loading...');
                  }

                  if (state is LoanFailed) {
                    EasyLoading.dismiss();
                    print(state.message);
                    snackBar(
                        state.message, Colors.green, Colors.white, context);
                  }
                },
                builder: (context, state) {
                  loan = loanBloc.state;

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
                                  onChanged: (value) {},
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
                          child: ValueListenableBuilder(
                              valueListenable: _searchController,
                              builder: (BuildContext context, _, __) {
                                var filteredLoan = loan
                                    .where((element) => element.name
                                        .toLowerCase()
                                        .contains(_searchController.text
                                            .toLowerCase()))
                                    .toList();

                                return ListView.builder(
                                  itemCount: filteredLoan.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return Padding(
                                      padding: const EdgeInsets.only(
                                          top: 4, bottom: 4),
                                      child: Slidable(
                                        endActionPane: ActionPane(
                                          // A motion is a widget used to control how the pane animates.
                                          motion: const ScrollMotion(),

                                          // All actions are defined in the children parameter.
                                          children: [
                                            // A SlidableAction can have an icon and/or a label.
                                            SlidableAction(
                                              onPressed:
                                                  (BuildContext context) {
                                                showDialog(
                                                  context: context,
                                                  builder: (BuildContext
                                                          context) =>
                                                      alertDeleteDialogLoan(
                                                          context,
                                                          user!,
                                                          filteredLoan[index]
                                                              .name),
                                                );
                                              },
                                              backgroundColor:
                                                  const Color(0xFFFE4A49),
                                              foregroundColor: Colors.white,
                                              icon: Icons.delete,
                                              label: 'Delete',
                                            ),
                                            SlidableAction(
                                              onPressed:
                                                  (BuildContext context) {
                                                showDialog(
                                                    context: context,
                                                    builder:
                                                        (BuildContext
                                                                context) =>
                                                            addLoanPaymentModal(
                                                                user!,
                                                                context.read<
                                                                    LoanCubit>(),
                                                                filteredLoan[
                                                                    index]));
                                              },
                                              backgroundColor: Colors.green,
                                              foregroundColor: Colors.white,
                                              icon: Icons.add,
                                              label: 'Add',
                                            ),
                                          ],
                                        ),
                                        child: InkWell(
                                          onTap: () {
                                            showDialog(
                                              context: context,
                                              builder: (BuildContext context) =>
                                                  loanDetails(
                                                      filteredLoan[index]),
                                            );
                                          },
                                          child: Container(
                                            margin: EdgeInsets.zero,
                                            child: ClipRRect(
                                              borderRadius:
                                                  const BorderRadius.all(
                                                      Radius.circular(10)),
                                              child: Container(
                                                decoration: const BoxDecoration(
                                                  color: Colors.white,
                                                  border: Border(
                                                    left: BorderSide(
                                                        color: Colors.red,
                                                        width: 5),
                                                  ),
                                                ),
                                                child: ListTile(
                                                  title: mediumFont(
                                                      filteredLoan[index].name,
                                                      color: Colors.black),
                                                  subtitle: mediumFont(
                                                      "RM${filteredLoan[index].total}",
                                                      color: Colors.black
                                                          .withOpacity(0.6)),
                                                  trailing: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      mediumFont(
                                                          "P ${filteredLoan[index].paid}",
                                                          color: Colors.green),
                                                      mediumFont(
                                                          "R ${filteredLoan[index].remain}",
                                                          color: Colors.red)
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                );
                              }))
                    ],
                  );
                },
              ),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) =>
                      addLoanModal(user!, context.read<LoanCubit>()),
                );
              },
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              child: const Icon(Icons.add),
            ),
          ),
        );
      },
    );
  }
}

void doNothing(BuildContext context) {}

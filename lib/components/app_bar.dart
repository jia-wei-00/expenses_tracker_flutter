import 'package:expenses_tracker/components/dialog.dart';
import 'package:expenses_tracker/components/text.dart';
import 'package:expenses_tracker/constant/page_constant.dart';
import 'package:expenses_tracker/cubit/auth/auth_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

AppBar appBar(int index, BuildContext context, String email) {
  return AppBar(
    title: Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          bigFont(pages[index].title),
          InkWell(
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) => alertDialog(
                  context,
                  context.read<AuthCubit>(),
                ),
              );
            },
            child: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                email.substring(0, 2).toUpperCase(),
                style: const TextStyle(color: Colors.black),
              ),
            ),
          ),
        ],
      ),
    ),
    automaticallyImplyLeading: false,
    backgroundColor: Colors.black,
  );
}

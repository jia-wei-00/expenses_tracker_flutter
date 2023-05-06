import 'package:expenses_tracker/components/text.dart';
import 'package:expenses_tracker/constant/page_constant.dart';
import 'package:flutter/material.dart';

AppBar appBar(int index) {
  return AppBar(
    title: Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          bigFont(pages[index].title),
          CircleAvatar(
            backgroundColor: Colors.white,
            child: Text(
              "JiaWei".substring(0, 2).toUpperCase(),
              style: const TextStyle(color: Colors.black),
            ),
          ),
        ],
      ),
    ),
    automaticallyImplyLeading: false,
    backgroundColor: Colors.black,
  );
}

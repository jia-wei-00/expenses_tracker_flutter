import 'package:expenses_tracker/constant/page_constant.dart';
import 'package:expenses_tracker/cubit/route/route_cubit.dart';
import 'package:flutter/material.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';

SalomonBottomBar navigationBar(int currentIndex, RouteCubit cubit) {
  return SalomonBottomBar(
    currentIndex: currentIndex,
    onTap: (int index) {
      cubit.pushRoute(index);
    },
    backgroundColor: Colors.black,
    items: List.generate(pages.length,
        (index) => barItem(pages[index].title, pages[index].icon)),
  );
}

SalomonBottomBarItem barItem(String title, IconData icon) {
  return SalomonBottomBarItem(
    icon: Icon(icon),
    title: Text(title),
    selectedColor: Colors.white,
    unselectedColor: Colors.white,
  );
}

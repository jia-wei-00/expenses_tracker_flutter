import 'package:expenses_tracker/pages/history_page.dart';
import 'package:expenses_tracker/pages/home_page.dart';
import 'package:expenses_tracker/pages/loan_page.dart';
import 'package:expenses_tracker/pages/todo_page.dart';
import 'package:flutter/material.dart';

class Pages {
  final String title;
  final IconData icon;
  final Widget page;

  const Pages({required this.title, required this.icon, required this.page});
}

// Define the titles constant using the Titles class
const List<Pages> pages = [
  Pages(title: 'Home', icon: Icons.home, page: HomePage()),
  Pages(title: 'History', icon: Icons.history, page: HistoryPage()),
  Pages(title: 'Loan', icon: Icons.attach_money_rounded, page: LoanPage()),
  Pages(title: 'Todo', icon: Icons.edit_document, page: TodoPage()),
];

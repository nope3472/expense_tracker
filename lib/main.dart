import 'package:expense_tracker/expenses.dart';

import 'package:flutter/material.dart';

void main() async {
  // Initialize Firebase
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expense Tracker',
      theme: ThemeData(
        primarySwatch: Colors.purple,
      ),
      home: const Expense(),
    );
  }
}

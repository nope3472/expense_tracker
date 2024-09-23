import 'package:expense_tracker/models/expense_structure.dart';
import 'package:expense_tracker/models/expenses_list.dart';
import 'package:expense_tracker/models/new_expense.dart';
import 'package:expense_tracker/models/settle.dart';
import 'package:flutter/material.dart';

class Expense extends StatefulWidget {
  const Expense({super.key});

  @override
  State<Expense> createState() {
    return ExpenseState();
  }
}

class ExpenseState extends State<Expense> {
  final List<Expenses> registeredExpenses = [
    Expenses(
      title: 'Flutter course',
      amount: 599,
      date: DateTime.now(),
      category: Category.Work,
    ),
    // Add more initial expenses if needed
  ];

  // Method to open the new expense modal
  void openexpenseoverlay(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => NewExpense(
        onAddExpense: addexpense, // Pass addExpense method to handle new expense
      ),
    );
  }

  // Method to calculate total expenses by category and open new widget
  void openCategoryTotals(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => CategoryTotals(expenses: registeredExpenses),
      ),
    );
  }

  // Add new expense to the list
  void addexpense(Expenses expense) {
    setState(() {
      registeredExpenses.add(expense);
    });
  }

  // Remove expense from the list
  void removeExpense(int index) {
    final removedExpense = registeredExpenses[index];

    setState(() {
      registeredExpenses.removeAt(index); // Remove the expense
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Expense removed'),
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            // Undo the removal
            setState(() {
              registeredExpenses.insert(index, removedExpense); // Add it back
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Tracker'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              openexpenseoverlay(context); // Opens the modal to add a new expense
            },
          ),
          IconButton(
            icon: const Icon(Icons.pie_chart), // Settle icon
            onPressed: () {
              openCategoryTotals(context); // Opens category total screen
            },
          ),
        ],
        backgroundColor: Colors.purpleAccent,
      ),
      body: Column(
        children: [
          Expanded(
            child: ExpensesList(
              expenses: registeredExpenses,
              onRemoveExpense: removeExpense, // Allow removing an expense
            ),
          ),
        ],
      ),
    );
  }
}

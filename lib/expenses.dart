import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_tracker/database/graph.dart';
import 'package:expense_tracker/models/expense_structure.dart';
import 'package:expense_tracker/models/expenses_list.dart';
import 'package:expense_tracker/models/new_expense.dart';
import 'package:expense_tracker/models/settle.dart';
import 'package:flutter/material.dart';


class Expense extends StatefulWidget {
  const Expense({super.key});

  @override
  State<Expense> createState() {
    return _ExpenseState();
  }
}

class _ExpenseState extends State<Expense> {
  final List<Expenses> _registeredExpenses = [];

  @override
  void initState() {
    super.initState();
    _loadExpensesFromFirestore();
  }

  // Load expenses from Firestore
  Future<void> _loadExpensesFromFirestore() async {
    final snapshot = await FirebaseFirestore.instance.collection('expenses').orderBy('date', descending: true).get();
    final expenses = snapshot.docs.map((doc) => Expenses.fromFirestore(doc)).toList();
    setState(() {
      _registeredExpenses.addAll(expenses);
    });
  }

  // Add new expense to the list and save to Firestore
  Future<void> _addExpense(Expenses expense) async {
    setState(() {
      _registeredExpenses.insert(0, expense); // Add the new expense to the top of the list
    });

    // Close the modal immediately after adding the expense
    Navigator.of(context).pop();

    try {
      // Save the expense to Firestore
      await expense.saveToFirebase();
    } catch (e) {
      // If saving fails, remove the added expense from the list
      setState(() {
        _registeredExpenses.removeAt(0);
      });

      // Handle error when saving to Firestore
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving expense: $e'),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  // Remove expense from the list and delete from Firestore
  Future<void> _removeExpense(int index) async {
    final removedExpense = _registeredExpenses[index];

    try {
      // Delete the expense from Firestore
      await FirebaseFirestore.instance.collection('expenses').doc(removedExpense.id).delete();

      setState(() {
        _registeredExpenses.removeAt(index); // Remove the expense
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Expense removed'),
          duration: const Duration(seconds: 3),
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () {
              // Undo the removal
              _addExpense(removedExpense);
            },
          ),
        ),
      );
    } catch (e) {
      // Handle error when deleting from Firestore
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error removing expense: $e'),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  // Method to open the new expense modal
  void _openNewExpenseModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Make modal scrollable when keyboard is open
      builder: (ctx) => Padding(
        padding: MediaQuery.of(context).viewInsets, // Adjust for keyboard height
        child: NewExpense(
          onAddExpense: (expense) {
            // Close the modal before saving the expense
            Navigator.of(context).pop();

            // Call the addExpense method to handle adding the new expense
            _addExpense(expense);
          },
        ),
      ),
    );
  }

  // Method to calculate total expenses by category and open new widget
  void _openCategoryTotals() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => CategoryTotals(expenses: _registeredExpenses),
      ),
    );
  }

  // Method to open the category expenditure graph
  void _openCategoryExpenditureGraph() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => CategoryExpenditureGraph(expenses: _registeredExpenses), // Graph screen
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isExpensesEmpty = _registeredExpenses.isEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Tracker'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _openNewExpenseModal, // Call the new method
          ),
          IconButton(
            icon: const Icon(Icons.pie_chart), // Pie chart icon for category totals
            onPressed: _openCategoryTotals, // Call the method to show category totals
          ),
          IconButton(
            icon: const Icon(Icons.bar_chart), // Bar chart icon for graph view
            onPressed: _openCategoryExpenditureGraph, // Call the method to show the graph
          ),
        ],
        backgroundColor: Colors.purpleAccent,
      ),
      body: isExpensesEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'No expenses added yet!',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    onPressed: _openNewExpenseModal,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Expense'),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ExpensesList(
                    expenses: _registeredExpenses,
                    onRemoveExpense: _removeExpense, // Allow removing an expense
                  ),
                ),
              ],
            ),
    );
  }
}

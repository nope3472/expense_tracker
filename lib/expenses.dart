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
  State<Expense> createState() => _ExpenseState();
}

class _ExpenseState extends State<Expense> {
  final List<Expenses> _registeredExpenses = [];
  bool _isLoading = true;
  // Keep track of expenses we've already saved to prevent duplicates
  final Set<String> _savedExpenseIds = {};

  @override
  void initState() {
    super.initState();
    _loadExpensesFromFirestore();
  }

  Future<void> _loadExpensesFromFirestore() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('expenses')
          .orderBy('date', descending: true)
          .get();

      final expenses = snapshot.docs.map((doc) => Expenses.fromFirestore(doc)).toList();
      
      // Clear existing data and get fresh data
      _registeredExpenses.clear();
      _savedExpenseIds.clear();
      
      for (var expense in expenses) {
        if (expense.id != null && !_savedExpenseIds.contains(expense.id)) {
          _registeredExpenses.add(expense);
          _savedExpenseIds.add(expense.id!);
        }
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load expenses: $e'),
            duration: const Duration(seconds: 3),
          ),
        );
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _addExpense(Expenses expense) async {
    try {
      // Save to Firebase and get document ID
      final docId = await expense.saveToFirebase();
      
      // Create a new expense with the document ID
      final savedExpense = Expenses(
        id: docId,
        title: expense.title,
        amount: expense.amount,
        date: expense.date,
        category: expense.category,
        transactionType: expense.transactionType,
      );
      
      // Only add to list if we haven't seen this ID before
      if (!_savedExpenseIds.contains(docId)) {
        setState(() {
          _registeredExpenses.insert(0, savedExpense);
          _savedExpenseIds.add(docId);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving expense: $e'),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _updateExpense(int index, Expenses expense) async {
    // Create a new expense with the original ID
    final originalId = _registeredExpenses[index].id;
    final updatedExpense = Expenses(
      id: originalId,
      title: expense.title,
      amount: expense.amount,
      date: expense.date,
      category: expense.category,
      transactionType: expense.transactionType,
    );
    
    try {
      await updatedExpense.updateInFirebase();
      
      // Update local state only if successful
      setState(() {
        _registeredExpenses[index] = updatedExpense;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating expense: $e'),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _removeExpense(int index) async {
    final removedExpense = _registeredExpenses[index];
    final expenseId = removedExpense.id;

    // Skip if no ID (which shouldn't happen)
    if (expenseId == null) return;

    try {
      // Remove from local state first for immediate UI feedback
      setState(() {
        _registeredExpenses.removeAt(index);
        _savedExpenseIds.remove(expenseId);
      });
      
      // Then remove from Firebase
      await FirebaseFirestore.instance
          .collection('expenses')
          .doc(expenseId)
          .delete();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Expense removed'),
          duration: const Duration(seconds: 3),
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () {
              _addExpense(removedExpense);
            },
          ),
        ),
      );
    } catch (e) {
      // If Firebase deletion fails, add the expense back to the list
      setState(() {
        _registeredExpenses.insert(index, removedExpense);
        if (expenseId != null) _savedExpenseIds.add(expenseId);
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error removing expense: $e'),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  // Open the add expense modal for a new expense
  void _openNewExpenseModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: MediaQuery.of(context).viewInsets,
        child: NewExpense(
          onAddExpense: (expense) {
            Navigator.of(context).pop();
            _addExpense(expense);
          },
        ),
      ),
    );
  }

  // Open the add expense modal for editing an existing expense
  void _openEditExpenseModal(Expenses expense, int index) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: MediaQuery.of(context).viewInsets,
        child: NewExpense(
          expense: expense,
          onAddExpense: (updatedExpense) {
            Navigator.of(context).pop();
            _updateExpense(index, updatedExpense);
          },
        ),
      ),
    );
  }

  // Handle long press on an expense to show options.
  void _handleLongPress(int index, Expenses expense) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Wrap(
        children: [
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Edit'),
            onTap: () {
              Navigator.of(ctx).pop();
              _openEditExpenseModal(expense, index);
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete),
            title: const Text('Delete'),
            onTap: () {
              Navigator.of(ctx).pop();
              _removeExpense(index);
            },
          ),
        ],
      ),
    );
  }

  void _openCategoryTotals() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => CategoryTotals(expenses: _registeredExpenses),
      ),
    );
  }

  void _openCategoryExpenditureGraph() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => FinancialOverviewDashboard(expenses: _registeredExpenses),
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
            onPressed: _openNewExpenseModal,
          ),
          IconButton(
            icon: const Icon(Icons.pie_chart),
            onPressed: _openCategoryTotals,
          ),
          IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: _openCategoryExpenditureGraph,
          ),
        ],
        backgroundColor: Colors.purpleAccent,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _registeredExpenses.isEmpty
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
                        onRemoveExpense: _removeExpense,
                        onLongPress: _handleLongPress,
                      ),
                    ),
                  ],
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openNewExpenseModal,
        child: const Icon(Icons.add),
      ),
    );
  }
}
import 'package:expense_tracker/models/category.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'expense_structure.dart';
 // New screen for managing categories

class NewExpense extends StatefulWidget {
  final void Function(Expenses expense) onAddExpense;
  final Expenses? expense; // Optional: if non-null, we are editing

  const NewExpense({super.key, required this.onAddExpense, this.expense});

  @override
  State<NewExpense> createState() => _NewExpenseState();
}

class _NewExpenseState extends State<NewExpense> {
  String _enteredTitle = '';
  double _enteredAmount = 0.0;
  DateTime? _selectedDate;
  String? _selectedCategory;
  TransactionType? _selectedTransactionType;

  List<String> _customCategories = [];

  @override
  void initState() {
    super.initState();
    _loadCustomCategories();
    if (widget.expense != null) {
      _enteredTitle = widget.expense!.title;
      _enteredAmount = widget.expense!.amount;
      _selectedDate = widget.expense!.date;
      _selectedCategory = widget.expense!.category;
      _selectedTransactionType = widget.expense!.transactionType;
    }
  }

  Future<void> _loadCustomCategories() async {
    final snapshot = await FirebaseFirestore.instance.collection('customCategories').get();
    final categories = snapshot.docs.map((doc) => doc['name'] as String).toList();
    setState(() {
      _customCategories = categories;
    });
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Invalid Input'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _submitExpense() async {
    if (_enteredTitle.isEmpty) {
      _showErrorDialog('Please enter a valid title.');
      return;
    }
    if (_enteredAmount <= 0) {
      _showErrorDialog('Please enter a valid amount greater than 0.');
      return;
    }
    if (_selectedDate == null) {
      _showErrorDialog('Please select a valid date.');
      return;
    }
    if (_selectedCategory == null) {
      _showErrorDialog('Please select a category.');
      return;
    }
    if (_selectedTransactionType == null) {
      _showErrorDialog('Please select a transaction type.');
      return;
    }

    if (widget.expense == null) {
    final newExpense = Expenses(
      title: _enteredTitle,
      amount: _enteredAmount,
      date: _selectedDate!,
      category: _selectedCategory!,
      transactionType: _selectedTransactionType!,
    );

    try {
      final String docId = await newExpense.saveToFirebase();
      // Create a new expense with the Firestore-generated ID
      final expenseWithId = Expenses(
        id: docId,
        title: newExpense.title,
        amount: newExpense.amount,
        date: newExpense.date,
        category: newExpense.category,
        transactionType: newExpense.transactionType,
      );
      widget.onAddExpense(expenseWithId); // Add the updated expense to local list
    } catch (e) {
      _showErrorDialog('Failed to save expense: $e');
    }
    } else {
      final updatedExpense = Expenses(
        id: widget.expense!.id,
        title: _enteredTitle,
        amount: _enteredAmount,
        date: _selectedDate!,
        category: _selectedCategory!,
        transactionType: _selectedTransactionType!,
      );
      await updatedExpense.updateInFirebase();
      widget.onAddExpense(updatedExpense);
    }
  }

  void _cancelExpense() {
    Navigator.of(context).pop();
  }

  void _presentDatePicker() {
    showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    ).then((pickedDate) {
      if (pickedDate == null) return;
      setState(() {
        _selectedDate = pickedDate;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // Combine default and custom categories
    final allCategories = {
      ...defaultCategories,
      ..._customCategories,
    }.toList();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            TextField(
              decoration: const InputDecoration(labelText: 'Title'),
              maxLength: 30,
              controller: TextEditingController(text: _enteredTitle),
              onChanged: (value) => _enteredTitle = value,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(prefixText: '\$', labelText: 'Amount'),
                    keyboardType: TextInputType.number,
                    controller: TextEditingController(
                        text: _enteredAmount == 0.0 ? '' : _enteredAmount.toString()),
                    onChanged: (value) => _enteredAmount = double.tryParse(value) ?? 0.0,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Row(
                    children: [
                      TextButton(
                        onPressed: _presentDatePicker,
                        child: Text(
                          _selectedDate == null
                              ? 'Pick Date'
                              : DateFormat.yMd().format(_selectedDate!),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.calendar_today),
                        onPressed: _presentDatePicker,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('Category:'),
                const SizedBox(width: 16),
                DropdownButton<String>(
                  value: _selectedCategory,
                  hint: const Text('Select Category'),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedCategory = newValue;
                    });
                  },
                  items: allCategories.map((String cat) {
                    return DropdownMenuItem<String>(
                      value: cat,
                      child: Text(cat),
                    );
                  }).toList(),
                ),
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    // Open Category Management screen.
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (ctx) => CategoryManagementScreen(
                              onCategoriesUpdated: _loadCustomCategories,
                            )));
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('Transaction Type:'),
                const SizedBox(width: 16),
                DropdownButton<TransactionType>(
                  value: _selectedTransactionType,
                  hint: const Text('Select Type'),
                  onChanged: (TransactionType? newValue) {
                    setState(() {
                      _selectedTransactionType = newValue;
                    });
                  },
                  items: TransactionType.values.map((TransactionType type) {
                    return DropdownMenuItem<TransactionType>(
                      value: type,
                      child: Text(type.toString().split('.').last),
                    );
                  }).toList(),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(onPressed: _cancelExpense, child: const Text('Cancel')),
                const SizedBox(width: 10),
                ElevatedButton(onPressed: _submitExpense, child: const Text('Save Expense')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

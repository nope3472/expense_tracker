import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'expense_structure.dart'; // Expenses class with Firebase functionality

class NewExpense extends StatefulWidget {
  final void Function(Expenses expense) onAddExpense; // Callback function

  const NewExpense({super.key, required this.onAddExpense});

  @override
  State<NewExpense> createState() {
    return _NewExpenseState();
  }
}

class _NewExpenseState extends State<NewExpense> {
  String _enteredTitle = '';
  double _enteredAmount = 0.0;
  DateTime? _selectedDate;
  Category? _selectedCategory;

  // Method to show error dialog
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Invalid Input'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // Submit expense method
  Future<void> _submitExpense() async {
    // Validate inputs
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

    // Create a new expense object
    final newExpense = Expenses(
      title: _enteredTitle,
      amount: _enteredAmount,
      date: _selectedDate!,
      category: _selectedCategory!,
    );

    // Save the expense to Firebase (optional if using Firebase)
    await newExpense.saveToFirebase(); // Comment this out if not needed

    // Pass the new expense to the parent widget
    widget.onAddExpense(newExpense);

    // Close the modal after submission
    Navigator.of(context).pop();
  }

  // Cancel the modal
  void _cancelExpense() {
    Navigator.of(context).pop(); // Close modal when "Cancel" is pressed
  }

  // Method to open date picker
  void _presentDatePicker() {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    ).then((pickedDate) {
      if (pickedDate == null) {
        return; // If the user cancels, do nothing
      }
      setState(() {
        _selectedDate = pickedDate; // Save the selected date
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          TextField(
            decoration: const InputDecoration(
              labelText: 'Title',
            ),
            maxLength: 30,
            onChanged: (value) {
              setState(() {
                _enteredTitle = value;
              });
            },
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(
                    prefixText: '\$',
                    labelText: 'Amount',
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    setState(() {
                      _enteredAmount = double.tryParse(value) ?? 0.0;
                    });
                  },
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
              DropdownButton<Category>(
                value: _selectedCategory,
                hint: const Text('Select Category'),
                onChanged: (Category? newValue) {
                  setState(() {
                    _selectedCategory = newValue;
                  });
                },
                items: Category.values.map((Category category) {
                  return DropdownMenuItem<Category>(
                    value: category,
                    child: Text(category.toString().split('.').last),
                  );
                }).toList(),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: _cancelExpense,
                child: const Text('Cancel'),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: _submitExpense,
                child: const Text('Save Expense'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

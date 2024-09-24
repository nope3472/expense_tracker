import 'package:expense_tracker/models/expense_structure.dart';
import 'package:flutter/material.dart';

class ExpensesList extends StatelessWidget {
  const ExpensesList({
    super.key,
    required this.expenses,
    required this.onRemoveExpense, // Callback to remove an expense
  });

  final List<Expenses> expenses;
  final void Function(int index) onRemoveExpense; // Function to remove expense

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: expenses.length,
      itemBuilder: (ctx, index) {
        final expense = expenses[index];
        return Dismissible(
          key: ValueKey(expense.id), // Unique key based on the expense id
          direction: DismissDirection.endToStart,
          onDismissed: (direction) {
            onRemoveExpense(index); // Trigger callback to remove expense
          },
          background: Container(
            alignment: Alignment.centerRight,
            color: Colors.redAccent,
            padding: const EdgeInsets.only(right: 20),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          child: ListTile(
            title: Text(
              expense.title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              expense.formattedDate, // Formatted date from the Expenses model
            ),
            trailing: Text(
              '\$${expense.amount.toStringAsFixed(2)}', // Two decimal places for amount
              style: const TextStyle(fontSize: 16, color: Colors.green),
            ),
            leading: _getIconForCategory(expense.category), // Icon based on category
          ),
        );
      },
    );
  }

  // Helper function to get an image icon based on the category
  Widget _getIconForCategory(Category category) {
    final imagePath = CategoryIcons[category];
    if (imagePath != null) {
      return Image.asset(
        imagePath,
        width: 40,
        height: 40,
      );
    }
    return const Icon(Icons.category, size: 40); // Default icon if none is found
  }
}

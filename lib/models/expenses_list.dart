import 'package:expense_tracker/models/expense_structure.dart';
import 'package:flutter/material.dart';

class ExpensesList extends StatelessWidget {
  const ExpensesList({super.key, required this.expenses, required void Function(int index) onRemoveExpense});

  final List<Expenses> expenses;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: expenses.length,
      itemBuilder: (ctx, index) {
        final expense = expenses[index];
        return ListTile(
          title: Text(expense.title),
          subtitle: Text(expense.formattedDate), // Use formatted date here
          trailing: Text('\$${expense.amount.toStringAsFixed(2)}'), // Display amount with two decimal places
          leading: _getIconForCategory(expense.category), // Use asset image for the category
        );
      },
    );
  }

  // Helper function to get an image icon based on the category
  Widget _getIconForCategory(Category category) {
    final imagePath = CategoryIcons[category];
    return Image.asset(
      imagePath!,
      width: 40,
      height: 40,
    );
  }
}

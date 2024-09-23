import 'package:expense_tracker/models/expense_structure.dart';
import 'package:flutter/material.dart';

class CategoryTotals extends StatelessWidget {
  final List<Expenses> expenses;

  const CategoryTotals({super.key, required this.expenses});

  // Calculate the total amount for each category
  Map<Category, double> calculateTotalsByCategory() {
    final Map<Category, double> totals = {};

    for (final expense in expenses) {
      totals.update(
        expense.category,
        (existingTotal) => existingTotal + expense.amount,
        ifAbsent: () => expense.amount,
      );
    }

    return totals;
  }

  @override
  Widget build(BuildContext context) {
    final totalsByCategory = calculateTotalsByCategory();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Category Totals'),
        backgroundColor: Colors.purpleAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: totalsByCategory.length,
          itemBuilder: (ctx, index) {
            final category = totalsByCategory.keys.elementAt(index);
            final totalAmount = totalsByCategory[category];

            return ListTile(
              title: Text(category.toString().split('.').last), // Display category name
              trailing: Text('\$${totalAmount!.toStringAsFixed(2)}'), // Total amount
            );
          },
        ),
      ),
    );
  }
}

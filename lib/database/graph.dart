import 'package:expense_tracker/models/expense_structure.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class CategoryExpenditureGraph extends StatelessWidget {
  final List<Expenses> expenses;

  const CategoryExpenditureGraph({super.key, required this.expenses});

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
    final pieChartSections = totalsByCategory.entries.map((entry) {
      return PieChartSectionData(
        color: _getCategoryColor(entry.key), // Custom method to get color for each category
        value: entry.value,
        title: '\$${entry.value.toStringAsFixed(2)}',
        radius: 100,
        titleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
      );
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Expenditure Graph'),
        backgroundColor: Colors.purpleAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: PieChart(
          PieChartData(
            sections: pieChartSections,
            centerSpaceRadius: 50,
            sectionsSpace: 4,
          ),
        ),
      ),
    );
  }

  // Custom method to assign colors to categories
  Color _getCategoryColor(Category category) {
    switch (category) {
      case Category.food:
        return Colors.blue;
      case Category.leisure:
        return Colors.green;
      case Category.travel:
        return Colors.orange;
      case Category.work:
        return Colors.pink;
     
      default:
        return Colors.grey;
    }
  }
}

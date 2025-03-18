import 'package:expense_tracker/models/expense_structure.dart';
import 'package:flutter/material.dart';

class CategoryTotals extends StatelessWidget {
  final List<Expenses> expenses;

  const CategoryTotals({super.key, required this.expenses});

  // Calculate net profit (total income minus total expenses)
  double get netProfit {
    final income = expenses
        .where((e) => e.transactionType == TransactionType.income)
        .fold(0.0, (sum, e) => sum + e.amount);
    final expensesTotal = expenses
        .where((e) => e.transactionType == TransactionType.expense)
        .fold(0.0, (sum, e) => sum + e.amount);
    return income - expensesTotal;
  }

  // Calculate totals by category (for expense transactions)
  Map<String, double> calculateTotalsByCategory() {
    final Map<String, double> totals = {};
    for (final expense in expenses.where((e) => e.transactionType == TransactionType.expense)) {
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
    // Sort categories in descending order (highest expense on top)
    final sortedCategories = totalsByCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Category Totals'),
        backgroundColor: Colors.purpleAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Net Profit Card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              color: netProfit >= 0 ? Colors.green[100] : Colors.red[100],
              child: ListTile(
                title: const Text(
                  'Net Profit',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                trailing: Text(
                  '\$${netProfit.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: netProfit >= 0 ? Colors.green : Colors.red,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Category Totals List
            Expanded(
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListView.builder(
                  itemCount: sortedCategories.length,
                  itemBuilder: (ctx, index) {
                    final entry = sortedCategories[index];
                    return ListTile(
                      title: Text(
                        entry.key,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      trailing: Text(
                        '\$${entry.value.toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 16),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

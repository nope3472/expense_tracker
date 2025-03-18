import 'package:flutter/material.dart';
import 'package:expense_tracker/models/expense_structure.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'dart:math' show max;

class FinancialOverviewDashboard extends StatelessWidget {
  final List<Expenses> expenses;

  const FinancialOverviewDashboard({Key? key, required this.expenses})
      : super(key: key);

  // Filter expenses for the current month.
  List<Expenses> get currentMonthExpenses {
    final now = DateTime.now();
    return expenses
        .where((e) => e.date.month == now.month && e.date.year == now.year)
        .toList();
  }

  // Compute total income for current month.
  double get totalIncome => currentMonthExpenses
      .where((e) => e.transactionType == TransactionType.income)
      .fold(0.0, (sum, e) => sum + e.amount);

  // Compute total expenses for current month.
  double get totalExpenses => currentMonthExpenses
      .where((e) => e.transactionType == TransactionType.expense)
      .fold(0.0, (sum, e) => sum + e.amount);

  // Net balance = income - expenses.
  double get netBalance => totalIncome - totalExpenses;

  // Calculate spending totals per category (for expense transactions).
  Map<String, double> getCategoryTotals() {
    final Map<String, double> totals = {};
    for (final expense in currentMonthExpenses
        .where((e) => e.transactionType == TransactionType.expense)) {
      totals.update(expense.category, (existing) => existing + expense.amount,
          ifAbsent: () => expense.amount);
    }
    return totals;
  }

  @override
  Widget build(BuildContext context) {
    final categoryTotals = getCategoryTotals();
    // Sort entries by descending total.
    final sortedEntries = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // Calculate width needed for chart based on number of categories
    // Use at least 400 width or 100 per category, whichever is larger
    final chartWidth = max(400.0, sortedEntries.length * 100.0);

    // Create BarChartGroupData for each category.
    final barGroups = <BarChartGroupData>[];
    int index = 0;
    for (var entry in sortedEntries) {
      barGroups.add(
        BarChartGroupData(
          x: index,
          barRods: [
            BarChartRodData(
              toY: entry.value,
              color: Colors.orange,
              width: 16,
              borderRadius: const BorderRadius.all(Radius.circular(4)),
            )
          ],
          showingTooltipIndicators: [0],
        ),
      );
      index++;
    }

    // Determine the maximum Y value for the chart.
    double maxY = 100;
    if (sortedEntries.isNotEmpty) {
      maxY = sortedEntries.first.value * 1.2;
      if (maxY < 100) maxY = 100;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Financial Overview Dashboard'),
        backgroundColor: Colors.purpleAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Overview Cards for Income, Expenses, and Net Balance.
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildOverviewCard('Income', totalIncome, Colors.green),
                _buildOverviewCard('Expenses', totalExpenses, Colors.red),
                _buildOverviewCard(
                    'Net', netBalance, netBalance >= 0 ? Colors.green : Colors.red),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              'Spending by Category (Current Month)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            // Bar Chart wrapped in a Card and made scrollable
            Expanded(
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Container(
                      width: chartWidth,
                      child: BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceAround,
                          maxY: maxY,
                          barTouchData: BarTouchData(
                            enabled: true,
                            touchTooltipData: BarTouchTooltipData(
                              // For older fl_chart versions
                              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                String category =
                                    sortedEntries[group.x.toInt()].key;
                                return BarTooltipItem(
                                  '$category\n',
                                  const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                  children: <TextSpan>[
                                    TextSpan(
                                      text: '\$${rod.toY.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        color: Colors.yellow,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                          titlesData: FlTitlesData(
                            show: true,
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 30,
                                getTitlesWidget: (double value, TitleMeta meta) {
                                  if (value.toInt() < sortedEntries.length) {
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Text(
                                        sortedEntries[value.toInt()].key,
                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    );
                                  } else {
                                    return const Text('');
                                  }
                                },
                              ),
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: false,  // Hide the y-axis values
                                reservedSize: 10,   // Keep some space for the grid
                              ),
                            ),
                            topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                          ),
                          borderData: FlBorderData(
                            show: false,
                          ),
                          gridData: FlGridData(
                            show: true,
                            drawHorizontalLine: true,
                            drawVerticalLine: false,
                            horizontalInterval: maxY / 5,  // Show 5 horizontal grid lines
                          ),
                          barGroups: barGroups,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewCard(String title, double amount, Color amountColor) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Container(
        width: 100,
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            Text(
              '\$${amount.toStringAsFixed(2)}',
              style: TextStyle(color: amountColor, fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
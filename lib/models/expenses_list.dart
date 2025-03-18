import 'package:expense_tracker/models/expense_structure.dart';
import 'package:flutter/material.dart';

class ExpensesList extends StatelessWidget {
  const ExpensesList({
    super.key,
    required this.expenses,
    required this.onRemoveExpense,
    required this.onLongPress,
  });

  final List<Expenses> expenses;
  final void Function(int index) onRemoveExpense;
  final void Function(int index, Expenses expense) onLongPress;

  @override
  Widget build(BuildContext context) {
    // Sort expenses by date descending so latest added appears first.
    final sortedExpenses = List<Expenses>.from(expenses)
      ..sort((a, b) => b.date.compareTo(a.date));
      
    return ListView.builder(
      itemCount: sortedExpenses.length,
      itemBuilder: (ctx, index) {
        final expense = sortedExpenses[index];
        final isIncome = expense.transactionType == TransactionType.income;
        final displayAmount = (isIncome ? '+' : '-') +
            '\$${expense.amount.toStringAsFixed(2)}';
        final amountColor = isIncome ? Colors.green : Colors.red;

        return Dismissible(
          key: ValueKey(expense.id),
          direction: DismissDirection.endToStart,
          onDismissed: (direction) {
            onRemoveExpense(index);
          },
          background: Container(
            alignment: Alignment.centerRight,
            color: Colors.redAccent,
            padding: const EdgeInsets.only(right: 20),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          child: ListTile(
            title: Text(expense.title,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(expense.formattedDate),
            trailing: Text(displayAmount,
                style: TextStyle(fontSize: 16, color: amountColor)),
            leading: _getIconForCategory(expense.category),
            onLongPress: () => onLongPress(index, expense),
          ),
        );
      },
    );
  }

  Widget _getIconForCategory(String category) {
    final imagePath = defaultCategoryIcons[category];
    if (imagePath != null) {
      return Image.asset(imagePath, width: 40, height: 40);
    }
    return const Icon(Icons.category, size: 40);
  }
}

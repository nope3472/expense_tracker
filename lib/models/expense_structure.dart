import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

final formatter = DateFormat.yMd();

const uuid = Uuid();

enum Category { Food, Leisure, Work, Travel }

const CategoryIcons = {
  Category.Food: 'lib/assets/food.png',
  Category.Leisure: 'lib/assets/leisure.png',
  Category.Work: 'lib/assets/work.png',
  Category.Travel: 'lib/assets/travel.png',
};

class Expenses {
  final int? id; // Nullable for new expenses
  final String title;
  final double amount;
  final DateTime date;
  final Category category;

  Expenses({
    this.id, // ID is nullable for new entries
    required this.title,
    required this.amount,
    required this.date,
    required this.category,
  });

  // Formatted date for UI
  String get formattedDate {
    return '${date.day}/${date.month}/${date.year}';
  }

  // Convert a JSON map to an Expenses object
  factory Expenses.fromJson(Map<String, dynamic> json) {
    return Expenses(
      id: json['id'] != null ? json['id'] : null, // Handle nullable ID
      title: json['title'],
      amount: json['amount'],
      date: DateTime.parse(json['date']),
      category: Category.values[json['category']],
    );
  }

  // Convert an Expenses object to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id, // Include ID if present
      'title': title,
      'amount': amount,
      'date': date.toIso8601String(),
      'category': category.index,
    };
  }
}

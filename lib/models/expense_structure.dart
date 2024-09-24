import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

final formatter = DateFormat.yMd();
const uuid = Uuid();

enum Category { food, leisure, work, travel }

const CategoryIcons = {
  Category.food: 'lib/assets/food.png',
  Category.leisure: 'lib/assets/leisure.png',
  Category.work: 'lib/assets/work.png',
  Category.travel: 'lib/assets/travel.png',
};

class Expenses {
  final String? id; // Nullable for new expenses
  final String title;
  final double amount;
  final DateTime date;
  final Category category;

  Expenses({
    this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.category,
  });

  // Convert an Expense object to a Firestore-friendly map
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'amount': amount,
      'date': date.toIso8601String(),
      'category': category.index,
    };
  }

  String get formattedDate {
    // Format the date to a readable string
    return DateFormat.yMMMd().format(date); // Change the format as needed
  }

 Future<void> saveToFirebase() async {
    try {
      // Save to Firestore
      final collection = FirebaseFirestore.instance.collection('expenses');
      await collection.add(toFirestore()); // Automatically generates an ID
    } catch (e) {
      print('Error saving expense: $e');
      rethrow;
    }
  }

  // Factory constructor for creating an Expense object from Firestore
  factory Expenses.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Expenses(
      id: doc.id,
      title: data['title'],
      amount: data['amount'],
      date: DateTime.parse(data['date']),
      category: Category.values[data['category']],
    );
  }
}
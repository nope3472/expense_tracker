import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

final formatter = DateFormat.yMd();
const uuid = Uuid();

// Default categories and their icons (you can adjust the asset paths as needed)
const List<String> defaultCategories = ['Food', 'Leisure', 'Work', 'Travel'];
const Map<String, String> defaultCategoryIcons = {
  'Food': 'lib/assets/food.png',
  'Leisure': 'lib/assets/leisure.png',
  'Work': 'lib/assets/work.png',
  'Travel': 'lib/assets/travel.png',
};

enum TransactionType { income, expense }

class Expenses {
  final String? id; // Nullable for new expenses
  final String title;
  final double amount;
  final DateTime date;
  final String category; // Now a string
  final TransactionType transactionType;

  Expenses({
    this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.category,
    required this.transactionType,
  });

  // Convert an Expense object to a Firestore-friendly map
 Map<String, dynamic> toFirestore() {
  return {
    'title': title,
    'amount': amount,
    'date': Timestamp.fromDate(date), // Store as Firestore Timestamp
    'category': category,
    'transactionType': transactionType.index,
  };
}

  String get formattedDate => DateFormat.yMMMd().format(date);

 Future<String> saveToFirebase() async {
  try {
    final collection = FirebaseFirestore.instance.collection('expenses');
    final docRef = await collection.add(toFirestore());
    return docRef.id; // Return the generated document ID
  } catch (e) {
    print('Error saving expense: $e');
    rethrow;
  }
}

  Future<void> updateInFirebase() async {
    try {
      final docRef = FirebaseFirestore.instance.collection('expenses').doc(id);
      await docRef.update(toFirestore());
    } catch (e) {
      print('Error updating expense: $e');
      rethrow;
    }
  }

  // Factory constructor to create an Expense from Firestore document
  factory Expenses.fromFirestore(DocumentSnapshot doc) {
  Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
  return Expenses(
    id: doc.id,
    title: data['title'],
    amount: data['amount'],
    date: (data['date'] as Timestamp).toDate(), // Convert Timestamp to DateTime
    category: data['category'],
    transactionType: TransactionType.values[data['transactionType']],
  );
}
}
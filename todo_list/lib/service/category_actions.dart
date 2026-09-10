import 'package:cloud_firestore/cloud_firestore.dart';

class CategoryActions {
  final CollectionReference categoriesCollection =
      FirebaseFirestore.instance.collection('categories');

  Future<void> createCategories() async {
    final snapshot = await categoriesCollection.get();

    if (snapshot.docs.isEmpty) {
      // Create default categories
      final defaultCategories = [
        'Work',
        'Personal',
        'Shopping',
        'Health',
        'School',
      ];

      for (final category in defaultCategories) {
        await categoriesCollection.add({
          'name': category,
        });
      }
    }
  }

  Future<bool> createCategory(String name) async {
    final snapshot = await categoriesCollection.get();

    final alreadyExists = snapshot.docs.any((doc) {
      final category = doc.data() as Map<String, dynamic>;

      return (category['name'] as String).trim().toLowerCase() ==
          name.trim().toLowerCase();
    });

    if (alreadyExists) {
      return false;
    }

    await categoriesCollection.add({
      'name': name.trim(),
    });

    return true;
  }

  Stream<List<String>> readCategories() {
    return categoriesCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final category = doc.data() as Map<String, dynamic>;
        return category['name'] as String;
      }).toList();
    });
  }
}
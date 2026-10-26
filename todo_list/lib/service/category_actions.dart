
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:todo_list/models/categories.dart';

class CategoryActions {
  final CollectionReference<Map<String, dynamic>>
      categoriesCollection =
      FirebaseFirestore.instance.collection('categories');

  // Get the current authenticated user's UID.
  String get _currentUid {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw StateError('User must be signed in.');
    }

    return user.uid;
  }

  // Initialize shared default categories.
  // Call this during app initialization after Firebase setup.
  Future<void> createCategories() async {
    const defaultCategories = [
      'Personal',
      'School',
      'Work',
    ];

    for (final name in defaultCategories) {
      final existing = await categoriesCollection
          .where('name', isEqualTo: name)
          .limit(1)
          .get();

      if (existing.docs.isEmpty) {
        await categoriesCollection.add({
          'name': name,
          'isDefault': true,
        });
      } else {
        final doc = existing.docs.first;
        final data = doc.data();

        // Mark existing defaults as shared.
        if (data['isDefault'] != true) {
          await doc.reference.update({
            'isDefault': true,
          });
        }
      }
    }
  }

  // Read shared defaults and only the current
  // user's custom categories.
  Query<Map<String, dynamic>> _visibleCategoriesQuery(
    String uid,
  ) {
    return categoriesCollection.where(
      Filter.or(
        Filter('isDefault', isEqualTo: true),
        Filter('ownerUid', isEqualTo: uid),
      ),
    );
  }

  // Return Category objects with document IDs.
  Stream<List<Category>> readCategories() {
    final uid = _currentUid;

    return _visibleCategoriesQuery(uid)
        .snapshots()
        .map((snapshot) {
      final categories = snapshot.docs
          .map(Category.fromDocument)
          .toList();

      categories.sort(
        (a, b) => a.name.toLowerCase().compareTo(
              b.name.toLowerCase(),
            ),
      );

      return categories;
    });
  }

  // Create a custom category owned by the user.
  Future<bool> createCategory(String name) async {
    final uid = _currentUid;
    final trimmedName = name.trim();

    if (trimmedName.isEmpty) {
      return false;
    }

    final snapshot =
        await _visibleCategoriesQuery(uid).get();

    final alreadyExists = snapshot.docs.any((doc) {
      final existingName =
          (doc.data()['name'] as String).trim();

      return existingName.toLowerCase() ==
          trimmedName.toLowerCase();
    });

    if (alreadyExists) {
      return false;
    }

    await categoriesCollection.add({
      'name': trimmedName,
      'ownerUid': uid,
      'isDefault': false,
    });

    return true;
  }

  // Update only the user's own custom category.
  // categoryId is the Firestore document ID.
  Future<bool> updateCategory(
    String categoryId,
    String newName,
  ) async {
    final uid = _currentUid;
    final trimmedName = newName.trim();

    if (trimmedName.isEmpty) {
      return false;
    }

    final docRef = categoriesCollection.doc(categoryId);
    final doc = await docRef.get();

    if (!doc.exists) {
      return false;
    }

    final data = doc.data()!;

    // Prevent editing defaults or other
    // users' categories.
    if (data['isDefault'] == true ||
        data['ownerUid'] != uid) {
      return false;
    }

    final snapshot =
        await _visibleCategoriesQuery(uid).get();

    final alreadyExists = snapshot.docs.any((otherDoc) {
      if (otherDoc.id == categoryId) {
        return false;
      }

      final existingName =
          (otherDoc.data()['name'] as String).trim();

      return existingName.toLowerCase() ==
          trimmedName.toLowerCase();
    });

    if (alreadyExists) {
      return false;
    }

    await docRef.update({
      'name': trimmedName,
    });

    return true;
  }

  // Delete only the user's own custom category.
  // categoryId is the Firestore document ID.
  Future<bool> deleteCategory(String categoryId) async {
    final uid = _currentUid;

    final docRef = categoriesCollection.doc(categoryId);
    final doc = await docRef.get();

    if (!doc.exists) {
      return false;
    }

    final data = doc.data()!;

    // Prevent deleting defaults or other
    // users' categories.
    if (data['isDefault'] == true ||
        data['ownerUid'] != uid) {
      return false;
    }

    await docRef.delete();

    return true;
  }
}

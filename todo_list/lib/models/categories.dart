
import 'package:cloud_firestore/cloud_firestore.dart';

class Category {
  final String id;
  final String name;
  final bool isDefault;
  final String? ownerUid;

  const Category({
    required this.id,
    required this.name,
    required this.isDefault,
    this.ownerUid,
  });

  // Convert a Firestore document into a Category.
  factory Category.fromDocument(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();

    return Category(
      id: doc.id,
      name: data['name'] as String,
      isDefault: data['isDefault'] == true,
      ownerUid: data['ownerUid'] as String?,
    );
  }
}

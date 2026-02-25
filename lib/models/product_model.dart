import 'package:cloud_firestore/cloud_firestore.dart';

class ProductModel {
  final String  id;
  final String  name;
  final String  type;
  final String  brand;
  final String? description;
  final String  lastEditedBy;      
  final String? lastEditedByName;  
  final DateTime createdAt;
  final DateTime updatedAt;

  const ProductModel({
    required this.id,
    required this.name,
    required this.type,
    required this.brand,
    this.description,
    required this.lastEditedBy,
    this.lastEditedByName,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProductModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return ProductModel(
      id:               doc.id,
      name:             d['name']             ?? '',
      type:             d['type']             ?? '',
      brand:            d['brand']            ?? '',
      description:      d['description'],
      lastEditedBy:     d['lastEditedBy']     ?? '',
      lastEditedByName: d['lastEditedByName'],
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (d['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
    'name':             name,
    'type':             type,
    'brand':            brand,
    'description':      description,
    'lastEditedBy':     lastEditedBy,
    'lastEditedByName': lastEditedByName,
    'createdAt':        Timestamp.fromDate(createdAt),
    'updatedAt':        Timestamp.fromDate(updatedAt),
  };

  ProductModel copyWith({
    String?   id,
    String?   name,
    String?   type,
    String?   brand,
    String?   description,
    String?   lastEditedBy,
    String?   lastEditedByName,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) =>
      ProductModel(
        id:               id               ?? this.id,
        name:             name             ?? this.name,
        type:             type             ?? this.type,
        brand:            brand            ?? this.brand,
        description:      description      ?? this.description,
        lastEditedBy:     lastEditedBy     ?? this.lastEditedBy,
        lastEditedByName: lastEditedByName ?? this.lastEditedByName,
        createdAt:        createdAt        ?? this.createdAt,
        updatedAt:        updatedAt        ?? this.updatedAt,
      );
}
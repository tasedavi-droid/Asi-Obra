import 'package:cloud_firestore/cloud_firestore.dart';

class InventoryModel {
  final String    id;
  final String    productId;       
  final String?   productName;     
  final String    batchNumber;
  final int       initialQuantity;
  final int       currentQuantity;
  final DateTime? expirationDate;
  final String    lastEditedBy;
  final String?   lastEditedByName;
  final DateTime  createdAt;
  final DateTime  updatedAt;

  const InventoryModel({
    required this.id,
    required this.productId,
    this.productName,
    required this.batchNumber,
    required this.initialQuantity,
    required this.currentQuantity,
    this.expirationDate,
    required this.lastEditedBy,
    this.lastEditedByName,
    required this.createdAt,
    required this.updatedAt,
  });


  bool get isEmpty     => currentQuantity <= 0;
  bool get isLow       => !isEmpty && currentQuantity <= (initialQuantity * 0.2).ceil();
  bool get isExpired   => expirationDate != null && expirationDate!.isBefore(DateTime.now());
  bool get expiresSoon {
    if (expirationDate == null) return false;
    final diff = expirationDate!.difference(DateTime.now()).inDays;
    return diff >= 0 && diff <= 30;
  }

  double get stockPercent =>
      initialQuantity > 0 ? (currentQuantity / initialQuantity).clamp(0.0, 1.0) : 0;

  factory InventoryModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return InventoryModel(
      id:               doc.id,
      productId:        d['productId']        ?? '',
      productName:      d['productName'],
      batchNumber:      d['batchNumber']      ?? '',
      initialQuantity:  (d['initialQuantity'] ?? 0) as int,
      currentQuantity:  (d['currentQuantity'] ?? 0) as int,
      expirationDate:   (d['expirationDate']  as Timestamp?)?.toDate(),
      lastEditedBy:     d['lastEditedBy']     ?? '',
      lastEditedByName: d['lastEditedByName'],
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (d['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    final exp = expirationDate;
    return {
      'productId':        productId,
      'productName':      productName,
      'batchNumber':      batchNumber,
      'initialQuantity':  initialQuantity,
      'currentQuantity':  currentQuantity,
      'expirationDate':   exp != null ? Timestamp.fromDate(exp) : null,
      'lastEditedBy':     lastEditedBy,
      'lastEditedByName': lastEditedByName,
      'createdAt':        Timestamp.fromDate(createdAt),
      'updatedAt':        Timestamp.fromDate(updatedAt),
    };
  }

  InventoryModel copyWith({
    String?   id,
    String?   productId,
    String?   productName,
    String?   batchNumber,
    int?      initialQuantity,
    int?      currentQuantity,
    DateTime? expirationDate,
    String?   lastEditedBy,
    String?   lastEditedByName,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) =>
      InventoryModel(
        id:               id               ?? this.id,
        productId:        productId        ?? this.productId,
        productName:      productName      ?? this.productName,
        batchNumber:      batchNumber      ?? this.batchNumber,
        initialQuantity:  initialQuantity  ?? this.initialQuantity,
        currentQuantity:  currentQuantity  ?? this.currentQuantity,
        expirationDate:   expirationDate   ?? this.expirationDate,
        lastEditedBy:     lastEditedBy     ?? this.lastEditedBy,
        lastEditedByName: lastEditedByName ?? this.lastEditedByName,
        createdAt:        createdAt        ?? this.createdAt,
        updatedAt:        updatedAt        ?? this.updatedAt,
      );
}
import 'package:cloud_firestore/cloud_firestore.dart';

class StockOutModel {
  final String id;
  final String inventoryItemId;
  final String? inventoryItemName;
  final String? batchNumber;
  final int quantity;
  final String userId;
  final String? userName;
  final DateTime date;
  final String reason;

  const StockOutModel({
    required this.id,
    required this.inventoryItemId,
    this.inventoryItemName,
    this.batchNumber,
    required this.quantity,
    required this.userId,
    this.userName,
    required this.date,
    required this.reason,
  });

  factory StockOutModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return StockOutModel(
      id: doc.id,
      inventoryItemId: data['inventoryItemId'] ?? '',
      inventoryItemName: data['inventoryItemName'],
      batchNumber: data['batchNumber'],
      quantity: data['quantity'] ?? 0,
      userId: data['userId'] ?? '',
      userName: data['userName'],
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      reason: data['reason'] ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
    'inventoryItemId': inventoryItemId,
    'inventoryItemName': inventoryItemName,
    'batchNumber': batchNumber,
    'quantity': quantity,
    'userId': userId,
    'userName': userName,
    'date': date,
    'reason': reason,
  };


}
import 'package:cloud_firestore/cloud_firestore.dart';

class StockOutModel {
  final String  id;
  final String  inventoryItemId;   
  final String? inventoryItemName; 
  final String? batchNumber;       
  final int     quantity;
  final String  userId;            
  final String? userName;          
  final DateTime date;
  final String  reason;

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
    final d = doc.data() as Map<String, dynamic>;
    return StockOutModel(
      id:                doc.id,
      inventoryItemId:   d['inventoryItemId']   ?? '',
      inventoryItemName: d['inventoryItemName'],
      batchNumber:       d['batchNumber'],
      quantity:          (d['quantity'] ?? 0) as int,
      userId:            d['userId']   ?? '',
      userName:          d['userName'],
      date:    (d['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      reason:  d['reason'] ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
    'inventoryItemId':   inventoryItemId,
    'inventoryItemName': inventoryItemName,
    'batchNumber':       batchNumber,
    'quantity':          quantity,
    'userId':            userId,
    'userName':          userName,
    'date':              Timestamp.fromDate(date),
    'reason':            reason,
  };
}

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/stock_out_model.dart';
import 'inventory_service.dart';

class StockOutService {
  final _col             = FirebaseFirestore.instance.collection('stockouts');
  final _inventoryService = InventoryService();

  Stream<List<StockOutModel>> watchAll() => _col
      .orderBy('date', descending: true)
      .snapshots()
      .map((s) => s.docs.map(StockOutModel.fromFirestore).toList());

  Stream<List<StockOutModel>> watchByItem(String itemId) => _col
      .where('inventoryItemId', isEqualTo: itemId)
      .orderBy('date', descending: true)
      .snapshots()
      .map((s) => s.docs.map(StockOutModel.fromFirestore).toList());

  Future<StockOutModel> register(StockOutModel so) async {
    final ref = await _col.add(so.toMap());
    await _inventoryService.decreaseQuantity(so.inventoryItemId, so.quantity);
    return StockOutModel(
      id:                ref.id,
      inventoryItemId:   so.inventoryItemId,
      inventoryItemName: so.inventoryItemName,
      batchNumber:       so.batchNumber,
      quantity:          so.quantity,
      userId:            so.userId,
      userName:          so.userName,
      date:              so.date,
      reason:            so.reason,
    );
  }
}
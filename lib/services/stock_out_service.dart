import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/stock_out_model.dart';

class StockOutService {
  final _db      = FirebaseFirestore.instance;
  final _col     = FirebaseFirestore.instance.collection('registro_baixas');
  final _estoque = FirebaseFirestore.instance.collection('estoque');

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
    final baixaRef   = _col.doc();
    final estoqueRef = _estoque.doc(so.inventoryItemId);

    await _db.runTransaction((tx) async {
      final estoqueSnap = await tx.get(estoqueRef);
      final curr = (estoqueSnap.data()?['currentQuantity'] ?? 0) as int;
      final novo = (curr - so.quantity).clamp(0, curr);

      tx.set(baixaRef, {
        ...so.toMap(),
        'id': baixaRef.id,
      });

      tx.update(estoqueRef, {
        'currentQuantity': novo,
        'updatedAt':       Timestamp.fromDate(DateTime.now()),
      });
    });

    return StockOutModel(
      id:                baixaRef.id,
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
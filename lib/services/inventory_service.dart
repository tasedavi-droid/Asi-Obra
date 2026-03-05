import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/inventory_model.dart';

class InventoryService {
  final _col = FirebaseFirestore.instance.collection('estoque');

  
  Stream<List<InventoryModel>> watchAll() => _col
      .orderBy('updatedAt', descending: true)
      .snapshots()
      .map((s) => s.docs.map(InventoryModel.fromFirestore).toList());

  
  Future<InventoryModel> create(InventoryModel item) async {
    final now  = DateTime.now();
    final data = item.copyWith(createdAt: now, updatedAt: now);
    final ref  = await _col.add(data.toMap());
    return data.copyWith(id: ref.id);
  }

  
  Future<void> update(InventoryModel item) =>
      _col.doc(item.id).update(item.copyWith(updatedAt: DateTime.now()).toMap());

  
  Future<void> decreaseQuantity(String itemId, int amount) async {
    await FirebaseFirestore.instance.runTransaction((tx) async {
      final ref  = _col.doc(itemId);
      final snap = await tx.get(ref);
      final curr = (snap.data()?['currentQuantity'] ?? 0) as int;
      tx.update(ref, {
        'currentQuantity': (curr - amount).clamp(0, curr),
        'updatedAt':       Timestamp.fromDate(DateTime.now()),
      });
    });
  }

  // Excluir lote
  Future<void> delete(String id) => _col.doc(id).delete();
}
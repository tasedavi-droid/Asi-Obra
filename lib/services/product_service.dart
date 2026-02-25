import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';

class ProductService {
  final _col = FirebaseFirestore.instance.collection('products');

  Stream<List<ProductModel>> watchAll() => _col
      .orderBy('name')
      .snapshots()
      .map((s) => s.docs.map(ProductModel.fromFirestore).toList());

  Future<ProductModel> create(ProductModel p) async {
    final now  = DateTime.now();
    final data = p.copyWith(createdAt: now, updatedAt: now);
    final ref  = await _col.add(data.toMap());
    return data.copyWith(id: ref.id);
  }

  Future<void> update(ProductModel p) =>
      _col.doc(p.id).update(p.copyWith(updatedAt: DateTime.now()).toMap());

  Future<void> delete(String id) => _col.doc(id).delete();
}
import 'package:flutter/foundation.dart';
import '../models/product_model.dart';
import '../services/product_service.dart';

class ProductProvider extends ChangeNotifier {
  final _svc = ProductService();

  List<ProductModel> _all     = [];
  bool               _loading = false;
  String?            _error;
  String             _search  = '';

  List<ProductModel> get products {
    if (_search.isEmpty) return _all;
    final q = _search.toLowerCase();
    return _all.where((p) =>
        p.name.toLowerCase().contains(q)  ||
        p.type.toLowerCase().contains(q)  ||
        p.brand.toLowerCase().contains(q)).toList();
  }

  bool    get loading => _loading;
  String? get error   => _error;
  int     get total   => _all.length;

  void setSearch(String v) { _search = v; notifyListeners(); }

  void listen() {
    _loading = true;
    notifyListeners();
    _svc.watchAll().listen(
      (list) { _all = list; _loading = false; notifyListeners(); },
      onError: (e) { _error = e.toString(); _loading = false; notifyListeners(); },
    );
  }

  Future<void> create({
    required String name,
    required String type,
    required String brand,
    String?         description,
    required String userId,
    String?         userName,
  }) async {
    _error = null;
    try {
      final now = DateTime.now();
      await _svc.create(ProductModel(
        id: '', name: name, type: type, brand: brand,
        description: description, lastEditedBy: userId,
        lastEditedByName: userName, createdAt: now, updatedAt: now,
      ));
    } on Exception catch (e) { _error = e.toString(); }
    notifyListeners();
  }

  Future<void> update({
    required ProductModel p,
    required String userId,
    String? userName,
  }) async {
    _error = null;
    try {
      await _svc.update(p.copyWith(
        lastEditedBy: userId, lastEditedByName: userName,
        updatedAt: DateTime.now(),
      ));
    } on Exception catch (e) { _error = e.toString(); }
    notifyListeners();
  }

  Future<void> delete(String id) async {
    _error = null;
    try { await _svc.delete(id); }
    on Exception catch (e) { _error = e.toString(); }
    notifyListeners();
  }
}
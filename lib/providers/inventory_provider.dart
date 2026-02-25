import 'package:flutter/foundation.dart';
import '../models/inventory_model.dart';
import '../services/inventory_service.dart';

class InventoryProvider extends ChangeNotifier {
  final _svc = InventoryService();

  List<InventoryModel> _all     = [];
  bool                 _loading = false;
  String?              _error;
  String               _search  = '';

  List<InventoryModel> get items {
    if (_search.isEmpty) return _all;
    final q = _search.toLowerCase();
    return _all.where((i) =>
        (i.productName?.toLowerCase().contains(q) ?? false) ||
        i.batchNumber.toLowerCase().contains(q)).toList();
  }

  bool    get loading    => _loading;
  String? get error      => _error;
  int     get total      => _all.length;
  int     get alertCount => _all.where((i) =>
      i.isExpired || i.isLow || i.expiresSoon || i.isEmpty).length;

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
    required String  productId,
    String?          productName,
    required String  batchNumber,
    required int     initialQuantity,
    DateTime?        expirationDate,
    required String  userId,
    String?          userName,
  }) async {
    _error = null;
    try {
      final now = DateTime.now();
      await _svc.create(InventoryModel(
        id: '', productId: productId, productName: productName,
        batchNumber: batchNumber, initialQuantity: initialQuantity,
        currentQuantity: initialQuantity, expirationDate: expirationDate,
        lastEditedBy: userId, lastEditedByName: userName,
        createdAt: now, updatedAt: now,
      ));
    } on Exception catch (e) { _error = e.toString(); }
    notifyListeners();
  }

  Future<void> update({
    required InventoryModel item,
    required String userId,
    String? userName,
  }) async {
    _error = null;
    try {
      await _svc.update(item.copyWith(
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
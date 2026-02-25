import 'package:flutter/foundation.dart';
import '../models/stock_out_model.dart';
import '../services/stock_out_service.dart';

class StockOutProvider extends ChangeNotifier {
  final _svc = StockOutService();

  List<StockOutModel> _all     = [];
  bool                _loading = false;
  String?             _error;

  List<StockOutModel> get stockOuts => _all;
  bool    get loading => _loading;
  String? get error   => _error;
  int     get total   => _all.length;

  void listen() {
    _loading = true;
    notifyListeners();
    _svc.watchAll().listen(
      (list) { _all = list; _loading = false; notifyListeners(); },
      onError: (e) { _error = e.toString(); _loading = false; notifyListeners(); },
    );
  }

  Future<bool> register({
    required String  inventoryItemId,
    String?          inventoryItemName,
    String?          batchNumber,
    required int     quantity,
    required String  userId,
    String?          userName,
    required String  reason,
  }) async {
    _loading = true;
    _error   = null;
    notifyListeners();
    try {
      await _svc.register(StockOutModel(
        id: '', inventoryItemId: inventoryItemId,
        inventoryItemName: inventoryItemName, batchNumber: batchNumber,
        quantity: quantity, userId: userId, userName: userName,
        date: DateTime.now(), reason: reason,
      ));
      _loading = false;
      notifyListeners();
      return true;
    } on Exception catch (e) {
      _error   = e.toString();
      _loading = false;
      notifyListeners();
      return false;
    }
  }
}
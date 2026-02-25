import 'package:intl/intl.dart';

class DateFormatter {
  DateFormatter._();

  static final _date     = DateFormat('dd/MM/yyyy', 'pt_BR');
  static final _dateTime = DateFormat('dd/MM/yyyy HH:mm', 'pt_BR');

  static String date(DateTime? d)     => d == null ? '—' : _date.format(d);
  static String dateTime(DateTime? d) => d == null ? '—' : _dateTime.format(d);
  static String today()               => _date.format(DateTime.now());

  static DateTime? parse(String? s) {
    if (s == null || s.isEmpty) return null;
    try { return _date.parse(s); } catch (_) { return null; }
  }
}
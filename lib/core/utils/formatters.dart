// File: lib/core/utils/formatters.dart
// Purpose: Date / currency / text formatters. DD-MM-YY is the project-wide date format.
// Used by: forms, table rows, dashboard cards.

import 'package:intl/intl.dart';

class Formatters {
  static final DateFormat _ddMmYy = DateFormat('dd-MM-yy');
  static final DateFormat _ddMmYyyy = DateFormat('dd-MM-yyyy');
  static final NumberFormat _inr = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  static String date(DateTime d) => _ddMmYy.format(d);
  static String dateFull(DateTime d) => _ddMmYyyy.format(d);
  static String currency(num value) => _inr.format(value);
  static String dayName(DateTime d) => DateFormat('EEEE').format(d);
}

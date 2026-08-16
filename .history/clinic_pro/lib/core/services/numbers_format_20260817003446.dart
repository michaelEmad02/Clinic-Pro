import 'package:intl/intl.dart';

String formatNumber( value) {
  return NumberFormat("#,##0", "en_US").format(value);
}
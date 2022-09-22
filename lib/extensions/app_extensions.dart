import 'package:intl/intl.dart';

extension DateTimeData on DateTime {
  String toLocalDate() {
    final DateFormat formatter = DateFormat('EEE, MM/dd');
    return formatter.format(toLocal());
  }

  String toLocalTime() {
    final DateFormat formatter = DateFormat('hh:mm a');
    return formatter.format(toLocal());
  }

  String toLocalDay() {
    final DateFormat formatter = DateFormat('EEE');
    return formatter.format(toLocal());
  }

}

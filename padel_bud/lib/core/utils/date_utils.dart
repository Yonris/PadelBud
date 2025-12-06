DateTime startOfDay(DateTime d) => DateTime(d.year, d.month, d.day);

String formatTimeRange(DateTime start, DateTime end) {
  final s =
      '${start.hour.toString().padLeft(2, '0')}:${start.minute.toString().padLeft(2, '0')}';
  final e =
      '${end.hour.toString().padLeft(2, '0')}:${end.minute.toString().padLeft(2, '0')}';
  return '\$s - \$e';
}

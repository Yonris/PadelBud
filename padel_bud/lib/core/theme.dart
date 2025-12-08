import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    primarySwatch: Colors.green,
    primaryColor: Colors.green,
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.green,
      brightness: Brightness.light,
    ),
    timePickerTheme: TimePickerThemeData(
      backgroundColor: Colors.white,
      hourMinuteTextColor: Colors.green,
      hourMinuteColor: Colors.grey.shade100,
      dialHandColor: Colors.green,
      dialBackgroundColor: Colors.green.shade50,
      entryModeIconColor: Colors.green,
      helpTextStyle: const TextStyle(color: Colors.green),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
    ),
    datePickerTheme: DatePickerThemeData(
      backgroundColor: Colors.white,
      headerBackgroundColor: Colors.green,
      headerForegroundColor: Colors.white,
      weekdayStyle: const TextStyle(color: Colors.green),
      yearStyle: TextStyle(color: Colors.green.shade600),
      dayStyle: TextStyle(color: Colors.green.shade700),
      todayForegroundColor: WidgetStateColor.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return Colors.white;
        }
        return Colors.white;
      }),
      todayBackgroundColor: WidgetStateColor.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return Colors.green;
        }
        return Colors.green.shade100;
      }),
      dayBackgroundColor: WidgetStateColor.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return Colors.green;
        }
        return Colors.transparent;
      }),
      dayForegroundColor: WidgetStateColor.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return Colors.white;
        }
        return Colors.green.shade700;
      }),
      yearBackgroundColor: WidgetStateColor.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return Colors.green;
        }
        return Colors.transparent;
      }),
      yearForegroundColor: WidgetStateColor.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return Colors.white;
        }
        return Colors.green.shade600;
      }),
      rangePickerBackgroundColor: Colors.white,
      rangePickerHeaderBackgroundColor: Colors.green,
      rangePickerHeaderForegroundColor: Colors.white,
      rangeSelectionBackgroundColor: Colors.green.shade100,
      cancelButtonStyle: ButtonStyle(
        foregroundColor: WidgetStateProperty.all(Colors.green),
      ),
      confirmButtonStyle: ButtonStyle(
        backgroundColor: WidgetStateProperty.all(Colors.green),
        foregroundColor: WidgetStateProperty.all(Colors.white),
      ),
    ),
  );
}

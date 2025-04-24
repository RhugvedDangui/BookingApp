import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

/// Utility class for date and time formatting and parsing operations.
///
/// Provides static methods to handle common date and time operations
/// such as formatting dates, parsing date strings, and converting between
/// TimeOfDay and formatted strings.
class DateTimeUtils {
  // Private constructors to prevent instantiation
  DateTimeUtils._();
  
  /// Date format used for standard date operations (yyyy-MM-dd).
  static final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');
  
  /// Time format used for standard time operations (hh:mm a).
  static final DateFormat _timeFormat = DateFormat('hh:mm a');

  /// Formats a DateTime object to a string in 'yyyy-MM-dd' format.
  ///
  /// @param date The DateTime object to format
  /// @return A formatted date string
  static String formatDate(DateTime date) => _dateFormat.format(date);

  /// Parses a date string in 'yyyy-MM-dd' format to a DateTime object.
  ///
  /// @param date The date string to parse
  /// @return A DateTime object
  /// @throws FormatException if the string cannot be parsed
  static DateTime parseDate(String date) {
    try {
      return _dateFormat.parse(date);
    } catch (e) {
      throw FormatException('Invalid date format. Expected yyyy-MM-dd, got: $date');
    }
  }

  /// Formats a TimeOfDay object to a string in 'hh:mm a' format.
  ///
  /// @param time The TimeOfDay object to format
  /// @return A formatted time string
  static String formatTime(TimeOfDay time) {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    return _timeFormat.format(dt);
  }

  /// Parses a time string in 'hh:mm a' format to a TimeOfDay object.
  ///
  /// @param time The time string to parse
  /// @return A TimeOfDay object
  /// @throws FormatException if the string cannot be parsed
  static TimeOfDay parseTime(String time) {
    try {
      final dateTime = _timeFormat.parse(time);
      return TimeOfDay.fromDateTime(dateTime);
    } catch (e) {
      throw FormatException('Invalid time format. Expected hh:mm a, got: $time');
    }
  }
  
  /// Combines a date and time into a single DateTime object.
  ///
  /// @param date The date part
  /// @param time The time part
  /// @return A DateTime object combining the date and time
  static DateTime combineDateAndTime(DateTime date, TimeOfDay time) {
    return DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
  }
  
  /// Checks if a date is today.
  ///
  /// @param date The date to check
  /// @return True if the date is today, false otherwise
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }
}

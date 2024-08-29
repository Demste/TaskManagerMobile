import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:todolist/pages/history_page.dart';

class LogEntry {
  final DateTime timestamp;
  final String message;

  LogEntry({required this.timestamp, required this.message});

  String get formattedTimestamp {
    // Yıl-Ay-Gün Saat:Dakika formatında tarih
    return DateFormat('yyyy-MM-dd HH:mm').format(timestamp);
  }
}

class LogService extends ChangeNotifier {
  final List<LogEntry> _logEntries = [];

  List<LogEntry> get logEntries => _logEntries;

  void addLog(String message) {
    _logEntries.add(LogEntry(timestamp: DateTime.now(), message: message));
    logBadgeCount++;
    notifyListeners();
  }
}

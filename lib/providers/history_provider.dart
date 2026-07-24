import 'package:biopet/models/history.dart';
import 'package:biopet/services/history_service.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HistoryProvider extends ChangeNotifier {
  final HistoryService _historyService;

  HistoryProvider({required HistoryService historyService})
      : _historyService = historyService;

  // STATE
  List<EachClassifying> _historyList = [];
  bool _isLoading = false;
  String? _errorMessage;

  // GETTERS
  List<EachClassifying> get historyList => _historyList;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get historyCount => _historyList.length;
  bool get hasHistory => _historyList.isNotEmpty;

  /// LOAD HISTORY
  Future<void> loadHistory(String userId) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _historyList = await _historyService.getHistory(userId);
    } catch (e) {
      _errorMessage = 'Failed to load history: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// REMOVE SINGLE ENTRY
  Future<void> removeEntry(String userId, EachClassifying entry) async {
    try {
      await _historyService.removeEntry(userId, entry.id);

      _historyList.removeWhere((item) => item.id == entry.id);

      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to remove entry: $e';
      notifyListeners();
    }
  }

  /// CLEAR ALL HISTORY
  Future<void> clearAllHistory(String userId) async {
    try {
      await _historyService.clearHistory(userId);

      _historyList = [];
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to clear history: $e';
      notifyListeners();
    }
  }

  /// FORMAT DATE
  String formatDate(DateTime date) {
    int hour = date.hour;
    String period = 'AM';

    if (hour >= 12) {
      period = 'PM';
      if (hour > 12) hour -= 12;
    } else if (hour == 0) {
      hour = 12;
    }

    String twoDigits(int n) => n.toString().padLeft(2, '0');

    return '${date.month}/${date.day}/${date.year} '
        '${twoDigits(hour)}:${twoDigits(date.minute)} $period';
  }

  /// OPEN WIKIPEDIA
  Future<void> openWikipedia(String keyword) async {
    final url = Uri.parse(
      "https://en.wikipedia.org/wiki/${Uri.encodeComponent(keyword)}",
    );

    try {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (e) {
      _errorMessage = "Failed to open Wikipedia: $e";
      notifyListeners();
    }
  }
}
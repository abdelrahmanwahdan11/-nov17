import 'package:flutter/material.dart';

import '../../core/models/mock_data.dart';
import '../../core/models/mock_repository.dart';

class SchedulerController extends ChangeNotifier {
  SchedulerController({required MockRepository repository}) : _repository = repository;

  final MockRepository _repository;

  DateTime _selectedDate = DateTime.now();
  List<ScheduleEntry> _entries = [];
  bool _loading = true;

  DateTime get selectedDate => _selectedDate;
  List<ScheduleEntry> get entries => List.unmodifiable(_entries);
  bool get isLoading => _loading;

  Future<void> bootstrap() async {
    if (_entries.isNotEmpty) return;
    await refresh();
  }

  Future<void> refresh() async {
    _loading = true;
    notifyListeners();
    _entries = await _repository.fetchSchedule(_selectedDate);
    _loading = false;
    notifyListeners();
  }

  Future<void> selectDate(DateTime date) async {
    _selectedDate = date;
    await refresh();
  }

  Future<void> addEntry({
    required String title,
    required String description,
    required TimeOfDay startTime,
    required Duration duration,
    required String tag,
  }) async {
    final start = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day, startTime.hour, startTime.minute);
    final end = start.add(duration);
    final entry = ScheduleEntry(
      id: 'schedule-${DateTime.now().microsecondsSinceEpoch}',
      title: title,
      description: description,
      start: start,
      end: end,
      tag: tag,
    );
    await _repository.addScheduleEntry(entry);
    await refresh();
  }

  Future<void> remove(String id) async {
    await _repository.removeScheduleEntry(id);
    await refresh();
  }

  List<ScheduleEntry> upcomingPeek({int limit = 3}) => _repository.nextScheduleEntries(limit);
}

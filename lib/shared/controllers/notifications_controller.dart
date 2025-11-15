import 'package:flutter/material.dart';

import '../../core/models/mock_data.dart';
import '../../core/models/mock_repository.dart';

class NotificationsController extends ChangeNotifier {
  NotificationsController({required MockRepository repository}) : _repository = repository;

  final MockRepository _repository;

  List<AppNotification> _items = [];
  bool _loading = true;

  bool get isLoading => _loading;
  bool get isEmpty => _items.isEmpty;
  int get unreadCount => _items.where((notification) => !notification.read).length;

  List<AppNotification> get pinned =>
      _items.where((notification) => notification.pinned).toList(growable: false);

  List<AppNotification> get timeline =>
      _items.where((notification) => !notification.pinned).toList(growable: false);

  Future<void> bootstrap() async {
    if (_items.isNotEmpty) return;
    await refresh();
  }

  Future<void> refresh() async {
    _loading = true;
    notifyListeners();
    final data = await _repository.fetchNotifications();
    _items = data;
    _loading = false;
    notifyListeners();
  }

  Future<void> markAsRead(AppNotification notification, {required bool read}) async {
    final saved = await _repository.saveNotification(notification.copyWith(read: read));
    if (saved != null) {
      _replace(saved);
    }
  }

  Future<void> togglePin(AppNotification notification) async {
    final saved = await _repository.saveNotification(notification.copyWith(pinned: !notification.pinned));
    if (saved != null) {
      _replace(saved);
    }
  }

  Future<void> markAllRead() async {
    _loading = true;
    notifyListeners();
    final data = await _repository.markAllNotificationsRead();
    _items = data;
    _loading = false;
    notifyListeners();
  }

  Future<void> clearAll() async {
    _loading = true;
    notifyListeners();
    await _repository.clearNotifications();
    _items = [];
    _loading = false;
    notifyListeners();
  }

  void _replace(AppNotification notification) {
    final index = _items.indexWhere((element) => element.id == notification.id);
    if (index != -1) {
      _items[index] = notification;
    } else {
      _items.add(notification);
    }
    _items.sort((a, b) {
      if (a.pinned != b.pinned) {
        return a.pinned ? -1 : 1;
      }
      return b.timestamp.compareTo(a.timestamp);
    });
    notifyListeners();
  }
}

import 'package:flutter/material.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/models/mock_data.dart';
import '../../shared/controllers/workspace_scope.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late Future<List<AppNotification>> _future;
  final Set<String> _read = <String>{};
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _future = WorkspaceScope.of(context).repository.fetchNotifications();
      _initialized = true;
    }
  }

  Future<void> _refresh() async {
    final repository = WorkspaceScope.of(context).repository;
    final data = await repository.fetchNotifications();
    if (mounted) {
      setState(() {
        _future = Future.value(data);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<AppNotification>>(
      future: _future,
      builder: (context, snapshot) {
        final notifications = snapshot.data ?? const [];
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (notifications.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Text(
                AppLocalizations.of(context).translate('notifications_empty'),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }
        return RefreshIndicator(
          onRefresh: _refresh,
          child: ListView.builder(
            padding: const EdgeInsets.only(top: kToolbarHeight + 16),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final item = notifications[index];
              final read = _read.contains(item.id);
              return ListTile(
                title: Text(item.title),
                subtitle: Text(item.subtitle),
                trailing: Text(_timeAgo(item.timestamp)),
                leading: Icon(read ? Icons.mark_email_read : Icons.mark_email_unread,
                    color: Theme.of(context).colorScheme.primary),
                onTap: () {
                  setState(() => _read.add(item.id));
                },
              );
            },
          ),
        );
      },
    );
  }

  String _timeAgo(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m';
    }
    if (diff.inHours < 24) {
      return '${diff.inHours}h';
    }
    return '${diff.inDays}d';
  }
}

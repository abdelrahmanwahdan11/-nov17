import 'package:flutter/material.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/models/mock_data.dart';
import '../../core/routing/app_routes.dart';
import '../../shared/controllers/notifications_controller.dart';
import '../../shared/controllers/workspace_scope.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late NotificationsController _controller;
  bool _attached = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_attached) {
      _controller = WorkspaceScope.of(context).notifications;
      _attached = true;
    }
  }

  Future<void> _refresh() => _controller.refresh();

  void _handleTap(AppNotification notification) {
    if (!notification.read) {
      _controller.markAsRead(notification, read: true);
    }
    _openRelatedRoute(notification.relatedRoute);
  }

  void _openRelatedRoute(String? route) {
    if (route == null) return;
    final mapping = {
      'projects': AppRoutes.projects,
      'tasks': AppRoutes.tasks,
      'catalog': AppRoutes.catalog,
      'finance': AppRoutes.finance,
      'dashboard': AppRoutes.dashboard,
    };
    final target = mapping[route];
    if (target != null) {
      Navigator.pushNamed(context, target);
    }
  }

  void _handleMenuSelection(AppNotification notification, _NotificationMenu action) {
    switch (action) {
      case _NotificationMenu.markRead:
        _controller.markAsRead(notification, read: true);
        break;
      case _NotificationMenu.markUnread:
        _controller.markAsRead(notification, read: false);
        break;
      case _NotificationMenu.pin:
        _controller.togglePin(notification);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final isLoading = _controller.isLoading && _controller.isEmpty;
        final pinned = _controller.pinned;
        final recent = _controller.timeline;
        final unreadCount = _controller.unreadCount;

        Widget buildEmpty() {
          return ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(top: kToolbarHeight + 16, left: 24, right: 24),
            children: [
              const SizedBox(height: 120),
              Center(
                child: Text(
                  loc.translate('notifications_empty'),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          );
        }

        if (isLoading) {
          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.only(top: kToolbarHeight + 16),
              children: const [
                SizedBox(height: 220, child: Center(child: CircularProgressIndicator())),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: _refresh,
          child: _controller.isEmpty
              ? buildEmpty()
              : ListView(
                  padding: const EdgeInsets.fromLTRB(24, kToolbarHeight + 16, 24, 24),
                  children: [
                    _NotificationActions(
                      onMarkAllRead: unreadCount > 0
                          ? () {
                              _controller.markAllRead();
                            }
                          : null,
                      onClearAll: () {
                        _controller.clearAll();
                      },
                    ),
                    if (pinned.isNotEmpty) ...[
                      _SectionTitle(title: loc.translate('notifications_section_pinned')),
                      ...pinned.map((item) => _NotificationCard(
                            notification: item,
                            onTap: () => _handleTap(item),
                            onActionSelected: (action) => _handleMenuSelection(item, action),
                          )),
                      const SizedBox(height: 16),
                    ],
                    if (recent.isNotEmpty) ...[
                      _SectionTitle(title: loc.translate('notifications_section_recent')),
                      ...recent.map((item) => _NotificationCard(
                            notification: item,
                            onTap: () => _handleTap(item),
                            onActionSelected: (action) => _handleMenuSelection(item, action),
                          )),
                    ],
                  ],
                ),
        );
      },
    );
  }
}

enum _NotificationMenu { markRead, markUnread, pin }

class _NotificationActions extends StatelessWidget {
  const _NotificationActions({
    required this.onMarkAllRead,
    required this.onClearAll,
  });

  final VoidCallback? onMarkAllRead;
  final VoidCallback? onClearAll;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Wrap(
        spacing: 12,
        runSpacing: 8,
        children: [
          TextButton.icon(
            onPressed: onMarkAllRead,
            icon: const Icon(Icons.done_all_rounded),
            label: Text(loc.translate('notifications_mark_all_read')),
          ),
          TextButton.icon(
            onPressed: onClearAll,
            icon: const Icon(Icons.clear_all_rounded),
            label: Text(loc.translate('notifications_clear_all')),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium,
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({
    required this.notification,
    required this.onTap,
    required this.onActionSelected,
  });

  final AppNotification notification;
  final VoidCallback onTap;
  final ValueChanged<_NotificationMenu> onActionSelected;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final read = notification.read;
    final pinned = notification.pinned;
    final menuItems = <PopupMenuEntry<_NotificationMenu>>[
      if (!read)
        PopupMenuItem(
          value: _NotificationMenu.markRead,
          child: Text(loc.translate('notifications_mark_read')),
        ),
      if (read)
        PopupMenuItem(
          value: _NotificationMenu.markUnread,
          child: Text(loc.translate('notifications_mark_unread')),
        ),
      PopupMenuItem(
        value: _NotificationMenu.pin,
        child: Text(pinned
            ? loc.translate('notifications_unpin')
            : loc.translate('notifications_pin')),
      ),
    ];

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: read
              ? Theme.of(context).colorScheme.outlineVariant
              : Theme.of(context).colorScheme.primary.withOpacity(0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  pinned ? Icons.push_pin : (read ? Icons.drafts : Icons.markunread),
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              notification.title,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: read ? FontWeight.w500 : FontWeight.w700,
                                  ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _timeAgo(notification.timestamp),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          PopupMenuButton<_NotificationMenu>(
                            onSelected: onActionSelected,
                            itemBuilder: (context) => menuItems,
                            icon: const Icon(Icons.more_horiz_rounded),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        notification.subtitle,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
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

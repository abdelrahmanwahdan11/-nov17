import 'package:flutter/material.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/models/mock_data.dart';
import '../../core/models/tracked_session.dart';
import '../../shared/controllers/app_controller.dart';
import '../../shared/controllers/workspace_scope.dart';

class TimeTrackerScreen extends StatefulWidget {
  const TimeTrackerScreen({super.key});

  @override
  State<TimeTrackerScreen> createState() => _TimeTrackerScreenState();
}

class _TimeTrackerScreenState extends State<TimeTrackerScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _running = false;
  Duration _elapsed = Duration.zero;
  String? _selectedTaskId;
  List<Task> _tasks = const [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 1))
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed && _running) {
          setState(() => _elapsed += const Duration(seconds: 1));
          _controller.forward(from: 0);
        }
      });
  }

  @override
  void didChangeDependencies() {
    final scope = WorkspaceScope.of(context);
    _tasks = scope.repository.allTasks();
    _selectedTaskId ??= scope.app.lastTrackedTaskId;
    if (_selectedTaskId == null && _tasks.isNotEmpty) {
      _selectedTaskId = _tasks.first.id;
    }
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _start() {
    if (_running) return;
    setState(() {
      _running = true;
      _controller.forward(from: 0);
    });
  }

  void _pause() {
    if (!_running) return;
    setState(() {
      _running = false;
      _controller.stop();
    });
  }

  Future<void> _reset(AppController app) async {
    setState(() {
      _running = false;
      _controller.stop();
      _controller.reset();
      _elapsed = Duration.zero;
    });
    await app.updateLastTrackedDuration(Duration.zero);
  }

  Future<void> _stop(AppController app) async {
    final sessionDuration = _elapsed;
    setState(() {
      _running = false;
      _controller.stop();
      _controller.reset();
    });
    await app.updateLastTrackedDuration(sessionDuration);
    final selectedTask = _tasks.where((task) => task.id == _selectedTaskId).firstOrNull;
    if (_selectedTaskId != null) {
      await app.updateLastTrackedTask(_selectedTaskId);
    }
    await app.recordTrackedSession(
      TrackedSession(
        id: 'session-${DateTime.now().microsecondsSinceEpoch}',
        taskId: _selectedTaskId,
        taskTitle: selectedTask?.title,
        duration: sessionDuration,
        timestamp: DateTime.now(),
      ),
    );
    if (mounted) {
      setState(() => _elapsed = Duration.zero);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).translate('time_tracker_logged'))),
      );
    }
  }

  String _formatDuration(Duration duration) {
    if (duration.inSeconds == 0) {
      return '0m';
    }
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    if (hours > 0) {
      return '${hours}h ${minutes.toString().padLeft(2, '0')}m';
    }
    if (minutes > 0) {
      return '${minutes}m ${seconds.toString().padLeft(2, '0')}s';
    }
    return '${seconds}s';
  }

  String _formatTimestamp(DateTime timestamp, MaterialLocalizations materialLoc) {
    final date = materialLoc.formatShortDate(timestamp);
    final time = materialLoc.formatTimeOfDay(TimeOfDay.fromDateTime(timestamp));
    return '$date · $time';
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final scope = WorkspaceScope.of(context);
    final app = scope.app;
    final theme = Theme.of(context);
    final selectedTask = _tasks.where((task) => task.id == _selectedTaskId).firstOrNull;

    return Scaffold(
      appBar: AppBar(title: Text(loc.translate('time_tracker_title'))),
      body: AnimatedBuilder(
        animation: app,
        builder: (context, _) {
          final materialLoc = MaterialLocalizations.of(context);
          final history = app.trackedSessions;
          final weeklyTotal = app.weeklyTrackedDuration;
          final totalTracked = app.totalTrackedDuration;
          final topTask = app.topTrackedTaskTitle;
          final lastSession = app.lastTrackedSession;
          final lastTimestampLabel = lastSession == null
              ? loc.translate('time_tracker_last_session_empty')
              : loc.translate(
                  'time_tracker_last_session_time',
                  params: {'time': _formatTimestamp(lastSession.timestamp, materialLoc)},
                );
          final lastDurationLabel = lastSession == null
              ? '--'
              : _formatDuration(app.lastTrackedDuration);

          final weeklyLabel = _formatDuration(weeklyTotal);
          final totalLabel = _formatDuration(totalTracked);
          final topTaskLabel = topTask == null
              ? loc.translate('time_tracker_top_task_empty')
              : loc.translate('time_tracker_top_task', params: {'task': topTask});

          return ListView(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
            children: [
              Text(loc.translate('time_tracker_subtitle'), style: theme.textTheme.titleMedium),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedTaskId,
                items: _tasks
                    .map(
                      (task) => DropdownMenuItem<String>(
                        value: task.id,
                        child: Text(task.title),
                      ),
                    )
                    .toList(),
                decoration: InputDecoration(labelText: loc.translate('time_tracker_task_label')),
                onChanged: (value) {
                  setState(() => _selectedTaskId = value);
                  if (value != null) {
                    app.updateLastTrackedTask(value);
                  }
                },
              ),
              const SizedBox(height: 32),
              SizedBox(
                height: 260,
                child: Center(
                  child: AnimatedBuilder(
                    animation: _controller,
                    builder: (context, _) {
                      final progress = _running ? _controller.value : (_elapsed.inSeconds % 60) / 60;
                      final displayDuration = _running
                          ? _elapsed + Duration(milliseconds: (_controller.value * 1000).round())
                          : _elapsed;
                      return Container(
                        width: 260,
                        height: 260,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              theme.colorScheme.surface,
                              theme.colorScheme.primary.withOpacity(0.18),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(200),
                          boxShadow: [
                            BoxShadow(
                              color: theme.colorScheme.primary.withOpacity(0.12),
                              blurRadius: 24,
                              offset: const Offset(0, 16),
                            ),
                          ],
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 220,
                              height: 220,
                              child: CircularProgressIndicator(
                                value: progress,
                                strokeWidth: 12,
                              ),
                            ),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(_formatDuration(displayDuration), style: theme.textTheme.displaySmall),
                                const SizedBox(height: 8),
                                Text(
                                  selectedTask?.title ?? loc.translate('time_tracker_no_task'),
                                  style: theme.textTheme.bodyMedium,
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(loc.translate('time_tracker_last_session'), style: theme.textTheme.labelLarge),
                          const SizedBox(height: 4),
                          Text(lastDurationLabel, style: theme.textTheme.titleMedium),
                          const SizedBox(height: 4),
                          Text(lastTimestampLabel, style: theme.textTheme.bodySmall),
                        ],
                      ),
                    ),
                    FilledButton.tonal(
                      onPressed: _running ? null : () => _reset(app),
                      child: Text(loc.translate('time_tracker_reset')),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: [
                  FilledButton.icon(
                    onPressed: _running ? null : _start,
                    icon: const Icon(Icons.play_arrow_rounded),
                    label: Text(loc.translate('time_tracker_start')),
                  ),
                  FilledButton.icon(
                    onPressed: _running ? _pause : null,
                    icon: const Icon(Icons.pause_rounded),
                    label: Text(loc.translate('time_tracker_pause')),
                  ),
                  OutlinedButton.icon(
                    onPressed: _elapsed.inSeconds > 0 ? () => _stop(app) : null,
                    icon: const Icon(Icons.stop_circle_outlined),
                    label: Text(loc.translate('time_tracker_stop')),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(loc.translate('time_tracker_summary_title'), style: theme.textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Text(
                      loc.translate('time_tracker_weekly_total', params: {'duration': weeklyLabel}),
                      style: theme.textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      loc.translate('time_tracker_total', params: {'duration': totalLabel}),
                      style: theme.textTheme.bodySmall,
                    ),
                    const SizedBox(height: 12),
                    Text(topTaskLabel, style: theme.textTheme.bodySmall),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      loc.translate('time_tracker_history'),
                      style: theme.textTheme.titleMedium,
                    ),
                  ),
                  if (history.isNotEmpty)
                    TextButton.icon(
                      onPressed: () async {
                        await app.clearTrackedSessions();
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(loc.translate('time_tracker_history_cleared'))),
                          );
                        }
                      },
                      icon: const Icon(Icons.delete_outline),
                      label: Text(loc.translate('time_tracker_clear_history')),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: history.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: Text(
                          loc.translate('time_tracker_history_empty'),
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium,
                        ),
                      )
                    : Column(
                        children: history
                            .map(
                              (session) => _HistoryTile(
                                key: ValueKey(session.id),
                                title: session.taskTitle ?? loc.translate('time_tracker_no_task'),
                                timestampLabel: loc.translate(
                                  'time_tracker_session_at',
                                  params: {'time': _formatTimestamp(session.timestamp, materialLoc)},
                                ),
                                durationLabel: _formatDuration(session.duration),
                              ),
                            )
                            .toList(),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  const _HistoryTile({super.key, required this.title, required this.timestampLabel, required this.durationLabel});

  final String title;
  final String timestampLabel;
  final String durationLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: theme.colorScheme.primary.withOpacity(0.18),
            ),
            child: const Icon(Icons.timer_outlined),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(timestampLabel, style: theme.textTheme.bodySmall),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(durationLabel, style: theme.textTheme.titleMedium),
        ],
      ),
    );
  }
}

extension<E> on Iterable<E> {
  E? get firstOrNull => isEmpty ? null : first;
}

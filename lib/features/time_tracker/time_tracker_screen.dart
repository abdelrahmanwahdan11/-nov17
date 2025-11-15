import 'package:flutter/material.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/models/mock_data.dart';
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
  Duration _lastSaved = Duration.zero;
  String? _selectedTaskId;
  List<Task> _tasks = const [];
  AppController? _app;

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
    if (_app != scope.app) {
      _app = scope.app;
      _lastSaved = scope.app.lastTrackedDuration;
      _selectedTaskId = scope.app.lastTrackedTaskId;
    }
    _tasks = scope.repository.allTasks();
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

  void _reset(AppController app) {
    setState(() {
      _running = false;
      _controller.stop();
      _controller.reset();
      _elapsed = Duration.zero;
      _lastSaved = Duration.zero;
    });
    app.updateLastTrackedDuration(_elapsed);
  }

  Future<void> _stop(AppController app) async {
    final session = _elapsed;
    setState(() {
      _running = false;
      _controller.stop();
      _controller.reset();
    });
    await app.updateLastTrackedDuration(session);
    if (_selectedTaskId != null) {
      await app.updateLastTrackedTask(_selectedTaskId);
    }
    if (mounted) {
      setState(() {
        _elapsed = Duration.zero;
        _lastSaved = session;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).translate('time_tracker_logged'))),
      );
    }
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    final buffer = StringBuffer();
    if (hours > 0) {
      buffer.write(hours.toString().padLeft(2, '0'));
      buffer.write('h ');
    }
    buffer.write(minutes.toString().padLeft(2, '0'));
    buffer.write('m ');
    buffer.write(seconds.toString().padLeft(2, '0'));
    buffer.write('s');
    return buffer.toString();
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
      body: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
            Expanded(
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
                        Text(_formatDuration(_lastSaved), style: theme.textTheme.titleMedium),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
          ],
        ),
      ),
    );
  }
}

extension<E> on Iterable<E> {
  E? get firstOrNull => isEmpty ? null : first;
}

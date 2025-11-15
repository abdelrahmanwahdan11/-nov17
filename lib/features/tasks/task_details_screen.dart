import 'dart:math';

import 'package:flutter/material.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/models/mock_data.dart';
import '../../shared/controllers/tasks_controller.dart';
import '../../shared/controllers/workspace_scope.dart';
import '../../shared/widgets/ai_info_button.dart';

class TaskDetailsScreen extends StatefulWidget {
  const TaskDetailsScreen({super.key, required this.task});

  final Task? task;

  @override
  State<TaskDetailsScreen> createState() => _TaskDetailsScreenState();
}

class _TaskDetailsScreenState extends State<TaskDetailsScreen> {
  bool _flipped = false;

  Task _resolveTask(TasksController controller, WorkspaceScope scope) {
    final initial = widget.task;
    if (initial != null) {
      return controller.findById(initial.id) ?? initial;
    }
    if (controller.tasks.isNotEmpty) {
      return controller.tasks.first;
    }
    final today = scope.repository.tasksForDate(DateTime.now());
    if (today.isNotEmpty) {
      return today.first;
    }
    final all = scope.repository.allTasks();
    return all.isNotEmpty
        ? all.first
        : Task(
            id: 'fallback-task',
            title: 'Task',
            priority: 'Medium',
            status: 'Upcoming',
            dueDate: DateTime.now(),
            hours: 1,
            description: '',
            category: 'General',
          );
  }

  String _localizedStatus(AppLocalizations loc, String status) {
    switch (status.toLowerCase()) {
      case 'in progress':
        return loc.translate('status_in_progress');
      case 'upcoming':
        return loc.translate('status_upcoming');
      case 'done':
        return loc.translate('status_done');
      default:
        return status;
    }
  }

  String _localizedPriority(AppLocalizations loc, String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return loc.translate('priority_high');
      case 'medium':
        return loc.translate('priority_medium');
      case 'low':
        return loc.translate('priority_low');
      default:
        return priority;
    }
  }

  Future<void> _toggleOverlay(Task task, AppLocalizations loc) async {
    await showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      transitionDuration: const Duration(milliseconds: 300),
      barrierLabel: 'overlay',
      pageBuilder: (_, __, ___) => const SizedBox.shrink(),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(
          scale: CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
          child: _FlipCard(
            flipped: _flipped,
            onFlip: () => setState(() => _flipped = !_flipped),
            front: loc.translate('task_overlay_front'),
            back: task.description,
          ),
        );
      },
    );
  }

  Future<void> _toggleCompletion(TasksController controller, Task task, AppLocalizations loc) async {
    await controller.toggleCompletion(task);
    if (!mounted) return;
    final updated = controller.findById(task.id) ?? task;
    final isDone = updated.status.toLowerCase() == 'done';
    final message = isDone ? loc.translate('task_details_marked_done') : loc.translate('task_details_marked_active');
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final scope = WorkspaceScope.of(context);
    final controller = scope.tasks;

    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final task = _resolveTask(controller, scope);
        final loc = AppLocalizations.of(context);
        final materialLoc = MaterialLocalizations.of(context);
        final isDone = task.status.toLowerCase() == 'done';
        final dueDate = materialLoc.formatFullDate(task.dueDate);

        return Scaffold(
          appBar: AppBar(title: Text(task.title)),
          floatingActionButton: const AiInfoButton(),
          body: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 12,
                  children: [
                    Chip(label: Text(_localizedStatus(loc, task.status))),
                    Chip(label: Text(_localizedPriority(loc, task.priority))),
                    Chip(label: Text(task.category)),
                  ],
                ),
                const SizedBox(height: 16),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(loc.translate('task_details_schedule')),
                  subtitle: Text(loc.translate('task_due_date', params: {'date': dueDate})),
                  trailing: Text('${task.hours.toStringAsFixed(1)}h'),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView(
                    children: [
                      Text(loc.translate('task_details_description'), style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 12),
                      Text(task.description),
                      const SizedBox(height: 24),
                      Text(loc.translate('task_details_hours'), style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 12),
                      Text('${task.hours.toStringAsFixed(1)}h'),
                      const SizedBox(height: 24),
                      GestureDetector(
                        onTap: () => _toggleOverlay(task, loc),
                        child: Hero(
                          tag: 'task_image_${task.id}',
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(32),
                            child: Image.network(
                              'https://images.unsplash.com/photo-1523475472560-d2df97ec485c?auto=format&fit=crop&w=900&q=80',
                              height: 220,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () => _toggleCompletion(controller, task, loc),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: Text(
                      isDone ? loc.translate('task_details_mark_active') : loc.translate('task_details_mark_done'),
                      key: ValueKey(isDone),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _FlipCard extends StatelessWidget {
  const _FlipCard({required this.flipped, required this.onFlip, required this.front, required this.back});

  final bool flipped;
  final VoidCallback onFlip;
  final String front;
  final String back;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: onFlip,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, animation) {
            final rotate = Tween(begin: pi, end: 0.0).animate(animation);
            return AnimatedBuilder(
              animation: rotate,
              child: child,
              builder: (context, child) {
                final isUnder = (ValueKey(flipped) != child?.key);
                var tilt = ((animation.value - 0.5).abs() - 0.5) * 0.003;
                tilt *= isUnder ? -1.0 : 1.0;
                final value = isUnder ? min(rotate.value, pi / 2) : rotate.value;
                return Transform(
                  transform: Matrix4.rotationY(value)..setEntry(3, 0, tilt),
                  alignment: Alignment.center,
                  child: child,
                );
              },
            );
          },
          child: flipped
              ? Container(
                  key: const ValueKey('back'),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(32),
                  ),
                  child: Text(back),
                )
              : Container(
                  key: const ValueKey('front'),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(32),
                  ),
                  child: Text(front),
                ),
        ),
      ),
    );
  }
}

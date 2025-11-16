import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/models/mock_data.dart';
import '../../shared/controllers/scheduler_controller.dart';
import '../../shared/controllers/workspace_scope.dart';
import '../../shared/skeletons/skeleton_widgets.dart';

class SchedulerScreen extends StatefulWidget {
  const SchedulerScreen({super.key});

  @override
  State<SchedulerScreen> createState() => _SchedulerScreenState();
}

class _SchedulerScreenState extends State<SchedulerScreen> {
  SchedulerController? _controller;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final List<String> _tags = ['Focus', 'Team', 'Client', 'Deep Work'];
  TimeOfDay _selectedTime = const TimeOfDay(hour: 9, minute: 0);
  Duration _selectedDuration = const Duration(hours: 1);
  String _selectedTag = 'Focus';

  SchedulerController get controller => _controller ??= WorkspaceScope.of(context).scheduler;

  @override
  void didChangeDependencies() {
    final scope = WorkspaceScope.of(context);
    if (_controller != scope.scheduler) {
      _controller = scope.scheduler;
    }
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  List<DateTime> _weekdays(DateTime anchor) {
    final start = DateTime(anchor.year, anchor.month, anchor.day);
    return List.generate(7, (index) => start.add(Duration(days: index)));
  }

  Future<void> _openComposer() async {
    final loc = AppLocalizations.of(context);
    _titleController.clear();
    _descriptionController.clear();
    _selectedTime = const TimeOfDay(hour: 9, minute: 0);
    _selectedDuration = const Duration(hours: 1);
    _selectedTag = 'Focus';

    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: StatefulBuilder(
            builder: (context, setSheetState) {
              return AnimatedPadding(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(loc.translate('scheduler_new_block'), style: Theme.of(context).textTheme.titleMedium),
                        const Spacer(),
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        labelText: loc.translate('scheduler_title_field'),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _descriptionController,
                      decoration: InputDecoration(
                        labelText: loc.translate('scheduler_description_field'),
                      ),
                      minLines: 2,
                      maxLines: 4,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        FilledButton.tonal(
                          onPressed: () async {
                            final picked = await showTimePicker(context: context, initialTime: _selectedTime);
                            if (picked != null) {
                              setSheetState(() => _selectedTime = picked);
                            }
                          },
                          child: Text(loc.translate('scheduler_pick_time')),
                        ),
                        const SizedBox(width: 12),
                        DropdownButton<Duration>(
                          value: _selectedDuration,
                          items: const [
                            Duration(minutes: 30),
                            Duration(minutes: 45),
                            Duration(hours: 1),
                            Duration(hours: 1, minutes: 30),
                            Duration(hours: 2),
                          ]
                              .map(
                                (duration) => DropdownMenuItem<Duration>(
                                  value: duration,
                                  child: Text(loc.translate('scheduler_duration_option', params: {
                                    'minutes': duration.inMinutes.toString(),
                                  })),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setSheetState(() => _selectedDuration = value);
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 12,
                      children: _tags
                          .map(
                            (tag) => ChoiceChip(
                              label: Text(loc.translate('scheduler_tag_${tag.toLowerCase().replaceAll(' ', '_')}')),
                              selected: _selectedTag == tag,
                              onSelected: (_) => setSheetState(() => _selectedTag = tag),
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () {
                          if (_titleController.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(loc.translate('scheduler_validation_title'))),
                            );
                            return;
                          }
                          Navigator.of(context).pop(true);
                        },
                        child: Text(loc.translate('scheduler_save')),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              );
            },
          ),
        );
      },
    );

    if (result == true) {
      await controller.addEntry(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        startTime: _selectedTime,
        duration: _selectedDuration,
        tag: _selectedTag,
      );
      if (!mounted) return;
      final loc2 = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc2.translate('scheduler_created_success'))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final materialLoc = MaterialLocalizations.of(context);
    final week = _weekdays(controller.selectedDate);

    return Scaffold(
      appBar: AppBar(title: Text(loc.translate('scheduler_title'))),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openComposer,
        icon: const Icon(IconlyBold.add_user),
        label: Text(loc.translate('scheduler_add_block')),
      ),
      body: RefreshIndicator(
        onRefresh: controller.refresh,
        child: AnimatedBuilder(
          animation: controller,
          builder: (context, _) {
            final entries = controller.entries;
            final isLoading = controller.isLoading;
            return ListView(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 120),
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                Text(loc.translate('scheduler_subtitle'), style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 16),
                SizedBox(
                  height: 48,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      final day = week[index];
                      final selected = controller.selectedDate.year == day.year &&
                          controller.selectedDate.month == day.month &&
                          controller.selectedDate.day == day.day;
                      final label = materialLoc.formatMediumDate(day);
                      return ChoiceChip(
                        label: Text(label),
                        selected: selected,
                        onSelected: (_) => controller.selectDate(day),
                      );
                    },
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemCount: week.length,
                  ),
                ),
                const SizedBox(height: 24),
                AnimatedCrossFade(
                  duration: const Duration(milliseconds: 250),
                  firstChild: const _SchedulerSkeleton(),
                  secondChild: entries.isEmpty
                      ? _EmptySchedule(message: loc.translate('scheduler_empty'))
                      : Column(
                          children: entries
                              .map(
                                (entry) => _ScheduleCard(
                                  entry: entry,
                                  materialLoc: materialLoc,
                                  onDelete: () async {
                                    await controller.remove(entry.id);
                                    if (!mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(loc.translate('scheduler_removed'))),
                                    );
                                  },
                                ),
                              )
                              .toList(),
                        ),
                  crossFadeState: isLoading ? CrossFadeState.showFirst : CrossFadeState.showSecond,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SchedulerSkeleton extends StatelessWidget {
  const _SchedulerSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        3,
        (index) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: SkeletonContainer(height: 120, borderRadius: 28),
        ),
      ),
    );
  }
}

class _EmptySchedule extends StatelessWidget {
  const _EmptySchedule({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        children: [
          const Icon(Icons.bubble_chart, size: 48),
          const SizedBox(height: 12),
          Text(message, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _ScheduleCard extends StatelessWidget {
  const _ScheduleCard({required this.entry, required this.materialLoc, required this.onDelete});

  final ScheduleEntry entry;
  final MaterialLocalizations materialLoc;
  final VoidCallback onDelete;

  String get _timeRange {
    final start = TimeOfDay.fromDateTime(entry.start);
    final end = TimeOfDay.fromDateTime(entry.end);
    return '${materialLoc.formatTimeOfDay(start)} – ${materialLoc.formatTimeOfDay(end)}';
  }

  @override
  Widget build(BuildContext context) {
    final durationHours = entry.duration.inMinutes / 60;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.18), width: 1.2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(IconlyBold.time_circle, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 12),
                Text(_timeRange, style: Theme.of(context).textTheme.titleMedium),
                const Spacer(),
                IconButton(onPressed: onDelete, icon: const Icon(Icons.delete_outline)),
              ],
            ),
            const SizedBox(height: 12),
            Text(entry.title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(entry.description, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              children: [
                Chip(label: Text(entry.tag)),
                Chip(label: Text('${durationHours.toStringAsFixed(durationHours.truncateToDouble() == durationHours ? 0 : 1)}h')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

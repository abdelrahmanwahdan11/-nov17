import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/models/mock_data.dart';
import '../../core/routing/app_routes.dart';
import '../../shared/controllers/tasks_controller.dart';
import '../../shared/controllers/workspace_scope.dart';
import '../../shared/widgets/app_header.dart';
import '../../shared/widgets/ai_info_button.dart';
import '../../shared/skeletons/skeleton_widgets.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  TasksController? _controller;
  Timer? _debounce;

  TasksController get controller => _controller ??= WorkspaceScope.of(context).tasks;

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    final scope = WorkspaceScope.of(context);
    if (_controller != scope.tasks) {
      _controller = scope.tasks;
      _searchController.text = controller.query;
    }
    super.didChangeDependencies();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 320), () {
      controller.updateQuery(value.toLowerCase());
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final statuses = [
      ('All', loc.translate('filter_all')),
      ('In Progress', loc.translate('status_in_progress')),
      ('Upcoming', loc.translate('status_upcoming')),
      ('Done', loc.translate('status_done')),
    ];

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openCreateTask,
        icon: const Icon(Icons.add),
        label: Text(loc.translate('tasks_add_button')),
      ),
      body: RefreshIndicator(
        onRefresh: controller.refresh,
        child: AnimatedBuilder(
          animation: controller,
          builder: (context, _) {
            final tasks = controller.tasks;
            final isLoading = controller.isLoading && tasks.isEmpty;

          return ListView(
            padding: EdgeInsets.zero,
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              const SizedBox(height: kToolbarHeight + 16),
              AppHeader(
                title: loc.translate('tasks'),
                subtitle: controller.view == TaskView.today
                    ? loc.translate('tasks_today')
                    : loc.translate('tasks_calendar'),
                onSearch: () {
                  _searchFocusNode.requestFocus();
                },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ToggleButtons(
                      isSelected: TaskView.values.map((view) => view == controller.view).toList(),
                      onPressed: (index) => controller.selectView(TaskView.values[index]),
                      borderRadius: BorderRadius.circular(18),
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(loc.translate('tasks_today')),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(loc.translate('tasks_calendar')),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            focusNode: _searchFocusNode,
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.search),
                              hintText: loc.translate('search_tasks_hint'),
                            ),
                            onSubmitted: (value) => controller.updateQuery(value.toLowerCase()),
                            onChanged: _onSearchChanged,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      children: statuses
                          .map(
                            (entry) => FilterChip(
                              label: Text(entry.$2),
                              selected: controller.statusFilter == entry.$1,
                              onSelected: (_) => controller.updateStatus(entry.$1),
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: 16),
                    _TaskStatsRow(controller: controller),
                    if (controller.view == TaskView.calendar) ...[
                      const SizedBox(height: 16),
                      _DaySelector(controller: controller),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: isLoading
                    ? const _TaskSkeletonList()
                    : Column(
                        children: [
                          ...tasks.map((task) {
                            final selected = controller.isCompared(task);
                            return GestureDetector(
                              onLongPress: () => controller.toggleCompare(task),
                              onTap: () => Navigator.of(context).pushNamed(AppRoutes.taskDetails, arguments: task),
                              child: AnimatedContainer(
                                key: ValueKey(task.id),
                                duration: const Duration(milliseconds: 250),
                                margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(28),
                                  gradient: LinearGradient(
                                    colors: [
                                      Theme.of(context).colorScheme.primary.withOpacity(0.25),
                                      Theme.of(context).colorScheme.surface,
                                    ],
                                  ),
                                  border: Border.all(
                                    color: selected
                                        ? Theme.of(context).colorScheme.primary.withOpacity(0.6)
                                        : Colors.transparent,
                                    width: 2,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(task.priority),
                                        const Spacer(),
                                        AiInfoButton(key: ValueKey(task.id)),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Text(task.title, style: Theme.of(context).textTheme.titleLarge),
                                    const SizedBox(height: 12),
                                    Text('${task.hours.toStringAsFixed(1)}h • ${task.status}'),
                                  ],
                                ),
                              ),
                            );
                          }),
                          if (controller.view == TaskView.today && controller.hasMore)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: controller.isLoadingMore
                                  ? const CircularProgressIndicator()
                                  : TextButton(
                                      onPressed: controller.loadMore,
                                      child: Text(loc.translate('load_more')),
                                    ),
                            ),
                          if (controller.compareCount > 0)
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: FilledButton(
                          onPressed: () => Navigator.pushNamed(context, AppRoutes.compare),
                          child: Text(
                            loc.translate('compare_selected', params: {'count': controller.compareCount.toString()}),
                          ),
                        ),
                      ),
                    const SizedBox(height: 120),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _openCreateTask() async {
    final loc = AppLocalizations.of(context);
    final created = await showModalBottomSheet<Task?>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: _TaskComposerSheet(controller: controller),
        );
      },
    );
    if (created != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.translate('tasks_created_success'))),
      );
    }
  }
}

class _TaskSkeletonList extends StatelessWidget {
  const _TaskSkeletonList();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(3, (index) => const SkeletonContainer(height: 140)),
    );
  }
}

class _TaskStatsRow extends StatelessWidget {
  const _TaskStatsRow({required this.controller});

  final TasksController controller;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final total = controller.totalTasks;
    final hours = controller.totalHours;
    final average = total == 0 ? 0 : (hours / total);
    return Row(
      children: [
        Expanded(
          child: _StatChip(label: loc.translate('tasks_total'), value: total.toString()),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatChip(label: loc.translate('tasks_hours'), value: '${hours.toStringAsFixed(1)}h'),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatChip(label: loc.translate('tasks_average'), value: '${average.toStringAsFixed(1)}h'),
        ),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 4),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _DaySelector extends StatelessWidget {
  const _DaySelector({required this.controller});

  final TasksController controller;

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final days = List.generate(7, (index) => today.add(Duration(days: index)));
    final localizations = MaterialLocalizations.of(context);
    return SizedBox(
      height: 72,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: days.length,
        itemBuilder: (context, index) {
          final day = days[index];
          final selected = controller.selectedDate.year == day.year &&
              controller.selectedDate.month == day.month &&
              controller.selectedDate.day == day.day;
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () => controller.selectDate(day),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: 64,
                decoration: BoxDecoration(
                  color: selected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('${day.day}', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: selected ? Colors.black : null)),
                    const SizedBox(height: 4),
                    Text(localizations.narrowWeekdays[(day.weekday % 7)],
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: selected ? Colors.black : null)),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _TaskComposerSheet extends StatefulWidget {
  const _TaskComposerSheet({required this.controller});

  final TasksController controller;

  @override
  State<_TaskComposerSheet> createState() => _TaskComposerSheetState();
}

class _TaskComposerSheetState extends State<_TaskComposerSheet> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  DateTime? _dueDate;
  String _priority = 'High';
  String _status = 'Upcoming';
  double _hours = 2;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _dueDate = DateTime.now().add(const Duration(days: 1));
  }

  @override
  void dispose() {
    _titleController.dispose();
    _categoryController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final statuses = [
      ('Upcoming', loc.translate('status_upcoming')),
      ('In Progress', loc.translate('status_in_progress')),
      ('Done', loc.translate('status_done')),
    ];
    return AnimatedSize(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        loc.translate('tasks_create_title'),
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(labelText: loc.translate('tasks_field_title')),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return loc.translate('required_field');
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _categoryController,
                  decoration: InputDecoration(labelText: loc.translate('tasks_field_category')),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return loc.translate('required_field');
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 3,
                  decoration: InputDecoration(labelText: loc.translate('tasks_field_description')),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return loc.translate('required_field');
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Text(loc.translate('tasks_field_priority'), style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 12,
                  children: ['High', 'Medium', 'Low']
                      .map(
                        (priority) => ChoiceChip(
                          label: Text(loc.translate('priority_${priority.toLowerCase()}')),
                          selected: _priority == priority,
                          onSelected: (_) => setState(() => _priority = priority),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 16),
                Text(loc.translate('tasks_field_status'), style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 12,
                  children: statuses
                      .map(
                        (entry) => ChoiceChip(
                          label: Text(entry.$2),
                          selected: _status == entry.$1,
                          onSelected: (_) => setState(() => _status = entry.$1),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 16),
                _TaskDuePicker(
                  label: loc.translate('tasks_field_due_date'),
                  initialDate: _dueDate,
                  onChanged: (value) => setState(() => _dueDate = value),
                ),
                const SizedBox(height: 16),
                Text(loc.translate('tasks_field_hours'), style: Theme.of(context).textTheme.bodySmall),
                Slider(
                  value: _hours,
                  min: 0.5,
                  max: 12,
                  divisions: 23,
                  label: '${_hours.toStringAsFixed(1)}h',
                  onChanged: (value) => setState(() => _hours = value),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text('${_hours.toStringAsFixed(1)}h'),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _saving ? null : _submit,
                    child: _saving
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(loc.translate('tasks_create_action')),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    final loc = AppLocalizations.of(context);
    if (_saving) return;
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_dueDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.translate('tasks_validation_due'))),
      );
      return;
    }
    setState(() => _saving = true);
    final task = await widget.controller.createTask(
      title: _titleController.text.trim(),
      priority: _priority,
      status: _status,
      dueDate: _dueDate!,
      hours: double.parse(_hours.toStringAsFixed(1)),
      description: _descriptionController.text.trim(),
      category: _categoryController.text.trim(),
    );
    if (!mounted) return;
    Navigator.of(context).pop(task);
  }
}

class _TaskDuePicker extends StatelessWidget {
  const _TaskDuePicker({required this.label, required this.initialDate, required this.onChanged});

  final String label;
  final DateTime? initialDate;
  final ValueChanged<DateTime?> onChanged;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final materialLoc = MaterialLocalizations.of(context);
    return InkWell(
      onTap: () async {
        final now = DateTime.now();
        final selected = await showDatePicker(
          context: context,
          initialDate: initialDate ?? now,
          firstDate: now.subtract(const Duration(days: 365)),
          lastDate: now.add(const Duration(days: 365 * 3)),
        );
        onChanged(selected);
      },
      child: InputDecorator(
        decoration: InputDecoration(labelText: label),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, size: 18),
            const SizedBox(width: 12),
            Text(
              initialDate == null
                  ? loc.translate('tasks_due_placeholder')
                  : materialLoc.formatMediumDate(initialDate!),
            ),
          ],
        ),
      ),
    );
  }
}

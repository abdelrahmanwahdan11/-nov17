import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/models/mock_data.dart';
import '../../core/routing/app_routes.dart';
import '../../shared/controllers/projects_controller.dart';
import '../../shared/controllers/workspace_scope.dart';
import '../../shared/widgets/app_header.dart';
import '../../shared/widgets/ai_info_button.dart';
import '../../shared/skeletons/skeleton_widgets.dart';

class ProjectsScreen extends StatefulWidget {
  const ProjectsScreen({super.key});

  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  ProjectsController? _controller;
  Timer? _debounce;

  ProjectsController get controller => _controller ??= WorkspaceScope.of(context).projects;

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 320), () {
      controller.updateQuery(value.toLowerCase());
    });
  }

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
    if (_controller != scope.projects) {
      _controller = scope.projects;
      _searchController.text = controller.query;
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final priorities = [
      ('All', loc.translate('filter_all')),
      ('High', loc.translate('priority_high')),
      ('Medium', loc.translate('priority_medium')),
      ('Low', loc.translate('priority_low')),
    ];

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openCreateProject,
        icon: const Icon(Icons.add),
        label: Text(loc.translate('projects_add_button')),
      ),
      body: RefreshIndicator(
        onRefresh: controller.refresh,
        child: AnimatedBuilder(
          animation: controller,
          builder: (context, _) {
            final projects = controller.projects;
            final isLoading = controller.isLoading && projects.isEmpty;

          return ListView(
            padding: EdgeInsets.zero,
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              const SizedBox(height: kToolbarHeight + 16),
              AppHeader(
                title: loc.translate('projects'),
                subtitle: loc.translate('projects_subtitle'),
                onSearch: () {
                  _searchFocusNode.requestFocus();
                },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _searchController,
                      focusNode: _searchFocusNode,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.search),
                        hintText: loc.translate('search_projects_hint'),
                      ),
                      onSubmitted: (value) => controller.updateQuery(value.toLowerCase()),
                      onChanged: _onSearchChanged,
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      children: priorities
                          .map(
                            (entry) => ChoiceChip(
                              label: Text(entry.$2),
                              selected: controller.priority == entry.$1,
                              onSelected: (_) => controller.updatePriority(entry.$1),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              AnimatedCrossFade(
                duration: const Duration(milliseconds: 300),
                crossFadeState: isLoading ? CrossFadeState.showFirst : CrossFadeState.showSecond,
                firstChild: const _ProjectsSkeleton(),
                secondChild: Column(
                  children: [
                    ...projects.map((project) {
                      final selected = controller.isCompared(project);
                      return GestureDetector(
                        onLongPress: () => controller.toggleCompare(project),
                        onTap: () => Navigator.of(context).pushNamed(AppRoutes.projectDetails, arguments: project),
                        child: AnimatedScale(
                          scale: selected ? 0.97 : 1,
                          duration: const Duration(milliseconds: 150),
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surface,
                              borderRadius: BorderRadius.circular(28),
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
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).colorScheme.primary.withOpacity(0.18),
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Text(loc.translate('priority_${project.priority.toLowerCase()}')),
                                    ),
                                    const SizedBox(width: 12),
                                    Text('#${project.index}', style: Theme.of(context).textTheme.titleMedium),
                                    const Spacer(),
                                    AiInfoButton(key: ValueKey(project.id)),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Text(project.title, style: Theme.of(context).textTheme.titleLarge),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Expanded(
                                      child: LinearProgressIndicator(value: project.progress),
                                    ),
                                    const SizedBox(width: 12),
                                    Text('${(project.progress * 100).round()}%'),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Text(project.status),
                                    const SizedBox(width: 16),
                                    Text('${project.estimatedHours.round()}h'),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                    if (controller.hasMore)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: controller.isLoadingMore
                            ? const Center(child: CircularProgressIndicator())
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

  Future<void> _openCreateProject() async {
    final loc = AppLocalizations.of(context);
    final created = await showModalBottomSheet<Project?>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: _ProjectComposerSheet(controller: controller),
        );
      },
    );
    if (created != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.translate('projects_created_success'))),
      );
    }
  }
}

class _ProjectsSkeleton extends StatelessWidget {
  const _ProjectsSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(3, (index) => const SkeletonListItem()),
    );
  }
}

class _ProjectComposerSheet extends StatefulWidget {
  const _ProjectComposerSheet({required this.controller});

  final ProjectsController controller;

  @override
  State<_ProjectComposerSheet> createState() => _ProjectComposerSheetState();
}

class _ProjectComposerSheetState extends State<_ProjectComposerSheet> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _hoursController = TextEditingController(text: '24');
  final TextEditingController _tagsController = TextEditingController();
  DateTime? _dueDate;
  String _priority = 'High';
  String _status = 'Planning';
  double _progress = 0.2;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _dueDate = DateTime.now().add(const Duration(days: 7));
  }

  @override
  void dispose() {
    _titleController.dispose();
    _hoursController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final statuses = [
      ('Planning', loc.translate('project_status_planning')),
      ('In Progress', loc.translate('project_status_in_progress')),
      ('In Review', loc.translate('project_status_in_review')),
      ('Blocked', loc.translate('project_status_blocked')),
      ('Completed', loc.translate('project_status_completed')),
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
                        loc.translate('projects_create_title'),
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
                  decoration: InputDecoration(labelText: loc.translate('projects_field_title')),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return loc.translate('projects_validation_title');
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                Text(loc.translate('projects_field_priority'), style: Theme.of(context).textTheme.bodySmall),
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
                DropdownButtonFormField<String>(
                  value: _status,
                  decoration: InputDecoration(labelText: loc.translate('projects_field_status')),
                  items: statuses
                      .map(
                        (entry) => DropdownMenuItem(
                          value: entry.$1,
                          child: Text(entry.$2),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _status = value);
                    }
                  },
                ),
                const SizedBox(height: 16),
                _DueDatePicker(
                  initialDate: _dueDate,
                  label: loc.translate('projects_field_due_date'),
                  onChanged: (value) => setState(() => _dueDate = value),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _hoursController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(labelText: loc.translate('projects_field_hours')),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return loc.translate('projects_validation_hours');
                    }
                    final parsed = double.tryParse(value);
                    if (parsed == null) {
                      return loc.translate('projects_validation_hours');
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Text(loc.translate('projects_field_progress'), style: Theme.of(context).textTheme.bodySmall),
                Slider(
                  value: _progress,
                  divisions: 20,
                  onChanged: (value) => setState(() => _progress = value),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text('${(_progress * 100).round()}%'),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _tagsController,
                  decoration: InputDecoration(
                    labelText: loc.translate('projects_field_tags'),
                    hintText: loc.translate('projects_tags_hint'),
                  ),
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
                        : Text(loc.translate('projects_create_action')),
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
        SnackBar(content: Text(loc.translate('projects_validation_due'))),
      );
      return;
    }
    setState(() => _saving = true);
    final tags = _tagsController.text
        .split(',')
        .map((tag) => tag.trim())
        .where((tag) => tag.isNotEmpty)
        .toList();
    final hours = double.tryParse(_hoursController.text.trim()) ?? 0;
    final project = await widget.controller.createProject(
      title: _titleController.text.trim(),
      priority: _priority,
      status: _status,
      dueDate: _dueDate!,
      estimatedHours: hours,
      progress: _progress,
      tags: tags,
    );
    if (!mounted) return;
    Navigator.of(context).pop(project);
  }
}

class _DueDatePicker extends StatelessWidget {
  const _DueDatePicker({required this.initialDate, required this.onChanged, required this.label});

  final DateTime? initialDate;
  final ValueChanged<DateTime?> onChanged;
  final String label;

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
                  ? loc.translate('projects_due_placeholder')
                  : materialLoc.formatMediumDate(initialDate!),
            ),
          ],
        ),
      ),
    );
  }
}

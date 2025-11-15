import 'package:flutter/material.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/models/mock_data.dart';
import '../../shared/controllers/workspace_scope.dart';
import '../../shared/widgets/ai_info_button.dart';

class ProjectDetailsScreen extends StatefulWidget {
  const ProjectDetailsScreen({super.key, required this.project});

  final Project project;

  @override
  State<ProjectDetailsScreen> createState() => _ProjectDetailsScreenState();
}

class _ProjectDetailsScreenState extends State<ProjectDetailsScreen> {
  late final Project _initialProject = widget.project;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final scope = WorkspaceScope.of(context);
    final controller = scope.projects;
    final tasksController = scope.tasks;
    final compare = scope.compare;
    final materialLoc = MaterialLocalizations.of(context);

    return AnimatedBuilder(
      animation: Listenable.merge([controller, compare, tasksController]),
      builder: (context, _) {
        final project = controller.findById(_initialProject.id) ?? _initialProject;
        final selected = compare.contains(project.id);
        final isCompleted = project.status.toLowerCase() == 'completed' || project.progress >= 0.999;
        final relatedTasks = scope.repository
            .allTasks()
            .where((task) => task.priority == project.priority)
            .take(4)
            .toList();

        return Scaffold(
          appBar: AppBar(title: Text(project.title)),
          floatingActionButton: const AiInfoButton(),
          body: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(loc.translate('priority_${project.priority.toLowerCase()}')),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(loc.translate('project_progress', params: {'percent': (project.progress * 100).round().toString()})),
                        const SizedBox(height: 4),
                        Text(materialLoc.formatFullDate(project.dueDate), style: Theme.of(context).textTheme.bodySmall),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                LinearProgressIndicator(value: project.progress.clamp(0.0, 1.0)),
                const SizedBox(height: 24),
                Text(loc.translate('project_linked_tasks'), style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 12),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: relatedTasks.isEmpty
                        ? Center(child: Text(loc.translate('project_no_tasks')))
                        : ListView.separated(
                            itemCount: relatedTasks.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final task = relatedTasks[index];
                              return ListTile(
                                tileColor: Theme.of(context).colorScheme.surface,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                title: Text(task.title),
                                subtitle: Text(task.status),
                                trailing: Text('${task.hours.toStringAsFixed(1)}h'),
                              );
                            },
                          ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton(
                        onPressed: () async {
                          await controller.toggleCompletion(project);
                          if (!mounted) return;
                          final message = isCompleted
                              ? loc.translate('mark_active')
                              : loc.translate('mark_completed');
                          ScaffoldMessenger.of(context)
                              .showSnackBar(SnackBar(content: Text(message)));
                        },
                        child: Text(isCompleted ? loc.translate('mark_active') : loc.translate('mark_completed')),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          compare.toggleProject(project);
                        },
                        child: Text(
                          selected ? loc.translate('remove_from_compare') : loc.translate('add_to_compare'),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

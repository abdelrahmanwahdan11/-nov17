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
  bool _completed = false;

  @override
  Widget build(BuildContext context) {
    final project = widget.project;
    final loc = AppLocalizations.of(context);
    final scope = WorkspaceScope.of(context);
    final compare = scope.compare;
    final relatedTasks = scope.tasks.tasks
        .where((task) => task.priority == project.priority)
        .take(4)
        .toList();

    return AnimatedBuilder(
      animation: compare,
      builder: (context, _) {
        final selected = compare.contains(project.id);
        return Scaffold(
          appBar: AppBar(title: Text(project.title)),
          floatingActionButton: const AiInfoButton(),
          body: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
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
                    Text(loc.translate('project_progress', params: {'percent': (project.progress * 100).round().toString()})),
                  ],
                ),
                const SizedBox(height: 24),
                LinearProgressIndicator(value: _completed ? 1 : project.progress),
                const SizedBox(height: 24),
                Text(loc.translate('project_linked_tasks'), style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 12),
                Expanded(
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
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton(
                        onPressed: () => setState(() => _completed = !_completed),
                        child: Text(_completed ? loc.translate('mark_active') : loc.translate('mark_completed')),
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

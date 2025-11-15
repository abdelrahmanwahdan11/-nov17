import 'package:flutter/material.dart';

import '../../core/models/mock_data.dart';
import '../../shared/widgets/ai_info_button.dart';

class ProjectDetailsScreen extends StatefulWidget {
  const ProjectDetailsScreen({super.key, required this.project});

  final Project? project;

  @override
  State<ProjectDetailsScreen> createState() => _ProjectDetailsScreenState();
}

class _ProjectDetailsScreenState extends State<ProjectDetailsScreen> {
  bool _completed = false;
  bool _inCompare = false;

  @override
  Widget build(BuildContext context) {
    final project = widget.project as Project? ?? projectsMock.first;
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
                  child: Text(project.priority),
                ),
                const SizedBox(width: 12),
                Text('Progress ${(project.progress * 100).round()}%'),
              ],
            ),
            const SizedBox(height: 24),
            LinearProgressIndicator(value: _completed ? 1 : project.progress),
            const SizedBox(height: 24),
            Text(
              'Linked tasks',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.separated(
                itemCount: tasksMock.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final task = tasksMock[index];
                  return ListTile(
                    tileColor: Theme.of(context).colorScheme.surface,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    title: Text(task.title),
                    subtitle: Text(task.status),
                    trailing: const Icon(Icons.chevron_right),
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
                    child: Text(_completed ? 'Mark as active' : 'Mark as completed'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => setState(() => _inCompare = !_inCompare),
                    child: Text(_inCompare ? 'Remove from compare' : 'Add to compare'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

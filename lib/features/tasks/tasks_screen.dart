import 'package:flutter/material.dart';

import '../../core/models/mock_data.dart';
import '../../core/routing/app_routes.dart';
import '../../shared/widgets/app_header.dart';
import '../../shared/widgets/ai_info_button.dart';
import '../../shared/skeletons/skeleton_widgets.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  bool _loading = false;
  String _view = 'Today';

  Future<void> _refresh() async {
    setState(() => _loading = true);
    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final tasks = tasksMock;
    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const SizedBox(height: kToolbarHeight + 16),
          AppHeader(
            title: 'Tasks',
            subtitle: _view,
            onSearch: () {},
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: ToggleButtons(
              isSelected: ['Today', 'Calendar'].map((tab) => tab == _view).toList(),
              onPressed: (index) => setState(() => _view = index == 0 ? 'Today' : 'Calendar'),
              borderRadius: BorderRadius.circular(18),
              children: const [
                Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('Today')),
                Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('Calendar')),
              ],
            ),
          ),
          const SizedBox(height: 16),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _loading
                ? const _TaskSkeletonList()
                : Column(
                    children: tasks
                        .map(
                          (task) => GestureDetector(
                                onTap: () => Navigator.of(context).pushNamed(AppRoutes.taskDetails, arguments: task),
                                child: AnimatedContainer(
                                  key: ValueKey(task.title),
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
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(task.priority),
                                          const Spacer(),
                                          AiInfoButton(key: ValueKey(task.title)),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      Text(task.title, style: Theme.of(context).textTheme.titleLarge),
                                      const SizedBox(height: 12),
                                      Text('${task.hours} hours • ${task.status}'),
                                    ],
                                  ),
                                ),
                              ),
                        )
                        .toList(),
                  ),
          ),
        ],
      ),
    );
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

import 'dart:math';

import 'package:flutter/material.dart';

import '../../core/models/mock_data.dart';
import '../../shared/widgets/ai_info_button.dart';

class TaskDetailsScreen extends StatefulWidget {
  const TaskDetailsScreen({super.key, required this.task});

  final Task? task;

  @override
  State<TaskDetailsScreen> createState() => _TaskDetailsScreenState();
}

class _TaskDetailsScreenState extends State<TaskDetailsScreen> {
  bool _done = false;
  bool _flipped = false;

  void _toggleOverlay() {
    showGeneralDialog<void>(
      context: context,
      pageBuilder: (_, __, ___) => const SizedBox.shrink(),
      barrierDismissible: true,
      transitionDuration: const Duration(milliseconds: 300),
      barrierLabel: 'overlay',
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(
          scale: CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
          child: _FlipCard(
            flipped: _flipped,
            onFlip: () => setState(() => _flipped = !_flipped),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final task = widget.task ?? tasksMock.first;
    return Scaffold(
      appBar: AppBar(title: Text(task.title)),
      floatingActionButton: const AiInfoButton(),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Chip(label: Text(task.status)),
                const SizedBox(width: 8),
                Chip(label: Text(task.priority)),
              ],
            ),
            const SizedBox(height: 16),
            Text('Due: ${task.dueDate.toLocal()}'),
            const SizedBox(height: 24),
            Expanded(
              child: ListView(
                children: [
                  Text('Description', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 12),
                  const Text('Detailed overview of the task goes here, describing the goals and deliverables.'),
                  const SizedBox(height: 24),
                  GestureDetector(
                    onTap: _toggleOverlay,
                    child: Hero(
                      tag: 'task_image_${task.title}',
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
              onPressed: () {
                setState(() => _done = !_done);
              },
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: Text(_done ? 'Marked as done' : 'Mark as done'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FlipCard extends StatelessWidget {
  const _FlipCard({required this.flipped, required this.onFlip});

  final bool flipped;
  final VoidCallback onFlip;

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
                  child: const Text('More details and attachments will be shown here.'),
                )
              : Container(
                  key: const ValueKey('front'),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(32),
                  ),
                  child: const Text('Preview of the task asset. Tap to flip.'),
                ),
        ),
      ),
    );
  }
}

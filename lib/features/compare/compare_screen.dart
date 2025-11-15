import 'package:flutter/material.dart';

import '../../core/models/mock_data.dart';

class CompareScreen extends StatelessWidget {
  const CompareScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final items = catalogMock.take(3).toList();
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text('Compare Items', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: items
                .map(
                  (item) => Container(
                    width: 240,
                    margin: const EdgeInsets.only(right: 16),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.title, style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: 12),
                        Text('Type: ${item.type}'),
                        Text('Priority: ${item.priority}'),
                        const SizedBox(height: 12),
                        const Text('Estimated time: 6h'),
                        const Text('Due date: 24 May'),
                        const Text('Status: Draft'),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        const SizedBox(height: 24),
        FilledButton(
          onPressed: () {},
          child: const Text('Clear comparison list'),
        ),
      ],
    );
  }
}

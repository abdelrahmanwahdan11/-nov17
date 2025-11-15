import 'package:flutter/material.dart';

import '../../core/localization/app_localizations.dart';
import '../../shared/controllers/compare_controller.dart';
import '../../shared/controllers/workspace_scope.dart';

class CompareScreen extends StatelessWidget {
  const CompareScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = WorkspaceScope.of(context).compare;
    final loc = AppLocalizations.of(context);

    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final items = controller.items;
        if (items.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(48),
              child: Text(
                loc.translate('compare_empty'),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
          );
        }

        return ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(loc.translate('compare_header'), style: Theme.of(context).textTheme.headlineSmall),
                ),
                TextButton(
                  onPressed: controller.clear,
                  child: Text(loc.translate('clear_compare')),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: items
                    .map(
                      (item) => _CompareColumn(item: item, controller: controller),
                    )
                    .toList(),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _CompareColumn extends StatelessWidget {
  const _CompareColumn({required this.item, required this.controller});

  final ComparableItem item;
  final CompareController controller;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final material = MaterialLocalizations.of(context);
    final due = item.dueDate != null ? material.formatShortDate(item.dueDate!) : '--';
    final kindLabel = switch (item.kind) {
      ComparableKind.project => loc.translate('projects'),
      ComparableKind.task => loc.translate('tasks'),
      ComparableKind.catalog => loc.translate('catalog'),
    };
    final priorityValue = loc.translate('priority_${item.priority.toLowerCase()}');

    return Container(
      width: 260,
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  item.title,
                  style: Theme.of(context).textTheme.titleLarge,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => controller.remove(item.id),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _AttributeRow(label: loc.translate('compare_type'), value: kindLabel),
          _AttributeRow(label: loc.translate('compare_priority'), value: priorityValue),
          _AttributeRow(label: loc.translate('compare_status'), value: item.status),
          _AttributeRow(label: loc.translate('compare_estimate'), value: '${item.estimatedHours.toStringAsFixed(1)}h'),
          _AttributeRow(label: loc.translate('compare_due'), value: due),
          if (item.summary != null) ...[
            const SizedBox(height: 12),
            Text(item.summary!, maxLines: 3, overflow: TextOverflow.ellipsis),
          ],
          const SizedBox(height: 12),
          Wrap(
            spacing: 6,
            children: item.tags
                .map((tag) => Chip(
                      label: Text(tag),
                      backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.15),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _AttributeRow extends StatelessWidget {
  const _AttributeRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          Text(value, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}

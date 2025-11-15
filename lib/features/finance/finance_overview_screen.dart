import 'package:flutter/material.dart';

import '../../shared/widgets/app_header.dart';
import '../../shared/skeletons/skeleton_widgets.dart';

class FinanceOverviewScreen extends StatefulWidget {
  const FinanceOverviewScreen({super.key});

  @override
  State<FinanceOverviewScreen> createState() => _FinanceOverviewScreenState();
}

class _FinanceOverviewScreenState extends State<FinanceOverviewScreen> {
  bool _loading = false;
  int _tabIndex = 0;

  Future<void> _refresh() async {
    setState(() => _loading = true);
    await Future<void>.delayed(const Duration(milliseconds: 700));
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const SizedBox(height: kToolbarHeight + 16),
          const AppHeader(title: 'Finance Overview', subtitle: 'Your revenue goals'),
          const SizedBox(height: 16),
          Center(
            child: SegmentedButton<int>(
              segments: const [
                ButtonSegment(value: 0, label: Text('Monthly')),
                ButtonSegment(value: 1, label: Text('Yearly')),
              ],
              selected: {_tabIndex},
              onSelectionChanged: (value) => setState(() => _tabIndex = value.first),
            ),
          ),
          const SizedBox(height: 16),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _loading
                ? const SkeletonContainer(height: 200)
                : Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        _FinanceBar(label: 'April', value: 0.75, highlight: _tabIndex == 0),
                        const SizedBox(height: 12),
                        _FinanceBar(label: 'May', value: 0.55, highlight: _tabIndex == 0),
                        const SizedBox(height: 12),
                        _FinanceBar(label: 'June', value: 0.9, highlight: _tabIndex == 0),
                        const SizedBox(height: 24),
                        _FinanceGoalBar(goal: 120000, earned: 74000),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _FinanceBar extends StatelessWidget {
  const _FinanceBar({required this.label, required this.value, required this.highlight});

  final String label;
  final double value;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final color = highlight ? const Color(0xFFF7FF5A) : Theme.of(context).colorScheme.primary;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          const SizedBox(width: 12),
          Expanded(
            flex: 3,
            child: LinearProgressIndicator(value: value, color: color, backgroundColor: color.withOpacity(0.2)),
          ),
        ],
      ),
    );
  }
}

class _FinanceGoalBar extends StatelessWidget {
  const _FinanceGoalBar({required this.goal, required this.earned});

  final double goal;
  final double earned;

  @override
  Widget build(BuildContext context) {
    final progress = earned / goal;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Yearly Revenue Goal'),
          const SizedBox(height: 12),
          LinearProgressIndicator(value: progress),
          const SizedBox(height: 8),
          Text('Earned: \$${earned.toStringAsFixed(0)} / \$${goal.toStringAsFixed(0)}'),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/routing/app_routes.dart';
import '../../shared/widgets/app_header.dart';
import '../../shared/widgets/stats_card.dart';
import '../../shared/skeletons/skeleton_widgets.dart';
import '../../core/models/mock_data.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _loading = false;

  Future<void> _refresh() async {
    setState(() => _loading = true);
    await Future<void>.delayed(const Duration(seconds: 1));
    if (mounted) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const SizedBox(height: kToolbarHeight + 16),
          AppHeader(
            title: loc.translate('dashboard'),
            subtitle: 'Good morning, Alya',
            onSearch: () => Navigator.pushNamed(context, AppRoutes.search),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: AnimatedCrossFade(
              duration: const Duration(milliseconds: 300),
              crossFadeState: _loading ? CrossFadeState.showFirst : CrossFadeState.showSecond,
              firstChild: const _DashboardSkeleton(),
              secondChild: Column(
                children: [
                  Row(
                    children: const [
                      Expanded(child: StatsCard(label: 'Tasks', value: '36')),
                      SizedBox(width: 16),
                      Expanded(child: StatsCard(label: 'New Leads', value: '09')),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: const [
                      Expanded(child: StatsCard(label: 'Today', value: '12')),
                      SizedBox(width: 16),
                      Expanded(child: StatsCard(label: 'Focus', value: '4h')),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _PaymentSummaryCard(),
                  const SizedBox(height: 24),
                  _MonthlyTimeline(tasks: tasksMock),
                  const SizedBox(height: 24),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(32),
                    child: Image.network(
                      'https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?auto=format&fit=crop&w=900&q=80',
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _DashboardSkeleton extends StatelessWidget {
  const _DashboardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        SkeletonContainer(height: 160),
        SizedBox(height: 16),
        SkeletonContainer(height: 160),
        SizedBox(height: 16),
        SkeletonContainer(height: 200),
      ],
    );
  }
}

class _PaymentSummaryCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Payment Summary', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  children: List.generate(4, (index) {
                    final height = (index + 1) * 20.0;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 400),
                        height: height,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.4 + index * 0.1),
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  _Legend(color: Color(0xFFF7FF5A), label: 'Invoices'),
                  _Legend(color: Color(0xFFD9E272), label: 'Subscriptions'),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(width: 12, height: 12, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(6))),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
    );
  }
}

class _MonthlyTimeline extends StatelessWidget {
  const _MonthlyTimeline({required this.tasks});

  final List<Task> tasks;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Monthly Tasks', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        Column(
          children: tasks
              .map(
                (task) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(child: Text(task.title)),
                      Text('${task.hours.toStringAsFixed(1)}h'),
                    ],
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/routing/app_routes.dart';
import '../../core/models/mock_data.dart';
import '../../shared/controllers/workspace_scope.dart';
import '../../shared/widgets/app_header.dart';

class ToolsScreen extends StatelessWidget {
  const ToolsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scope = WorkspaceScope.of(context);
    final listenable = Listenable.merge([scope.scheduler, scope.templates, scope.library, scope.app, scope.insights]);
    final loc = AppLocalizations.of(context);

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        const SizedBox(height: kToolbarHeight + 16),
        AppHeader(
          title: loc.translate('tools'),
          subtitle: loc.translate('tools_subtitle'),
          onSearch: () => Navigator.pushNamed(context, AppRoutes.search),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: AnimatedBuilder(
            animation: listenable,
            builder: (context, _) {
              final materialLoc = MaterialLocalizations.of(context);
              final schedulerPeek = scope.scheduler.upcomingPeek(limit: 2);
              final schedulerSubtitle = schedulerPeek.isEmpty
                  ? loc.translate('tools_scheduler_empty')
                  : '${materialLoc.formatTimeOfDay(TimeOfDay.fromDateTime(schedulerPeek.first.start))} · ${schedulerPeek.first.title}';
              final templateSubtitle = loc.translate(
                'tools_templates_count',
                params: {'count': scope.templates.templates.length.toString()},
              );
              final librarySubtitle = loc.translate(
                'tools_library_count',
                params: {'count': scope.library.items.length.toString()},
              );
              final insightsRate = (scope.insights.completionRate * 100).clamp(0, 100).toStringAsFixed(0);
              final insightsDeadlines = scope.insights.deadlines.length;
              final insightsSubtitle = insightsDeadlines == 0
                  ? loc.translate('tools_insights_summary_zero', params: {'rate': insightsRate})
                  : insightsDeadlines == 1
                      ? loc.translate('tools_insights_summary_one', params: {'rate': insightsRate})
                      : loc.translate(
                          'tools_insights_summary_many',
                          params: {'rate': insightsRate, 'count': insightsDeadlines.toString()},
                        );
              final lastDuration = scope.app.lastTrackedDuration;
              final weeklyDuration = scope.app.weeklyTrackedDuration;
              final formattedLast = _formatDuration(lastDuration, materialLoc);
              final formattedWeek = _formatDuration(weeklyDuration, materialLoc);
              final timeTrackerSubtitle = loc.translate(
                'tools_time_tracker_subtitle',
                params: {
                  'last': formattedLast,
                  'week': formattedWeek,
                },
              );

              final cards = [
                _ToolCardData(
                  icon: IconlyBold.calendar,
                  title: loc.translate('tools_calendar'),
                  subtitle: loc.translate('tools_calendar_subtitle'),
                  route: AppRoutes.calendar,
                ),
                _ToolCardData(
                  icon: IconlyBold.time_circle,
                  title: loc.translate('tools_scheduler'),
                  subtitle: schedulerSubtitle,
                  route: AppRoutes.scheduler,
                  highlight: schedulerPeek.isNotEmpty,
                ),
                _ToolCardData(
                  icon: IconlyBold.activity,
                  title: loc.translate('tools_insights'),
                  subtitle: insightsSubtitle,
                  route: AppRoutes.insights,
                ),
                _ToolCardData(
                  icon: IconlyBold.document,
                  title: loc.translate('tools_templates'),
                  subtitle: templateSubtitle,
                  route: AppRoutes.templates,
                ),
                _ToolCardData(
                  icon: IconlyBold.folder,
                  title: loc.translate('tools_library'),
                  subtitle: librarySubtitle,
                  route: AppRoutes.library,
                ),
                _ToolCardData(
                  icon: IconlyBold.timer,
                  title: loc.translate('tools_time_tracker'),
                  subtitle: timeTrackerSubtitle,
                  route: AppRoutes.timeTracker,
                ),
                _ToolCardData(
                  icon: IconlyBold.task,
                  title: loc.translate('tools_tasks'),
                  subtitle: loc.translate('tools_tasks_subtitle'),
                  route: AppRoutes.tasks,
                ),
              ];

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 1.1,
                ),
                itemCount: cards.length,
                itemBuilder: (context, index) {
                  final card = cards[index];
                  return _ToolCard(data: card);
                },
              );
            },
          ),
        ),
        AnimatedBuilder(
          animation: listenable,
          builder: (context, _) {
            final spotlight = scope.templates.spotlight;
            final recentLibrary = scope.library.recent;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (spotlight.isNotEmpty) ...[
                  const SizedBox(height: 32),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      loc.translate('tools_spotlight_templates'),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 180,
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) {
                        final template = spotlight[index];
                        return _SpotlightCard(
                          title: template.title,
                          badge: template.type,
                          description: template.summary,
                          onTap: () => Navigator.pushNamed(context, AppRoutes.templates),
                        );
                      },
                      separatorBuilder: (_, __) => const SizedBox(width: 16),
                      itemCount: spotlight.length,
                    ),
                  ),
                ],
                if (recentLibrary.isNotEmpty) ...[
                  const SizedBox(height: 28),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      loc.translate('tools_recent_library'),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...recentLibrary.map((item) => _LibraryRow(item: item)),
                ],
                const SizedBox(height: 48),
              ],
            );
          },
        ),
      ],
    );
  }

  String _formatDuration(Duration duration, MaterialLocalizations materialLoc) {
    if (duration.inSeconds == 0) {
      return '0m';
    }
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    if (hours == 0 && minutes == 0) {
      return '${duration.inSeconds}s';
    }
    if (hours > 0) {
      return '${hours}h ${minutes.toString().padLeft(2, '0')}m';
    }
    return '${minutes}m';
  }
}

class _ToolCardData {
  _ToolCardData({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.route,
    this.highlight = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String route;
  final bool highlight;
}

class _ToolCard extends StatefulWidget {
  const _ToolCard({required this.data});

  final _ToolCardData data;

  @override
  State<_ToolCard> createState() => _ToolCardState();
}

class _ToolCardState extends State<_ToolCard> {
  bool _pressed = false;

  void _handleTapDown(TapDownDetails details) {
    setState(() => _pressed = true);
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _pressed = false);
  }

  void _handleTapCancel() {
    setState(() => _pressed = false);
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.data;
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, data.route),
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: AnimatedScale(
        scale: _pressed ? 0.98 : 1,
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeInOut,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: data.highlight
                ? Theme.of(context).colorScheme.primary.withOpacity(0.18)
                : Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: data.highlight
                  ? Theme.of(context).colorScheme.primary.withOpacity(0.4)
                  : Colors.transparent,
              width: 2,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.24),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(data.icon, color: Theme.of(context).colorScheme.onPrimaryContainer, size: 24),
              ),
              const SizedBox(height: 18),
              Text(data.title, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Text(
                data.subtitle,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).textTheme.bodySmall?.color ?? Theme.of(context).hintColor,
                    ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SpotlightCard extends StatelessWidget {
  const _SpotlightCard({
    required this.title,
    required this.badge,
    required this.description,
    required this.onTap,
  });

  final String title;
  final String badge;
  final String description;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 220,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(badge, style: Theme.of(context).textTheme.labelMedium),
            ),
            const SizedBox(height: 12),
            Text(title, style: Theme.of(context).textTheme.titleSmall, maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 12),
            Expanded(
              child: Text(
                description,
                style: Theme.of(context).textTheme.bodySmall,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LibraryRow extends StatelessWidget {
  const _LibraryRow({required this.item});

  final LibraryItem item;

  @override
  Widget build(BuildContext context) {
    final materialLoc = MaterialLocalizations.of(context);
    final date = materialLoc.formatFullDate(item.updatedAt);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.title, style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 8),
                  Text(
                    item.summary,
                    style: Theme.of(context).textTheme.bodySmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    children: [
                      Chip(label: Text(item.type)),
                      Chip(label: Text(item.author)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(date, style: Theme.of(context).textTheme.labelMedium),
                const SizedBox(height: 12),
                Text(item.link, style: Theme.of(context).textTheme.bodySmall, overflow: TextOverflow.ellipsis),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

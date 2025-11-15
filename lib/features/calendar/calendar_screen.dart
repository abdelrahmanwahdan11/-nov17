import 'package:flutter/material.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/routing/app_routes.dart';
import '../../shared/controllers/tasks_controller.dart';
import '../../shared/controllers/workspace_scope.dart';
import '../../shared/skeletons/skeleton_widgets.dart';
import '../../shared/widgets/app_header.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late DateTime _focusedMonth;
  late DateTime _selectedDay;

  String _statusLabel(AppLocalizations loc, String status) {
    switch (status.toLowerCase()) {
      case 'in progress':
        return loc.translate('status_in_progress');
      case 'upcoming':
        return loc.translate('status_upcoming');
      case 'done':
        return loc.translate('status_done');
      default:
        return status;
    }
  }

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDay = DateUtils.dateOnly(now);
    _focusedMonth = DateTime(now.year, now.month);
  }

  void _changeMonth(int offset) {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + offset);
      final daysInMonth = DateUtils.getDaysInMonth(_focusedMonth.year, _focusedMonth.month);
      final day = _selectedDay.day.clamp(1, daysInMonth);
      _selectedDay = DateTime(_focusedMonth.year, _focusedMonth.month, day);
    });
  }

  @override
  Widget build(BuildContext context) {
    final scope = WorkspaceScope.of(context);
    final controller = scope.tasks;
    final loc = AppLocalizations.of(context);

    return RefreshIndicator(
      onRefresh: controller.refresh,
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          final materialLoc = MaterialLocalizations.of(context);
          final tasksForDay = controller.tasksForDate(_selectedDay);
          final counts = controller.taskCountForMonth(_focusedMonth);
          final isLoading = controller.isLoading && controller.tasks.isEmpty;
          final monthLabel = materialLoc.formatMonthYear(_focusedMonth);

          return ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            children: [
              const SizedBox(height: kToolbarHeight + 16),
              AppHeader(
                title: loc.translate('calendar'),
                subtitle: loc.translate('calendar_overview'),
                onSearch: () => Navigator.pushNamed(context, AppRoutes.search),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    IconButton(
                      tooltip: loc.translate('calendar_previous_month'),
                      onPressed: () => _changeMonth(-1),
                      icon: const Icon(Icons.chevron_left),
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          monthLabel,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: loc.translate('calendar_next_month'),
                      onPressed: () => _changeMonth(1),
                      icon: const Icon(Icons.chevron_right),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: _CalendarGrid(
                  month: _focusedMonth,
                  selected: _selectedDay,
                  counts: counts,
                  onSelected: (day) => setState(() => _selectedDay = day),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  loc.translate('calendar_selected_day', params: {'date': materialLoc.formatFullDate(_selectedDay)}),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              const SizedBox(height: 8),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: isLoading
                    ? const SkeletonListItem()
                    : tasksForDay.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                            child: Text(loc.translate('calendar_empty'), textAlign: TextAlign.center),
                          )
                        : Column(
                            children: tasksForDay
                                .map(
                                  (task) => ListTile(
                                    onTap: () => Navigator.pushNamed(context, AppRoutes.taskDetails, arguments: task),
                                    title: Text(task.title),
                                    subtitle: Text(_statusLabel(loc, task.status)),
                                    trailing: const Icon(Icons.chevron_right),
                                  ),
                                )
                                .toList(),
                          ),
              ),
              const SizedBox(height: 24),
            ],
          );
        },
      ),
    );
  }
}

class _CalendarGrid extends StatelessWidget {
  const _CalendarGrid({
    required this.month,
    required this.selected,
    required this.counts,
    required this.onSelected,
  });

  final DateTime month;
  final DateTime selected;
  final Map<int, int> counts;
  final ValueChanged<DateTime> onSelected;

  @override
  Widget build(BuildContext context) {
    final firstDay = DateTime(month.year, month.month, 1);
    final daysInMonth = DateUtils.getDaysInMonth(month.year, month.month);
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7, crossAxisSpacing: 8, mainAxisSpacing: 8),
      itemCount: daysInMonth,
      itemBuilder: (context, index) {
        final day = firstDay.add(Duration(days: index));
        final isSelected = day.year == selected.year && day.month == selected.month && day.day == selected.day;
        final count = counts[day.day] ?? 0;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          decoration: BoxDecoration(
            color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: count > 0 ? Theme.of(context).colorScheme.primary.withOpacity(0.4) : Colors.transparent,
            ),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => onSelected(day),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${day.day}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: isSelected ? Colors.black : Theme.of(context).colorScheme.onSurface,
                      ),
                ),
                if (count > 0) ...[
                  const SizedBox(height: 4),
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.black.withOpacity(0.75)
                          : Theme.of(context).colorScheme.primary.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        '$count',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: isSelected ? Theme.of(context).colorScheme.onPrimary : Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

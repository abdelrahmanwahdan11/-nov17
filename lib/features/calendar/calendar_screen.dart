import 'package:flutter/material.dart';

import '../../core/models/mock_data.dart';
import '../../shared/widgets/app_header.dart';
import '../../shared/skeletons/skeleton_widgets.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _selectedDay = DateTime.now();
  bool _loading = false;

  Future<void> _refresh() async {
    setState(() => _loading = true);
    await Future<void>.delayed(const Duration(milliseconds: 850));
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
          const AppHeader(title: 'Calendar', subtitle: 'Monthly overview'),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: _CalendarGrid(
              selected: _selectedDay,
              onSelected: (day) => setState(() => _selectedDay = day),
            ),
          ),
          const SizedBox(height: 16),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _loading
                ? const SkeletonListItem()
                : Column(
                    children: tasksMock
                        .where((task) => task.dueDate.day == _selectedDay.day)
                        .map(
                          (task) => ListTile(
                            title: Text(task.title),
                            subtitle: Text(task.status),
                            trailing: const Icon(Icons.chevron_right),
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

class _CalendarGrid extends StatelessWidget {
  const _CalendarGrid({required this.selected, required this.onSelected});

  final DateTime selected;
  final ValueChanged<DateTime> onSelected;

  @override
  Widget build(BuildContext context) {
    final firstDay = DateTime(selected.year, selected.month, 1);
    final daysInMonth = DateUtils.getDaysInMonth(selected.year, selected.month);
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7, crossAxisSpacing: 8, mainAxisSpacing: 8),
      itemCount: daysInMonth,
      itemBuilder: (context, index) {
        final day = firstDay.add(Duration(days: index));
        final isSelected = day.day == selected.day;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          decoration: BoxDecoration(
            color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => onSelected(day),
            child: Center(
              child: Text(
                '${day.day}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: isSelected ? Colors.black : Theme.of(context).colorScheme.onSurface,
                    ),
              ),
            ),
          ),
        );
      },
    );
  }
}

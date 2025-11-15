import 'dart:async';

import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/models/mock_data.dart';
import '../../shared/controllers/team_controller.dart';
import '../../shared/controllers/workspace_scope.dart';
import '../../shared/skeletons/skeleton_widgets.dart';

class TeamMemberDetailsScreen extends StatefulWidget {
  const TeamMemberDetailsScreen({super.key, required this.member});

  final TeamMember member;

  @override
  State<TeamMemberDetailsScreen> createState() => _TeamMemberDetailsScreenState();
}

class _TeamMemberDetailsScreenState extends State<TeamMemberDetailsScreen> {
  late TeamController _controller;
  bool _attached = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final scope = WorkspaceScope.of(context);
    if (!_attached || _controller != scope.team) {
      _controller = scope.team;
      _attached = true;
      unawaited(_controller.loadCheckIns(widget.member.id));
    }
  }

  Future<void> _refresh() => _controller.loadCheckIns(widget.member.id, force: true);

  void _openLogCheckIn() {
    final loc = AppLocalizations.of(context);
    final formKey = GlobalKey<FormState>();
    final summaryController = TextEditingController();
    final highlightsController = TextEditingController();
    final nextStepsController = TextEditingController();
    String sentiment = 'positive';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final theme = Theme.of(context);
            return AnimatedPadding(
              duration: const Duration(milliseconds: 200),
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                loc.translate('team_details_check_in_sheet_title'),
                                style: theme.textTheme.titleLarge,
                              ),
                            ),
                            IconButton(
                              onPressed: () => Navigator.of(context).pop(),
                              icon: const Icon(Icons.close),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: summaryController,
                          decoration: InputDecoration(
                            labelText: loc.translate('team_details_check_in_summary'),
                            hintText: loc.translate('team_details_check_in_summary_hint'),
                          ),
                          maxLines: 3,
                          validator: (value) => value == null || value.trim().isEmpty
                              ? loc.translate('team_details_check_in_summary_error')
                              : null,
                        ),
                        const SizedBox(height: 16),
                        Text(loc.translate('team_details_check_in_sentiment'), style: theme.textTheme.labelLarge),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 12,
                          children: [
                            for (final option in ['positive', 'neutral', 'attention'])
                              ChoiceChip(
                                label: Text(loc.translate('team_details_sentiment_$option')),
                                selected: sentiment == option,
                                onSelected: (_) => setModalState(() => sentiment = option),
                              ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: highlightsController,
                          decoration: InputDecoration(
                            labelText: loc.translate('team_details_check_in_highlights'),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: nextStepsController,
                          decoration: InputDecoration(
                            labelText: loc.translate('team_details_check_in_next_steps'),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: Text(loc.translate('team_details_check_in_cancel')),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () async {
                                  if (!formKey.currentState!.validate()) return;
                                  final highlights = highlightsController.text
                                      .split(',')
                                      .map((value) => value.trim())
                                      .where((value) => value.isNotEmpty)
                                      .toList();
                                  final nextSteps = nextStepsController.text
                                      .split(',')
                                      .map((value) => value.trim())
                                      .where((value) => value.isNotEmpty)
                                      .toList();
                                  await _controller.logCheckIn(
                                    memberId: widget.member.id,
                                    summary: summaryController.text.trim(),
                                    sentiment: sentiment,
                                    highlights: highlights,
                                    nextSteps: nextSteps,
                                  );
                                  if (!mounted) return;
                                  Navigator.of(context).pop();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(loc.translate('team_details_check_in_success'))),
                                  );
                                },
                                child: Text(loc.translate('team_details_check_in_save')),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    ).whenComplete(() {
      summaryController.dispose();
      highlightsController.dispose();
      nextStepsController.dispose();
    });
  }

  String _relativeTime(DateTime timestamp) {
    final loc = AppLocalizations.of(context);
    final material = MaterialLocalizations.of(context);
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    if (difference.inMinutes < 1) {
      return loc.translate('team_last_active_now');
    }
    if (difference.inMinutes < 60) {
      return loc.translate('team_last_active_minutes', params: {'minutes': difference.inMinutes.toString()});
    }
    if (difference.inHours < 24) {
      return loc.translate('team_last_active_hours', params: {'hours': difference.inHours.toString()});
    }
    if (difference.inDays == 1) {
      return loc.translate('team_last_active_yesterday', params: {
        'time': material.formatTimeOfDay(TimeOfDay.fromDateTime(timestamp)),
      });
    }
    if (difference.inDays < 7) {
      return loc.translate('team_last_active_days', params: {'days': difference.inDays.toString()});
    }
    return loc.translate('team_last_active_date', params: {'date': material.formatMediumDate(timestamp)});
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.member.name),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openLogCheckIn,
        icon: const Icon(Icons.note_add_rounded),
        label: Text(loc.translate('team_details_check_in_add')),
      ),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final member = _controller.memberById(widget.member.id) ?? widget.member;
          final checkIns = _controller.checkInsFor(member.id);
          final isLoading = _controller.isLoadingCheckIns(member.id);
          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 120),
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                _MemberHeaderCard(member: member),
                const SizedBox(height: 24),
                Text(
                  loc.translate('team_details_activity_timeline'),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                if (isLoading && checkIns.isEmpty) ...[
                  const SkeletonContainer(height: 120),
                  const SizedBox(height: 12),
                  const SkeletonContainer(height: 120),
                ] else if (checkIns.isEmpty) ...[
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Text(
                      loc.translate('team_details_check_ins_empty'),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ] else ...[
                  ...checkIns.map(
                    (checkIn) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _CheckInTimelineCard(
                        checkIn: checkIn,
                        timeLabel: _relativeTime(checkIn.createdAt),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 48),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _MemberHeaderCard extends StatelessWidget {
  const _MemberHeaderCard({required this.member});

  final TeamMember member;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final material = MaterialLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 42,
                backgroundImage: NetworkImage(member.avatarUrl),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      member.name,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 12,
                      runSpacing: 8,
                      children: [
                        _DetailChip(icon: IconlyLight.briefcase, label: member.role),
                        if (member.location.isNotEmpty)
                          _DetailChip(icon: IconlyLight.location, label: member.location),
                        if (member.timezone.isNotEmpty)
                          _DetailChip(icon: IconlyLight.time_circle, label: member.timezone),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      loc.translate('team_focus_hours', params: {'hours': member.focusHoursThisWeek.toStringAsFixed(1)}),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      loc.translate('team_tasks_this_week', params: {'count': member.tasksThisWeek.toString()}),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      loc.translate('team_capacity_label', params: {'percent': (member.capacity * 100).toStringAsFixed(0)}),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      loc.translate('team_member_since', params: {
                        'date': material.formatMediumDate(member.joinedOn),
                      }),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 120,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(loc.translate('team_details_contact_section'), style: Theme.of(context).textTheme.labelMedium),
                    const SizedBox(height: 8),
                    if (member.email.isNotEmpty)
                      Text('${loc.translate('team_details_contact_email')}: ${member.email}', style: Theme.of(context).textTheme.bodySmall),
                    if (member.location.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text('${loc.translate('team_details_contact_location')}: ${member.location}',
                            style: Theme.of(context).textTheme.bodySmall),
                      ),
                    if (member.timezone.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text('${loc.translate('team_details_contact_timezone')}: ${member.timezone}',
                            style: Theme.of(context).textTheme.bodySmall),
                      ),
                  ],
                ),
              ),
            ],
          ),
          if (member.skills.isNotEmpty) ...[
            const SizedBox(height: 20),
            Text(loc.translate('team_details_skillset'), style: Theme.of(context).textTheme.labelMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: member.skills.map((skill) => Chip(label: Text('#$skill'))).toList(),
            ),
          ],
        ],
      ),
    );
  }
}

class _DetailChip extends StatelessWidget {
  const _DetailChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 6),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _CheckInTimelineCard extends StatelessWidget {
  const _CheckInTimelineCard({required this.checkIn, required this.timeLabel});

  final TeamCheckIn checkIn;
  final String timeLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context);
    final highlights = checkIn.highlights.where((item) => item.trim().isNotEmpty).toList();
    final nextSteps = checkIn.nextSteps.where((item) => item.trim().isNotEmpty).toList();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.bolt_rounded, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  loc.translate('team_recent_check_in_sentiment_${checkIn.sentiment}'),
                  style: theme.textTheme.labelLarge,
                ),
              ),
              Text(timeLabel, style: theme.textTheme.labelSmall),
            ],
          ),
          const SizedBox(height: 12),
          Text(checkIn.summary, style: theme.textTheme.bodyMedium),
          if (highlights.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: highlights.map((item) => Chip(label: Text(item))).toList(),
            ),
          ],
          if (nextSteps.isNotEmpty) ...[
            const SizedBox(height: 12),
            ...nextSteps.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_outline, size: 16),
                    const SizedBox(width: 6),
                    Expanded(child: Text(item, style: theme.textTheme.bodySmall)),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 12),
          Text(loc.translate('team_details_logged_by', params: {'author': checkIn.author}), style: theme.textTheme.labelSmall),
        ],
      ),
    );
  }
}

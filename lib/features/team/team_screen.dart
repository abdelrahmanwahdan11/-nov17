import 'dart:async';

import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/models/mock_data.dart';
import '../../core/routing/app_routes.dart';
import '../../shared/controllers/team_controller.dart';
import '../../shared/controllers/workspace_scope.dart';
import '../../shared/skeletons/skeleton_widgets.dart';

class TeamScreen extends StatefulWidget {
  const TeamScreen({super.key});

  @override
  State<TeamScreen> createState() => _TeamScreenState();
}

class _TeamScreenState extends State<TeamScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  Timer? _debounce;
  TeamController? _controller;

  static const _statuses = [
    'All',
    'Active',
    'Onboarding',
    'Out of office',
    'Contractor',
  ];

  TeamController get controller => _controller ??= WorkspaceScope.of(context).team;

  @override
  void didChangeDependencies() {
    final scope = WorkspaceScope.of(context);
    if (_controller != scope.team) {
      _controller = scope.team;
      _searchController.text = controller.query;
    }
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 320), () {
      controller.updateQuery(value);
    });
  }

  Future<void> _refresh() => controller.refresh();

  void _toggleFavorite(TeamMember member) async {
    await controller.toggleFavorite(member);
    if (!mounted) return;
    final loc = AppLocalizations.of(context);
    final message = member.favorite
        ? loc.translate('team_favorite_removed')
        : loc.translate('team_favorite_added');
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void _changeStatus(TeamMember member, String status) async {
    await controller.changeStatus(member, status);
    if (!mounted) return;
    final loc = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(loc.translate('team_status_updated'))));
  }

  void _openMemberDetails(TeamMember member) {
    Navigator.pushNamed(context, AppRoutes.teamMemberDetails, arguments: member);
  }

  void _openCreateMember() {
    final loc = AppLocalizations.of(context);
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final roleController = TextEditingController();
    final emailController = TextEditingController();
    final locationController = TextEditingController();
    final timezoneController = TextEditingController();
    final focusController = TextEditingController(text: '16');
    final tasksController = TextEditingController(text: '10');
    final skillsController = TextEditingController();
    String selectedStatus = 'Active';
    double capacity = controller.metrics.averageCapacity.clamp(0.2, 0.9);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AnimatedPadding(
              duration: const Duration(milliseconds: 200),
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                child: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                loc.translate('team_add_title'),
                                style: Theme.of(context).textTheme.titleLarge,
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
                          controller: nameController,
                          decoration: InputDecoration(labelText: loc.translate('team_add_name')),
                          validator: (value) => value == null || value.trim().isEmpty
                              ? loc.translate('team_add_name_error')
                              : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: roleController,
                          decoration: InputDecoration(labelText: loc.translate('team_add_role')),
                          validator: (value) => value == null || value.trim().isEmpty
                              ? loc.translate('team_add_role_error')
                              : null,
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          value: selectedStatus,
                          decoration: InputDecoration(labelText: loc.translate('team_add_status')),
                          items: _statuses
                              .where((status) => status != 'All')
                              .map(
                                (status) => DropdownMenuItem<String>(
                                  value: status,
                                  child: Text(loc.translate('team_status_${_statusKey(status)}')),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            if (value == null) return;
                            setModalState(() => selectedStatus = value);
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: emailController,
                          decoration: InputDecoration(labelText: loc.translate('team_add_email')),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: locationController,
                          decoration: InputDecoration(labelText: loc.translate('team_add_location')),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: timezoneController,
                          decoration: InputDecoration(labelText: loc.translate('team_add_timezone')),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: focusController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(labelText: loc.translate('team_add_focus_hours')),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextFormField(
                                controller: tasksController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(labelText: loc.translate('team_add_tasks')),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: skillsController,
                          decoration: InputDecoration(labelText: loc.translate('team_add_skills')),
                        ),
                        const SizedBox(height: 16),
                        Text(loc.translate('team_capacity_label', params: {
                          'percent': (capacity * 100).toStringAsFixed(0),
                        })),
                        Slider(
                          value: capacity,
                          onChanged: (value) => setModalState(() => capacity = value),
                          min: 0.2,
                          max: 1,
                          divisions: 8,
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: Text(loc.translate('team_add_cancel')),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: FilledButton(
                                onPressed: () async {
                                  if (!formKey.currentState!.validate()) return;
                                  final focus = double.tryParse(focusController.text.trim()) ?? 12;
                                  final tasks = int.tryParse(tasksController.text.trim()) ?? 10;
                                  final skills = skillsController.text
                                      .split(',')
                                      .map((skill) => skill.trim())
                                      .where((skill) => skill.isNotEmpty)
                                      .toList();
                                  await controller.createMember(
                                    name: nameController.text.trim(),
                                    role: roleController.text.trim(),
                                    status: selectedStatus,
                                    email: emailController.text.trim(),
                                    location: locationController.text.trim(),
                                    timezone: timezoneController.text.trim(),
                                    focusHours: focus,
                                    tasks: tasks,
                                    capacity: capacity,
                                    skills: skills,
                                  );
                                  if (!mounted) return;
                                  Navigator.of(context).pop();
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(SnackBar(content: Text(loc.translate('team_add_success'))));
                                },
                                child: Text(loc.translate('team_add_save')),
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
      nameController.dispose();
      roleController.dispose();
      emailController.dispose();
      locationController.dispose();
      timezoneController.dispose();
      focusController.dispose();
      tasksController.dispose();
      skillsController.dispose();
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final material = MaterialLocalizations.of(context);
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openCreateMember,
        icon: const Icon(Icons.person_add_alt_1_rounded),
        label: Text(loc.translate('team_add_button')),
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: AnimatedBuilder(
          animation: controller,
          builder: (context, _) {
            final members = controller.members;
            final metrics = controller.metrics;
            final isLoading = controller.isLoading && members.isEmpty;
            final distribution = controller.distribution;
            final spotlight = controller.spotlight;

            return ListView(
              padding: EdgeInsets.zero,
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                const SizedBox(height: kToolbarHeight + 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        loc.translate('team'),
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        loc.translate('team_subtitle'),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 24),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final isWide = constraints.maxWidth > 680;
                          final width = isWide ? (constraints.maxWidth - 12) / 2 : constraints.maxWidth;
                          final cards = [
                            _SummaryCard(
                              icon: IconlyBold.user_1,
                              title: loc.translate('team_summary_members'),
                              value: metrics.total.toString(),
                            ),
                            _SummaryCard(
                              icon: IconlyBold.category,
                              title: loc.translate('team_summary_active'),
                              value: metrics.active.toString(),
                            ),
                            _SummaryCard(
                              icon: IconlyBold.time_circle,
                              title: loc.translate('team_summary_focus'),
                              value: '${metrics.averageFocus.toStringAsFixed(1)}h',
                            ),
                            _SummaryCard(
                              icon: Icons.chat_rounded,
                              title: loc.translate('team_summary_checkins'),
                              value: metrics.checkInsThisWeek.toString(),
                            ),
                          ];
                          return Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: cards
                                .map(
                                  (card) => SizedBox(
                                    width: isWide ? width : constraints.maxWidth,
                                    child: card,
                                  ),
                                )
                                .toList(),
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                      if (metrics.latestCheckIn != null)
                        _RecentCheckInCard(
                          checkIn: metrics.latestCheckIn!,
                          timeLabel: _formatLastActive(loc, material, metrics.latestCheckIn!.createdAt),
                          onViewTimeline: () {
                            final member = controller.memberById(metrics.latestCheckIn!.memberId);
                            if (member != null) {
                              _openMemberDetails(member);
                            }
                          },
                          onLog: () {
                            final member = controller.memberById(metrics.latestCheckIn!.memberId);
                            if (member != null) {
                              _openMemberDetails(member);
                            }
                          },
                        )
                      else
                        _RecentCheckInPlaceholder(
                          message: loc.translate('team_recent_check_in_empty'),
                          onLog: members.isNotEmpty ? () => _openMemberDetails(members.first) : null,
                        ),
                      const SizedBox(height: 24),
                      TextField(
                        controller: _searchController,
                        focusNode: _searchFocusNode,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.search),
                          hintText: loc.translate('team_search_hint'),
                        ),
                        onChanged: _onSearchChanged,
                        onSubmitted: controller.updateQuery,
                      ),
                      const SizedBox(height: 12),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: _statuses
                              .map(
                                (status) => Padding(
                                  padding: const EdgeInsetsDirectional.only(end: 12),
                                  child: ChoiceChip(
                                    label: Text(status == 'All'
                                        ? loc.translate('team_filter_all')
                                        : loc.translate('team_status_${_statusKey(status)}')),
                                    selected: controller.status.toLowerCase() == status.toLowerCase(),
                                    onSelected: (_) => controller.updateStatusFilter(status),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                      if (distribution.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: distribution.entries
                              .map(
                                (entry) => Chip(
                                  avatar: CircleAvatar(
                                    backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.12),
                                    child: Text(entry.value.toString()),
                                  ),
                                  label: Text(loc.translate('team_status_${_statusKey(entry.key)}')),
                                ),
                              )
                              .toList(),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            loc.translate('team_highlight_title'),
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const Spacer(),
                          if (metrics.favoriteCount > 0)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                loc.translate('team_summary_favorites', params: {
                                  'count': metrics.favoriteCount.toString(),
                                }),
                                style: Theme.of(context).textTheme.labelSmall,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (spotlight.isEmpty)
                        Text(
                          loc.translate('team_highlight_empty'),
                          style: Theme.of(context).textTheme.bodySmall,
                        )
                      else
                        SizedBox(
                          height: 160,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            padding: EdgeInsets.zero,
                            itemBuilder: (context, index) {
                              final member = spotlight[index];
                              return _SpotlightCard(
                                member: member,
                                statusLabel: loc.translate('team_status_${_statusKey(member.status)}'),
                                onTap: () => controller.updateStatusFilter(member.status),
                              );
                            },
                            separatorBuilder: (_, __) => const SizedBox(width: 16),
                            itemCount: spotlight.length,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                AnimatedCrossFade(
                  duration: const Duration(milliseconds: 250),
                  crossFadeState: isLoading ? CrossFadeState.showFirst : CrossFadeState.showSecond,
                  firstChild: const _TeamSkeleton(),
                  secondChild: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: members.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.only(top: 48),
                            child: Column(
                              children: [
                                Icon(Icons.groups_rounded, size: 48, color: Theme.of(context).colorScheme.primary),
                                const SizedBox(height: 12),
                                Text(
                                  loc.translate('team_empty_state'),
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                              ],
                            ),
                          )
                        : Column(
                            children: [
                              ...members.map(
                                (member) => Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: _TeamMemberCard(
                                    member: member,
                                    onFavorite: () => _toggleFavorite(member),
                                    onStatusChanged: (status) => _changeStatus(member, status),
                                    lastActiveLabel: _formatLastActive(loc, material, member.lastActive),
                                    onTap: () => _openMemberDetails(member),
                                  ),
                                ),
                              ),
                              if (controller.hasMore)
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  child: OutlinedButton(
                                    onPressed: controller.isLoadingMore ? null : controller.loadMore,
                                    child: controller.isLoadingMore
                                        ? const SizedBox(
                                            height: 18,
                                            width: 18,
                                            child: CircularProgressIndicator(strokeWidth: 2),
                                          )
                                        : Text(loc.translate('team_load_more')),
                                  ),
                                ),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            );
          },
        ),
      ),
    );
  }

  String _formatLastActive(AppLocalizations loc, MaterialLocalizations material, DateTime timestamp) {
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

  String _statusKey(String status) => status.toLowerCase().replaceAll(' ', '_');
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.icon, required this.title, required this.value});

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 12),
          Text(value, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(title, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _RecentCheckInCard extends StatelessWidget {
  const _RecentCheckInCard({
    required this.checkIn,
    required this.timeLabel,
    required this.onViewTimeline,
    required this.onLog,
  });

  final TeamCheckIn checkIn;
  final String timeLabel;
  final VoidCallback onViewTimeline;
  final VoidCallback onLog;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context);
    final sentimentColor = _sentimentColor(theme);
    final sentimentLabel = loc.translate('team_recent_check_in_sentiment_${checkIn.sentiment}');
    final highlights = checkIn.highlights.where((item) => item.trim().isNotEmpty).toList();
    final nextSteps = checkIn.nextSteps.where((item) => item.trim().isNotEmpty).toList();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 44,
                width: 44,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.auto_awesome_rounded),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  loc.translate('team_recent_check_in_title'),
                  style: theme.textTheme.titleMedium,
                ),
              ),
              Chip(
                label: Text(sentimentLabel),
                backgroundColor: sentimentColor.background,
                labelStyle: theme.textTheme.labelLarge?.copyWith(color: sentimentColor.foreground),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            checkIn.memberName,
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            checkIn.summary,
            style: theme.textTheme.bodyMedium,
          ),
          if (highlights.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(loc.translate('team_details_check_in_highlights_label'), style: theme.textTheme.labelMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: highlights
                  .map(
                    (item) => Chip(
                      label: Text(item),
                      backgroundColor: theme.colorScheme.primary.withOpacity(0.08),
                    ),
                  )
                  .toList(),
            ),
          ],
          if (nextSteps.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(loc.translate('team_details_check_in_next_label'), style: theme.textTheme.labelMedium),
            const SizedBox(height: 8),
            ...nextSteps.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    Icon(Icons.check_circle_rounded, size: 18, color: theme.colorScheme.primary),
                    const SizedBox(width: 8),
                    Expanded(child: Text(item, style: theme.textTheme.bodySmall)),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              Text(
                loc.translate('team_recent_check_in_by', params: {'author': checkIn.author}),
                style: theme.textTheme.labelSmall,
              ),
              const SizedBox(width: 12),
              const Icon(Icons.access_time_rounded, size: 16),
              const SizedBox(width: 4),
              Text(loc.translate('team_recent_check_in_time', params: {'time': timeLabel}), style: theme.textTheme.labelSmall),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              TextButton.icon(
                onPressed: onViewTimeline,
                icon: const Icon(Icons.visibility_rounded),
                label: Text(loc.translate('team_recent_check_in_cta')),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: onLog,
                icon: const Icon(Icons.note_add_rounded),
                label: Text(loc.translate('team_recent_check_in_log')),
              ),
            ],
          ),
        ],
      ),
    );
  }

  _SentimentPalette _sentimentColor(ThemeData theme) {
    switch (checkIn.sentiment) {
      case 'attention':
        return _SentimentPalette(
          background: theme.colorScheme.error.withOpacity(0.12),
          foreground: theme.colorScheme.error,
        );
      case 'neutral':
        return _SentimentPalette(
          background: theme.colorScheme.primary.withOpacity(0.08),
          foreground: theme.colorScheme.onSurface.withOpacity(0.7),
        );
      default:
        return _SentimentPalette(
          background: theme.colorScheme.primary.withOpacity(0.16),
          foreground: theme.colorScheme.primary,
        );
    }
  }
}

class _RecentCheckInPlaceholder extends StatelessWidget {
  const _RecentCheckInPlaceholder({required this.message, this.onLog});

  final String message;
  final VoidCallback? onLog;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 44,
                width: 44,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.auto_awesome_rounded),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  loc.translate('team_recent_check_in_title'),
                  style: theme.textTheme.titleMedium,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            message,
            style: theme.textTheme.bodyMedium,
          ),
          if (onLog != null) ...[
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onLog,
              icon: const Icon(Icons.note_add_rounded),
              label: Text(loc.translate('team_recent_check_in_log')),
            ),
          ],
        ],
      ),
    );
  }
}

class _SentimentPalette {
  const _SentimentPalette({required this.background, required this.foreground});

  final Color background;
  final Color foreground;
}

class _TeamMemberCard extends StatelessWidget {
  const _TeamMemberCard({
    required this.member,
    required this.onFavorite,
    required this.onStatusChanged,
    required this.lastActiveLabel,
    this.onTap,
  });

  final TeamMember member;
  final VoidCallback onFavorite;
  final ValueChanged<String> onStatusChanged;
  final String lastActiveLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Material(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(radius: 28, backgroundImage: NetworkImage(member.avatarUrl)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            member.name,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                          ),
                        ),
                        IconButton(
                          onPressed: onFavorite,
                          icon: Icon(member.favorite ? Icons.star_rounded : Icons.star_outline_rounded),
                          color: member.favorite ? Theme.of(context).colorScheme.primary : null,
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        _InfoChip(label: member.role, icon: IconlyLight.briefcase),
                        if (member.location.isNotEmpty)
                          _InfoChip(label: member.location, icon: IconlyLight.location),
                        if (member.timezone.isNotEmpty)
                          _InfoChip(label: member.timezone, icon: IconlyLight.time_circle),
                        _InfoChip(label: loc.translate('team_status_${member.status.toLowerCase().replaceAll(' ', '_')}'), icon: IconlyLight.user_1),
                      ],
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: onStatusChanged,
                itemBuilder: (context) {
                  return _TeamScreenState._statuses
                      .where((status) => status != 'All')
                      .map(
                        (status) => PopupMenuItem<String>(
                          value: status,
                          child: Text(loc.translate('team_status_${status.toLowerCase().replaceAll(' ', '_')}')),
                        ),
                      )
                      .toList();
                },
                icon: const Icon(Icons.more_vert),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      loc.translate('team_focus_hours', params: {'hours': member.focusHoursThisWeek.toStringAsFixed(1)}),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      loc.translate('team_tasks_this_week', params: {'count': member.tasksThisWeek.toString()}),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      loc.translate('team_member_since', params: {
                        'date': MaterialLocalizations.of(context).formatMediumDate(member.joinedOn),
                      }),
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 120,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(loc.translate('team_last_active_label'), style: Theme.of(context).textTheme.labelSmall),
                    const SizedBox(height: 4),
                    Text(lastActiveLabel, style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: LinearProgressIndicator(
              value: member.capacity,
              minHeight: 10,
              backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation(Theme.of(context).colorScheme.primary),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            loc.translate('team_capacity_label', params: {'percent': (member.capacity * 100).toStringAsFixed(0)}),
            style: Theme.of(context).textTheme.labelSmall,
          ),
          if (member.skills.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: member.skills
                  .map((skill) => Chip(label: Text('#$skill')))
                  .toList(),
            ),
          ],
        ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.12),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 6),
          Text(label, style: Theme.of(context).textTheme.labelSmall),
        ],
      ),
    );
  }
}

class _SpotlightCard extends StatelessWidget {
  const _SpotlightCard({required this.member, required this.statusLabel, required this.onTap});

  final TeamMember member;
  final String statusLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 200,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(backgroundImage: NetworkImage(member.avatarUrl)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        member.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      Text(statusLabel, style: Theme.of(context).textTheme.labelSmall),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded),
              ],
            ),
            const Spacer(),
            Text(
              member.role,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Text(
              '${member.tasksThisWeek} ${AppLocalizations.of(context).translate('team_spotlight_tasks')}',
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _TeamSkeleton extends StatelessWidget {
  const _TeamSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        SkeletonListItem(),
        SkeletonListItem(),
        SkeletonListItem(),
      ],
    );
  }
}

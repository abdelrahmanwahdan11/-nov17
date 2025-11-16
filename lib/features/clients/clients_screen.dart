import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/models/mock_data.dart';
import '../../shared/controllers/clients_controller.dart';
import '../../shared/controllers/workspace_scope.dart';
import '../../shared/skeletons/skeleton_widgets.dart';

class ClientsScreen extends StatefulWidget {
  const ClientsScreen({super.key});

  @override
  State<ClientsScreen> createState() => _ClientsScreenState();
}

class _ClientsScreenState extends State<ClientsScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  ClientsController? _controller;
  Timer? _debounce;

  ClientsController get controller => _controller ??= WorkspaceScope.of(context).clients;

  static const _stages = [
    'All',
    'Prospect',
    'Contacted',
    'Proposal',
    'Negotiation',
    'Won',
    'Lost',
  ];

  @override
  void didChangeDependencies() {
    final scope = WorkspaceScope.of(context);
    if (_controller != scope.clients) {
      _controller = scope.clients;
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

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final materialLoc = MaterialLocalizations.of(context);
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openCreateClient,
        icon: const Icon(Icons.person_add_alt_1_rounded),
        label: Text(loc.translate('clients_add_button')),
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: AnimatedBuilder(
          animation: controller,
          builder: (context, _) {
            final clients = controller.clients;
            final isLoading = controller.isLoading && clients.isEmpty;
            final stageCounts = controller.stageDistribution;
            final pipelineValue = controller.pipelineValue;
            final activeClients = controller.activeClients;
            final starredClients = controller.starredClients;

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
                        loc.translate('clients'),
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        loc.translate('clients_subtitle'),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: _SummaryCard(
                              title: loc.translate('clients_pipeline_value'),
                              value: '\$${pipelineValue.toStringAsFixed(0)}',
                              icon: Icons.trending_up,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _SummaryCard(
                              title: loc.translate('clients_active_clients'),
                              value: activeClients.toString(),
                              icon: Icons.groups_rounded,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _SummaryCard(
                              title: loc.translate('clients_starred_clients'),
                              value: starredClients.toString(),
                              icon: Icons.star_rounded,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      TextField(
                        controller: _searchController,
                        focusNode: _searchFocusNode,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.search),
                          hintText: loc.translate('clients_search_hint'),
                        ),
                        onChanged: _onSearchChanged,
                        onSubmitted: controller.updateQuery,
                      ),
                      const SizedBox(height: 12),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: _stages
                              .map(
                                (stage) => Padding(
                                  padding: const EdgeInsetsDirectional.only(end: 12),
                                  child: ChoiceChip(
                                    label: Text(loc.translate('clients_stage_${stage.toLowerCase()}')),
                                    selected: controller.stage.toLowerCase() == stage.toLowerCase(),
                                    onSelected: (_) => controller.updateStage(stage),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (stageCounts.isNotEmpty)
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: stageCounts.entries
                              .map(
                                (entry) => Chip(
                                  label: Text(
                                    '${loc.translate('clients_stage_${entry.key.toLowerCase()}')}: ${entry.value}',
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                AnimatedCrossFade(
                  duration: const Duration(milliseconds: 250),
                  crossFadeState: isLoading ? CrossFadeState.showFirst : CrossFadeState.showSecond,
                  firstChild: const _ClientsSkeleton(),
                  secondChild: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: clients.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.only(top: 48),
                            child: Column(
                              children: [
                                Icon(Icons.sentiment_satisfied_alt, size: 48, color: Theme.of(context).colorScheme.primary),
                                const SizedBox(height: 12),
                                Text(
                                  loc.translate('clients_empty_state'),
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                              ],
                            ),
                          )
                        : Column(
                            children: [
                              ...clients.map(
                                (client) => _ClientCard(
                                  client: client,
                                  onToggleStar: () => controller.toggleStarred(client),
                                  onStageChanged: (stage) => _updateStage(client, stage),
                                  onLogInteraction: () => _logInteraction(client),
                                  lastInteractionLabel: _formatLastInteraction(
                                    client.lastInteraction,
                                    loc,
                                    materialLoc,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              if (controller.hasMore)
                                Align(
                                  alignment: AlignmentDirectional.center,
                                  child: TextButton(
                                    onPressed: controller.isLoadingMore ? null : controller.loadMore,
                                    child: controller.isLoadingMore
                                        ? const SizedBox(
                                            width: 18,
                                            height: 18,
                                            child: CircularProgressIndicator(strokeWidth: 2),
                                          )
                                        : Text(loc.translate('clients_load_more')),
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

  String _formatLastInteraction(DateTime timestamp, AppLocalizations loc, MaterialLocalizations materialLoc) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    String value;
    if (difference.inMinutes <= 1) {
      value = loc.translate('clients_last_contact_now');
    } else if (difference.inHours < 1) {
      value = loc.translate('clients_last_contact_minutes', params: {
        'minutes': difference.inMinutes.toString(),
      });
    } else if (difference.inDays == 0) {
      final time = materialLoc.formatTimeOfDay(TimeOfDay.fromDateTime(timestamp));
      value = loc.translate('clients_last_contact_today', params: {'time': time});
    } else if (difference.inDays == 1) {
      final time = materialLoc.formatTimeOfDay(TimeOfDay.fromDateTime(timestamp));
      value = loc.translate('clients_last_contact_yesterday', params: {'time': time});
    } else if (difference.inDays < 7) {
      value = loc.translate('clients_last_contact_days', params: {'days': difference.inDays.toString()});
    } else {
      value = loc.translate('clients_last_contact_date', params: {
        'date': materialLoc.formatShortDate(timestamp),
      });
    }
    return loc.translate('clients_last_contact', params: {'value': value});
  }

  void _updateStage(Client client, String stage) async {
    final loc = AppLocalizations.of(context);
    await controller.updateStageFor(client, stage);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(loc.translate('clients_stage_updated'))),
    );
  }

  void _logInteraction(Client client) {
    final loc = AppLocalizations.of(context);
    final formKey = GlobalKey<FormState>();
    final noteController = TextEditingController();
    String type = 'Call';
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(loc.translate('clients_interaction_title'), style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: type,
                  decoration: InputDecoration(labelText: loc.translate('clients_interaction_type_label')),
                  items: ['Call', 'Email', 'Meeting']
                      .map(
                        (entry) => DropdownMenuItem(
                          value: entry,
                          child: Text(loc.translate('clients_interaction_type_${entry.toLowerCase()}')),
                        ),
                      )
                      .toList(),
                  onChanged: (value) => type = value ?? 'Call',
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: noteController,
                  maxLines: 3,
                  decoration: InputDecoration(hintText: loc.translate('clients_interaction_note_hint')),
                  validator: (value) => value == null || value.trim().isEmpty ? loc.translate('clients_interaction_note_error') : null,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(loc.translate('clients_form_cancel')),
                    ),
                    const Spacer(),
                    FilledButton(
                      onPressed: () {
                        if (!formKey.currentState!.validate()) return;
                        controller
                            .logInteraction(client: client, type: type, note: noteController.text.trim())
                            .then((_) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(loc.translate('clients_interaction_logged'))),
                          );
                        });
                      },
                      child: Text(loc.translate('clients_interaction_save')),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _openCreateClient() {
    final loc = AppLocalizations.of(context);
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final companyController = TextEditingController();
    final valueController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();
    final notesController = TextEditingController();
    final tagsController = TextEditingController();
    String stage = 'Prospect';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(loc.translate('clients_form_title'), style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: nameController,
                    decoration: InputDecoration(labelText: loc.translate('clients_form_name')),
                    validator: (value) => value == null || value.trim().isEmpty ? loc.translate('clients_form_name_error') : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: companyController,
                    decoration: InputDecoration(labelText: loc.translate('clients_form_company')),
                    validator: (value) => value == null || value.trim().isEmpty ? loc.translate('clients_form_company_error') : null,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: stage,
                    decoration: InputDecoration(labelText: loc.translate('clients_form_stage')),
                    items: _stages
                        .where((value) => value != 'All')
                        .map(
                          (entry) => DropdownMenuItem(
                            value: entry,
                            child: Text(loc.translate('clients_stage_${entry.toLowerCase()}')),
                          ),
                        )
                        .toList(),
                    onChanged: (value) => stage = value ?? 'Prospect',
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: valueController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(labelText: loc.translate('clients_form_value')),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: emailController,
                    decoration: InputDecoration(labelText: loc.translate('clients_form_email')),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: phoneController,
                    decoration: InputDecoration(labelText: loc.translate('clients_form_phone')),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: tagsController,
                    decoration: InputDecoration(labelText: loc.translate('clients_form_tags_hint')),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: notesController,
                    maxLines: 3,
                    decoration: InputDecoration(labelText: loc.translate('clients_form_notes')),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(loc.translate('clients_form_cancel')),
                      ),
                      const Spacer(),
                      FilledButton(
                        onPressed: () {
                          if (!formKey.currentState!.validate()) return;
                          final value = double.tryParse(valueController.text.replaceAll(',', '')) ?? 0;
                          final tags = tagsController.text
                              .split(',')
                              .map((tag) => tag.trim())
                              .where((tag) => tag.isNotEmpty)
                              .toList();
                          controller
                              .createClient(
                                name: nameController.text.trim(),
                                company: companyController.text.trim(),
                                stage: stage,
                                value: value,
                                email: emailController.text.trim(),
                                phone: phoneController.text.trim(),
                                notes: notesController.text.trim(),
                                tags: tags,
                              )
                              .then((_) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(loc.translate('clients_form_created'))),
                            );
                          });
                        },
                        child: Text(loc.translate('clients_form_save')),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  final String title;
  final String value;
  final IconData icon;

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
          const SizedBox(height: 16),
          Text(value, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text(title, style: Theme.of(context).textTheme.labelMedium),
        ],
      ),
    );
  }
}

class _ClientCard extends StatelessWidget {
  const _ClientCard({
    required this.client,
    required this.onToggleStar,
    required this.onStageChanged,
    required this.onLogInteraction,
    required this.lastInteractionLabel,
  });

  final Client client;
  final VoidCallback onToggleStar;
  final ValueChanged<String> onStageChanged;
  final VoidCallback onLogInteraction;
  final String lastInteractionLabel;

  static const _stageOptions = [
    'Prospect',
    'Contacted',
    'Proposal',
    'Negotiation',
    'Won',
    'Lost',
  ];

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      client.name,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(client.company, style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              ),
              IconButton(
                onPressed: onToggleStar,
                icon: Icon(
                  client.starred ? Icons.star_rounded : Icons.star_outline_rounded,
                  color: client.starred ? Theme.of(context).colorScheme.primary : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Chip(
                label: Text(loc.translate('clients_stage_${client.stage.toLowerCase()}')),
              ),
              const SizedBox(width: 12),
              Text(
                '\$${client.value.toStringAsFixed(0)}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const Spacer(),
              Text(lastInteractionLabel, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
          if (client.tags.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: client.tags
                  .map((tag) => Chip(
                        label: Text(tag),
                        visualDensity: VisualDensity.compact,
                      ))
                  .toList(),
            ),
          ],
          if (client.notes.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              client.notes,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              FilledButton.tonal(
                onPressed: onLogInteraction,
                child: Text(loc.translate('clients_log_interaction')),
              ),
              const SizedBox(width: 12),
              PopupMenuButton<String>(
                onSelected: onStageChanged,
                itemBuilder: (context) {
                  return _stageOptions
                      .map(
                        (stage) => PopupMenuItem(
                          value: stage,
                          child: Row(
                            children: [
                              if (stage == client.stage)
                                Icon(Icons.check, size: 16, color: Theme.of(context).colorScheme.primary)
                              else
                                const SizedBox(width: 16),
                              const SizedBox(width: 8),
                              Text(loc.translate('clients_stage_${stage.toLowerCase()}')),
                            ],
                          ),
                        ),
                      )
                      .toList();
                },
                child: Chip(
                  avatar: const Icon(Icons.swap_horiz, size: 18),
                  label: Text(loc.translate('clients_change_stage')),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ClientsSkeleton extends StatelessWidget {
  const _ClientsSkeleton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: const [
          SkeletonContainer(height: 180),
          SizedBox(height: 16),
          SkeletonContainer(height: 180),
          SizedBox(height: 16),
          SkeletonContainer(height: 180),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';

import '../../core/localization/app_localizations.dart';
import '../controllers/app_controller.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({
    super.key,
    required this.controller,
    required this.selectedIndex,
    required this.onNavigate,
    required this.destinations,
  });

  final AppController controller;
  final int selectedIndex;
  final ValueChanged<int> onNavigate;
  final List<String> destinations;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final icons = const [
      IconlyBold.category,
      IconlyBold.work,
      IconlyBold.paper,
      IconlyBold.calendar,
      IconlyBold.wallet,
      IconlyBold.setting,
      IconlyBold.buy,
      IconlyBold.activity,
      IconlyBold.search,
      IconlyBold.notification,
      IconlyBold.profile,
    ];

    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundImage: const NetworkImage('https://i.pravatar.cc/150?img=8'),
                    backgroundColor: Theme.of(context).colorScheme.surface,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Alya Hassan',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Row(
                          children: [
                            Text(
                              'alya@connecq.app',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(controller.locale.languageCode.toUpperCase()),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: destinations.length,
                itemBuilder: (context, index) {
                  final selected = index == selectedIndex;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    decoration: BoxDecoration(
                      color: selected
                          ? Theme.of(context).colorScheme.primary.withOpacity(0.15)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: ListTile(
                      leading: Icon(icons[index], color: Theme.of(context).colorScheme.primary),
                      title: Text(destinations[index]),
                      onTap: () => onNavigate(index),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(loc.translate('app_title'), style: Theme.of(context).textTheme.labelSmall),
            ),
          ],
        ),
      ),
    );
  }
}

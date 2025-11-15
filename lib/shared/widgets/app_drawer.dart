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
    final userName = controller.displayName;
    final email = controller.displayEmail;
    final icons = const [
      IconlyBold.category,
      IconlyBold.work,
      IconlyBold.paper,
      IconlyBold.calendar,
      IconlyBold.wallet,
      IconlyBold.user_1,
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
                  const CircleAvatar(
                    radius: 28,
                    backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=8'),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userName,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                email,
                                style: Theme.of(context).textTheme.bodySmall,
                                overflow: TextOverflow.ellipsis,
                              ),
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
                        const SizedBox(height: 8),
                        Text(
                          loc.translate('profile_trial', params: {'days': '12'}),
                          style: Theme.of(context).textTheme.labelSmall,
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

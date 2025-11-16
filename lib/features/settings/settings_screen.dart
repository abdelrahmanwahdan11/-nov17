import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/routing/app_routes.dart';
import '../../shared/controllers/app_controller.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key, required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final palette = const [
      Color(0xFFD9E272),
      Color(0xFF7ED0F5),
      Color(0xFFF9B170),
      Color(0xFFB982FF),
      Color(0xFFFF6B6B),
    ];
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                const CircleAvatar(radius: 36, backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=11')),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(controller.displayName, style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(controller.displayEmail),
                    Text(loc.translate('profile_trial', params: {'days': '12'})),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        SwitchListTile(
          value: controller.themeMode == ThemeMode.dark,
          onChanged: (value) => controller.updateThemeMode(value ? ThemeMode.dark : ThemeMode.light),
          title: Text(loc.translate('dark_mode')),
        ),
        const SizedBox(height: 12),
        Text(loc.translate('primary_color'), style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          children: palette
              .map(
                (color) => GestureDetector(
                  onTap: () => controller.updatePrimaryColor(color),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(color: controller.primaryColor == color ? Colors.black : Colors.transparent, width: 2),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 24),
        Text(loc.translate('language'), style: Theme.of(context).textTheme.titleMedium),
        RadioListTile(
          value: const Locale('en'),
          groupValue: controller.locale,
          onChanged: (locale) => controller.updateLocale(locale!),
          title: Text(loc.translate('language_en')),
        ),
        RadioListTile(
          value: const Locale('ar'),
          groupValue: controller.locale,
          onChanged: (locale) => controller.updateLocale(locale!),
          title: Text(loc.translate('language_ar')),
        ),
        const SizedBox(height: 24),
        ListTile(
          leading: const Icon(IconlyBold.graph),
          title: Text(loc.translate('workspace_goals')),
          subtitle: Text(loc.translate('settings_goals_subtitle')),
          onTap: () => Navigator.pushNamed(context, AppRoutes.goals),
        ),
      ],
    );
  }
}

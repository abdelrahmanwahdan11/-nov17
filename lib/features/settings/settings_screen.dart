import 'package:flutter/material.dart';

import '../../shared/controllers/app_controller.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key, required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
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
                  children: const [
                    Text('Alya Hassan', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('alya@connecq.app'),
                    Text('Trial ends in 12 days'),
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
          title: const Text('Dark Mode'),
        ),
        const SizedBox(height: 12),
        Text('Primary color', style: Theme.of(context).textTheme.titleMedium),
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
        Text('Language', style: Theme.of(context).textTheme.titleMedium),
        RadioListTile(
          value: const Locale('en'),
          groupValue: controller.locale,
          onChanged: (locale) => controller.updateLocale(locale!),
          title: const Text('English'),
        ),
        RadioListTile(
          value: const Locale('ar'),
          groupValue: controller.locale,
          onChanged: (locale) => controller.updateLocale(locale!),
          title: const Text('العربية'),
        ),
      ],
    );
  }
}

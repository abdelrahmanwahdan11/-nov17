import 'package:flutter/material.dart';

import '../../core/routing/app_routes.dart';

class ToolsScreen extends StatelessWidget {
  const ToolsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tools = [
      ('Calendar', AppRoutes.calendar),
      ('Scheduler', AppRoutes.scheduler),
      ('My Templates', AppRoutes.templates),
      ('My Library', AppRoutes.library),
      ('Time Tracker', AppRoutes.timeTracker),
      ('All Tasks', AppRoutes.tasks),
    ];
    return ListView.builder(
      padding: const EdgeInsets.only(top: kToolbarHeight + 16),
      itemCount: tools.length,
      itemBuilder: (context, index) {
        final item = tools[index];
        return ListTile(
          title: Text(item.$1),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => Navigator.pushNamed(context, item.$2),
        );
      },
    );
  }
}

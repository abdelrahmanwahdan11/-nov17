import 'package:flutter/material.dart';

class SchedulerScreen extends StatelessWidget {
  const SchedulerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final schedule = [
      ('09:00', 'Standup'),
      ('11:00', 'Design review'),
      ('15:00', 'Client call'),
    ];
    return Scaffold(
      appBar: AppBar(title: const Text('Scheduler')),
      body: ListView.builder(
        itemCount: schedule.length,
        itemBuilder: (context, index) {
          final item = schedule[index];
          return ListTile(
            title: Text(item.$2),
            subtitle: Text(item.$1),
            trailing: const Icon(Icons.edit_calendar),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
    );
  }
}

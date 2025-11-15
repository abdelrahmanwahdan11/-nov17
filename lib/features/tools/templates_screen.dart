import 'package:flutter/material.dart';

class TemplatesScreen extends StatelessWidget {
  const TemplatesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final templates = ['Sales deck', 'Project kickoff', 'Product demo'];
    return Scaffold(
      appBar: AppBar(title: const Text('Templates')),
      body: ListView.builder(
        itemCount: templates.length,
        itemBuilder: (context, index) {
          final template = templates[index];
          return ListTile(
            title: Text(template),
            trailing: const Icon(Icons.chevron_right),
          );
        },
      ),
    );
  }
}

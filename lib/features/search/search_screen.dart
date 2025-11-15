import 'package:flutter/material.dart';

import '../../core/models/mock_data.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final results = {
      'Projects': projectsMock.where((p) => p.title.toLowerCase().contains(_query)).toList(),
      'Tasks': tasksMock.where((t) => t.title.toLowerCase().contains(_query)).toList(),
      'Catalog': catalogMock.where((c) => c.title.toLowerCase().contains(_query)).toList(),
    };
    return Scaffold(
      appBar: AppBar(title: const Text('Search')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(
              decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Search anything'),
              onChanged: (value) => setState(() => _query = value.toLowerCase()),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView(
                children: results.entries
                    .map(
                      (entry) => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(entry.key, style: Theme.of(context).textTheme.titleMedium),
                          ...entry.value.map((item) => ListTile(title: Text(item.title))).toList(),
                          const SizedBox(height: 12),
                        ],
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

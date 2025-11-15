class Project {
  Project({required this.title, required this.priority, required this.progress, required this.index});

  final String title;
  final String priority;
  final double progress;
  final int index;
}

class Task {
  Task({required this.title, required this.priority, required this.status, required this.dueDate, required this.hours});

  final String title;
  final String priority;
  final String status;
  final DateTime dueDate;
  final double hours;
}

class CatalogItem {
  CatalogItem({required this.title, required this.type, required this.priority, required this.summary});

  final String title;
  final String type;
  final String priority;
  final String summary;
}

final projectsMock = [
  Project(title: 'ConnecQ Landing', priority: 'High', progress: 0.82, index: 1),
  Project(title: 'CRM Integration', priority: 'Medium', progress: 0.45, index: 2),
  Project(title: 'Finance Cleanup', priority: 'Low', progress: 0.28, index: 3),
];

final tasksMock = [
  Task(title: 'Sales Sync', priority: 'High', status: 'In Progress', dueDate: DateTime.now(), hours: 3.5),
  Task(title: 'Design Review', priority: 'Medium', status: 'Upcoming', dueDate: DateTime.now().add(const Duration(days: 1)), hours: 2.0),
  Task(title: 'Ops Alignment', priority: 'Low', status: 'Done', dueDate: DateTime.now().subtract(const Duration(days: 1)), hours: 1.5),
];

final catalogMock = [
  CatalogItem(title: 'Sales Pipeline Template', type: 'Template', priority: 'High', summary: 'A ready-made pipeline template.'),
  CatalogItem(title: 'Design Brief Doc', type: 'Document', priority: 'Medium', summary: 'Outline for product launch assets.'),
];

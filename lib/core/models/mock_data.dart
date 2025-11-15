import 'dart:math';

class Project {
  Project({
    required this.id,
    required this.title,
    required this.priority,
    required this.progress,
    required this.index,
    required this.status,
    required this.dueDate,
    required this.estimatedHours,
    required this.tags,
  });

  final String id;
  final String title;
  final String priority;
  final double progress;
  final int index;
  final String status;
  final DateTime dueDate;
  final double estimatedHours;
  final List<String> tags;

  Project copyWith({
    String? title,
    String? priority,
    double? progress,
    int? index,
    String? status,
    DateTime? dueDate,
    double? estimatedHours,
    List<String>? tags,
  }) {
    return Project(
      id: id,
      title: title ?? this.title,
      priority: priority ?? this.priority,
      progress: progress ?? this.progress,
      index: index ?? this.index,
      status: status ?? this.status,
      dueDate: dueDate ?? this.dueDate,
      estimatedHours: estimatedHours ?? this.estimatedHours,
      tags: tags ?? this.tags,
    );
  }
}

class Task {
  Task({
    required this.id,
    required this.title,
    required this.priority,
    required this.status,
    required this.dueDate,
    required this.hours,
    required this.description,
    required this.category,
  });

  final String id;
  final String title;
  final String priority;
  final String status;
  final DateTime dueDate;
  final double hours;
  final String description;
  final String category;

  Task copyWith({
    String? title,
    String? priority,
    String? status,
    DateTime? dueDate,
    double? hours,
    String? description,
    String? category,
  }) {
    return Task(
      id: id,
      title: title ?? this.title,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      dueDate: dueDate ?? this.dueDate,
      hours: hours ?? this.hours,
      description: description ?? this.description,
      category: category ?? this.category,
    );
  }
}

class CatalogItem {
  CatalogItem({
    required this.id,
    required this.title,
    required this.type,
    required this.priority,
    required this.summary,
    required this.tags,
    required this.estimatedHours,
  });

  final String id;
  final String title;
  final String type;
  final String priority;
  final String summary;
  final List<String> tags;
  final double estimatedHours;
}

class AppNotification {
  AppNotification({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.timestamp,
    this.read = false,
    this.pinned = false,
    this.relatedRoute,
  });

  final String id;
  final String title;
  final String subtitle;
  final DateTime timestamp;
  final bool read;
  final bool pinned;
  final String? relatedRoute;

  AppNotification copyWith({
    String? title,
    String? subtitle,
    DateTime? timestamp,
    bool? read,
    bool? pinned,
    String? relatedRoute,
  }) {
    return AppNotification(
      id: id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      timestamp: timestamp ?? this.timestamp,
      read: read ?? this.read,
      pinned: pinned ?? this.pinned,
      relatedRoute: relatedRoute ?? this.relatedRoute,
    );
  }
}

final _random = Random(7);

List<Project> seedProjects() {
  final now = DateTime.now();
  return [
    Project(
      id: 'proj-landing',
      title: 'ConnecQ Landing Refresh',
      priority: 'High',
      progress: 0.82,
      index: 1,
      status: 'In Review',
      dueDate: now.add(const Duration(days: 6)),
      estimatedHours: 48,
      tags: const ['marketing', 'design'],
    ),
    Project(
      id: 'proj-crm',
      title: 'CRM Integration Sprint',
      priority: 'High',
      progress: 0.58,
      index: 2,
      status: 'In Progress',
      dueDate: now.add(const Duration(days: 12)),
      estimatedHours: 64,
      tags: const ['sales', 'api'],
    ),
    Project(
      id: 'proj-ops',
      title: 'Operations Alignment',
      priority: 'Medium',
      progress: 0.34,
      index: 3,
      status: 'Planning',
      dueDate: now.add(const Duration(days: 21)),
      estimatedHours: 32,
      tags: const ['ops'],
    ),
    Project(
      id: 'proj-finance',
      title: 'Finance Cleanup',
      priority: 'Low',
      progress: 0.28,
      index: 4,
      status: 'Blocked',
      dueDate: now.add(const Duration(days: 18)),
      estimatedHours: 24,
      tags: const ['finance'],
    ),
    Project(
      id: 'proj-mobile',
      title: 'Mobile Dashboard Polish',
      priority: 'High',
      progress: 0.67,
      index: 5,
      status: 'In Progress',
      dueDate: now.add(const Duration(days: 9)),
      estimatedHours: 52,
      tags: const ['mobile', 'ui'],
    ),
    Project(
      id: 'proj-training',
      title: 'Client Training Toolkit',
      priority: 'Medium',
      progress: 0.46,
      index: 6,
      status: 'In Progress',
      dueDate: now.add(const Duration(days: 15)),
      estimatedHours: 36,
      tags: const ['training'],
    ),
    Project(
      id: 'proj-brand',
      title: 'Brand Elements Update',
      priority: 'Low',
      progress: 0.19,
      index: 7,
      status: 'Backlog',
      dueDate: now.add(const Duration(days: 30)),
      estimatedHours: 20,
      tags: const ['brand', 'design'],
    ),
    Project(
      id: 'proj-insights',
      title: 'Insights Automation',
      priority: 'High',
      progress: 0.41,
      index: 8,
      status: 'Planning',
      dueDate: now.add(const Duration(days: 25)),
      estimatedHours: 58,
      tags: const ['automation'],
    ),
    Project(
      id: 'proj-catalog',
      title: 'Catalog Expansion',
      priority: 'Medium',
      progress: 0.52,
      index: 9,
      status: 'In Progress',
      dueDate: now.add(const Duration(days: 11)),
      estimatedHours: 42,
      tags: const ['catalog'],
    ),
    Project(
      id: 'proj-support',
      title: 'Support Playbook',
      priority: 'Low',
      progress: 0.23,
      index: 10,
      status: 'Draft',
      dueDate: now.add(const Duration(days: 28)),
      estimatedHours: 18,
      tags: const ['support'],
    ),
  ];
}

List<Task> seedTasks() {
  final now = DateTime.now();
  return List.generate(18, (index) {
    final dayOffset = index - 6;
    final titles = [
      'Sales Sync',
      'Design Review',
      'Ops Alignment',
      'Product Demo',
      'Finance Hand-off',
      'AI Workshop',
    ];
    final priorities = ['High', 'Medium', 'Low'];
    final statuses = ['In Progress', 'Upcoming', 'Done'];
    final title = titles[index % titles.length];
    return Task(
      id: 'task-$index',
      title: '$title ${index + 1}',
      priority: priorities[index % priorities.length],
      status: statuses[index % statuses.length],
      dueDate: now.add(Duration(days: dayOffset)),
      hours: 1.5 + _random.nextInt(4),
      description: 'Detailed steps to complete $title ${index + 1} with cross-team visibility.',
      category: ['Sales', 'Design', 'Operations'][index % 3],
    );
  });
}

List<CatalogItem> seedCatalog() {
  final items = <CatalogItem>[
    CatalogItem(
      id: 'cat-template-sales',
      title: 'Sales Pipeline Template',
      type: 'Template',
      priority: 'High',
      summary: 'Structured template for managing sales leads from intake to close.',
      tags: const ['sales', 'template'],
      estimatedHours: 6,
    ),
    CatalogItem(
      id: 'cat-brief-design',
      title: 'Design Brief Document',
      type: 'Document',
      priority: 'Medium',
      summary: 'Creative brief for product launch assets and messaging.',
      tags: const ['design', 'document'],
      estimatedHours: 4,
    ),
    CatalogItem(
      id: 'cat-meeting',
      title: 'Weekly Sync Agenda',
      type: 'Template',
      priority: 'Low',
      summary: 'Reusable agenda for weekly leadership sync meetings.',
      tags: const ['operations', 'meeting'],
      estimatedHours: 2,
    ),
    CatalogItem(
      id: 'cat-checklist',
      title: 'Onboarding Checklist',
      type: 'Task',
      priority: 'High',
      summary: 'Step-by-step tasks for onboarding new teammates.',
      tags: const ['people', 'template'],
      estimatedHours: 5,
    ),
    CatalogItem(
      id: 'cat-finance',
      title: 'Quarterly Finance Template',
      type: 'Template',
      priority: 'Medium',
      summary: 'Spreadsheet layout for finance reviews with neon markers.',
      tags: const ['finance'],
      estimatedHours: 7,
    ),
    CatalogItem(
      id: 'cat-guide-ai',
      title: 'AI Prompt Guide',
      type: 'Document',
      priority: 'Medium',
      summary: 'Best practices to collaborate with the coming ConnecQ AI assistant.',
      tags: const ['ai', 'document'],
      estimatedHours: 3,
    ),
    CatalogItem(
      id: 'cat-template-project',
      title: 'Project Kick-off Pack',
      type: 'Template',
      priority: 'High',
      summary: 'Checklist and timeline to kick-off new strategic initiatives.',
      tags: const ['project', 'template'],
      estimatedHours: 8,
    ),
    CatalogItem(
      id: 'cat-ops-kit',
      title: 'Operations Starter Kit',
      type: 'Document',
      priority: 'Low',
      summary: 'Reference pack for new operations coordinators.',
      tags: const ['operations'],
      estimatedHours: 3,
    ),
  ];
  return items;
}

List<AppNotification> seedNotifications() {
  final now = DateTime.now();
  return [
    AppNotification(
      id: 'notif-1',
      title: 'CRM Integration updated',
      subtitle: 'New milestone added to sprint backlog',
      timestamp: now.subtract(const Duration(minutes: 12)),
      pinned: true,
      relatedRoute: 'projects',
    ),
    AppNotification(
      id: 'notif-2',
      title: 'Finance goal reached 72%',
      subtitle: 'Revenue is tracking ahead of forecast',
      timestamp: now.subtract(const Duration(hours: 2)),
      pinned: true,
      relatedRoute: 'finance',
    ),
    AppNotification(
      id: 'notif-3',
      title: 'New catalog items ready',
      subtitle: 'Three pastel templates were curated for you',
      timestamp: now.subtract(const Duration(days: 1, hours: 3)),
      relatedRoute: 'catalog',
    ),
    AppNotification(
      id: 'notif-4',
      title: 'Ops Alignment task completed',
      subtitle: 'Najla marked the task as done',
      timestamp: now.subtract(const Duration(days: 2, hours: 5)),
      relatedRoute: 'tasks',
    ),
  ];
}

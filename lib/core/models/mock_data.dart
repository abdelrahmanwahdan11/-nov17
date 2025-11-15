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

class ScheduleEntry {
  ScheduleEntry({
    required this.id,
    required this.title,
    required this.description,
    required this.start,
    required this.end,
    required this.tag,
  });

  final String id;
  final String title;
  final String description;
  final DateTime start;
  final DateTime end;
  final String tag;

  Duration get duration => end.difference(start);

  ScheduleEntry copyWith({
    String? title,
    String? description,
    DateTime? start,
    DateTime? end,
    String? tag,
  }) {
    return ScheduleEntry(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      start: start ?? this.start,
      end: end ?? this.end,
      tag: tag ?? this.tag,
    );
  }
}

class TemplateItem {
  TemplateItem({
    required this.id,
    required this.title,
    required this.type,
    required this.category,
    required this.summary,
    required this.estimatedHours,
    required this.tags,
    this.popular = false,
  });

  final String id;
  final String title;
  final String type;
  final String category;
  final String summary;
  final double estimatedHours;
  final List<String> tags;
  final bool popular;
}

class FinanceSnapshot {
  FinanceSnapshot({
    required this.id,
    required this.label,
    required this.period,
    required this.revenue,
    required this.expenses,
    required this.goal,
    required this.trend,
  });

  final String id;
  final String label;
  final DateTime period;
  final double revenue;
  final double expenses;
  final double goal;
  final double trend;

  double get net => revenue - expenses;
  double get progress => goal == 0 ? 0 : (revenue / goal).clamp(0, 1);

  FinanceSnapshot copyWith({
    String? label,
    DateTime? period,
    double? revenue,
    double? expenses,
    double? goal,
    double? trend,
  }) {
    return FinanceSnapshot(
      id: id,
      label: label ?? this.label,
      period: period ?? this.period,
      revenue: revenue ?? this.revenue,
      expenses: expenses ?? this.expenses,
      goal: goal ?? this.goal,
      trend: trend ?? this.trend,
    );
  }
}

class Invoice {
  Invoice({
    required this.id,
    required this.client,
    required this.title,
    required this.amount,
    required this.dueDate,
    required this.status,
  });

  final String id;
  final String client;
  final String title;
  final double amount;
  final DateTime dueDate;
  final String status;

  bool isOverdue([DateTime? reference]) {
    final check = reference ?? DateTime.now();
    return dueDate.isBefore(check) && status.toLowerCase() != 'paid';
  }

  Invoice copyWith({
    String? client,
    String? title,
    double? amount,
    DateTime? dueDate,
    String? status,
  }) {
    return Invoice(
      id: id,
      client: client ?? this.client,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      dueDate: dueDate ?? this.dueDate,
      status: status ?? this.status,
    );
  }
}

class LibraryItem {
  LibraryItem({
    required this.id,
    required this.title,
    required this.type,
    required this.updatedAt,
    required this.summary,
    required this.author,
    required this.link,
  });

  final String id;
  final String title;
  final String type;
  final DateTime updatedAt;
  final String summary;
  final String author;
  final String link;
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

List<ScheduleEntry> seedSchedule() {
  final now = DateTime.now();
  DateTime at(int hour, int minute) => DateTime(now.year, now.month, now.day, hour, minute);
  return [
    ScheduleEntry(
      id: 'schedule-1',
      title: 'Daily standup',
      description: 'Sync with the product squad on delivery focus.',
      start: at(9, 0),
      end: at(9, 30),
      tag: 'Team',
    ),
    ScheduleEntry(
      id: 'schedule-2',
      title: 'Design QA',
      description: 'Review pastel theming on mobile layouts.',
      start: at(11, 0),
      end: at(12, 0),
      tag: 'Design',
    ),
    ScheduleEntry(
      id: 'schedule-3',
      title: 'Client onboarding',
      description: 'Walkthrough of ConnecQ workspace with the new partner.',
      start: at(14, 30),
      end: at(15, 30),
      tag: 'Client',
    ),
    ScheduleEntry(
      id: 'schedule-4',
      title: 'Focus block',
      description: 'Heads-down time to craft finance dashboards.',
      start: at(16, 0),
      end: at(18, 0),
      tag: 'Deep Work',
    ),
  ];
}

List<TemplateItem> seedTemplates() {
  return [
    TemplateItem(
      id: 'template-1',
      title: 'Sales discovery flow',
      type: 'Sales',
      category: 'Pipeline',
      summary: 'Capture discovery notes, qualifying questions, and follow-up tasks in one flow.',
      estimatedHours: 4,
      tags: const ['sales', 'crm', 'call scripts'],
      popular: true,
    ),
    TemplateItem(
      id: 'template-2',
      title: 'Motion design sprint',
      type: 'Design',
      category: 'Creative',
      summary: 'Storyboard, prototype, and review sequences with daily checkpoints.',
      estimatedHours: 16,
      tags: const ['design', 'animation', 'review'],
    ),
    TemplateItem(
      id: 'template-3',
      title: 'Weekly leadership sync',
      type: 'Operations',
      category: 'Meetings',
      summary: 'Align leadership KPIs, highlight blockers, and document decisions.',
      estimatedHours: 2,
      tags: const ['operations', 'leadership', 'agenda'],
      popular: true,
    ),
    TemplateItem(
      id: 'template-4',
      title: 'Campaign launch checklist',
      type: 'Marketing',
      category: 'Campaigns',
      summary: 'Plan creative, channels, QA, and post-launch review in pastel clarity.',
      estimatedHours: 10,
      tags: const ['marketing', 'campaign', 'qa'],
    ),
    TemplateItem(
      id: 'template-5',
      title: 'Customer success playbook',
      type: 'Success',
      category: 'Customer',
      summary: 'Document health scoring, renewal prompts, and expansion experiments.',
      estimatedHours: 6,
      tags: const ['success', 'renewal', 'playbook'],
    ),
    TemplateItem(
      id: 'template-6',
      title: 'Product discovery workshop',
      type: 'Product',
      category: 'Workshops',
      summary: 'Facilitate opportunity mapping, research synthesis, and prioritisation.',
      estimatedHours: 12,
      tags: const ['product', 'discovery', 'research'],
      popular: true,
    ),
  ];
}

List<LibraryItem> seedLibraryItems() {
  final now = DateTime.now();
  return [
    LibraryItem(
      id: 'library-1',
      title: 'ConnecQ brand deck',
      type: 'Presentation',
      updatedAt: now.subtract(const Duration(days: 2)),
      summary: 'All typography, color, and tone rules for the pastel workspace experience.',
      author: 'Brand Studio',
      link: 'https://dribbble.com/shots/12345678',
    ),
    LibraryItem(
      id: 'library-2',
      title: 'Finance automation SOP',
      type: 'Document',
      updatedAt: now.subtract(const Duration(days: 6)),
      summary: 'Step-by-step automation blueprint for revenue reconciliation.',
      author: 'Finance Guild',
      link: 'https://www.notion.so',
    ),
    LibraryItem(
      id: 'library-3',
      title: 'Motion references board',
      type: 'Gallery',
      updatedAt: now.subtract(const Duration(days: 9)),
      summary: 'A curated board of transitions and timing studies for inspiration.',
      author: 'Motion Lab',
      link: 'https://www.behance.net',
    ),
    LibraryItem(
      id: 'library-4',
      title: 'Enterprise onboarding notes',
      type: 'Notes',
      updatedAt: now.subtract(const Duration(days: 1)),
      summary: 'Highlights from last week’s onboarding including open questions.',
      author: 'Success Team',
      link: 'https://miro.com',
    ),
    LibraryItem(
      id: 'library-5',
      title: 'UX research insights',
      type: 'Report',
      updatedAt: now.subtract(const Duration(days: 12)),
      summary: 'Condensed findings from interviews about the comparison workspace.',
      author: 'Research Collective',
      link: 'https://www.figma.com',
    ),
  ];
}

List<FinanceSnapshot> seedFinanceSnapshotsMonthly() {
  final now = DateTime.now();
  final months = [
    {'offset': -3, 'label': 'February', 'revenue': 38600.0, 'expenses': 17200.0, 'goal': 42000.0, 'trend': 0.08},
    {'offset': -2, 'label': 'March', 'revenue': 41850.0, 'expenses': 18500.0, 'goal': 45000.0, 'trend': 0.11},
    {'offset': -1, 'label': 'April', 'revenue': 44720.0, 'expenses': 19120.0, 'goal': 47000.0, 'trend': 0.07},
    {'offset': 0, 'label': 'May', 'revenue': 46890.0, 'expenses': 20310.0, 'goal': 50000.0, 'trend': 0.05},
    {'offset': 1, 'label': 'June', 'revenue': 49240.0, 'expenses': 21440.0, 'goal': 52000.0, 'trend': 0.06},
    {'offset': 2, 'label': 'July', 'revenue': 51580.0, 'expenses': 22360.0, 'goal': 54000.0, 'trend': 0.04},
  ];
  return List.generate(months.length, (index) {
    final entry = months[index];
    final offset = entry['offset'] as int;
    final label = entry['label'] as String;
    final revenue = entry['revenue'] as double;
    final expenses = entry['expenses'] as double;
    final goal = entry['goal'] as double;
    final trend = entry['trend'] as double;
    final period = DateTime(now.year, now.month + offset, 1);
    return FinanceSnapshot(
      id: 'finance-month-$index',
      label: label,
      period: period,
      revenue: revenue,
      expenses: expenses,
      goal: goal,
      trend: trend,
    );
  });
}

List<FinanceSnapshot> seedFinanceSnapshotsYearly() {
  final now = DateTime.now();
  final years = [
    {'offset': -2, 'label': '${now.year - 2}', 'revenue': 452000.0, 'expenses': 238400.0, 'goal': 420000.0, 'trend': 0.18},
    {'offset': -1, 'label': '${now.year - 1}', 'revenue': 489000.0, 'expenses': 251600.0, 'goal': 460000.0, 'trend': 0.14},
    {'offset': 0, 'label': '${now.year}', 'revenue': 164500.0, 'expenses': 81200.0, 'goal': 520000.0, 'trend': 0.09},
  ];
  return List.generate(years.length, (index) {
    final entry = years[index];
    final offset = entry['offset'] as int;
    final label = entry['label'] as String;
    final revenue = entry['revenue'] as double;
    final expenses = entry['expenses'] as double;
    final goal = entry['goal'] as double;
    final trend = entry['trend'] as double;
    final year = now.year + offset;
    return FinanceSnapshot(
      id: 'finance-year-$index',
      label: label,
      period: DateTime(year, 1, 1),
      revenue: revenue,
      expenses: expenses,
      goal: goal,
      trend: trend,
    );
  });
}

List<Invoice> seedInvoices() {
  final now = DateTime.now();
  return [
    Invoice(
      id: 'invoice-001',
      client: 'Aurora Ventures',
      title: 'Discovery sprint retainer',
      amount: 8400,
      dueDate: now.add(const Duration(days: 5)),
      status: 'Due',
    ),
    Invoice(
      id: 'invoice-002',
      client: 'Nebula Labs',
      title: 'Product strategy workshop',
      amount: 12200,
      dueDate: now.add(const Duration(days: 12)),
      status: 'Due',
    ),
    Invoice(
      id: 'invoice-003',
      client: 'Softline Co.',
      title: 'Time tracker integration',
      amount: 9700,
      dueDate: now.subtract(const Duration(days: 3)),
      status: 'Due',
    ),
    Invoice(
      id: 'invoice-004',
      client: 'Brightline Studio',
      title: 'Brand refresh phase 2',
      amount: 15400,
      dueDate: now.add(const Duration(days: 21)),
      status: 'Due',
    ),
    Invoice(
      id: 'invoice-005',
      client: 'Atlas Fintech',
      title: 'Finance automation playbook',
      amount: 6800,
      dueDate: now.subtract(const Duration(days: 11)),
      status: 'Due',
    ),
    Invoice(
      id: 'invoice-006',
      client: 'Merge Collective',
      title: 'Operations enablement kit',
      amount: 5400,
      dueDate: now.add(const Duration(days: 2)),
      status: 'Due',
    ),
    Invoice(
      id: 'invoice-007',
      client: 'Skyline Retail',
      title: 'Catalog optimisation audit',
      amount: 7600,
      dueDate: now.subtract(const Duration(days: 18)),
      status: 'Paid',
    ),
    Invoice(
      id: 'invoice-008',
      client: 'Northshore Bank',
      title: 'Executive dashboard build',
      amount: 18800,
      dueDate: now.add(const Duration(days: 32)),
      status: 'Due',
    ),
  ];
}

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

class ClientInteraction {
  const ClientInteraction({
    required this.id,
    required this.type,
    required this.note,
    required this.timestamp,
  });

  final String id;
  final String type;
  final String note;
  final DateTime timestamp;
}

class Client {
  Client({
    required this.id,
    required this.name,
    required this.company,
    required this.stage,
    required this.value,
    required this.email,
    required this.phone,
    required this.notes,
    required this.tags,
    required this.starred,
    required this.lastInteraction,
    required this.interactions,
  });

  final String id;
  final String name;
  final String company;
  final String stage;
  final double value;
  final String email;
  final String phone;
  final String notes;
  final List<String> tags;
  final bool starred;
  final DateTime lastInteraction;
  final List<ClientInteraction> interactions;

  Client copyWith({
    String? name,
    String? company,
    String? stage,
    double? value,
    String? email,
    String? phone,
    String? notes,
    List<String>? tags,
    bool? starred,
    DateTime? lastInteraction,
    List<ClientInteraction>? interactions,
  }) {
    return Client(
      id: id,
      name: name ?? this.name,
      company: company ?? this.company,
      stage: stage ?? this.stage,
      value: value ?? this.value,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      notes: notes ?? this.notes,
      tags: tags ?? this.tags,
      starred: starred ?? this.starred,
      lastInteraction: lastInteraction ?? this.lastInteraction,
      interactions: interactions ?? this.interactions,
    );
  }
}

class TeamMember {
  TeamMember({
    required this.id,
    required this.name,
    required this.role,
    required this.status,
    required this.email,
    required this.location,
    required this.timezone,
    required this.avatarUrl,
    required this.focusHoursThisWeek,
    required this.tasksThisWeek,
    required this.capacity,
    required this.skills,
    required this.favorite,
    required this.lastActive,
    required this.joinedOn,
  });

  final String id;
  final String name;
  final String role;
  final String status;
  final String email;
  final String location;
  final String timezone;
  final String avatarUrl;
  final double focusHoursThisWeek;
  final int tasksThisWeek;
  final double capacity;
  final List<String> skills;
  final bool favorite;
  final DateTime lastActive;
  final DateTime joinedOn;

  TeamMember copyWith({
    String? name,
    String? role,
    String? status,
    String? email,
    String? location,
    String? timezone,
    String? avatarUrl,
    double? focusHoursThisWeek,
    int? tasksThisWeek,
    double? capacity,
    List<String>? skills,
    bool? favorite,
    DateTime? lastActive,
    DateTime? joinedOn,
  }) {
    return TeamMember(
      id: id,
      name: name ?? this.name,
      role: role ?? this.role,
      status: status ?? this.status,
      email: email ?? this.email,
      location: location ?? this.location,
      timezone: timezone ?? this.timezone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      focusHoursThisWeek: focusHoursThisWeek ?? this.focusHoursThisWeek,
      tasksThisWeek: tasksThisWeek ?? this.tasksThisWeek,
      capacity: capacity ?? this.capacity,
      skills: skills ?? this.skills,
      favorite: favorite ?? this.favorite,
      lastActive: lastActive ?? this.lastActive,
      joinedOn: joinedOn ?? this.joinedOn,
    );
  }
}

class TeamCheckIn {
  TeamCheckIn({
    required this.id,
    required this.memberId,
    required this.memberName,
    required this.author,
    required this.summary,
    required this.sentiment,
    required this.highlights,
    required this.nextSteps,
    required this.createdAt,
  });

  final String id;
  final String memberId;
  final String memberName;
  final String author;
  final String summary;
  final String sentiment;
  final List<String> highlights;
  final List<String> nextSteps;
  final DateTime createdAt;

  TeamCheckIn copyWith({
    String? summary,
    String? sentiment,
    List<String>? highlights,
    List<String>? nextSteps,
    DateTime? createdAt,
  }) {
    return TeamCheckIn(
      id: id,
      memberId: memberId,
      memberName: memberName,
      author: author,
      summary: summary ?? this.summary,
      sentiment: sentiment ?? this.sentiment,
      highlights: highlights ?? this.highlights,
      nextSteps: nextSteps ?? this.nextSteps,
      createdAt: createdAt ?? this.createdAt,
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

List<Client> seedClients() {
  final now = DateTime.now();
  return [
    Client(
      id: 'client-001',
      name: 'Lina Faris',
      company: 'Aurora Ventures',
      stage: 'Negotiation',
      value: 18500,
      email: 'lina@auroraventures.io',
      phone: '+971 52 111 2233',
      notes: 'Finalising scope adjustments for automation rollout.',
      tags: const ['venture', 'automation'],
      starred: true,
      lastInteraction: now.subtract(const Duration(days: 1, hours: 3)),
      interactions: [
        ClientInteraction(
          id: 'log-001a',
          type: 'Call',
          note: 'Aligned on budget guardrails and payment milestones.',
          timestamp: now.subtract(const Duration(days: 1, hours: 3)),
        ),
        ClientInteraction(
          id: 'log-001b',
          type: 'Email',
          note: 'Shared revised architecture slides and success metrics.',
          timestamp: now.subtract(const Duration(days: 4)),
        ),
      ],
    ),
    Client(
      id: 'client-002',
      name: 'Omar Riyadi',
      company: 'Nebula Labs',
      stage: 'Proposal',
      value: 12600,
      email: 'omar@nebulalabs.dev',
      phone: '+1 415 555 0189',
      notes: 'Waiting on security review feedback before sign-off.',
      tags: const ['product', 'scaleup'],
      starred: false,
      lastInteraction: now.subtract(const Duration(hours: 8)),
      interactions: [
        ClientInteraction(
          id: 'log-002a',
          type: 'Meeting',
          note: 'Walked through analytics instrumentation timeline.',
          timestamp: now.subtract(const Duration(hours: 8)),
        ),
        ClientInteraction(
          id: 'log-002b',
          type: 'Email',
          note: 'Sent follow-up docs requested by engineering.',
          timestamp: now.subtract(const Duration(days: 2, hours: 6)),
        ),
      ],
    ),
    Client(
      id: 'client-003',
      name: 'Sara Elwan',
      company: 'Brightline Studio',
      stage: 'Won',
      value: 9200,
      email: 'sara@brightline.studio',
      phone: '+44 20 7946 0650',
      notes: 'Kickoff scheduled next week with brand and ops teams.',
      tags: const ['design', 'retainer'],
      starred: true,
      lastInteraction: now.subtract(const Duration(days: 2, hours: 4)),
      interactions: [
        ClientInteraction(
          id: 'log-003a',
          type: 'Call',
          note: 'Confirmed scope and timeline, contract countersigned.',
          timestamp: now.subtract(const Duration(days: 2, hours: 4)),
        ),
        ClientInteraction(
          id: 'log-003b',
          type: 'Email',
          note: 'Shared kickoff agenda draft and workspace invite.',
          timestamp: now.subtract(const Duration(days: 5)),
        ),
      ],
    ),
    Client(
      id: 'client-004',
      name: 'Ranya Qassim',
      company: 'Skyline Retail',
      stage: 'Prospect',
      value: 6400,
      email: 'ranya@skylineretail.co',
      phone: '+971 4 600 9911',
      notes: 'Preparing tailored catalog automation demo.',
      tags: const ['retail', 'catalog'],
      starred: false,
      lastInteraction: now.subtract(const Duration(days: 3, hours: 6)),
      interactions: [
        ClientInteraction(
          id: 'log-004a',
          type: 'Call',
          note: 'Introduced workspace and captured integration needs.',
          timestamp: now.subtract(const Duration(days: 3, hours: 6)),
        ),
      ],
    ),
    Client(
      id: 'client-005',
      name: 'Jonah Price',
      company: 'Atlas Fintech',
      stage: 'Contacted',
      value: 15400,
      email: 'jonah@atlasfin.tech',
      phone: '+1 212 555 0193',
      notes: 'Needs alignment with compliance before next workshop.',
      tags: const ['finance', 'compliance'],
      starred: true,
      lastInteraction: now.subtract(const Duration(days: 6, hours: 2)),
      interactions: [
        ClientInteraction(
          id: 'log-005a',
          type: 'Email',
          note: 'Sent tailored case studies and onboarding outline.',
          timestamp: now.subtract(const Duration(days: 6, hours: 2)),
        ),
      ],
    ),
    Client(
      id: 'client-006',
      name: 'Mira Santos',
      company: 'Merge Collective',
      stage: 'Lost',
      value: 7800,
      email: 'mira@mergecollective.agency',
      phone: '+55 11 5550 1020',
      notes: 'Paused due to internal team bandwidth, follow up next quarter.',
      tags: const ['agency', 'pause'],
      starred: false,
      lastInteraction: now.subtract(const Duration(days: 14)),
      interactions: [
        ClientInteraction(
          id: 'log-006a',
          type: 'Call',
          note: 'Chose to pause after internal reprioritisation.',
          timestamp: now.subtract(const Duration(days: 14)),
        ),
      ],
    ),
    Client(
      id: 'client-007',
      name: 'Kareem Dalia',
      company: 'Northshore Bank',
      stage: 'Proposal',
      value: 21200,
      email: 'kareem@northshorebank.com',
      phone: '+1 617 555 0177',
      notes: 'Reviewing contract with procurement, warm follow-up tomorrow.',
      tags: const ['banking', 'enterprise'],
      starred: true,
      lastInteraction: now.subtract(const Duration(hours: 30)),
      interactions: [
        ClientInteraction(
          id: 'log-007a',
          type: 'Email',
          note: 'Shared implementation roadmap and ROI summary.',
          timestamp: now.subtract(const Duration(hours: 30)),
        ),
        ClientInteraction(
          id: 'log-007b',
          type: 'Meeting',
          note: 'Walked procurement through compliance checklist.',
          timestamp: now.subtract(const Duration(days: 3)),
        ),
      ],
    ),
  ];
}

List<TeamMember> seedTeamMembers() {
  final now = DateTime.now();
  final random = Random();
  final baseAvatars = [
    'https://i.pravatar.cc/150?img=12',
    'https://i.pravatar.cc/150?img=32',
    'https://i.pravatar.cc/150?img=47',
    'https://i.pravatar.cc/150?img=68',
    'https://i.pravatar.cc/150?img=24',
    'https://i.pravatar.cc/150?img=56',
    'https://i.pravatar.cc/150?img=36',
    'https://i.pravatar.cc/150?img=4',
    'https://i.pravatar.cc/150?img=18',
    'https://i.pravatar.cc/150?img=62',
  ];

  final members = <TeamMember>[
    TeamMember(
      id: 'team-001',
      name: 'Layla Haddad',
      role: 'Product Lead',
      status: 'Active',
      email: 'layla@connecq.app',
      location: 'Dubai, UAE',
      timezone: 'GMT+4',
      avatarUrl: baseAvatars[0],
      focusHoursThisWeek: 24,
      tasksThisWeek: 18,
      capacity: 0.72,
      skills: const ['Strategy', 'Workflows', 'Sprints'],
      favorite: true,
      lastActive: now.subtract(const Duration(hours: 2, minutes: 10)),
      joinedOn: now.subtract(const Duration(days: 420)),
    ),
    TeamMember(
      id: 'team-002',
      name: 'Mina Faris',
      role: 'Senior Designer',
      status: 'Active',
      email: 'mina@connecq.app',
      location: 'Cairo, Egypt',
      timezone: 'GMT+2',
      avatarUrl: baseAvatars[1],
      focusHoursThisWeek: 21,
      tasksThisWeek: 16,
      capacity: 0.66,
      skills: const ['UI', 'Illustration', 'Motion'],
      favorite: true,
      lastActive: now.subtract(const Duration(minutes: 35)),
      joinedOn: now.subtract(const Duration(days: 310)),
    ),
    TeamMember(
      id: 'team-003',
      name: 'Sami Al Maktoum',
      role: 'Full-stack Engineer',
      status: 'Active',
      email: 'sami@connecq.app',
      location: 'Abu Dhabi, UAE',
      timezone: 'GMT+4',
      avatarUrl: baseAvatars[2],
      focusHoursThisWeek: 28,
      tasksThisWeek: 21,
      capacity: 0.81,
      skills: const ['Flutter', 'APIs', 'Automation'],
      favorite: false,
      lastActive: now.subtract(const Duration(hours: 5, minutes: 12)),
      joinedOn: now.subtract(const Duration(days: 510)),
    ),
    TeamMember(
      id: 'team-004',
      name: 'Huda Al Rashid',
      role: 'Operations Manager',
      status: 'Onboarding',
      email: 'huda@connecq.app',
      location: 'Riyadh, Saudi Arabia',
      timezone: 'GMT+3',
      avatarUrl: baseAvatars[3],
      focusHoursThisWeek: 12,
      tasksThisWeek: 9,
      capacity: 0.48,
      skills: const ['Processes', 'Docs', 'Vendors'],
      favorite: false,
      lastActive: now.subtract(const Duration(hours: 10, minutes: 45)),
      joinedOn: now.subtract(const Duration(days: 34)),
    ),
    TeamMember(
      id: 'team-005',
      name: 'Jad Khoury',
      role: 'Growth Strategist',
      status: 'Active',
      email: 'jad@connecq.app',
      location: 'Beirut, Lebanon',
      timezone: 'GMT+3',
      avatarUrl: baseAvatars[4],
      focusHoursThisWeek: 19,
      tasksThisWeek: 14,
      capacity: 0.63,
      skills: const ['Funnels', 'Content', 'Campaigns'],
      favorite: true,
      lastActive: now.subtract(const Duration(hours: 1, minutes: 12)),
      joinedOn: now.subtract(const Duration(days: 260)),
    ),
    TeamMember(
      id: 'team-006',
      name: 'Noura Al Ali',
      role: 'Customer Success',
      status: 'Out of office',
      email: 'noura@connecq.app',
      location: 'Muscat, Oman',
      timezone: 'GMT+4',
      avatarUrl: baseAvatars[5],
      focusHoursThisWeek: 6,
      tasksThisWeek: 3,
      capacity: 0.18,
      skills: const ['Onboarding', 'Support', 'Feedback'],
      favorite: false,
      lastActive: now.subtract(const Duration(days: 1, hours: 4)),
      joinedOn: now.subtract(const Duration(days: 190)),
    ),
    TeamMember(
      id: 'team-007',
      name: 'Omar Bahri',
      role: 'QA Specialist',
      status: 'Contractor',
      email: 'omar@connecq.app',
      location: 'Casablanca, Morocco',
      timezone: 'GMT+1',
      avatarUrl: baseAvatars[6],
      focusHoursThisWeek: 15,
      tasksThisWeek: 11,
      capacity: 0.54,
      skills: const ['Testing', 'Automation', 'Scenarios'],
      favorite: false,
      lastActive: now.subtract(const Duration(hours: 6, minutes: 20)),
      joinedOn: now.subtract(const Duration(days: 150)),
    ),
    TeamMember(
      id: 'team-008',
      name: 'Sara Al Mansouri',
      role: 'Content Producer',
      status: 'Active',
      email: 'sara@connecq.app',
      location: 'Sharjah, UAE',
      timezone: 'GMT+4',
      avatarUrl: baseAvatars[7],
      focusHoursThisWeek: 17,
      tasksThisWeek: 15,
      capacity: 0.57,
      skills: const ['Video', 'Copywriting', 'Podcasts'],
      favorite: false,
      lastActive: now.subtract(const Duration(minutes: 5)),
      joinedOn: now.subtract(const Duration(days: 210)),
    ),
    TeamMember(
      id: 'team-009',
      name: 'Faisal Rahman',
      role: 'Data Analyst',
      status: 'Active',
      email: 'faisal@connecq.app',
      location: 'Doha, Qatar',
      timezone: 'GMT+3',
      avatarUrl: baseAvatars[8],
      focusHoursThisWeek: 23,
      tasksThisWeek: 17,
      capacity: 0.69,
      skills: const ['Dashboards', 'Forecasting', 'Insights'],
      favorite: false,
      lastActive: now.subtract(const Duration(hours: 3, minutes: 18)),
      joinedOn: now.subtract(const Duration(days: 330)),
    ),
    TeamMember(
      id: 'team-010',
      name: 'Rana Idris',
      role: 'People Partner',
      status: 'Active',
      email: 'rana@connecq.app',
      location: 'Amman, Jordan',
      timezone: 'GMT+3',
      avatarUrl: baseAvatars[9],
      focusHoursThisWeek: 14,
      tasksThisWeek: 10,
      capacity: 0.46,
      skills: const ['Hiring', 'Culture', 'Policies'],
      favorite: true,
      lastActive: now.subtract(const Duration(hours: 7, minutes: 48)),
      joinedOn: now.subtract(const Duration(days: 270)),
    ),
  ];

  return members
      .map(
        (member) => member.copyWith(
          focusHoursThisWeek: (member.focusHoursThisWeek + random.nextInt(4) - 1).clamp(4, 32).toDouble(),
          tasksThisWeek: (member.tasksThisWeek + random.nextInt(3) - 1).clamp(3, 24),
          capacity: (member.capacity + (random.nextDouble() * 0.08) - 0.04).clamp(0.18, 0.92),
        ),
      )
      .toList();
}

Map<String, List<TeamCheckIn>> seedTeamCheckIns(List<TeamMember> members) {
  final now = DateTime.now();
  final random = Random();
  final map = <String, List<TeamCheckIn>>{
    for (final member in members) member.id: <TeamCheckIn>[],
  };
  final names = {for (final member in members) member.id: member.name};

  TeamCheckIn build({
    required String id,
    required String memberId,
    required String author,
    required String summary,
    required String sentiment,
    required Duration delta,
    List<String> highlights = const [],
    List<String> nextSteps = const [],
  }) {
    return TeamCheckIn(
      id: id,
      memberId: memberId,
      memberName: names[memberId] ?? 'Teammate',
      author: author,
      summary: summary,
      sentiment: sentiment,
      highlights: highlights,
      nextSteps: nextSteps,
      createdAt: now.subtract(delta) - Duration(minutes: random.nextInt(30)),
    );
  }

  void add(String memberId, TeamCheckIn checkIn) {
    map.putIfAbsent(memberId, () => <TeamCheckIn>[]).add(checkIn);
  }

  add(
    'team-001',
    build(
      id: 'checkin-001',
      memberId: 'team-001',
      author: 'Rana Idris',
      summary: 'Roadmap sync locked in Q2 priorities with confidence across squads.',
      sentiment: 'positive',
      highlights: const ['Roadmap aligned', 'Stakeholder feedback clear'],
      nextSteps: const ['Share recap deck', 'Confirm launch checklist'],
      delta: const Duration(hours: 6),
    ),
  );

  add(
    'team-002',
    build(
      id: 'checkin-002',
      memberId: 'team-002',
      author: 'Layla Haddad',
      summary: 'Design system update ready for animation polish and copy sweep.',
      sentiment: 'positive',
      highlights: const ['Illustrations refined', 'Prototype clickable'],
      nextSteps: const ['Record Loom walkthrough'],
      delta: const Duration(days: 1, hours: 3),
    ),
  );

  add(
    'team-003',
    build(
      id: 'checkin-003',
      memberId: 'team-003',
      author: 'Sami Al Maktoum',
      summary: 'Automation pipeline experiencing queue delays during nightly sync.',
      sentiment: 'attention',
      highlights: const ['Retry logic catching failures'],
      nextSteps: const ['Expand worker pool', 'Monitor tonight\'s sync'],
      delta: const Duration(days: 2, hours: 5),
    ),
  );

  add(
    'team-005',
    build(
      id: 'checkin-004',
      memberId: 'team-005',
      author: 'Jad Khoury',
      summary: 'Campaign launch warming up influencers and finalizing offer matrix.',
      sentiment: 'neutral',
      highlights: const ['Landing page QA passed'],
      nextSteps: const ['Draft announcement copy', 'Coordinate paid ads switch'],
      delta: const Duration(hours: 18),
    ),
  );

  add(
    'team-008',
    build(
      id: 'checkin-005',
      memberId: 'team-008',
      author: 'Sara Al Mansouri',
      summary: 'Podcast outline drafted with guest notes and teaser script.',
      sentiment: 'positive',
      highlights: const ['Guest availability confirmed'],
      nextSteps: const ['Record pilot segment'],
      delta: const Duration(days: 3, hours: 2),
    ),
  );

  add(
    'team-010',
    build(
      id: 'checkin-006',
      memberId: 'team-010',
      author: 'Rana Idris',
      summary: 'Hiring pipeline calibrated; shortlisted candidates ready for panel.',
      sentiment: 'neutral',
      highlights: const ['Interview panel confirmed'],
      nextSteps: const ['Share prep kit with panel'],
      delta: const Duration(days: 4, hours: 4),
    ),
  );

  add(
    'team-006',
    build(
      id: 'checkin-007',
      memberId: 'team-006',
      author: 'Noura Al Ali',
      summary: 'Support macros drafted before short leave; handover with CS bench done.',
      sentiment: 'positive',
      highlights: const ['Macro library synced'],
      nextSteps: const ['Schedule follow-up after return'],
      delta: const Duration(days: 5, hours: 6),
    ),
  );

  return map;
}

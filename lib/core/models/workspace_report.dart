import 'dart:convert';

class WorkspaceReportSnapshot {
  WorkspaceReportSnapshot({
    required this.generatedAt,
    required this.totalProjects,
    required this.completedProjects,
    required this.atRiskProjects,
    required this.dueSoonProjects,
    required this.totalTasks,
    required this.completedTasks,
    required this.overdueTasks,
    required this.completionRate,
    required this.focusHoursThisWeek,
    required this.focusGoalHours,
    required this.pipelineValue,
    required this.activeClients,
    required this.monthlyRevenue,
    required this.monthlyExpenses,
    required this.netIncome,
    required this.outstandingInvoices,
    required this.monthlyTaskGoal,
    required this.monthlyTaskCompleted,
    required this.primaryColorHex,
    required this.topFocusLabel,
    required this.clientStageDistribution,
    required this.teamStatusDistribution,
  });

  final DateTime generatedAt;
  final int totalProjects;
  final int completedProjects;
  final int atRiskProjects;
  final int dueSoonProjects;
  final int totalTasks;
  final int completedTasks;
  final int overdueTasks;
  final double completionRate;
  final double focusHoursThisWeek;
  final double focusGoalHours;
  final double pipelineValue;
  final int activeClients;
  final double monthlyRevenue;
  final double monthlyExpenses;
  final double netIncome;
  final double outstandingInvoices;
  final int monthlyTaskGoal;
  final int monthlyTaskCompleted;
  final String primaryColorHex;
  final String? topFocusLabel;
  final Map<String, int> clientStageDistribution;
  final Map<String, int> teamStatusDistribution;

  double get completionPercentage => completionRate * 100;

  double get taskGoalProgress =>
      monthlyTaskGoal == 0 ? 0 : (monthlyTaskCompleted / monthlyTaskGoal).clamp(0, 1);

  Map<String, dynamic> toJson() {
    return {
      'generatedAt': generatedAt.toIso8601String(),
      'projects': {
        'total': totalProjects,
        'completed': completedProjects,
        'atRisk': atRiskProjects,
        'dueSoon': dueSoonProjects,
      },
      'tasks': {
        'total': totalTasks,
        'completed': completedTasks,
        'overdue': overdueTasks,
        'completionRate': completionRate,
        'goal': {
          'target': monthlyTaskGoal,
          'completed': monthlyTaskCompleted,
        },
      },
      'focus': {
        'hoursThisWeek': focusHoursThisWeek,
        'goalHours': focusGoalHours,
        'topLabel': topFocusLabel,
      },
      'finance': {
        'monthlyRevenue': monthlyRevenue,
        'monthlyExpenses': monthlyExpenses,
        'netIncome': netIncome,
        'outstandingInvoices': outstandingInvoices,
        'pipelineValue': pipelineValue,
      },
      'clients': {
        'activeCount': activeClients,
        'stageDistribution': clientStageDistribution,
      },
      'team': {
        'statusDistribution': teamStatusDistribution,
      },
      'theme': {
        'primaryColor': primaryColorHex,
      },
    };
  }

  String toPrettyJson() {
    final encoder = const JsonEncoder.withIndent('  ');
    return encoder.convert(toJson());
  }
}

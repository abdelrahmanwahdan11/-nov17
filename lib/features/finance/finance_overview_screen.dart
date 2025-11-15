import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/localization/app_localizations.dart';
import '../../shared/controllers/finance_controller.dart';
import '../../shared/controllers/workspace_scope.dart';
import '../../shared/skeletons/skeleton_widgets.dart';
import '../../shared/widgets/app_header.dart';

class FinanceOverviewScreen extends StatelessWidget {
  const FinanceOverviewScreen({super.key});

  Future<void> _refresh(BuildContext context) {
    final finance = WorkspaceScope.of(context).finance;
    return finance.refresh();
  }

  @override
  Widget build(BuildContext context) {
    final scope = WorkspaceScope.of(context);
    final finance = scope.finance;
    final loc = AppLocalizations.of(context);

    return RefreshIndicator(
      onRefresh: () => _refresh(context),
      child: AnimatedBuilder(
        animation: finance,
        builder: (context, _) {
          final isLoading = finance.isLoading && finance.snapshots.isEmpty;
          final snapshots = finance.snapshots;
          return ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            children: [
              const SizedBox(height: kToolbarHeight + 16),
              AppHeader(
                title: loc.translate('finance'),
                subtitle: loc.translate('finance_overview_subtitle'),
              ),
              const SizedBox(height: 16),
              Center(
                child: SegmentedButton<FinancePeriod>(
                  segments: [
                    ButtonSegment(
                      value: FinancePeriod.monthly,
                      label: Text(loc.translate('finance_tab_monthly')),
                    ),
                    ButtonSegment(
                      value: FinancePeriod.yearly,
                      label: Text(loc.translate('finance_tab_yearly')),
                    ),
                  ],
                  selected: {finance.period},
                  onSelectionChanged: (value) => finance.selectPeriod(value.first),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 320),
                  child: isLoading
                      ? const _FinanceSkeleton()
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _SummaryRow(
                              revenueLabel: loc.translate('finance_summary_revenue'),
                              revenue: finance.totalRevenue,
                              expensesLabel: loc.translate('finance_summary_expenses'),
                              expenses: finance.totalExpenses,
                              outstandingLabel: loc.translate('finance_summary_outstanding'),
                              outstanding: finance.totalOutstanding,
                              netLabel: loc.translate('finance_summary_net'),
                              net: finance.totalNet,
                            ),
                            const SizedBox(height: 24),
                            if (finance.bestSnapshot != null)
                              _HighlightCard(
                                snapshot: finance.bestSnapshot!,
                                subtitle: finance.period == FinancePeriod.monthly
                                    ? loc.translate('finance_highlight_monthly')
                                    : loc.translate('finance_highlight_yearly'),
                                trendLabel: loc.translate(
                                  'finance_highlight_trend',
                                  params: {
                                    'percent': (finance.bestSnapshot!.trend * 100).toStringAsFixed(1),
                                  },
                                ),
                                progressLabel: loc.translate('finance_progress_to_goal'),
                              ),
                            if (finance.bestSnapshot != null) const SizedBox(height: 24),
                            if (snapshots.isNotEmpty)
                              _SnapshotBars(
                                snapshots: snapshots,
                                isMonthly: finance.period == FinancePeriod.monthly,
                                loc: loc,
                              ),
                            if (snapshots.isNotEmpty) const SizedBox(height: 24),
                            _InvoiceHighlights(
                              loc: loc,
                              upcoming: finance.upcomingInvoices,
                              overdue: finance.overdueInvoices,
                              onMarkPaid: finance.markInvoicePaid,
                            ),
                            const SizedBox(height: 24),
                            _InvoiceList(finance: finance, loc: loc),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          );
        },
      ),
    );
  }
}

class _FinanceSkeleton extends StatelessWidget {
  const _FinanceSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        SkeletonContainer(height: 160),
        SizedBox(height: 16),
        SkeletonContainer(height: 200),
        SizedBox(height: 16),
        SkeletonContainer(height: 220),
      ],
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.revenueLabel,
    required this.revenue,
    required this.expensesLabel,
    required this.expenses,
    required this.outstandingLabel,
    required this.outstanding,
    required this.netLabel,
    required this.net,
  });

  final String revenueLabel;
  final double revenue;
  final String expensesLabel;
  final double expenses;
  final String outstandingLabel;
  final double outstanding;
  final String netLabel;
  final double net;

  @override
  Widget build(BuildContext context) {
    final cards = [
      _SummaryMetric(label: revenueLabel, value: revenue, highlight: true),
      _SummaryMetric(label: expensesLabel, value: expenses),
      _SummaryMetric(label: outstandingLabel, value: outstanding),
      _SummaryMetric(label: netLabel, value: net, emphasizePositive: true),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final itemWidth = (width - 16) / 2;
        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: cards
              .map((metric) => SizedBox(width: itemWidth, child: _SummaryMetricCard(metric: metric)))
              .toList(),
        );
      },
    );
  }
}

class _SummaryMetric {
  _SummaryMetric({
    required this.label,
    required this.value,
    this.highlight = false,
    this.emphasizePositive = false,
  });

  final String label;
  final double value;
  final bool highlight;
  final bool emphasizePositive;
}

class _SummaryMetricCard extends StatelessWidget {
  const _SummaryMetricCard({required this.metric});

  final _SummaryMetric metric;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final absolute = metric.value.abs().toStringAsFixed(0);
    final valueText = metric.value < 0 ? '-\$$absolute' : '\$$absolute';
    final isPositive = metric.value >= 0;
    final textColor = metric.emphasizePositive
        ? (isPositive ? const Color(0xFF1B5E20) : const Color(0xFFB00020))
        : theme.textTheme.titleLarge?.color;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 320),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: metric.highlight ? colorScheme.primary.withOpacity(0.15) : colorScheme.surface,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(metric.label, style: theme.textTheme.bodyMedium),
          const SizedBox(height: 12),
          Text(
            valueText,
            style: theme.textTheme.headlineMedium?.copyWith(color: textColor, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class _HighlightCard extends StatelessWidget {
  const _HighlightCard({
    required this.snapshot,
    required this.subtitle,
    required this.trendLabel,
    required this.progressLabel,
  });

  final FinanceSnapshot snapshot;
  final String subtitle;
  final String trendLabel;
  final String progressLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(snapshot.label, style: theme.textTheme.titleLarge),
                const SizedBox(height: 6),
                Text(subtitle, style: theme.textTheme.bodyMedium),
                const SizedBox(height: 16),
                Text(trendLabel, style: theme.textTheme.bodySmall),
              ],
            ),
          ),
          const SizedBox(width: 16),
          SizedBox(
            height: 120,
            width: 120,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: snapshot.progress),
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: value,
                      strokeWidth: 10,
                      backgroundColor: theme.colorScheme.primary.withOpacity(0.15),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('${(value * 100).toStringAsFixed(0)}%', style: theme.textTheme.titleLarge),
                        Text(progressLabel, style: theme.textTheme.bodySmall),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SnapshotBars extends StatelessWidget {
  const _SnapshotBars({required this.snapshots, required this.isMonthly, required this.loc});

  final List<FinanceSnapshot> snapshots;
  final bool isMonthly;
  final AppLocalizations loc;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final maxRevenue = snapshots.fold<double>(0, (value, snapshot) => math.max(value, snapshot.revenue));
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isMonthly ? loc.translate('finance_chart_monthly') : loc.translate('finance_chart_yearly'),
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 160,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: snapshots.map((snapshot) {
                final barHeight = maxRevenue == 0 ? 0 : (snapshot.revenue / maxRevenue);
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 360),
                              height: 40 + (100 * barHeight),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(18),
                                gradient: LinearGradient(
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                  colors: [
                                    theme.colorScheme.primary.withOpacity(0.8),
                                    theme.colorScheme.primary.withOpacity(0.25),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(snapshot.label, style: theme.textTheme.bodySmall),
                        Text(
                          '\$${snapshot.revenue.toStringAsFixed(0)}',
                          style: theme.textTheme.labelSmall,
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _LegendDot(color: theme.colorScheme.primary, label: loc.translate('finance_bar_revenue')),
              const SizedBox(width: 16),
              _LegendDot(color: const Color(0xFFF7FF5A), label: loc.translate('finance_bar_expenses')),
            ],
          ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4)),
        ),
        const SizedBox(width: 6),
        Text(label, style: theme.textTheme.bodySmall),
      ],
    );
  }
}

class _InvoiceHighlights extends StatelessWidget {
  const _InvoiceHighlights({
    required this.loc,
    required this.upcoming,
    required this.overdue,
    required this.onMarkPaid,
  });

  final AppLocalizations loc;
  final List<Invoice> upcoming;
  final List<Invoice> overdue;
  final Future<void> Function(Invoice) onMarkPaid;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(loc.translate('finance_invoices_section'), style: theme.textTheme.titleMedium),
          const SizedBox(height: 16),
          if (upcoming.isNotEmpty) ...[
            Text(loc.translate('finance_invoices_upcoming'), style: theme.textTheme.bodySmall),
            const SizedBox(height: 8),
            ...upcoming.map((invoice) => _InvoiceHighlightTile(
                  invoice: invoice,
                  loc: loc,
                  onMarkPaid: onMarkPaid,
                )),
            const SizedBox(height: 20),
          ],
          if (overdue.isNotEmpty) ...[
            Text(loc.translate('finance_invoices_overdue'), style: theme.textTheme.bodySmall),
            const SizedBox(height: 8),
            ...overdue.map((invoice) => _InvoiceHighlightTile(
                  invoice: invoice,
                  loc: loc,
                  onMarkPaid: onMarkPaid,
                )),
          ],
          if (upcoming.isEmpty && overdue.isEmpty)
            Text(loc.translate('finance_invoices_empty'), style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _InvoiceHighlightTile extends StatelessWidget {
  const _InvoiceHighlightTile({required this.invoice, required this.loc, required this.onMarkPaid});

  final Invoice invoice;
  final AppLocalizations loc;
  final Future<void> Function(Invoice) onMarkPaid;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final localizations = MaterialLocalizations.of(context);
    final formattedDate = localizations.formatMediumDate(invoice.dueDate);
    final isPaid = invoice.status.toLowerCase() == 'paid';
    final isOverdue = invoice.isOverdue();
    final statusKey = isOverdue && !isPaid ? 'overdue' : invoice.status.toLowerCase();
    final statusLabel = loc.translate('finance_invoice_status_$statusKey');
    final dateLabel = isPaid
        ? loc.translate('finance_invoice_paid_date', params: {'date': formattedDate})
        : isOverdue
            ? loc.translate('finance_invoice_overdue_date', params: {'date': formattedDate})
            : loc.translate('finance_invoice_due_date', params: {'date': formattedDate});
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: theme.colorScheme.primary.withOpacity(0.08),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(invoice.client, style: textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(invoice.title, style: textTheme.bodyMedium),
                const SizedBox(height: 4),
                Text(dateLabel, style: textTheme.bodySmall),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('\$${invoice.amount.toStringAsFixed(0)}', style: textTheme.titleMedium),
              const SizedBox(height: 6),
              Chip(
                label: Text(statusLabel),
                backgroundColor: _statusColor(theme, statusKey).withOpacity(0.15),
                labelStyle: textTheme.labelSmall?.copyWith(color: _statusColor(theme, statusKey)),
              ),
              if (!isPaid)
                TextButton(
                  onPressed: () => onMarkPaid(invoice),
                  child: Text(loc.translate('finance_invoice_mark_paid')),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InvoiceList extends StatelessWidget {
  const _InvoiceList({required this.finance, required this.loc});

  final FinanceController finance;
  final AppLocalizations loc;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(loc.translate('finance_invoices_all'), style: theme.textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text(loc.translate('finance_invoices_filter_label'), style: theme.textTheme.bodySmall),
                  ],
                ),
              ),
              Wrap(
                spacing: 8,
                children: finance.invoiceFilters.map((filter) {
                  final selected = finance.invoiceFilter.toLowerCase() == filter.toLowerCase();
                  return ChoiceChip(
                    label: Text(loc.translate('finance_filter_${filter.toLowerCase()}')),
                    selected: selected,
                    onSelected: (value) {
                      if (value) finance.updateInvoiceFilter(filter);
                    },
                  );
                }).toList(),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (finance.isLoadingInvoices && finance.invoices.isEmpty)
            const _InvoiceSkeletonList()
          else ...[
            ...finance.invoices.map((invoice) => _InvoiceTile(invoice: invoice, loc: loc, onMarkPaid: finance.markInvoicePaid)),
            if (finance.invoices.isEmpty)
              Text(loc.translate('finance_invoices_empty'), style: theme.textTheme.bodySmall),
            if (finance.hasMoreInvoices)
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: finance.isLoadingMoreInvoices ? null : finance.loadMoreInvoices,
                  icon: finance.isLoadingMoreInvoices
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.expand_more),
                  label: Text(loc.translate('finance_load_more_invoices')),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _InvoiceTile extends StatelessWidget {
  const _InvoiceTile({required this.invoice, required this.loc, required this.onMarkPaid});

  final Invoice invoice;
  final AppLocalizations loc;
  final Future<void> Function(Invoice) onMarkPaid;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final localizations = MaterialLocalizations.of(context);
    final formattedDate = localizations.formatMediumDate(invoice.dueDate);
    final isPaid = invoice.status.toLowerCase() == 'paid';
    final isOverdue = invoice.isOverdue();
    final statusKey = isOverdue && !isPaid ? 'overdue' : invoice.status.toLowerCase();
    final statusLabel = loc.translate('finance_invoice_status_$statusKey');
    final dateLabel = isPaid
        ? loc.translate('finance_invoice_paid_date', params: {'date': formattedDate})
        : isOverdue
            ? loc.translate('finance_invoice_overdue_date', params: {'date': formattedDate})
            : loc.translate('finance_invoice_due_date', params: {'date': formattedDate});
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(invoice.title, style: textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text(invoice.client, style: textTheme.bodyMedium),
                    const SizedBox(height: 4),
                    Text(dateLabel, style: textTheme.bodySmall),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('\$${invoice.amount.toStringAsFixed(0)}', style: textTheme.titleMedium),
                  const SizedBox(height: 6),
                  Chip(
                    label: Text(statusLabel),
                    backgroundColor: _statusColor(theme, statusKey).withOpacity(0.15),
                    labelStyle: textTheme.labelSmall?.copyWith(color: _statusColor(theme, statusKey)),
                  ),
                ],
              ),
            ],
          ),
          if (!isPaid)
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => onMarkPaid(invoice),
                child: Text(loc.translate('finance_invoice_mark_paid')),
              ),
            ),
        ],
      ),
    );
  }
}

class _InvoiceSkeletonList extends StatelessWidget {
  const _InvoiceSkeletonList();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        SkeletonContainer(height: 120),
        SizedBox(height: 12),
        SkeletonContainer(height: 120),
        SizedBox(height: 12),
        SkeletonContainer(height: 120),
      ],
    );
  }
}

Color _statusColor(ThemeData theme, String statusKey) {
  switch (statusKey) {
    case 'paid':
      return const Color(0xFF2E7D32);
    case 'overdue':
      return const Color(0xFFC62828);
    default:
      return theme.colorScheme.primary;
  }
}

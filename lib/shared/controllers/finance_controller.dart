import 'package:flutter/foundation.dart';

import '../../core/models/mock_data.dart';
import '../../core/models/mock_repository.dart';

class FinanceController extends ChangeNotifier {
  FinanceController({required MockRepository repository}) : _repository = repository;

  final MockRepository _repository;

  FinancePeriod _period = FinancePeriod.monthly;
  bool _loading = true;
  bool _loadingInvoices = true;
  bool _loadingMoreInvoices = false;
  bool _hasMoreInvoices = true;
  final int _invoicePageSize = 6;
  int _invoicePage = 1;
  String _invoiceFilter = 'All';

  List<FinanceSnapshot> _monthly = [];
  List<FinanceSnapshot> _yearly = [];
  final List<Invoice> _invoices = [];
  List<Invoice> _upcoming = [];
  List<Invoice> _overdue = [];

  bool get isLoading => _loading;
  bool get isLoadingInvoices => _loadingInvoices;
  bool get isLoadingMoreInvoices => _loadingMoreInvoices;
  bool get hasMoreInvoices => _hasMoreInvoices;
  FinancePeriod get period => _period;
  String get invoiceFilter => _invoiceFilter;

  List<FinanceSnapshot> get snapshots =>
      _period == FinancePeriod.monthly ? List.unmodifiable(_monthly) : List.unmodifiable(_yearly);

  List<FinanceSnapshot> get monthlySnapshots => List.unmodifiable(_monthly);
  List<FinanceSnapshot> get yearlySnapshots => List.unmodifiable(_yearly);

  List<Invoice> get invoices => List.unmodifiable(_invoices);
  List<Invoice> get upcomingInvoices => List.unmodifiable(_upcoming);
  List<Invoice> get overdueInvoices => List.unmodifiable(_overdue);

  double get totalRevenue => snapshots.fold(0, (sum, item) => sum + item.revenue);
  double get totalExpenses => snapshots.fold(0, (sum, item) => sum + item.expenses);
  double get totalNet => totalRevenue - totalExpenses;
  double get totalOutstanding => _repository.totalOutstandingInvoices();

  double get averageTrend {
    if (snapshots.isEmpty) return 0;
    final total = snapshots.fold<double>(0, (sum, item) => sum + item.trend);
    return total / snapshots.length;
  }

  FinanceSnapshot? get bestSnapshot {
    if (snapshots.isEmpty) return null;
    return snapshots.reduce((value, element) => element.progress > value.progress ? element : value);
  }

  List<String> get invoiceFilters => const ['All', 'Due', 'Overdue', 'Paid'];

  Future<void> bootstrap() async {
    if (_monthly.isNotEmpty && _yearly.isNotEmpty && _invoices.isNotEmpty) return;
    await refresh();
  }

  Future<void> refresh() async {
    _loading = true;
    notifyListeners();
    await Future.wait([_loadSnapshots(), _reloadInvoices()]);
    _loading = false;
    notifyListeners();
  }

  Future<void> _loadSnapshots() async {
    final monthly = await _repository.fetchFinanceSnapshots(period: FinancePeriod.monthly);
    final yearly = await _repository.fetchFinanceSnapshots(period: FinancePeriod.yearly);
    _monthly = monthly;
    _yearly = yearly;
    _upcoming = _repository.upcomingInvoices(limit: 3);
    _overdue = _repository.overdueInvoices(limit: 3);
  }

  Future<void> _reloadInvoices() async {
    _loadingInvoices = true;
    _invoicePage = 1;
    notifyListeners();
    final result =
        await _repository.fetchInvoices(page: _invoicePage, pageSize: _invoicePageSize, status: _invoiceFilter);
    _invoices
      ..clear()
      ..addAll(result.items);
    _sortInvoices();
    _hasMoreInvoices = result.hasMore;
    _loadingInvoices = false;
  }

  Future<void> loadMoreInvoices() async {
    if (_loadingMoreInvoices || !_hasMoreInvoices) return;
    _loadingMoreInvoices = true;
    notifyListeners();
    final nextPage = _invoicePage + 1;
    final result =
        await _repository.fetchInvoices(page: nextPage, pageSize: _invoicePageSize, status: _invoiceFilter);
    _invoicePage = nextPage;
    _invoices.addAll(result.items);
    _sortInvoices();
    _hasMoreInvoices = result.hasMore;
    _loadingMoreInvoices = false;
    notifyListeners();
  }

  void selectPeriod(FinancePeriod value) {
    if (_period == value) return;
    _period = value;
    notifyListeners();
  }

  Future<void> updateInvoiceFilter(String value) async {
    if (_invoiceFilter == value) return;
    _invoiceFilter = value;
    await _reloadInvoices();
    notifyListeners();
  }

  Future<void> markInvoicePaid(Invoice invoice) async {
    if (invoice.status.toLowerCase() == 'paid') return;
    final updated = invoice.copyWith(status: 'Paid');
    final saved = await _repository.saveInvoice(updated);
    if (saved == null) return;
    final index = _invoices.indexWhere((item) => item.id == saved.id);
    if (index != -1) {
      _invoices[index] = saved;
      _sortInvoices();
    }
    _upcoming = _repository.upcomingInvoices(limit: 3);
    _overdue = _repository.overdueInvoices(limit: 3);
    notifyListeners();
  }

  void _sortInvoices() {
    _invoices.sort((a, b) {
      final aPaid = a.status.toLowerCase() == 'paid';
      final bPaid = b.status.toLowerCase() == 'paid';
      if (aPaid != bPaid) {
        return aPaid ? 1 : -1;
      }
      return a.dueDate.compareTo(b.dueDate);
    });
  }
}

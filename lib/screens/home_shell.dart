import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/transaction.dart';
import '../services/storage_service.dart';
import '../services/tax_engine.dart';
import '../widgets/bottom_nav.dart';
import 'dashboard_screen.dart';
import 'transactions_screen.dart';
import 'reports_screen.dart';
import 'settings_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  final _storage = StorageService();
  final _engine = TaxEngine();
  bool _loading = true;
  int activeIndex = 0;

  String name = '';
  String ntn = '';
  bool psebRegistered = false;
  List<TaxTransaction> transactions = [];
  late TaxYearRange selectedYear;

  @override
  void initState() {
    super.initState();
    selectedYear = _engine.currentTaxYear();
    _loadState();
  }

  Future<void> _loadState() async {
    final loadedName = await _storage.loadName();
    final loadedNtn = await _storage.loadNtn();
    final loadedPseb = await _storage.loadPsebRegistered();
    final loadedTx = await _storage.loadTransactions();
    setState(() {
      name = loadedName;
      ntn = loadedNtn;
      psebRegistered = loadedPseb;
      transactions = loadedTx;
      _loading = false;
    });
  }

  void addTransaction(TaxTransaction t) {
    setState(() => transactions.add(t));
    _storage.saveTransactions(transactions);
  }

  void deleteTransaction(String id) {
    setState(() => transactions.removeWhere((t) => t.id == id));
    _storage.saveTransactions(transactions);
  }

  void changeSelectedYear(TaxYearRange year) {
    setState(() => selectedYear = year);
  }

  Future<void> refreshProfile() async {
    name = await _storage.loadName();
    ntn = await _storage.loadNtn();
    psebRegistered = await _storage.loadPsebRegistered();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(backgroundColor: context.colors.cream, body: Center(child: CircularProgressIndicator(color: context.colors.navy)));
    }

    final yearTransactions = _engine.transactionsInRange(transactions, selectedYear);
    final summary = _engine.summarize(yearTransactions, psebRegistered: psebRegistered);

    final screens = [
      DashboardScreen(
        name: name,
        selectedYear: selectedYear,
        summary: summary,
        transactionCount: yearTransactions.length,
        onChangeYear: changeSelectedYear,
        onAddTransaction: addTransaction,
      ),
      TransactionsScreen(
        transactions: yearTransactions,
        selectedYear: selectedYear,
        onAdd: addTransaction,
        onDelete: deleteTransaction,
      ),
      ReportsScreen(
        selectedYear: selectedYear,
        transactions: yearTransactions,
        summary: summary,
        ntn: ntn,
        psebRegistered: psebRegistered,
      ),
      SettingsScreen(
        name: name,
        ntn: ntn,
        psebRegistered: psebRegistered,
        onProfileChanged: refreshProfile,
      ),
    ];

    return Scaffold(
      backgroundColor: context.colors.cream,
      body: SafeArea(child: screens[activeIndex]),
      bottomNavigationBar: HisaabBottomNav(activeIndex: activeIndex, onTap: (i) => setState(() => activeIndex = i)),
    );
  }
}

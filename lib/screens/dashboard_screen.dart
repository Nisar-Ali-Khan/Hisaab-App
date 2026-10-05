import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../models/transaction.dart';
import '../services/tax_engine.dart';
import '../widgets/section_card.dart';
import '../widgets/compliance_ring.dart';
import 'add_transaction_screen.dart';

class DashboardScreen extends StatelessWidget {
  final String name;
  final TaxYearRange selectedYear;
  final TaxSummary summary;
  final int transactionCount;
  final void Function(TaxYearRange) onChangeYear;
  final void Function(TaxTransaction) onAddTransaction;

  const DashboardScreen({
    super.key,
    required this.name,
    required this.selectedYear,
    required this.summary,
    required this.transactionCount,
    required this.onChangeYear,
    required this.onAddTransaction,
  });

  final _currency = const _PkrFormat();

  @override
  Widget build(BuildContext context) {
    final engine = TaxEngine();
    final deadlineDays = engine.daysUntilFilingDeadline(selectedYear);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name.isEmpty ? 'Hisaab' : 'Hello, $name', style: AppText.display(context, size: 23)),
                const SizedBox(height: 2),
                Text('Tax year ${selectedYear.label}', style: AppText.body(context, size: 13, color: context.colors.muted)),
              ],
            ),
            GestureDetector(
              onTap: () => _showYearPicker(context),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(color: context.colors.white, borderRadius: BorderRadius.circular(99)),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today_outlined, size: 14, color: context.colors.navy),
                    const SizedBox(width: 6),
                    Text(selectedYear.label, style: AppText.body(context, size: 12, weight: FontWeight.w700, color: context.colors.navy)),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (deadlineDays != null)
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(color: context.colors.gold.withOpacity(0.18), borderRadius: BorderRadius.circular(14)),
            child: Row(
              children: [
                Icon(Icons.event_outlined, size: 16, color: context.colors.ink),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '$deadlineDays days left to file your return (deadline: Sep 30)',
                    style: AppText.body(context, size: 12.5, weight: FontWeight.w600, color: context.colors.ink),
                  ),
                ),
              ],
            ),
          ),
        SectionCard(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Column(
            children: [
              ComplianceRing(percentage: summary.approvedPercentage),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: (summary.meets80PercentRule ? context.colors.teal : context.colors.rose).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Text(
                  summary.meets80PercentRule ? '80% rule met' : '80% rule not met',
                  style: AppText.body(context, size: 12, weight: FontWeight.w700, color: summary.meets80PercentRule ? context.colors.teal : context.colors.rose),
                ),
              ),
            ],
          ),
        ),
        Row(
          children: [
            Expanded(child: _statCard(context, 'Total income', _currency.format(summary.totalIncome), Icons.account_balance_wallet_outlined)),
            const SizedBox(width: 12),
            Expanded(child: _statCard(context, 'Est. tax', summary.meets80PercentRule ? _currency.format(summary.estimatedTaxAmount) : '—', Icons.calculate_outlined)),
          ],
        ),
        const SizedBox(height: 16),
        SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.info_outline, size: 16, color: context.colors.navy),
                  const SizedBox(width: 8),
                  Text('What this means', style: AppText.display(context, size: 15)),
                ],
              ),
              const SizedBox(height: 10),
              Text(summary.rateExplanation, style: AppText.body(context, size: 13, color: context.colors.ink).copyWith(height: 1.5)),
            ],
          ),
        ),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () async {
              final result = await Navigator.of(context).push<TaxTransaction>(MaterialPageRoute(builder: (_) => const AddTransactionScreen()));
              if (result != null) onAddTransaction(result);
            },
            icon: const Icon(Icons.add, size: 18),
            label: Text('Log a payment', style: AppText.body(context, size: 14, weight: FontWeight.w600, color: context.colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: context.colors.navy,
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(99)),
              elevation: 0,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '$transactionCount transaction${transactionCount == 1 ? '' : 's'} logged this tax year',
          textAlign: TextAlign.center,
          style: AppText.body(context, size: 12, color: context.colors.muted),
        ),
      ],
    );
  }

  Widget _statCard(BuildContext context, String label, String value, IconData icon) {
    return SectionCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: context.colors.teal),
          const SizedBox(height: 10),
          Text(value, style: AppText.mono(context, size: 16, weight: FontWeight.w700)),
          const SizedBox(height: 2),
          Text(label, style: AppText.body(context, size: 11.5, color: context.colors.muted)),
        ],
      ),
    );
  }

  void _showYearPicker(BuildContext context) {
    final engine = TaxEngine();
    final now = DateTime.now();
    final options = List.generate(4, (i) => engine.taxYearFor(DateTime(now.year - i, now.month)));
    final uniqueOptions = {for (var o in options) o.label: o}.values.toList();

    showModalBottomSheet(
      context: context,
      backgroundColor: context.colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Select tax year', style: AppText.display(context, size: 17)),
            const SizedBox(height: 14),
            ...uniqueOptions.map((y) => ListTile(
                  title: Text(y.label, style: AppText.body(context, size: 14, weight: FontWeight.w600)),
                  trailing: y.label == selectedYear.label ? Icon(Icons.check, color: context.colors.navy) : null,
                  onTap: () {
                    onChangeYear(y);
                    Navigator.of(ctx).pop();
                  },
                )),
          ],
        ),
      ),
    );
  }
}

class _PkrFormat {
  const _PkrFormat();
  String format(double value) {
    final formatter = NumberFormat.currency(locale: 'en_PK', symbol: 'PKR ', decimalDigits: 0);
    return formatter.format(value);
  }
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../models/transaction.dart';
import '../services/tax_engine.dart';
import '../widgets/section_card.dart';
import 'add_transaction_screen.dart';

class TransactionsScreen extends StatefulWidget {
  final List<TaxTransaction> transactions;
  final TaxYearRange selectedYear;
  final void Function(TaxTransaction) onAdd;
  final void Function(String id) onDelete;

  const TransactionsScreen({
    super.key,
    required this.transactions,
    required this.selectedYear,
    required this.onAdd,
    required this.onDelete,
  });

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  String _searchQuery = '';
  IncomeChannel? _selectedFilter;

  Color _channelColor(IncomeChannel c) {
    switch (c) {
      case IncomeChannel.payoneer:
        return context.colors.teal;
      case IncomeChannel.wise:
        return context.colors.navy;
      case IncomeChannel.pakistaniBank:
        return context.colors.gold;
      case IncomeChannel.other:
        return context.colors.rose;
    }
  }

  @override
  Widget build(BuildContext context) {
    var filtered = widget.transactions.where((t) {
      if (_selectedFilter != null && t.channel != _selectedFilter) return false;
      if (_searchQuery.isNotEmpty && !t.note.toLowerCase().contains(_searchQuery.toLowerCase())) return false;
      return true;
    }).toList();

    filtered.sort((a, b) => b.date.compareTo(a.date));
    final currency = NumberFormat.currency(locale: 'en_PK', symbol: 'PKR ', decimalDigits: 0);
    final dateFmt = DateFormat('d MMM yyyy');

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Transactions', style: AppText.display(context, size: 22)),
                  Text(widget.selectedYear.label, style: AppText.body(context, size: 12.5, color: context.colors.muted)),
                ],
              ),
              IconButton(
                onPressed: () async {
                  final result = await Navigator.of(context).push<TaxTransaction>(MaterialPageRoute(builder: (_) => const AddTransactionScreen()));
                  if (result != null) widget.onAdd(result);
                },
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: context.colors.navy, shape: BoxShape.circle),
                  child: Icon(Icons.add, size: 18, color: context.colors.white),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: TextField(
            onChanged: (val) => setState(() => _searchQuery = val),
            style: AppText.body(context, size: 14),
            decoration: InputDecoration(
              hintText: 'Search by note...',
              hintStyle: AppText.body(context, size: 13, color: context.colors.muted),
              prefixIcon: Icon(Icons.search, size: 18, color: context.colors.muted),
              filled: true,
              fillColor: context.colors.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(99), borderSide: BorderSide.none),
            ),
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            children: [
              _buildFilterChip('All', null),
              ...IncomeChannel.values.map((c) => _buildFilterChip(c.label, c)),
            ],
          ),
        ),
        Expanded(
          child: filtered.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.receipt_long_outlined, size: 40, color: context.colors.muted),
                        const SizedBox(height: 14),
                        Text('No transactions yet', style: AppText.display(context, size: 16)),
                        const SizedBox(height: 6),
                        Text(
                          'Tap the + button to log your first Payoneer, Wise, or bank payment.',
                          textAlign: TextAlign.center,
                          style: AppText.body(context, size: 13, color: context.colors.muted),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final t = filtered[index];
                    return Dismissible(
                      key: ValueKey(t.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(color: context.colors.rose, borderRadius: BorderRadius.circular(18)),
                        child: Icon(Icons.delete_outline, color: context.colors.white),
                      ),
                      onDismissed: (_) => widget.onDelete(t.id),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: context.colors.white,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [BoxShadow(color: context.colors.navy.withOpacity(0.05), blurRadius: 14, offset: const Offset(0, 3))],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(color: _channelColor(t.channel), shape: BoxShape.circle),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(t.channel.label, style: AppText.body(context, size: 13.5, weight: FontWeight.w700)),
                                  const SizedBox(height: 2),
                                  Text(
                                    t.note.isEmpty ? dateFmt.format(t.date) : '${dateFmt.format(t.date)} · ${t.note}',
                                    style: AppText.body(context, size: 11.5, color: context.colors.muted),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(currency.format(t.amountPkr), style: AppText.mono(context, size: 13, weight: FontWeight.w700)),
                                if (t.originalAmount > 0)
                                  Text(
                                    '${t.originalAmount} ${t.originalCurrency}',
                                    style: AppText.mono(context, size: 10, color: context.colors.muted),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, IncomeChannel? channel) {
    final isSelected = _selectedFilter == channel;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label, style: AppText.body(context, size: 12, weight: FontWeight.w600, color: isSelected ? context.colors.white : context.colors.navy)),
        selected: isSelected,
        onSelected: (val) => setState(() => _selectedFilter = channel),
        backgroundColor: context.colors.white,
        selectedColor: context.colors.navy,
        checkmarkColor: context.colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(99), side: BorderSide(color: isSelected ? context.colors.navy : context.colors.creamDeep)),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
      ),
    );
  }
}

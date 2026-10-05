import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/transaction.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _amountController = TextEditingController();
  final _originalAmountController = TextEditingController();
  final _noteController = TextEditingController();
  DateTime _date = DateTime.now();
  IncomeChannel _channel = IncomeChannel.payoneer;
  String _originalCurrency = 'USD';
  
  final List<String> _currencies = ['USD', 'EUR', 'GBP', 'PKR', 'CAD', 'AUD', 'AED', 'SAR'];

  @override
  void dispose() {
    _amountController.dispose();
    _originalAmountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: context.colors.navy, onPrimary: context.colors.white, surface: context.colors.cream, onSurface: context.colors.ink),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _date = picked);
  }

  void _save() {
    final amount = double.tryParse(_amountController.text.trim());
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter a valid amount in PKR')));
      return;
    }
    
    final origAmountText = _originalAmountController.text.trim();
    final origAmount = origAmountText.isEmpty ? 0.0 : double.tryParse(origAmountText) ?? 0.0;

    final transaction = TaxTransaction(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      date: _date,
      amountPkr: amount,
      channel: _channel,
      note: _noteController.text.trim(),
      originalCurrency: _originalCurrency,
      originalAmount: origAmount,
    );
    Navigator.of(context).pop(transaction);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.cream,
      appBar: AppBar(
        backgroundColor: context.colors.cream,
        elevation: 0,
        iconTheme: IconThemeData(color: context.colors.ink),
        title: Text('Log a payment', style: AppText.display(context, size: 18)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('Original amount & currency (optional)', style: AppText.body(context, size: 12.5, weight: FontWeight.w600, color: context.colors.muted)),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(color: context.colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: context.colors.creamDeep)),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _originalCurrency,
                    items: _currencies.map((c) => DropdownMenuItem(value: c, child: Text(c, style: AppText.body(context, size: 14, weight: FontWeight.w600)))).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _originalCurrency = val);
                    },
                    icon: Icon(Icons.arrow_drop_down, color: context.colors.navy),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(color: context.colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: context.colors.creamDeep)),
                  child: TextField(
                    controller: _originalAmountController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    style: AppText.mono(context, size: 16, weight: FontWeight.w700),
                    decoration: InputDecoration(
                      hintText: '0',
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text('Amount received (PKR)', style: AppText.body(context, size: 12.5, weight: FontWeight.w600, color: context.colors.muted)),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(color: context.colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: context.colors.creamDeep)),
            child: TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: AppText.mono(context, size: 16, weight: FontWeight.w700),
              decoration: InputDecoration(
                prefixText: 'PKR  ',
                prefixStyle: AppText.mono(context, size: 16, weight: FontWeight.w700, color: context.colors.muted),
                hintText: '0',
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text('Channel', style: AppText.body(context, size: 12.5, weight: FontWeight.w600, color: context.colors.muted)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: IncomeChannel.values.map((c) {
              final selected = _channel == c;
              return GestureDetector(
                onTap: () => setState(() => _channel = c),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: selected ? context.colors.navy.withOpacity(0.08) : context.colors.white,
                    borderRadius: BorderRadius.circular(99),
                    border: Border.all(color: selected ? context.colors.navy : context.colors.creamDeep, width: selected ? 1.5 : 1),
                  ),
                  child: Text(c.label, style: AppText.body(context, size: 12.5, weight: FontWeight.w600, color: selected ? context.colors.navy : context.colors.ink)),
                ),
              );
            }).toList(),
          ),
          if (_channel == IncomeChannel.other)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Row(
                children: [
                  Icon(Icons.warning_amber_rounded, size: 15, color: context.colors.rose),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'This channel does not count toward the 80% approved-channel rule.',
                      style: AppText.body(context, size: 11.5, color: context.colors.rose),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 20),
          Text('Date', style: AppText.body(context, size: 12.5, weight: FontWeight.w600, color: context.colors.muted)),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: _pickDate,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: context.colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: context.colors.creamDeep)),
              child: Row(
                children: [
                  Icon(Icons.calendar_month_outlined, size: 18, color: context.colors.navy),
                  const SizedBox(width: 12),
                  Text('${_date.day}/${_date.month}/${_date.year}', style: AppText.body(context, size: 14, weight: FontWeight.w600)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text('Note (optional)', style: AppText.body(context, size: 12.5, weight: FontWeight.w600, color: context.colors.muted)),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(color: context.colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: context.colors.creamDeep)),
            child: TextField(
              controller: _noteController,
              style: AppText.body(context, size: 14),
              decoration: InputDecoration(
                hintText: 'e.g. Client name or project',
                hintStyle: AppText.body(context, size: 13, color: context.colors.muted),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
            ),
          ),
          const SizedBox(height: 28),
          SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: _save,
              style: ElevatedButton.styleFrom(backgroundColor: context.colors.navy, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(99)), elevation: 0),
              child: Text('Save payment', style: AppText.body(context, size: 15, weight: FontWeight.w600, color: context.colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}

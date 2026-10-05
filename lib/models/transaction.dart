/// Channels recognized by FBR as "approved" foreign remittance channels
/// for the freelancer export-income 80% rule. "Other" (cash, crypto,
/// unofficial transfer) does NOT count toward the 80% threshold.
enum IncomeChannel { payoneer, wise, pakistaniBank, other }

extension IncomeChannelX on IncomeChannel {
  String get label {
    switch (this) {
      case IncomeChannel.payoneer:
        return 'Payoneer';
      case IncomeChannel.wise:
        return 'Wise';
      case IncomeChannel.pakistaniBank:
        return 'Pakistani Bank';
      case IncomeChannel.other:
        return 'Other (not approved)';
    }
  }

  bool get isApproved => this != IncomeChannel.other;

  static IncomeChannel fromLabel(String label) {
    return IncomeChannel.values.firstWhere(
      (c) => c.label == label,
      orElse: () => IncomeChannel.other,
    );
  }
}

class TaxTransaction {
  final String id;
  final DateTime date;
  final double amountPkr;
  final IncomeChannel channel;
  final String note;
  final String originalCurrency;
  final double originalAmount;

  TaxTransaction({
    required this.id,
    required this.date,
    required this.amountPkr,
    required this.channel,
    this.note = '',
    this.originalCurrency = 'PKR',
    this.originalAmount = 0.0,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'date': date.toIso8601String(),
        'amountPkr': amountPkr,
        'channel': channel.label,
        'note': note,
        'originalCurrency': originalCurrency,
        'originalAmount': originalAmount,
      };

  factory TaxTransaction.fromMap(Map<String, dynamic> map) => TaxTransaction(
        id: map['id'] as String,
        date: DateTime.parse(map['date'] as String),
        amountPkr: (map['amountPkr'] as num).toDouble(),
        channel: IncomeChannelX.fromLabel(map['channel'] as String),
        note: (map['note'] as String?) ?? '',
        originalCurrency: (map['originalCurrency'] as String?) ?? 'PKR',
        originalAmount: ((map['originalAmount'] ?? 0) as num).toDouble(),
      );
}

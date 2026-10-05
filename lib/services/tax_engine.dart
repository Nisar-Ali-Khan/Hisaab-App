import '../models/transaction.dart';

class TaxYearRange {
  final DateTime start;
  final DateTime end;
  final String label;
  TaxYearRange({required this.start, required this.end, required this.label});
}

class TaxSummary {
  final double totalIncome;
  final double approvedIncome;
  final double approvedPercentage;
  final bool meets80PercentRule;
  final double estimatedTaxRate;
  final double estimatedTaxAmount;
  final String rateExplanation;

  TaxSummary({
    required this.totalIncome,
    required this.approvedIncome,
    required this.approvedPercentage,
    required this.meets80PercentRule,
    required this.estimatedTaxRate,
    required this.estimatedTaxAmount,
    required this.rateExplanation,
  });
}

/// Encapsulates the Pakistani freelancer export-income tax logic:
/// - Tax year runs July 1 to June 30.
/// - At least 80% of foreign earnings must arrive through an approved
///   channel (Payoneer, Wise, or a Pakistani bank) to qualify for the
///   reduced final tax rate.
/// - PSEB-registered freelancers get 0.25%; non-registered get 1%,
///   both only when the 80% rule is met. If the 80% rule is NOT met,
///   normal income tax slabs may apply instead — this app flags that
///   case rather than guessing a slab calculation, since it depends on
///   total taxable income and filing status.
class TaxEngine {
  TaxYearRange taxYearFor(DateTime date) {
    // Pakistani tax year: July 1 (previous calendar year if month < 7) to June 30.
    final startYear = date.month >= 7 ? date.year : date.year - 1;
    final start = DateTime(startYear, 7, 1);
    final end = DateTime(startYear + 1, 6, 30);
    final label = '$startYear-${(startYear + 1).toString().substring(2)}';
    return TaxYearRange(start: start, end: end, label: label);
  }

  TaxYearRange currentTaxYear() => taxYearFor(DateTime.now());

  List<TaxTransaction> transactionsInRange(List<TaxTransaction> all, TaxYearRange range) {
    return all.where((t) => !t.date.isBefore(range.start) && !t.date.isAfter(range.end)).toList();
  }

  TaxSummary summarize(List<TaxTransaction> transactionsInYear, {required bool psebRegistered}) {
    final total = transactionsInYear.fold<double>(0, (sum, t) => sum + t.amountPkr);
    final approved = transactionsInYear
        .where((t) => t.channel.isApproved)
        .fold<double>(0, (sum, t) => sum + t.amountPkr);
    final pct = total == 0 ? 0.0 : (approved / total) * 100;
    final meets80 = pct >= 80;

    double rate;
    String explanation;
    if (total == 0) {
      rate = 0;
      explanation = 'No income logged yet for this tax year.';
    } else if (meets80) {
      rate = psebRegistered ? 0.25 : 1.0;
      explanation = psebRegistered
          ? 'You meet the 80% approved-channel rule and are PSEB-registered — final tax rate is 0.25% of total foreign income.'
          : 'You meet the 80% approved-channel rule. Final tax rate is 1% of total foreign income. Registering with PSEB could reduce this to 0.25%.';
    } else {
      rate = 0;
      explanation =
          'Less than 80% of your income came through an approved channel (Payoneer, Wise, or a Pakistani bank). The reduced final tax rate may not apply — normal income tax slabs could apply instead. Consult a tax advisor for your exact liability.';
    }

    final taxAmount = meets80 ? total * (rate / 100) : 0.0;

    return TaxSummary(
      totalIncome: total,
      approvedIncome: approved,
      approvedPercentage: pct,
      meets80PercentRule: meets80,
      estimatedTaxRate: rate,
      estimatedTaxAmount: taxAmount,
      rateExplanation: explanation,
    );
  }

  /// Days remaining until the typical annual return filing deadline
  /// (September 30, following the end of the tax year). Returns null if
  /// outside the usual filing window.
  int? daysUntilFilingDeadline(TaxYearRange range) {
    final deadline = DateTime(range.end.year, 9, 30);
    final now = DateTime.now();
    if (now.isAfter(deadline)) return null;
    return deadline.difference(now).inDays;
  }
}

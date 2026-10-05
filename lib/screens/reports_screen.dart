import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/transaction.dart';
import '../services/tax_engine.dart';
import '../services/pdf_service.dart';
import '../widgets/section_card.dart';

class ReportsScreen extends StatefulWidget {
  final TaxYearRange selectedYear;
  final List<TaxTransaction> transactions;
  final TaxSummary summary;
  final String ntn;
  final bool psebRegistered;

  const ReportsScreen({
    super.key,
    required this.selectedYear,
    required this.transactions,
    required this.summary,
    required this.ntn,
    required this.psebRegistered,
  });

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  bool _generating = false;

  Future<void> _generate() async {
    setState(() => _generating = true);
    try {
      final service = PdfService();
      final file = await service.generateReport(
        taxYearLabel: widget.selectedYear.label,
        transactions: widget.transactions,
        summary: widget.summary,
        ntn: widget.ntn,
        psebRegistered: widget.psebRegistered,
      );
      await service.shareReport(file);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not generate the report. Please try again.')));
      }
    } finally {
      if (mounted) setState(() => _generating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasData = widget.transactions.isNotEmpty;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      children: [
        Text('Reports', style: AppText.display(context, size: 22)),
        const SizedBox(height: 4),
        Text('A clean summary for your accountant or IRIS filing', style: AppText.body(context, size: 13, color: context.colors.muted)),
        const SizedBox(height: 20),
        SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: context.colors.navy.withOpacity(0.08), borderRadius: BorderRadius.circular(14)),
                    child: Icon(Icons.picture_as_pdf_outlined, size: 18, color: context.colors.navy),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Tax Year ${widget.selectedYear.label} Report', style: AppText.body(context, size: 14, weight: FontWeight.w700)),
                        const SizedBox(height: 2),
                        Text('${widget.transactions.length} transactions included', style: AppText.body(context, size: 11.5, color: context.colors.muted)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: hasData && !_generating ? _generate : null,
                  icon: _generating
                      ? SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: context.colors.white))
                      : Icon(Icons.download_outlined, size: 18, color: context.colors.white),
                  label: Text(
                    _generating ? 'Generating…' : 'Generate & share PDF',
                    style: AppText.body(context, size: 14, weight: FontWeight.w600, color: context.colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.colors.navy,
                    disabledBackgroundColor: context.colors.creamDeep,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(99)),
                    elevation: 0,
                  ),
                ),
              ),
              if (!hasData) ...[
                const SizedBox(height: 10),
                Text('Log at least one transaction to generate a report.', style: AppText.body(context, size: 11.5, color: context.colors.muted)),
              ],
            ],
          ),
        ),
        SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.shield_outlined, size: 15, color: context.colors.muted),
                  const SizedBox(width: 8),
                  Text('What\'s in the report', style: AppText.display(context, size: 14)),
                ],
              ),
              const SizedBox(height: 10),
              _bullet('Total foreign income and the 80%-approved-channel breakdown'),
              _bullet('Your estimated final tax rate and amount'),
              _bullet('A full, dated list of every transaction logged this tax year'),
              const SizedBox(height: 12),
              Text(
                'This is a self-reported summary for reference, not an official tax document. Always confirm figures with a tax consultant or FBR IRIS before filing.',
                style: AppText.body(context, size: 11.5, color: context.colors.muted),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _bullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('•  ', style: AppText.body(context, size: 13)),
          Expanded(child: Text(text, style: AppText.body(context, size: 13))),
        ],
      ),
    );
  }
}

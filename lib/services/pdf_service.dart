import 'dart:io';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import '../models/transaction.dart';
import 'tax_engine.dart';

class PdfService {
  final _currency = NumberFormat.currency(locale: 'en_PK', symbol: 'PKR ', decimalDigits: 0);
  final _dateFmt = DateFormat('d MMM yyyy');

  Future<File> generateReport({
    required String taxYearLabel,
    required List<TaxTransaction> transactions,
    required TaxSummary summary,
    required String ntn,
    required bool psebRegistered,
  }) async {
    final doc = pw.Document();
    final sorted = [...transactions]..sort((a, b) => a.date.compareTo(b.date));

    doc.addPage(
      pw.MultiPage(
        build: (context) => [
          pw.Text('Hisaab', style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 2),
          pw.Text('Freelancer Tax Companion', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
          pw.SizedBox(height: 20),
          pw.Text('Foreign Income Summary — Tax Year $taxYearLabel', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 4),
          pw.Text('Generated ${_dateFmt.format(DateTime.now())}', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
          pw.SizedBox(height: 16),
          pw.Text('NTN: ${ntn.isEmpty ? '(not set)' : ntn}', style: const pw.TextStyle(fontSize: 11)),
          pw.Text('PSEB Registered: ${psebRegistered ? 'Yes' : 'No'}', style: const pw.TextStyle(fontSize: 11)),
          pw.SizedBox(height: 20),
          pw.Text('Summary', style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 8),
          pw.Table(
            columnWidths: const {0: pw.FlexColumnWidth(2), 1: pw.FlexColumnWidth(1.4)},
            children: [
              _row('Total foreign income', _currency.format(summary.totalIncome)),
              _row('Via approved channels', _currency.format(summary.approvedIncome)),
              _row('Approved-channel percentage', '${summary.approvedPercentage.toStringAsFixed(1)}%'),
              _row('Meets 80% rule', summary.meets80PercentRule ? 'Yes' : 'No'),
              _row('Estimated final tax rate', summary.meets80PercentRule ? '${summary.estimatedTaxRate}%' : 'N/A — see note'),
              _row('Estimated tax amount', summary.meets80PercentRule ? _currency.format(summary.estimatedTaxAmount) : 'N/A — see note'),
            ],
          ),
          pw.SizedBox(height: 14),
          pw.Container(
            padding: const pw.EdgeInsets.all(10),
            decoration: pw.BoxDecoration(color: PdfColors.grey100, borderRadius: pw.BorderRadius.circular(6)),
            child: pw.Text(summary.rateExplanation, style: const pw.TextStyle(fontSize: 10)),
          ),
          pw.SizedBox(height: 24),
          pw.Text('Transactions (${sorted.length})', style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 8),
          pw.TableHelper.fromTextArray(
            headers: ['Date', 'Channel', 'Amount (PKR)', 'Note'],
            data: sorted
                .map((t) => [_dateFmt.format(t.date), t.channel.label, _currency.format(t.amountPkr), t.note])
                .toList(),
            headerStyle: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
            cellStyle: const pw.TextStyle(fontSize: 9.5),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.grey200),
            cellAlignments: {0: pw.Alignment.centerLeft, 1: pw.Alignment.centerLeft, 2: pw.Alignment.centerRight, 3: pw.Alignment.centerLeft},
          ),
          pw.SizedBox(height: 24),
          pw.Divider(),
          pw.Text(
            'This report is generated from self-reported data for reference purposes. It is not tax advice. '
            'Please verify figures and confirm your final tax liability with a registered tax consultant or on the FBR IRIS portal before filing.',
            style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey500),
          ),
        ],
      ),
    );

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/Hisaab_Report_$taxYearLabel.pdf');
    await file.writeAsBytes(await doc.save());
    return file;
  }

  pw.TableRow _row(String label, String value) {
    return pw.TableRow(
      children: [
        pw.Padding(padding: const pw.EdgeInsets.symmetric(vertical: 4), child: pw.Text(label, style: const pw.TextStyle(fontSize: 11))),
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(vertical: 4),
          child: pw.Text(value, style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.right),
        ),
      ],
    );
  }

  Future<void> shareReport(File file) async {
    await Share.shareXFiles([XFile(file.path)], text: 'Hisaab tax year report');
  }
}

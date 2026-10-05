import 'package:flutter/material.dart';
import '../models/transaction.dart';
import '../theme/app_theme.dart';

class ChannelBreakdownBar extends StatelessWidget {
  final List<TaxTransaction> transactions;

  const ChannelBreakdownBar({super.key, required this.transactions});

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) return const SizedBox.shrink();

    double total = 0;
    Map<IncomeChannel, double> channelTotals = {
      for (var c in IncomeChannel.values) c: 0.0,
    };

    for (var t in transactions) {
      channelTotals[t.channel] = (channelTotals[t.channel] ?? 0) + t.amountPkr;
      total += t.amountPkr;
    }

    if (total == 0) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Income by Channel', style: AppText.display(context, size: 15)),
        const SizedBox(height: 16),
        ClipRRect(
          borderRadius: BorderRadius.circular(99),
          child: SizedBox(
            height: 12,
            width: double.infinity,
            child: Row(
              children: IncomeChannel.values.map((c) {
                final amount = channelTotals[c] ?? 0.0;
                if (amount == 0) return const SizedBox.shrink();
                final flex = (amount / total * 1000).toInt();
                return Expanded(
                  flex: flex,
                  child: Container(color: _getChannelColor(context, c)),
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: IncomeChannel.values.map((c) {
            final amount = channelTotals[c] ?? 0.0;
            if (amount == 0) return const SizedBox.shrink();
            final pct = (amount / total) * 100;
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: _getChannelColor(context, c)),
                ),
                const SizedBox(width: 6),
                Text(
                  '${c.label} (${pct.toStringAsFixed(0)}%)',
                  style: AppText.body(context, size: 12, color: context.colors.muted),
                ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }

  Color _getChannelColor(BuildContext context, IncomeChannel c) {
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
}

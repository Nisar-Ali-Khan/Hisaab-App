import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class NavItem {
  final IconData icon;
  final String label;
  const NavItem(this.icon, this.label);
}

class HisaabBottomNav extends StatelessWidget {
  final int activeIndex;
  final ValueChanged<int> onTap;

  static const items = [
    NavItem(Icons.space_dashboard_outlined, 'Dashboard'),
    NavItem(Icons.receipt_long_outlined, 'Transactions'),
    NavItem(Icons.description_outlined, 'Reports'),
    NavItem(Icons.settings_outlined, 'Settings'),
  ];

  const HisaabBottomNav({super.key, required this.activeIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(color: context.colors.white, border: Border(top: BorderSide(color: context.colors.creamDeep))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(items.length, (i) {
          final active = i == activeIndex;
          final color = active ? context.colors.navy : context.colors.muted;
          return GestureDetector(
            onTap: () => onTap(i),
            behavior: HitTestBehavior.opaque,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(items[i].icon, size: 22, color: color),
                const SizedBox(height: 2),
                Text(items[i].label, style: AppText.body(context, size: 10, weight: FontWeight.w600, color: color)),
              ],
            ),
          );
        }),
      ),
    );
  }
}

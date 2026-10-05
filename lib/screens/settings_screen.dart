import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/storage_service.dart';
import '../main.dart';
import '../widgets/section_card.dart';

class SettingsScreen extends StatefulWidget {
  final String name;
  final String ntn;
  final bool psebRegistered;
  final VoidCallback onProfileChanged;

  const SettingsScreen({
    super.key,
    required this.name,
    required this.ntn,
    required this.psebRegistered,
    required this.onProfileChanged,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _ntnController;
  late bool _pseb;
  final _storage = StorageService();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.name);
    _ntnController = TextEditingController(text: widget.ntn);
    _pseb = widget.psebRegistered;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ntnController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    await _storage.saveName(_nameController.text.trim());
    await _storage.saveNtn(_ntnController.text.trim());
    await _storage.savePsebRegistered(_pseb);
    widget.onProfileChanged();
    if (!mounted) return;
    setState(() => _saving = false);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Saved')));
  }

  Future<void> _confirmClearData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Clear all data?', style: AppText.display(context, size: 18)),
        content: Text(
          'This permanently deletes all logged transactions and your profile from this device. This can\'t be undone.',
          style: AppText.body(context, size: 13.5, color: context.colors.muted),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text('Cancel', style: AppText.body(context, size: 14, color: context.colors.muted))),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text('Clear', style: AppText.body(context, size: 14, weight: FontWeight.w700, color: context.colors.rose))),
        ],
      ),
    );
    if (confirmed == true) {
      await _storage.clearAllData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('All data cleared. Restart the app to set up again.')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      children: [
        Text('Settings', style: AppText.display(context, size: 22)),
        const SizedBox(height: 16),
        SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Profile', style: AppText.display(context, size: 15)),
              const SizedBox(height: 14),
              _field('Name', _nameController, 'Your name'),
              const SizedBox(height: 14),
              _field('NTN', _ntnController, 'National Tax Number'),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('PSEB registered', style: AppText.body(context, size: 13.5, weight: FontWeight.w700)),
                        Text('Affects your estimated tax rate', style: AppText.body(context, size: 11.5, color: context.colors.muted)),
                      ],
                    ),
                  ),
                  Switch(value: _pseb, onChanged: (v) => setState(() => _pseb = v), activeColor: context.colors.teal),
                ],
              ),
              const SizedBox(height: 14),
              Text('Theme', style: AppText.body(context, size: 12, weight: FontWeight.w600, color: context.colors.muted)),
              const SizedBox(height: 6),
              Container(
                decoration: BoxDecoration(color: context.colors.cream, borderRadius: BorderRadius.circular(14)),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<ThemeMode>(
                    isExpanded: true,
                    value: themeNotifier.value,
                    icon: Icon(Icons.arrow_drop_down, color: context.colors.navy),
                    dropdownColor: context.colors.cream,
                    items: [
                      DropdownMenuItem(value: ThemeMode.system, child: Text('System Default', style: AppText.body(context, size: 14, weight: FontWeight.w600))),
                      DropdownMenuItem(value: ThemeMode.light, child: Text('Light', style: AppText.body(context, size: 14, weight: FontWeight.w600))),
                      DropdownMenuItem(value: ThemeMode.dark, child: Text('Dark', style: AppText.body(context, size: 14, weight: FontWeight.w600))),
                    ],
                    onChanged: (ThemeMode? mode) async {
                      if (mode != null) {
                        themeNotifier.value = mode;
                        String modeStr = 'system';
                        if (mode == ThemeMode.light) modeStr = 'light';
                        if (mode == ThemeMode.dark) modeStr = 'dark';
                        await _storage.saveThemeMode(modeStr);
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saving ? null : _save,
                  style: ElevatedButton.styleFrom(backgroundColor: context.colors.navy, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(99)), elevation: 0),
                  child: _saving
                      ? SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: context.colors.white))
                      : Text('Save', style: AppText.body(context, size: 14, weight: FontWeight.w600, color: context.colors.white)),
                ),
              ),
            ],
          ),
        ),
        SectionCard(
          padding: EdgeInsets.zero,
          child: InkWell(
            onTap: _confirmClearData,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  Icon(Icons.delete_outline, size: 18, color: context.colors.rose),
                  const SizedBox(width: 14),
                  Expanded(child: Text('Clear all data', style: AppText.body(context, size: 13.5, weight: FontWeight.w600, color: context.colors.rose))),
                  Icon(Icons.chevron_right, size: 18, color: context.colors.muted),
                ],
              ),
            ),
          ),
        ),
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text('Hisaab · Version 1.0.0', style: AppText.body(context, size: 11, color: context.colors.muted)),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: context.colors.navy.withOpacity(0.05), borderRadius: BorderRadius.circular(16)),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline, size: 16, color: context.colors.navy),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Hisaab helps you track your own foreign income and estimate tax. It is not a substitute for professional tax advice — always confirm with a registered consultant before filing.',
                  style: AppText.body(context, size: 11.5, color: context.colors.navy),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _field(String label, TextEditingController controller, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppText.body(context, size: 12, weight: FontWeight.w600, color: context.colors.muted)),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(color: context.colors.cream, borderRadius: BorderRadius.circular(14)),
          child: TextField(
            controller: controller,
            style: AppText.body(context, size: 14, weight: FontWeight.w600),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: AppText.body(context, size: 13, color: context.colors.muted),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            ),
          ),
        ),
      ],
    );
  }
}

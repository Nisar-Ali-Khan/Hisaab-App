import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/transaction.dart';

class StorageService {
  static const _keyNtn = 'ntn';
  static const _keyPseb = 'pseb_registered';
  static const _keyTransactions = 'transactions';
  static const _keyName = 'display_name';
  static const _keyOnboarded = 'onboarded';

  Future<SharedPreferences> get _prefs async => SharedPreferences.getInstance();

  Future<bool> loadOnboarded() async {
    final prefs = await _prefs;
    return prefs.getBool(_keyOnboarded) ?? false;
  }

  Future<void> saveOnboarded(bool value) async {
    final prefs = await _prefs;
    await prefs.setBool(_keyOnboarded, value);
  }

  Future<String> loadName() async {
    final prefs = await _prefs;
    return prefs.getString(_keyName) ?? '';
  }

  Future<void> saveName(String name) async {
    final prefs = await _prefs;
    await prefs.setString(_keyName, name);
  }

  Future<String> loadNtn() async {
    final prefs = await _prefs;
    return prefs.getString(_keyNtn) ?? '';
  }

  Future<void> saveNtn(String ntn) async {
    final prefs = await _prefs;
    await prefs.setString(_keyNtn, ntn);
  }

  Future<bool> loadPsebRegistered() async {
    final prefs = await _prefs;
    return prefs.getBool(_keyPseb) ?? false;
  }

  Future<void> savePsebRegistered(bool value) async {
    final prefs = await _prefs;
    await prefs.setBool(_keyPseb, value);
  }

  Future<List<TaxTransaction>> loadTransactions() async {
    final prefs = await _prefs;
    final stored = prefs.getString(_keyTransactions);
    if (stored == null) return [];
    final list = jsonDecode(stored) as List<dynamic>;
    return list.map((e) => TaxTransaction.fromMap(e as Map<String, dynamic>)).toList();
  }

  Future<void> saveTransactions(List<TaxTransaction> transactions) async {
    final prefs = await _prefs;
    final list = transactions.map((t) => t.toMap()).toList();
    await prefs.setString(_keyTransactions, jsonEncode(list));
  }

  static const _keyTheme = 'theme_preference';

  Future<String> loadThemeMode() async {
    final prefs = await _prefs;
    return prefs.getString(_keyTheme) ?? 'system';
  }

  Future<void> saveThemeMode(String mode) async {
    final prefs = await _prefs;
    await prefs.setString(_keyTheme, mode);
  }

  Future<void> clearAllData() async {
    final prefs = await _prefs;
    await prefs.remove(_keyNtn);
    await prefs.remove(_keyPseb);
    await prefs.remove(_keyTransactions);
    await prefs.remove(_keyName);
    await prefs.remove(_keyOnboarded);
    await prefs.remove(_keyTheme);
  }
}

import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/splash_screen.dart';
import 'services/storage_service.dart';

final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.system);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final storage = StorageService();
  final modeStr = await storage.loadThemeMode();
  ThemeMode mode = ThemeMode.system;
  if (modeStr == 'light') mode = ThemeMode.light;
  if (modeStr == 'dark') mode = ThemeMode.dark;
  themeNotifier.value = mode;

  runApp(const HisaabApp());
}

class HisaabApp extends StatelessWidget {
  const HisaabApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, ThemeMode currentMode, __) {
        return MaterialApp(
          title: 'Hisaab',
          debugShowCheckedModeBanner: false,
          theme: buildAppTheme(),
          darkTheme: buildAppThemeDark(),
          themeMode: currentMode,
          home: const SplashScreen(),
        );
      },
    );
  }
}

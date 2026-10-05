import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/storage_service.dart';
import 'onboarding_screen.dart';
import 'home_shell.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _scale = Tween<double>(begin: 0.85, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));
    _controller.forward();
    _decideNext();
  }

  Future<void> _decideNext() async {
    final onboarded = await StorageService().loadOnboarded();
    await Future.delayed(const Duration(milliseconds: 1600));
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (_, animation, __) => FadeTransition(
          opacity: animation,
          child: onboarded ? const HomeShell() : const OnboardingScreen(),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.navyDeep,
      body: Center(
        child: FadeTransition(
          opacity: _fade,
          child: ScaleTransition(
            scale: _scale,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 84,
                  height: 84,
                  decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: context.colors.gold, width: 2.5)),
                  child: Icon(Icons.receipt_long_outlined, size: 34, color: context.colors.gold),
                ),
                const SizedBox(height: 22),
                Text('Hisaab', style: AppText.display(context, size: 30, weight: FontWeight.w600, color: context.colors.white)),
                const SizedBox(height: 6),
                Text(
                  'FREELANCER TAX COMPANION',
                  style: AppText.body(context, size: 11, weight: FontWeight.w600, color: context.colors.tealLight).copyWith(letterSpacing: 2.5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

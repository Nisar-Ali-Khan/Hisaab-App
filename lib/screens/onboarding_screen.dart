import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/storage_service.dart';
import 'home_shell.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  static const int _lastPage = 2;

  final _nameController = TextEditingController();
  final _ntnController = TextEditingController();
  bool _psebRegistered = false;
  bool? _psebAnswered;

  void _nextPage() {
    if (_currentPage < _lastPage) {
      setState(() => _currentPage++);
      _pageController.animateToPage(_currentPage, duration: const Duration(milliseconds: 350), curve: Curves.easeOut);
    } else {
      _finish();
    }
  }

  void _previousPage() {
    if (_currentPage == 0) return;
    setState(() => _currentPage--);
    _pageController.animateToPage(_currentPage, duration: const Duration(milliseconds: 350), curve: Curves.easeOut);
  }

  Future<void> _finish() async {
    final storage = StorageService();
    await storage.saveName(_nameController.text.trim());
    await storage.saveNtn(_ntnController.text.trim());
    await storage.savePsebRegistered(_psebRegistered);
    await storage.saveOnboarded(true);
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const HomeShell()), (route) => false);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _ntnController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final canContinue = _currentPage != 2 || _psebAnswered != null;

    return Scaffold(
      backgroundColor: context.colors.cream,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 18, 24, 8),
              child: Row(
                children: [
                  if (_currentPage > 0)
                    IconButton(onPressed: _previousPage, icon: Icon(Icons.arrow_back_ios_new, size: 18, color: context.colors.ink))
                  else
                    const SizedBox(width: 48),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        3,
                        (i) => AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          height: 5,
                          width: i == _currentPage ? 28 : 8,
                          decoration: BoxDecoration(color: i == _currentPage ? context.colors.navy : context.colors.creamDeep, borderRadius: BorderRadius.circular(99)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [_buildWelcomePage(), _buildDetailsPage(), _buildPsebPage()],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: canContinue ? _nextPage : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.colors.navy,
                    foregroundColor: context.colors.white,
                    disabledBackgroundColor: context.colors.creamDeep,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(99)),
                  ),
                  child: Text(
                    _currentPage == _lastPage ? 'Get started' : 'Continue',
                    style: AppText.body(context, size: 15, weight: FontWeight.w600, color: context.colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomePage() {
    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(color: context.colors.navy.withOpacity(0.08), shape: BoxShape.circle),
            child: Icon(Icons.receipt_long_outlined, size: 44, color: context.colors.navy),
          ),
          const SizedBox(height: 32),
          Text('Track your foreign\nincome, simply', textAlign: TextAlign.center, style: AppText.display(context, size: 28)),
          const SizedBox(height: 14),
          Text(
            'Log Payoneer, Wise, and bank payments, and Hisaab tracks the 80% rule and your estimated tax — so you\'re never guessing at filing time.',
            textAlign: TextAlign.center,
            style: AppText.body(context, size: 14, color: context.colors.muted),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsPage() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 30, 28, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('A couple of\ndetails', style: AppText.display(context, size: 28)),
          const SizedBox(height: 10),
          Text('You can change these anytime in Settings.', style: AppText.body(context, size: 14, color: context.colors.muted)),
          const SizedBox(height: 28),
          Text('Your name', style: AppText.body(context, size: 12.5, weight: FontWeight.w600, color: context.colors.muted)),
          const SizedBox(height: 8),
          _textField(_nameController, 'e.g. Ali Khan'),
          const SizedBox(height: 20),
          Text('NTN (optional)', style: AppText.body(context, size: 12.5, weight: FontWeight.w600, color: context.colors.muted)),
          const SizedBox(height: 8),
          _textField(_ntnController, 'National Tax Number'),
        ],
      ),
    );
  }

  Widget _textField(TextEditingController controller, String hint) {
    return Container(
      decoration: BoxDecoration(color: context.colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: context.colors.creamDeep)),
      child: TextField(
        controller: controller,
        style: AppText.body(context, size: 14, weight: FontWeight.w600),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: AppText.body(context, size: 14, color: context.colors.muted),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildPsebPage() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 30, 28, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Are you PSEB\nregistered?', style: AppText.display(context, size: 28)),
          const SizedBox(height: 10),
          Text(
            'PSEB (Pakistan Software Export Board) registration can reduce your final tax rate from 1% to 0.25% on qualifying export income.',
            style: AppText.body(context, size: 14, color: context.colors.muted),
          ),
          const SizedBox(height: 28),
          _choiceCard('Yes, I\'m registered', _psebAnswered == true, () => setState(() {
                _psebAnswered = true;
                _psebRegistered = true;
              })),
          const SizedBox(height: 12),
          _choiceCard('No, not registered', _psebAnswered == false, () => setState(() {
                _psebAnswered = false;
                _psebRegistered = false;
              })),
        ],
      ),
    );
  }

  Widget _choiceCard(String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 17),
        decoration: BoxDecoration(
          color: selected ? context.colors.navy.withOpacity(0.06) : context.colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: selected ? context.colors.navy : context.colors.creamDeep, width: selected ? 1.5 : 1),
        ),
        child: Row(
          children: [
            Icon(selected ? Icons.check_circle : Icons.circle_outlined, color: selected ? context.colors.navy : context.colors.muted),
            const SizedBox(width: 14),
            Expanded(child: Text(label, style: AppText.body(context, size: 15, weight: FontWeight.w600))),
          ],
        ),
      ),
    );
  }
}

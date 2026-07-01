import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../models/onboarding_data.dart';
import '../widgets/illustration_painter.dart';
import 'login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  late AnimationController _contentController;
  late Animation<Offset> _slideAnim;
  late Animation<double> _fadeAnim;

  final List<OnboardingData> _pages = OnboardingData.pages;

  @override
  void initState() {
    super.initState();
    _contentController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _contentController,
      curve: Curves.easeOut,
    ));
    _fadeAnim = CurvedAnimation(
      parent: _contentController,
      curve: Curves.easeIn,
    );
    _contentController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _navigateToLogin();
    }
  }

  void _skip() {
    _navigateToLogin();
  }

  void _navigateToLogin() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, animation, __) => FadeTransition(
          opacity: animation,
          child: const LoginScreen(),
        ),
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  void _onPageChanged(int index) {
    setState(() => _currentPage = index);
    _contentController.reset();
    _contentController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              children: [
                _buildTopBar(),
                // PERBAIKAN: Konten utama (Gambar + Teks) sekarang bersatu di dalam Expanded PageView
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: _onPageChanged,
                    itemCount: _pages.length,
                    itemBuilder: (_, i) {
                      return Column(
                        children: [
                          Expanded(
                            flex: 5,
                            child: IllustrationPanel(
                              illustration: _pages[i].illustration,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 28),
                            child: SlideTransition(
                              position: _slideAnim,
                              child: FadeTransition(
                                opacity: _fadeAnim,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _pages[i].title,
                                      style: const TextStyle(
                                        fontSize: 26,
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFF111111),
                                        height: 1.2,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      _pages[i].description,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                        color: AppColors.black.withOpacity(0.5),
                                        height: 1.6,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                _buildBottomControls(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Top bar ──────────────────────────────────────────────────────────────
  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Image.asset(
            'assets/images/logoPolos.png',
            width: 30,
            height: 30,
            fit: BoxFit.contain,
          ),
          const SizedBox(width: 8),
          const Text(
            'SILAPOR UIN',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.darkGreen2,
              letterSpacing: 0.5,
            ),
          ),
          const Spacer(),
          if (_currentPage < _pages.length - 1)
            GestureDetector(
              onTap: _skip,
              child: const Text(
                'Lewati',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF888888),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ── Bottom controls (Indicator & Button) ─────────────────────────────────
  Widget _buildBottomControls() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 20, 28, 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildDotIndicators(),
          const SizedBox(height: 32),
          _buildNextButton(),
        ],
      ),
    );
  }

  Widget _buildDotIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: List.generate(
        _pages.length,
        (i) {
          final isActive = i == _currentPage;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.only(right: 6),
            width: isActive ? 24 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: isActive ? AppColors.darkGreen2 : const Color(0xFFCCCCCC),
              borderRadius: BorderRadius.circular(4),
            ),
          );
        },
      ),
    );
  }

  Widget _buildNextButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: _nextPage,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1A5E35),
          foregroundColor: AppColors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _currentPage == _pages.length - 1 ? 'Mulai' : 'Lanjut',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward, size: 18),
          ],
        ),
      ),
    );
  }
}
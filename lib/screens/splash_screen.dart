import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'onboarding_screen.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;
  late Animation<Offset> _slideSubtitleAnim;
  late Animation<Offset> _slideBadgeAnim;
  late Animation<double> _fadeProgressAnim;

  // untuk loading timer
  Timer? _timer;
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _fadeAnim = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
    );
    _scaleAnim = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.elasticOut),
      ),
    );
    _slideSubtitleAnim = Tween<Offset>(
      begin: const Offset(0, 0.4),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.3, 0.7, curve: Curves.easeOut),
    ));
    _slideBadgeAnim = Tween<Offset>(
      begin: const Offset(0, 0.6),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.45, 0.8, curve: Curves.easeOut),
    ));
    
    // PERBAIKAN: Menutup tanda kurung CurvedAnimation dengan benar di sini
    _fadeProgressAnim = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.7, 1.0, curve: Curves.easeIn),
    );

    _controller.forward();

    // PERBAIKAN: Meletakkan timer di tempat yang benar secara terpisah
    _timer = Timer(const Duration(seconds: 5), () {
      _goToNextScreen();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _goToNextScreen() async {
  if (_isNavigating || !mounted) return;

  _isNavigating = true;
  _timer?.cancel();

  final prefs = await SharedPreferences.getInstance();
  final hasSeenOnboarding = prefs.getBool('has_seen_onboarding') ?? false;

  if (!mounted) return;

  Navigator.of(context).pushReplacement(
    PageRouteBuilder(
      pageBuilder: (_, animation, __) => FadeTransition(
        opacity: animation,
        child: hasSeenOnboarding
            ? const LoginScreen()
            : const OnboardingScreen(),
      ),
      transitionDuration: const Duration(milliseconds: 600),
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: GestureDetector(
        onTap: _goToNextScreen,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.darkGreen1,
                AppColors.darkGreen2,
                AppColors.midGreen,
                AppColors.lightGreen,
              ],
              stops: [0.0, 0.35, 0.7, 1.0],
            ),
          ),
          child: SafeArea(
            child: Stack(
              children: [
                _buildDecorCircle(
                  top: -size.width * 0.25,
                  right: -size.width * 0.2,
                  diameter: size.width * 0.65,
                ),
                _buildDecorCircle(
                  bottom: -size.width * 0.3,
                  left: -size.width * 0.15,
                  diameter: size.width * 0.7,
                ),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FadeTransition(
                        opacity: _fadeAnim,
                        child: ScaleTransition(
                          scale: _scaleAnim,
                          child: _buildIconCard(),
                        ),
                      ),
                      const SizedBox(height: 28),
                      FadeTransition(
                        opacity: _fadeAnim,
                        child: ScaleTransition(
                          scale: _scaleAnim,
                          child: const Text(
                            'SILAPOR',
                            style: TextStyle(
                              fontSize: 38,
                              fontWeight: FontWeight.w800,
                              color: AppColors.white,
                              letterSpacing: 3.5,
                              shadows: [
                                Shadow(
                                  blurRadius: 12,
                                  color: Color(0x55000000),
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      SlideTransition(
                        position: _slideSubtitleAnim,
                        child: FadeTransition(
                          opacity: _fadeAnim,
                          child: Text(
                            'Sistem Laporan Fasilitas',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                              color: AppColors.white.withOpacity(0.78),
                              letterSpacing: 0.6,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 36),
                      SlideTransition(
                        position: _slideBadgeAnim,
                        child: FadeTransition(
                          opacity: _fadeAnim,
                          child: _buildPillBadge(),
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 40,
                  left: 0,
                  right: 0,
                  child: FadeTransition(
                    opacity: _fadeProgressAnim,
                    child: const Center(
                      child: SizedBox(
                        width: 28,
                        height: 28,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(AppColors.white),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDecorCircle({
    double? top,
    double? bottom,
    double? left,
    double? right,
    required double diameter,
  }) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Container(
        width: diameter,
        height: diameter,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.white.withOpacity(0.04),
        ),
      ),
    );
  }

  Widget _buildIconCard() {
    return SizedBox(
      width: 150,
      height: 150,
      child: Center(
        child: Image.asset(
          'assets/images/logoPolos.png',
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  Widget _buildPillBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.white.withOpacity(0.13),
        borderRadius: BorderRadius.circular(40),
        border: Border.all(
          color: AppColors.white.withOpacity(0.3),
          width: 1.2,
        ),
      ),
      child: const Text(
        'UIN ALAUDDIN MAKASSAR',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.white,
          letterSpacing: 1.5,
        ),
      ),
    );
  }
}
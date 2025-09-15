import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  String _statusText = 'Initializing VoiceType...';
  bool _isLoading = true;
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startInitialization();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
    ));

    _animationController.forward();
  }

  Future<void> _startInitialization() async {
    try {
      // Step 1: Initialize offline voice models
      await _loadVoskModels();

      // Step 2: Check permissions
      await _checkPermissions();

      // Step 3: Validate keyboard setup
      await _validateKeyboardSetup();

      // Step 4: Complete initialization
      await _completeSetup();
    } catch (e) {
      _handleInitializationError(e.toString());
    }
  }

  Future<void> _loadVoskModels() async {
    setState(() {
      _statusText = 'Loading Hindi voice model...';
      _progress = 0.2;
    });

    await Future.delayed(const Duration(milliseconds: 800));

    setState(() {
      _statusText = 'Loading English voice model...';
      _progress = 0.4;
    });

    await Future.delayed(const Duration(milliseconds: 800));

    setState(() {
      _statusText = 'Setting up offline voice recognition...';
      _progress = 0.6;
    });

    await Future.delayed(const Duration(milliseconds: 600));
  }

  Future<void> _checkPermissions() async {
    setState(() {
      _statusText = 'Checking microphone permissions...';
      _progress = 0.7;
    });

    await Future.delayed(const Duration(milliseconds: 400));

    // Simulate permission check
    bool hasPermission = true; // Mock permission status

    if (!hasPermission) {
      _navigateToPermissionScreen();
      return;
    }
  }

  Future<void> _validateKeyboardSetup() async {
    setState(() {
      _statusText = 'Validating keyboard setup...';
      _progress = 0.85;
    });

    await Future.delayed(const Duration(milliseconds: 500));

    // Check if keyboard is properly configured
    bool isKeyboardEnabled = false; // Mock keyboard status
    bool isFirstTime = true; // Mock first time user status

    if (!isKeyboardEnabled && isFirstTime) {
      _navigateToOnboarding();
      return;
    } else if (!isKeyboardEnabled) {
      _navigateToKeyboardSettings();
      return;
    }
  }

  Future<void> _completeSetup() async {
    setState(() {
      _statusText = 'Ready to type with voice!';
      _progress = 1.0;
      _isLoading = false;
    });

    await Future.delayed(const Duration(milliseconds: 800));

    // Navigate to main keyboard interface
    _navigateToKeyboardInterface();
  }

  void _handleInitializationError(String error) {
    setState(() {
      _statusText = 'Setup failed. Tap to retry.';
      _isLoading = false;
      _progress = 0.0;
    });
  }

  void _navigateToOnboarding() {
    Navigator.pushReplacementNamed(context, '/onboarding-flow');
  }

  void _navigateToPermissionScreen() {
    Navigator.pushReplacementNamed(context, '/permission-request-screen');
  }

  void _navigateToKeyboardSettings() {
    Navigator.pushReplacementNamed(context, '/keyboard-settings');
  }

  void _navigateToKeyboardInterface() {
    Navigator.pushReplacementNamed(context, '/custom-keyboard-interface');
  }

  void _retryInitialization() {
    setState(() {
      _statusText = 'Initializing VoiceType...';
      _isLoading = true;
      _progress = 0.0;
    });
    _startInitialization();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.lightTheme.primaryColor,
              AppTheme.lightTheme.primaryColor.withValues(alpha: 0.8),
              AppTheme.lightTheme.colorScheme.secondary,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),

              // App Logo with Animation
              AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return FadeTransition(
                    opacity: _fadeAnimation,
                    child: ScaleTransition(
                      scale: _scaleAnimation,
                      child: _buildAppLogo(),
                    ),
                  );
                },
              ),

              SizedBox(height: 8.h),

              // App Name
              FadeTransition(
                opacity: _fadeAnimation,
                child: Text(
                  'VoiceType',
                  style: AppTheme.lightTheme.textTheme.headlineLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ),

              SizedBox(height: 2.h),

              // Tagline
              FadeTransition(
                opacity: _fadeAnimation,
                child: Text(
                  'Offline Voice Keyboard',
                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),

              const Spacer(flex: 1),

              // Loading Section
              _buildLoadingSection(),

              const Spacer(flex: 2),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppLogo() {
    return Container(
      width: 25.w,
      height: 25.w,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Center(
        child: CustomIconWidget(
          iconName: 'mic',
          color: Colors.white,
          size: 12.w,
        ),
      ),
    );
  }

  Widget _buildLoadingSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.w),
      child: Column(
        children: [
          // Status Text
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Text(
              _statusText,
              key: ValueKey(_statusText),
              style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                color: Colors.white.withValues(alpha: 0.9),
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          SizedBox(height: 4.h),

          // Progress Indicator or Retry Button
          _isLoading ? _buildProgressIndicator() : _buildRetryButton(),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Column(
      children: [
        // Progress Bar
        Container(
          width: 60.w,
          height: 6,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(3),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: _progress,
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation<Color>(
                Colors.white.withValues(alpha: 0.8),
              ),
            ),
          ),
        ),

        SizedBox(height: 2.h),

        // Progress Percentage
        Text(
          '${(_progress * 100).toInt()}%',
          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
            color: Colors.white.withValues(alpha: 0.7),
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildRetryButton() {
    return GestureDetector(
      onTap: _retryInitialization,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 8.w,
          vertical: 2.h,
        ),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.4),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomIconWidget(
              iconName: 'refresh',
              color: Colors.white,
              size: 5.w,
            ),
            SizedBox(width: 2.w),
            Text(
              'Retry Setup',
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

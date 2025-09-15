import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../theme/app_theme.dart';
import './widgets/onboarding_navigation_widget.dart';
import './widgets/onboarding_page_widget.dart';
import './widgets/page_indicator_widget.dart';

class OnboardingFlow extends StatefulWidget {
  const OnboardingFlow({Key? key}) : super(key: key);

  @override
  State<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<OnboardingFlow> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final int _totalPages = 3;

  // Mock onboarding data
  final List<Map<String, dynamic>> _onboardingData = [
    {
      "title": "Offline Voice-to-Text",
      "description":
          "Convert your speech to text without internet connection. Perfect for areas with poor connectivity or when you want to keep your conversations private.",
      "imageUrl":
          "https://images.unsplash.com/photo-1589254065878-42c9da997008?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3",
      "showMicrophoneDemo": false,
    },
    {
      "title": "Bilingual Support",
      "description":
          "Seamlessly switch between Hindi and English. Our advanced recognition supports both languages with high accuracy for natural conversations.",
      "imageUrl":
          "https://images.pexels.com/photos/267669/pexels-photo-267669.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2",
      "showMicrophoneDemo": false,
    },
    {
      "title": "Works Everywhere",
      "description":
          "Use voice input across all your favorite apps - WhatsApp, Notes, Browser, and more. One keyboard for all your typing needs.",
      "imageUrl":
          "https://cdn.pixabay.com/photo/2016/11/29/06/15/mobile-phone-1867510_1280.jpg",
      "showMicrophoneDemo": true,
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _totalPages - 1) {
      HapticFeedback.lightImpact();
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _skipOnboarding() {
    HapticFeedback.lightImpact();
    Navigator.pushReplacementNamed(context, '/permission-request-screen');
  }

  void _getStarted() {
    HapticFeedback.mediumImpact();
    Navigator.pushReplacementNamed(context, '/permission-request-screen');
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.colorScheme.surface,
      body: Column(
        children: [
          // Main content area
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: _onPageChanged,
              itemCount: _totalPages,
              itemBuilder: (context, index) {
                final data = _onboardingData[index];
                return OnboardingPageWidget(
                  title: data["title"] as String,
                  description: data["description"] as String,
                  imageUrl: data["imageUrl"] as String,
                  showMicrophoneDemo: data["showMicrophoneDemo"] as bool,
                );
              },
            ),
          ),

          // Page indicator
          Container(
            padding: EdgeInsets.symmetric(vertical: 2.h),
            child: PageIndicatorWidget(
              currentPage: _currentPage,
              totalPages: _totalPages,
            ),
          ),

          // Navigation buttons
          OnboardingNavigationWidget(
            currentPage: _currentPage,
            totalPages: _totalPages,
            onNext: _nextPage,
            onSkip: _skipOnboarding,
            onGetStarted: _getStarted,
          ),

          // Bottom safe area
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:untitled/screens/auth/login_screen.dart';
import 'package:untitled/theme/app_theme.dart';
import 'package:untitled/utils/animations.dart';
import 'package:untitled/utils/preferences_manager.dart';
import 'package:untitled/widgets/animated_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final int _numPages = 4;

  final List<Map<String, dynamic>> _pages = [
    {
      'title': 'Welcome to Virtual Time Capsule',
      'description': 'Preserve your memories and open them in the future.',
      'image': 'assets/animations/welcome.json',
      'color': AppTheme.primaryColor,
    },
    {
      'title': 'Create Capsules',
      'description': 'Choose from a variety of templates for different occasions.',
      'image': 'assets/animations/create.json',
      'color': const Color(0xFF4CAF50),
    },
    {
      'title': 'Set Unlock Dates',
      'description': 'Decide when your capsules will be available to open.',
      'image': 'assets/animations/calendar.json',
      'color': const Color(0xFFFF9800),
    },
    {
      'title': 'Share with Friends',
      'description': 'Invite others to view or contribute to your time capsules.',
      'image': 'assets/animations/share.json',
      'color': const Color(0xFF2196F3),
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _numPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _completeOnboarding() async {
    await PreferencesManager.setCompletedOnboarding(true);
    
    if (!mounted) return;
    
    Navigator.of(context).pushReplacement(
      Animations.fadeTransition(const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background gradient
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  _pages[_currentPage]['color'],
                  _pages[_currentPage]['color'].withOpacity(0.7),
                ],
              ),
            ),
          ),
          
          // Content
          SafeArea(
            child: Column(
              children: [
                // Skip button
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextButton(
                      onPressed: _completeOnboarding,
                      child: const Text(
                        'Skip',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                
                // Page content
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (int page) {
                      setState(() {
                        _currentPage = page;
                      });
                    },
                    itemCount: _numPages,
                    itemBuilder: (context, index) {
                      return _buildPage(
                        title: _pages[index]['title'],
                        description: _pages[index]['description'],
                        image: _pages[index]['image'],
                      );
                    },
                  ),
                ),
                
                // Page indicator
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _numPages,
                      (index) => _buildPageIndicator(index == _currentPage),
                    ),
                  ),
                ),
                
                // Navigation buttons
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Back button
                      _currentPage > 0
                          ? IconButton(
                              onPressed: _previousPage,
                              icon: const Icon(
                                Icons.arrow_back_rounded,
                                color: Colors.white,
                              ),
                            )
                          : const SizedBox(width: 48),
                      
                      // Next/Get Started button
                      AnimatedButton(
                        text: _currentPage == _numPages - 1
                            ? 'Get Started'
                            : 'Next',
                        onPressed: _nextPage,
                        width: 150,
                        color: Colors.white,
                        isOutlined: true,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage({
    required String title,
    required String description,
    required String image,
  }) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Image
          Expanded(
            flex: 3,
            child: Animate(
              effects: const [
                FadeEffect(
                  duration: Duration(milliseconds: 800),
                ),
                ScaleEffect(
                  duration: Duration(milliseconds: 800),
                  curve: Curves.easeOut,
                ),
              ],
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                child: Image.asset(
                  image,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          
          // Text content
          Expanded(
            flex: 2,
            child: Column(
              children: [
                Animate(
                  effects: const [
                    FadeEffect(
                      duration: Duration(milliseconds: 800),
                      delay: Duration(milliseconds: 300),
                    ),
                    SlideEffect(
                      begin: Offset(0, 0.2),
                      end: Offset(0, 0),
                      duration: Duration(milliseconds: 800),
                      delay: Duration(milliseconds: 300),
                    ),
                  ],
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 16),
                Animate(
                  effects: const [
                    FadeEffect(
                      duration: Duration(milliseconds: 800),
                      delay: Duration(milliseconds: 500),
                    ),
                    SlideEffect(
                      begin: Offset(0, 0.2),
                      end: Offset(0, 0),
                      duration: Duration(milliseconds: 800),
                      delay: Duration(milliseconds: 500),
                    ),
                  ],
                  child: Text(
                    description,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageIndicator(bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 8,
      width: isActive ? 24 : 8,
      decoration: BoxDecoration(
        color: isActive ? Colors.white : Colors.white.withOpacity(0.4),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

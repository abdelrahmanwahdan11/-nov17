import 'package:flutter/material.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/routing/app_routes.dart';
import '../../shared/controllers/app_controller.dart';

class OnboardingStoryScreen extends StatefulWidget {
  const OnboardingStoryScreen({super.key, required this.controller});

  final AppController controller;

  @override
  State<OnboardingStoryScreen> createState() => _OnboardingStoryScreenState();
}

class _OnboardingStoryScreenState extends State<OnboardingStoryScreen> {
  final PageController _pageController = PageController();
  int _index = 0;

  final _slides = const [
    _OnboardingSlide(
      title: 'Organize your work beautifully',
      description: 'Stay in control of projects, tasks and resources in a single flow.',
      image: 'https://images.unsplash.com/photo-1521737604893-d14cc237f11d?auto=format&fit=crop&w=900&q=80',
    ),
    _OnboardingSlide(
      title: 'Collaborate in pastel calm',
      description: 'Share progress with your team in a soft, minimal dashboard.',
      image: 'https://images.unsplash.com/photo-1545239351-1141bd82e8a6?auto=format&fit=crop&w=900&q=80',
    ),
    _OnboardingSlide(
      title: 'Plan smarter with ConnecQ',
      description: 'Track time, finances and catalog assets without friction.',
      image: 'https://images.unsplash.com/photo-1521737604893-d14cc237f11d?auto=format&fit=crop&w=900&q=80',
    ),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _autoPlay());
  }

  void _autoPlay() {
    Future.delayed(const Duration(seconds: 4), () {
      if (!mounted) return;
      final next = (_index + 1) % _slides.length;
      _pageController.animateToPage(next, duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
    });
  }

  void _next() {
    if (_index == _slides.length - 1) {
      _finish();
    } else {
      _pageController.nextPage(duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
    }
  }

  Future<void> _finish() async {
    await widget.controller.markOnboardingSeen();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (value) {
              setState(() => _index = value);
              _autoPlay();
            },
            itemCount: _slides.length,
            itemBuilder: (context, index) {
              final slide = _slides[index];
              return Column(
                children: [
                  Expanded(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 500),
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
                        image: DecorationImage(image: NetworkImage(slide.image), fit: BoxFit.cover),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(slide.title, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        Text(slide.description, style: Theme.of(context).textTheme.bodyLarge),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
          Positioned(
            bottom: 40,
            left: 24,
            right: 24,
            child: Row(
              children: [
                TextButton(onPressed: _finish, child: Text(loc.translate('skip'))),
                const Spacer(),
                Row(
                  children: List.generate(
                    _slides.length,
                    (i) => AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      height: 8,
                      width: i == _index ? 24 : 8,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                FilledButton(
                  onPressed: _next,
                  style: FilledButton.styleFrom(shape: const StadiumBorder()),
                  child: Text(_index == _slides.length - 1 ? loc.translate('get_started') : loc.translate('next')),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingSlide {
  const _OnboardingSlide({required this.title, required this.description, required this.image});

  final String title;
  final String description;
  final String image;
}

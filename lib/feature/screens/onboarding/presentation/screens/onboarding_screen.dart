import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:swarna_bindu/core/constants/app_string/app_strings.dart';
import 'package:swarna_bindu/core/constants/image_string/image_strings.dart';
import 'package:swarna_bindu/core/router/route_name.dart';
import 'package:swarna_bindu/core/theme/app_colors.dart';
import 'package:swarna_bindu/core/theme/app_spacing.dart';
import 'package:swarna_bindu/core/theme/app_typography.dart';

import '../viewmodels/onboarding_viewmodel.dart';

class _OnboardingPageData {
  const _OnboardingPageData({required this.image, required this.titleLine1, required this.titleLine2, required this.description});

  final String image;
  final String titleLine1;
  final String titleLine2;
  final String description;
}

final List<_OnboardingPageData> _pages = [
  _OnboardingPageData(
    image: AppAssetImage.onboarding1,
    titleLine1: AppStrings.onboarding.page1TitleLine1,
    titleLine2: AppStrings.onboarding.page1TitleLine2,
    description: AppStrings.onboarding.page1Description,
  ),
  _OnboardingPageData(
    image: AppAssetImage.onboarding2,
    titleLine1: AppStrings.onboarding.page2TitleLine1,
    titleLine2: AppStrings.onboarding.page2TitleLine2,
    description: AppStrings.onboarding.page2Description,
  ),
  _OnboardingPageData(
    image: AppAssetImage.onboarding3,
    titleLine1: AppStrings.onboarding.page3TitleLine1,
    titleLine2: AppStrings.onboarding.page3TitleLine2,
    description: AppStrings.onboarding.page3Description,
  ),
];

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNext(int currentIndex) {
    if (currentIndex == _pages.length - 1) {
      context.go(RouteName.login);
      return;
    }
    _pageController.nextPage(duration: const Duration(milliseconds: 320), curve: Curves.easeOutCubic);
  }

  void _skip() => context.go(RouteName.login);

  @override
  Widget build(BuildContext context) {
    final currentPage = ref.watch(onboardingViewModelProvider);
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // Align(
                //   alignment: Alignment.topRight,
                //   child: Padding(
                //     padding: const EdgeInsets.symmetric(
                //       horizontal: AppSpacing.lg,
                //       vertical: AppSpacing.sm,
                //     ),
                //     child: TextButton(
                //       onPressed: _skip,
                //       child: Text(
                //         AppStrings.onboarding.skip,
                //         style: AppTypography.labelLarge(
                //           color: AppColors.textMutedLight,
                //         ),
                //       ),
                //     ),
                //   ),
                // ),
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _pages.length,
                    onPageChanged: (index) => ref.read(onboardingViewModelProvider.notifier).setPage(index),
                    itemBuilder: (context, index) => _OnboardingPage(data: _pages[index]),
                  ),
                ),
              ],
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _BottomBar(currentPage: currentPage, pageCount: _pages.length, onNext: () => _onNext(currentPage)),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  const _OnboardingPage({required this.data});

  final _OnboardingPageData data;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
      child: Column(
        // mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 100.h),
          Image.asset(data.image, fit: BoxFit.contain, width: 300.w, height: 300.h),
          SizedBox(height: AppSpacing.huge),
          Text(
            data.titleLine1,
            textAlign: TextAlign.center,
            style: AppTypography.headingLG(color: AppColors.textPrimaryLight),
          ),
          Text(
            data.titleLine2,
            textAlign: TextAlign.center,
            style: AppTypography.headingLG(color: AppColors.maroonPrimary),
          ),
          SizedBox(height: AppSpacing.xxxl),
          const _SectionDivider(),
          SizedBox(height: AppSpacing.xl),
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Text(
              data.description,
              textAlign: TextAlign.center,
              style: AppTypography.bodySmall(color: AppColors.textMutedLight),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionDivider extends StatelessWidget {
  const _SectionDivider();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 20, height: 1.5, color: AppColors.borderStrongLight),
        SizedBox(width: AppSpacing.xs),
        _dot(AppColors.borderStrongLight, 4),
        SizedBox(width: AppSpacing.xs),
        _dot(AppColors.maroonPrimary, 6),
        SizedBox(width: AppSpacing.xs),
        _dot(AppColors.borderStrongLight, 4),
        SizedBox(width: AppSpacing.xs),
        Container(width: 20, height: 1.5, color: AppColors.borderStrongLight),
      ],
    );
  }

  Widget _dot(Color color, double size) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
  );
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({required this.currentPage, required this.pageCount, required this.onNext});

  final int currentPage;
  final int pageCount;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [
          ClipPath(
            clipper: _WaveClipper(),
            child: Container(height: 90, color: AppColors.goldSurfaceLight.withValues(alpha: 0.8)),
          ),
          Positioned(
            // left: AppSpacing.xxl,
            bottom: 34,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(pageCount, (index) {
                final isActive = index == currentPage;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: EdgeInsets.only(right: AppSpacing.sm),
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: isActive ? AppColors.maroonPrimary : AppColors.borderStrongLight),
                );
              }),
            ),
          ),
          Positioned(
            right: AppSpacing.xxl,
            bottom: 12,
            child: Material(
              color: AppColors.maroonPrimary,
              shape: const CircleBorder(),
              elevation: 4,
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: onNext,
                child: Padding(
                  padding: EdgeInsets.all(AppSpacing.md),
                  child: Icon(Icons.arrow_forward, color: Colors.white, size: AppSpacing.iconLg),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path()..lineTo(0, size.height * 0.45);
    path.quadraticBezierTo(size.width * 0.25, size.height * 0.1, size.width * 0.5, size.height * 0.35);
    path.quadraticBezierTo(size.width * 0.75, size.height * 0.6, size.width, size.height * 0.3);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

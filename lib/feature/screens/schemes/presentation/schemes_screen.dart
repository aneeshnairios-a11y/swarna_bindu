import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:swarna_bindu/core/router/route_name.dart';
import 'package:swarna_bindu/core/theme/app_colors.dart';
import 'package:swarna_bindu/core/theme/app_spacing.dart';
import 'package:swarna_bindu/core/theme/app_typography.dart';

import '../../../../core/constants/image_string/image_strings.dart';
import '../../../../core/formatter/app_formatters.dart';
import '../../../global_widgets/common_button.dart';
import '../../../global_widgets/dashboard_bottom_nav.dart';
import '../schemes_viewmodel/scheme_model.dart';
import '../schemes_viewmodel/schemes_notifier.dart';

/// Scheme browser — Phase 2, wired to `GET /schemes` via [schemesListProvider].
class SchemesScreen extends ConsumerStatefulWidget {
  const SchemesScreen({super.key});

  @override
  ConsumerState<SchemesScreen> createState() => _SchemesScreenState();
}

class _SchemesScreenState extends ConsumerState<SchemesScreen> {
  int navIndex = 1;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.backgroundDark : AppColors.backgroundLight;
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final state = ref.watch(schemesListProvider);

    return Scaffold(
      backgroundColor: bgColor,
      bottomNavigationBar: DashboardBottomNav(
        currentIndex: navIndex,
        onTap: (i) => setState(() => navIndex = i),
      ),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // ── Header ───────────────────────────────────────
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
              child: Row(
                children: [
                  InkWell(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                    onTap: () => context.go(RouteName.dashboard),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Icon(
                        Icons.arrow_back_rounded,
                        color: textColor,
                        size: AppSpacing.iconLg,
                      ),
                    ),
                  ),
                  SizedBox(width: AppSpacing.sm),
                  Text(
                    'Schemes',
                    style: AppTypography.headingSM(color: textColor),
                  ),
                ],
              ),
            ),
            Expanded(child: _buildBody(context, state)),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, SchemesListState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.errorMessage != null && state.schemes.isEmpty) {
      return _ErrorState(
        message: state.errorMessage!,
        onRetry: () => ref.read(schemesListProvider.notifier).loadFirstPage(),
      );
    }

    if (state.isEmpty) {
      return const _EmptyState();
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(schemesListProvider.notifier).refresh(),
      child: ListView.separated(
        padding: EdgeInsets.all(AppSpacing.lg),
        itemCount: state.schemes.length + (state.hasMore ? 1 : 0),
        separatorBuilder: (_, __) => SizedBox(height: AppSpacing.md),
        itemBuilder: (context, i) {
          if (i >= state.schemes.length) {
            return _LoadMoreButton(
              isLoading: state.isLoadingMore,
              onTap: () => ref.read(schemesListProvider.notifier).loadMore(),
            );
          }
          return _SchemeCard(scheme: state.schemes[i]);
        },
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mutedColor = isDark ? AppColors.textMutedDark : AppColors.textMutedLight;
    return Center(
      child: Text('No schemes available right now.', style: AppTypography.bodySmall(color: mutedColor)),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline_rounded, size: 40, color: AppColors.errorRed),
            SizedBox(height: AppSpacing.sm),
            Text(message, textAlign: TextAlign.center, style: AppTypography.bodySmall(color: textColor)),
            SizedBox(height: AppSpacing.md),
            OutlinedButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}

class _LoadMoreButton extends StatelessWidget {
  const _LoadMoreButton({required this.isLoading, required this.onTap});

  final bool isLoading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Center(
        child: isLoading
            ? const SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(strokeWidth: 2),
        )
            : TextButton(onPressed: onTap, child: const Text('Load more')),
      ),
    );
  }
}

class _SchemeCard extends StatelessWidget {
  const _SchemeCard({required this.scheme});

  final SchemeModel scheme;

  void _openDetail(BuildContext context) => context.push(RouteName.schemeDetailPath(scheme.id));

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final border = isDark ? AppColors.borderDark : AppColors.borderLight;
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final mutedColor = isDark ? AppColors.textMutedDark : AppColors.textMutedLight;
    final footerBg = isDark ? AppColors.goldSurfaceDark : AppColors.goldSurfaceLight;

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
      child: InkWell(
        onTap: () => _openDetail(context),
        child: Container(
          decoration: BoxDecoration(
            color: cardColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
            border: Border.all(color: border),
            borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.lg,
                  AppSpacing.lg,
                  AppSpacing.md,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 40.w,
                          height: 40.h,
                          padding: EdgeInsets.all(AppSpacing.radiusSm),
                          decoration: BoxDecoration(
                            color: AppColors.maroonDark,
                            shape: BoxShape.circle,
                          ),
                          child: Image.asset(
                            AppAssetImage.goldRate,
                            fit: BoxFit.cover,
                          ),
                        ),
                        SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                scheme.name,
                                style: AppTypography.sectionTitleSM(color: textColor),
                              ),
                              SizedBox(height: 2),
                              Text(
                                scheme.description,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.caption(color: mutedColor),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: AppSpacing.md),
                    Container(height: 1, color: border),
                    SizedBox(height: AppSpacing.md),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _StatCell(
                            label: 'Monthly Investment',
                            value: AppFormatters.currency(scheme.monthlyInvestment),
                            textColor: textColor,
                            mutedColor: mutedColor,
                          ),
                        ),
                        _StatDivider(color: border),
                        Expanded(
                          child: _StatCell(
                            label: 'Duration',
                            value: AppFormatters.months(scheme.durationMonths),
                            textColor: textColor,
                            mutedColor: mutedColor,
                          ),
                        ),
                        _StatDivider(color: border),
                        Expanded(
                          child: _StatCell(
                            label: 'Maturity Bene',
                            value: 'Up to ${scheme.maturityBenefitPercent.toStringAsFixed(0)}%',
                            textColor: AppColors.successGreen,
                            mutedColor: mutedColor,
                          ),
                        ),
                        _StatDivider(color: border),
                        Expanded(
                          child: _StatCell(
                            label: 'Min. Gold',
                            value: '${scheme.minGoldGram.toStringAsFixed(0)} Gram',
                            textColor: textColor,
                            mutedColor: mutedColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: AppSpacing.md),
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.md,
                ),
                color: footerBg.withValues(alpha: 0.5),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        scheme.bestFor,
                        style: AppTypography.labelSmall(
                          color: AppColors.primaryGoldDark,
                        ).copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                    AppButton(
                      text: 'Join Now',
                      onPressed: () => _openDetail(context),
                      width: 130,
                      height: 46,
                      backgroundColor: AppColors.maroonDark,
                      textColor: Colors.white,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatDivider extends StatelessWidget {
  const _StatDivider({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 44,
      color: color,
      margin: EdgeInsets.symmetric(horizontal: AppSpacing.sm),
    );
  }
}

class _StatCell extends StatelessWidget {
  const _StatCell({
    required this.label,
    required this.value,
    required this.textColor,
    required this.mutedColor,
  });

  final String label;
  final String value;
  final Color textColor;
  final Color mutedColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.statusBadge(color: mutedColor)),
        SizedBox(height: 2),
        Text(value, style: AppTypography.labelMedium(color: textColor)),
      ],
    );
  }
}
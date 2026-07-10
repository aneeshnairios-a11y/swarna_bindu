import 'package:flutter/material.dart';

import 'package:gold_scheme/core/theme/app_colors.dart';
import 'package:gold_scheme/core/theme/app_spacing.dart';
import 'package:gold_scheme/core/theme/app_typography.dart';

class PromoBannerCard extends StatelessWidget {
  const PromoBannerCard({super.key, this.onExplore});

  final VoidCallback? onExplore;

  static const LinearGradient _promoGradient = LinearGradient(
    colors: [Color(0xFF0F2818), Color(0xFF16321F), Color(0xFF1E3F27)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: _promoGradient,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Save Today,', style: AppTypography.bodySmall(color: Colors.white70)),
                Text('Shine Tomorrow', style: AppTypography.headingSM(color: Colors.white)),
                SizedBox(height: AppSpacing.xs),
                Text(
                  'Build your gold reserve with secure monthly savings.',
                  style: AppTypography.caption(color: Colors.white60),
                ),
                SizedBox(height: AppSpacing.md),
                ElevatedButton(
                  onPressed: onExplore,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGold,
                    foregroundColor: AppColors.textOnGold,
                    minimumSize: const Size(0, 40),
                    padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusMd)),
                  ),
                  child: Text('Explore Schemes', style: AppTypography.buttonSmall(color: AppColors.textOnGold)),
                ),
              ],
            ),
          ),
          SizedBox(width: AppSpacing.md),
          Icon(Icons.diamond_outlined, color: AppColors.primaryGoldLight.withValues(alpha: 0.5), size: 64),
        ],
      ),
    );
  }
}

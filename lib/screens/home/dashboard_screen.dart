import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../../models/user_model.dart';
import '../../utils/constants.dart';
import '../subscription/subscription_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, _) {
        final user = userProvider.user;

        return Container(
          decoration: const BoxDecoration(gradient: AppConstants.backgroundGradient),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppConstants.spacingL),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome back,',
                            style: AppConstants.bodyMedium,
                          ),
                          Text(
                            user?.displayName ?? 'Mystical Seeker',
                            style: AppConstants.headingMedium,
                          ),
                        ],
                      ),
                      _buildTierBadge(user?.subscriptionTier ?? SubscriptionTier.free),
                    ],
                  ),
                  const SizedBox(height: AppConstants.spacingL),

                  // Zodiac Card
                  if (user?.zodiacSign != null) _buildZodiacCard(user!),
                  const SizedBox(height: AppConstants.spacingL),

                  // Quick Actions
                  const Text(
                    'Quick Actions',
                    style: AppConstants.headingSmall,
                  ),
                  const SizedBox(height: AppConstants.spacingM),
                  _buildQuickActions(context),
                  const SizedBox(height: AppConstants.spacingL),

                  // Subscription CTA for free users
                  if (user?.subscriptionTier == SubscriptionTier.free)
                    _buildUpgradeCard(context),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTierBadge(SubscriptionTier tier) {
    IconData icon;
    Gradient gradient;
    String label;

    switch (tier) {
      case SubscriptionTier.premium:
        icon = Icons.diamond;
        gradient = AppConstants.premiumGradient;
        label = 'Premium';
        break;
      case SubscriptionTier.gold:
        icon = Icons.workspace_premium;
        gradient = AppConstants.goldGradient;
        label = 'Gold';
        break;
      default:
        icon = Icons.star_border;
        gradient = const LinearGradient(colors: [Colors.grey, Colors.grey]);
        label = 'Free';
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacingM,
        vertical: AppConstants.spacingS,
      ),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildZodiacCard(UserModel user) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingL),
      decoration: BoxDecoration(
        gradient: AppConstants.primaryGradient,
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
        boxShadow: [
          BoxShadow(
            color: AppConstants.primaryPurple.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Text(
            AppConstants.zodiacEmojis[user.zodiacSign] ?? '✨',
            style: const TextStyle(fontSize: 48),
          ),
          const SizedBox(width: AppConstants.spacingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your Sign',
                  style: AppConstants.bodySmall.copyWith(color: Colors.white70),
                ),
                Text(
                  user.zodiacSign ?? '',
                  style: AppConstants.headingMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: AppConstants.spacingM,
      crossAxisSpacing: AppConstants.spacingM,
      children: [
        _buildActionCard(
          icon: Icons.local_cafe,
          title: 'Coffee Reading',
          gradient: AppConstants.primaryGradient,
          onTap: () {},
        ),
        _buildActionCard(
          icon: Icons.auto_awesome,
          title: 'Daily Horoscope',
          gradient: const LinearGradient(
            colors: [Color(0xFFFF6B9D), Color(0xFFFFA500)],
          ),
          onTap: () {},
        ),
        _buildActionCard(
          icon: Icons.favorite,
          title: 'Compatibility',
          gradient: const LinearGradient(
            colors: [Color(0xFFFF1744), Color(0xFFFF6B9D)],
          ),
          onTap: () {},
        ),
        _buildActionCard(
          icon: Icons.star_purple500,
          title: 'Birth Chart',
          gradient: const LinearGradient(
            colors: [Color(0xFF6B4CE6), Color(0xFF00D4FF)],
          ),
          onTap: () {},
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required Gradient gradient,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: Colors.white),
            const SizedBox(height: AppConstants.spacingS),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpgradeCard(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SubscriptionScreen()),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(AppConstants.spacingL),
        decoration: BoxDecoration(
          gradient: AppConstants.goldGradient,
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
        ),
        child: Row(
          children: [
            const Icon(Icons.upgrade, size: 48, color: Colors.white),
            const SizedBox(width: AppConstants.spacingM),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Upgrade to Premium',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Unlock unlimited readings & advanced AI',
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.white),
          ],
        ),
      ),
    );
  }
}

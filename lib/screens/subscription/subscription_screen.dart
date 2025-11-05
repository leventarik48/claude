import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../../services/subscription_service.dart';
import '../../utils/constants.dart';

class SubscriptionScreen extends StatelessWidget {
  const SubscriptionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final pricing = SubscriptionService.getMockPricing();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Upgrade Your Experience'),
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppConstants.backgroundGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstants.spacingL),
            child: Column(
              children: [
                const Icon(
                  Icons.diamond,
                  size: 80,
                  color: AppConstants.accentGold,
                ),
                const SizedBox(height: AppConstants.spacingM),
                const Text(
                  'Unlock Your Full Potential',
                  style: AppConstants.headingLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppConstants.spacingS),
                const Text(
                  'Choose the plan that\'s right for you',
                  style: AppConstants.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppConstants.spacingXL),

                // Free tier (current)
                _buildTierCard(
                  context,
                  title: 'Free',
                  price: '\$0',
                  gradient: const LinearGradient(
                    colors: [Colors.grey, Colors.blueGrey],
                  ),
                  features: [
                    '1 free reading per day',
                    'Watch ads to unlock',
                    'Basic AI (GPT-3.5)',
                    'Standard interpretations',
                  ],
                  isCurrent: true,
                ),
                const SizedBox(height: AppConstants.spacingL),

                // Gold tier
                _buildTierCard(
                  context,
                  title: 'Gold',
                  price: pricing['gold']!['monthly']!,
                  gradient: AppConstants.goldGradient,
                  features: [
                    'Unlimited readings',
                    'No ads',
                    'Advanced AI (GPT-4)',
                    'Detailed interpretations',
                    'Reading history export',
                    'Priority support',
                  ],
                  onTap: () => _handlePurchase(context, 'gold'),
                ),
                const SizedBox(height: AppConstants.spacingL),

                // Premium tier
                _buildTierCard(
                  context,
                  title: 'Premium',
                  price: pricing['premium']!['monthly']!,
                  gradient: AppConstants.premiumGradient,
                  features: [
                    'Everything in Gold',
                    'Ultra-personalized AI (GPT-4.5)',
                    'Voice readings with TTS',
                    'Custom AI prompts',
                    'Multiple voice accents',
                    'Early access to features',
                    'Exclusive astrology APIs',
                    'VIP support',
                  ],
                  onTap: () => _handlePurchase(context, 'premium'),
                  isRecommended: true,
                ),
                const SizedBox(height: AppConstants.spacingL),

                // Restore purchases
                TextButton(
                  onPressed: () => _restorePurchases(context),
                  child: const Text(
                    'Restore Purchases',
                    style: TextStyle(color: AppConstants.primaryPurple),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTierCard(
    BuildContext context, {
    required String title,
    required String price,
    required Gradient gradient,
    required List<String> features,
    VoidCallback? onTap,
    bool isCurrent = false,
    bool isRecommended = false,
  }) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: const EdgeInsets.all(AppConstants.spacingL),
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(AppConstants.radiusM),
            boxShadow: [
              BoxShadow(
                color: gradient.colors.first.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    price,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppConstants.spacingM),
              ...features.map((feature) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.white, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            feature,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  )),
              if (!isCurrent) ...[
                const SizedBox(height: AppConstants.spacingM),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onTap,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: gradient.colors.first,
                    ),
                    child: const Text('Subscribe Now'),
                  ),
                ),
              ],
              if (isCurrent)
                Container(
                  margin: const EdgeInsets.only(top: AppConstants.spacingM),
                  padding: const EdgeInsets.all(AppConstants.spacingS),
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(AppConstants.radiusS),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check, color: Colors.white, size: 16),
                      SizedBox(width: 4),
                      Text(
                        'Current Plan',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        if (isRecommended)
          Positioned(
            top: -12,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.spacingM,
                vertical: AppConstants.spacingS,
              ),
              decoration: BoxDecoration(
                color: AppConstants.accentGold,
                borderRadius: BorderRadius.circular(AppConstants.radiusL),
              ),
              child: const Text(
                'RECOMMENDED',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ),
      ],
    );
  }

  void _handlePurchase(BuildContext context, String tier) {
    // In production, this would integrate with RevenueCat
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Purchase $tier tier (connect RevenueCat in production)'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _restorePurchases(BuildContext context) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.user;
    if (user == null) return;

    try {
      final restored = await SubscriptionService.restorePurchases(user.uid);
      if (restored) {
        await userProvider.loadUser();
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Purchases restored successfully')),
          );
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No purchases to restore')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error restoring purchases: $e')),
        );
      }
    }
  }
}

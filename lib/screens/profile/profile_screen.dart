import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../../services/auth_service.dart';
import '../../utils/constants.dart';
import '../subscription/subscription_screen.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

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
                children: [
                  // Profile header
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: AppConstants.primaryPurple,
                    child: Text(
                      user?.displayName?.substring(0, 1).toUpperCase() ?? 'M',
                      style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacingM),
                  Text(
                    user?.displayName ?? 'Mystical User',
                    style: AppConstants.headingMedium,
                  ),
                  const SizedBox(height: AppConstants.spacingS),
                  Text(
                    user?.email ?? '',
                    style: AppConstants.bodyMedium,
                  ),
                  const SizedBox(height: AppConstants.spacingXL),

                  // Account info
                  _buildInfoCard(
                    title: 'Account Information',
                    children: [
                      _buildInfoRow('Zodiac Sign', user?.zodiacSign ?? 'Not set'),
                      _buildInfoRow(
                        'Birth Date',
                        user?.birthDate != null
                            ? '${user!.birthDate!.day}/${user.birthDate!.month}/${user.birthDate!.year}'
                            : 'Not set',
                      ),
                      _buildInfoRow(
                        'Gender',
                        user?.gender?.toString().split('.').last ?? 'Not set',
                      ),
                      _buildInfoRow(
                        'Relationship',
                        user?.relationshipStatus?.toString().split('.').last ?? 'Not set',
                      ),
                    ],
                  ),
                  const SizedBox(height: AppConstants.spacingL),

                  // Subscription info
                  _buildInfoCard(
                    title: 'Subscription',
                    children: [
                      _buildInfoRow(
                        'Current Plan',
                        user?.subscriptionTier.toString().split('.').last.toUpperCase() ?? 'FREE',
                      ),
                      if (user?.subscriptionExpiry != null)
                        _buildInfoRow(
                          'Expires',
                          '${user!.subscriptionExpiry!.day}/${user.subscriptionExpiry!.month}/${user.subscriptionExpiry!.year}',
                        ),
                      const SizedBox(height: AppConstants.spacingM),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const SubscriptionScreen(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppConstants.accentGold,
                            foregroundColor: Colors.black,
                          ),
                          child: const Text('Manage Subscription'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppConstants.spacingL),

                  // Actions
                  _buildActionButton(
                    icon: Icons.history,
                    label: 'Reading History',
                    onTap: () {
                      // Navigate to history screen
                    },
                  ),
                  const SizedBox(height: AppConstants.spacingM),
                  _buildActionButton(
                    icon: Icons.notifications,
                    label: 'Notifications',
                    onTap: () {
                      // Navigate to notifications settings
                    },
                  ),
                  const SizedBox(height: AppConstants.spacingM),
                  _buildActionButton(
                    icon: Icons.privacy_tip,
                    label: 'Privacy Policy',
                    onTap: () {
                      // Show privacy policy
                    },
                  ),
                  const SizedBox(height: AppConstants.spacingM),
                  _buildActionButton(
                    icon: Icons.help,
                    label: 'Help & Support',
                    onTap: () {
                      // Navigate to help
                    },
                  ),
                  const SizedBox(height: AppConstants.spacingXL),

                  // Sign out
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => _signOut(context),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red),
                      ),
                      child: const Text(
                        'Sign Out',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacingS),
                  TextButton(
                    onPressed: () => _showDeleteAccountDialog(context),
                    child: const Text(
                      'Delete Account',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoCard({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingL),
      decoration: BoxDecoration(
        color: AppConstants.cardBackground,
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppConstants.headingSmall.copyWith(
              color: AppConstants.primaryPurple,
            ),
          ),
          const SizedBox(height: AppConstants.spacingM),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.spacingM),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppConstants.bodyMedium),
          Text(
            value,
            style: AppConstants.bodyLarge.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppConstants.spacingL),
        decoration: BoxDecoration(
          color: AppConstants.cardBackground,
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppConstants.primaryPurple),
            const SizedBox(width: AppConstants.spacingM),
            Expanded(
              child: Text(label, style: AppConstants.bodyLarge),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16),
          ],
        ),
      ),
    );
  }

  void _signOut(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await AuthService.signOut();
      Provider.of<UserProvider>(context, listen: false).clearUser();
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'This action cannot be undone. All your data will be permanently deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await AuthService.deleteAccount();
                if (context.mounted) {
                  Provider.of<UserProvider>(context, listen: false).clearUser();
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

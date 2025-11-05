import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../../providers/user_provider.dart';
import '../../models/user_model.dart';
import '../../models/compatibility_model.dart';
import '../../services/ai_service.dart';
import '../../services/ads_service.dart';
import '../../services/firebase_service.dart';
import '../../utils/constants.dart';
import '../subscription/subscription_screen.dart';

class CompatibilityScreen extends StatefulWidget {
  const CompatibilityScreen({Key? key}) : super(key: key);

  @override
  State<CompatibilityScreen> createState() => _CompatibilityScreenState();
}

class _CompatibilityScreenState extends State<CompatibilityScreen> {
  String? _sign1;
  String? _sign2;
  Map<String, dynamic>? _compatibilityData;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final user = Provider.of<UserProvider>(context, listen: false).user;
    _sign1 = user?.zodiacSign ?? AppConstants.zodiacSigns.first;
  }

  Future<void> _checkCompatibility() async {
    if (_sign1 == null || _sign2 == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select both zodiac signs')),
      );
      return;
    }

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.user;
    if (user == null) return;

    // Check free tier limits
    if (user.subscriptionTier == SubscriptionTier.free) {
      if (!user.canUseFreeReading) {
        _showUpgradeDialog();
        return;
      }

      final adShown = await AdsService.showRewardedAd(
        onRewardEarned: () {
          _fetchCompatibility(user);
        },
      );

      if (!adShown) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please wait for ad to load...')),
        );
      }
    } else {
      await _fetchCompatibility(user);
    }
  }

  Future<void> _fetchCompatibility(UserModel user) async {
    setState(() => _isLoading = true);

    try {
      final aiResult = await AIService.generateCompatibility(
        user: user,
        sign1: _sign1!,
        sign2: _sign2!,
      );

      // Save to Firestore
      final compatibility = CompatibilityModel(
        id: '',
        userId: user.uid,
        sign1: _sign1!,
        sign2: _sign2!,
        overallScore: aiResult['overallScore'] ?? 75,
        categoryScores: {
          'love': aiResult['love'] ?? 75,
          'friendship': aiResult['friendship'] ?? 75,
          'communication': aiResult['communication'] ?? 75,
        },
        interpretation: aiResult['interpretation'] ?? '',
        strengths: List<String>.from(aiResult['strengths'] ?? []),
        challenges: List<String>.from(aiResult['challenges'] ?? []),
        advice: aiResult['advice'] ?? '',
        createdAt: DateTime.now(),
        aiModel: AIService.getModelForTier(user.subscriptionTier),
      );

      await FirebaseService.saveCompatibility(compatibility);

      // Update daily count for free users
      if (user.subscriptionTier == SubscriptionTier.free) {
        await userProvider.incrementDailyReading();
      }

      setState(() {
        _compatibilityData = aiResult;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void _showUpgradeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Daily Limit Reached'),
        content: const Text(
          'Upgrade to Gold or Premium for unlimited compatibility checks!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Later'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SubscriptionScreen()),
              );
            },
            child: const Text('Upgrade'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppConstants.backgroundGradient),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.spacingL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Relationship Compatibility',
                style: AppConstants.headingLarge,
              ),
              const SizedBox(height: AppConstants.spacingL),

              // Sign 1 selector
              DropdownButtonFormField<String>(
                value: _sign1,
                decoration: const InputDecoration(
                  labelText: 'Your Sign',
                  prefixIcon: Icon(Icons.person),
                ),
                items: AppConstants.zodiacSigns.map((sign) {
                  return DropdownMenuItem(
                    value: sign,
                    child: Text('${AppConstants.zodiacEmojis[sign]} $sign'),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _sign1 = value;
                    _compatibilityData = null;
                  });
                },
              ),
              const SizedBox(height: AppConstants.spacingM),

              // Sign 2 selector
              DropdownButtonFormField<String>(
                value: _sign2,
                decoration: const InputDecoration(
                  labelText: 'Partner\'s Sign',
                  prefixIcon: Icon(Icons.favorite),
                ),
                items: AppConstants.zodiacSigns.map((sign) {
                  return DropdownMenuItem(
                    value: sign,
                    child: Text('${AppConstants.zodiacEmojis[sign]} $sign'),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _sign2 = value;
                    _compatibilityData = null;
                  });
                },
              ),
              const SizedBox(height: AppConstants.spacingL),

              // Check button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _checkCompatibility,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.secondaryPink,
                  ),
                  child: _isLoading
                      ? const SpinKitThreeBounce(color: Colors.white, size: 20)
                      : const Text('Check Compatibility'),
                ),
              ),

              // Results
              if (_compatibilityData != null) ...[
                const SizedBox(height: AppConstants.spacingXL),

                // Overall score
                Container(
                  padding: const EdgeInsets.all(AppConstants.spacingL),
                  decoration: BoxDecoration(
                    gradient: AppConstants.primaryGradient,
                    borderRadius: BorderRadius.circular(AppConstants.radiusM),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Compatibility Score',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: AppConstants.spacingM),
                      Text(
                        '${_compatibilityData!['overallScore']}%',
                        style: const TextStyle(
                          fontSize: 64,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppConstants.spacingL),

                // Category scores
                _buildScoreCard('Love', _compatibilityData!['love']),
                _buildScoreCard('Friendship', _compatibilityData!['friendship']),
                _buildScoreCard('Communication', _compatibilityData!['communication']),

                // Interpretation
                _buildSection('Interpretation', _compatibilityData!['interpretation']),

                // Strengths
                if (_compatibilityData!['strengths'] != null)
                  _buildListSection('Strengths', _compatibilityData!['strengths']),

                // Challenges
                if (_compatibilityData!['challenges'] != null)
                  _buildListSection('Challenges', _compatibilityData!['challenges']),

                // Advice
                _buildSection('Advice', _compatibilityData!['advice']),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScoreCard(String label, int? score) {
    if (score == null) return const SizedBox();

    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.spacingM),
      padding: const EdgeInsets.all(AppConstants.spacingL),
      decoration: BoxDecoration(
        color: AppConstants.cardBackground,
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppConstants.headingSmall),
          Text(
            '$score%',
            style: AppConstants.headingSmall.copyWith(
              color: AppConstants.accentGold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, String? content) {
    if (content == null || content.isEmpty) return const SizedBox();

    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.spacingM),
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
          const SizedBox(height: AppConstants.spacingS),
          Text(content, style: AppConstants.bodyLarge),
        ],
      ),
    );
  }

  Widget _buildListSection(String title, List<dynamic> items) {
    if (items.isEmpty) return const SizedBox();

    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.spacingM),
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
          const SizedBox(height: AppConstants.spacingS),
          ...items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• ', style: AppConstants.bodyLarge),
                    Expanded(
                      child: Text(item.toString(), style: AppConstants.bodyLarge),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

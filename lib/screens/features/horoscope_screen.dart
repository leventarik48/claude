import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../../providers/user_provider.dart';
import '../../models/user_model.dart';
import '../../models/horoscope_model.dart';
import '../../services/ai_service.dart';
import '../../services/ads_service.dart';
import '../../services/firebase_service.dart';
import '../../utils/constants.dart';
import '../subscription/subscription_screen.dart';

class HoroscopeScreen extends StatefulWidget {
  const HoroscopeScreen({Key? key}) : super(key: key);

  @override
  State<HoroscopeScreen> createState() => _HoroscopeScreenState();
}

class _HoroscopeScreenState extends State<HoroscopeScreen> {
  String? _selectedSign;
  HoroscopePeriod _selectedPeriod = HoroscopePeriod.daily;
  Map<String, dynamic>? _horoscopeData;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final user = Provider.of<UserProvider>(context, listen: false).user;
    _selectedSign = user?.zodiacSign ?? AppConstants.zodiacSigns.first;
  }

  Future<void> _loadHoroscope() async {
    if (_selectedSign == null) return;

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
          _fetchHoroscope(user);
        },
      );

      if (!adShown) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please wait for ad to load...')),
        );
      }
    } else {
      await _fetchHoroscope(user);
    }
  }

  Future<void> _fetchHoroscope(UserModel user) async {
    setState(() => _isLoading = true);

    try {
      // Check if horoscope exists in Firestore
      final existingHoroscope = await FirebaseService.getHoroscope(
        _selectedSign!,
        _selectedPeriod,
        DateTime.now(),
      );

      if (existingHoroscope != null) {
        setState(() {
          _horoscopeData = {
            'content': existingHoroscope.content,
            'love': existingHoroscope.ratings['love'],
            'career': existingHoroscope.ratings['career'],
            'health': existingHoroscope.ratings['health'],
            'luckyNumber': existingHoroscope.luckyNumber,
            'luckyColor': existingHoroscope.luckyColor,
          };
          _isLoading = false;
        });
        return;
      }

      // Generate new horoscope
      final aiResult = await AIService.generateHoroscope(
        user: user,
        zodiacSign: _selectedSign!,
        period: _selectedPeriod.toString().split('.').last,
      );

      // Save to Firestore
      final horoscope = HoroscopeModel(
        id: '',
        zodiacSign: _selectedSign!,
        period: _selectedPeriod,
        date: DateTime.now(),
        content: aiResult['content'] ?? '',
        ratings: {
          'love': aiResult['love'] ?? 3,
          'career': aiResult['career'] ?? 3,
          'health': aiResult['health'] ?? 3,
        },
        luckyNumber: aiResult['luckyNumber'],
        luckyColor: aiResult['luckyColor'],
        aiModel: AIService.getModelForTier(user.subscriptionTier),
      );

      await FirebaseService.saveHoroscope(horoscope);

      // Update daily count for free users
      if (user.subscriptionTier == SubscriptionTier.free) {
        await userProvider.incrementDailyReading();
      }

      setState(() {
        _horoscopeData = aiResult;
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
          'Upgrade to Gold or Premium for unlimited horoscope readings!',
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
                'Your Horoscope',
                style: AppConstants.headingLarge,
              ),
              const SizedBox(height: AppConstants.spacingL),

              // Zodiac selector
              DropdownButtonFormField<String>(
                value: _selectedSign,
                decoration: const InputDecoration(
                  labelText: 'Select Zodiac Sign',
                  prefixIcon: Icon(Icons.auto_awesome),
                ),
                items: AppConstants.zodiacSigns.map((sign) {
                  return DropdownMenuItem(
                    value: sign,
                    child: Text('${AppConstants.zodiacEmojis[sign]} $sign'),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedSign = value;
                    _horoscopeData = null;
                  });
                },
              ),
              const SizedBox(height: AppConstants.spacingM),

              // Period selector
              Row(
                children: [
                  _buildPeriodChip('Daily', HoroscopePeriod.daily),
                  const SizedBox(width: AppConstants.spacingS),
                  _buildPeriodChip('Weekly', HoroscopePeriod.weekly),
                  const SizedBox(width: AppConstants.spacingS),
                  _buildPeriodChip('Monthly', HoroscopePeriod.monthly),
                ],
              ),
              const SizedBox(height: AppConstants.spacingL),

              // Get horoscope button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _loadHoroscope,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.primaryPurple,
                  ),
                  child: _isLoading
                      ? const SpinKitThreeBounce(color: Colors.white, size: 20)
                      : const Text('Get Horoscope'),
                ),
              ),

              // Horoscope display
              if (_horoscopeData != null) ...[
                const SizedBox(height: AppConstants.spacingXL),
                Container(
                  padding: const EdgeInsets.all(AppConstants.spacingL),
                  decoration: BoxDecoration(
                    color: AppConstants.cardBackground,
                    borderRadius: BorderRadius.circular(AppConstants.radiusM),
                    border: Border.all(
                      color: AppConstants.primaryPurple.withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _horoscopeData!['content'] ?? '',
                        style: AppConstants.bodyLarge,
                      ),
                      const SizedBox(height: AppConstants.spacingL),
                      _buildRating('Love', _horoscopeData!['love'] ?? 3),
                      _buildRating('Career', _horoscopeData!['career'] ?? 3),
                      _buildRating('Health', _horoscopeData!['health'] ?? 3),
                      if (_horoscopeData!['luckyNumber'] != null) ...[
                        const SizedBox(height: AppConstants.spacingM),
                        Text(
                          'Lucky Number: ${_horoscopeData!['luckyNumber']}',
                          style: AppConstants.headingSmall,
                        ),
                      ],
                      if (_horoscopeData!['luckyColor'] != null) ...[
                        const SizedBox(height: AppConstants.spacingS),
                        Text(
                          'Lucky Color: ${_horoscopeData!['luckyColor']}',
                          style: AppConstants.headingSmall,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPeriodChip(String label, HoroscopePeriod period) {
    final isSelected = _selectedPeriod == period;
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedPeriod = period;
            _horoscopeData = null;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: AppConstants.spacingM),
          decoration: BoxDecoration(
            gradient: isSelected ? AppConstants.primaryGradient : null,
            color: isSelected ? null : AppConstants.cardBackground,
            borderRadius: BorderRadius.circular(AppConstants.radiusM),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRating(String label, int rating) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.spacingS),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(label, style: AppConstants.bodyMedium),
          ),
          ...List.generate(
            5,
            (index) => Icon(
              index < rating ? Icons.star : Icons.star_border,
              color: AppConstants.accentGold,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}

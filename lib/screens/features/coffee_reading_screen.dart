import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../../providers/user_provider.dart';
import '../../models/user_model.dart';
import '../../services/ai_service.dart';
import '../../services/ads_service.dart';
import '../../services/firebase_service.dart';
import '../../models/coffee_reading_model.dart';
import '../../utils/constants.dart';
import '../subscription/subscription_screen.dart';

class CoffeeReadingScreen extends StatefulWidget {
  const CoffeeReadingScreen({Key? key}) : super(key: key);

  @override
  State<CoffeeReadingScreen> createState() => _CoffeeReadingScreenState();
}

class _CoffeeReadingScreenState extends State<CoffeeReadingScreen> {
  final ImagePicker _picker = ImagePicker();
  XFile? _selectedImage;
  bool _isLoading = false;
  Map<String, dynamic>? _reading;

  Future<void> _pickImage(ImageSource source) async {
    try {
      final image = await _picker.pickImage(source: source);
      if (image != null) {
        setState(() => _selectedImage = image);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }

  Future<void> _analyzeReading() async {
    if (_selectedImage == null) return;

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.user;
    if (user == null) return;

    // Check if user can use free reading
    if (user.subscriptionTier == SubscriptionTier.free) {
      if (!user.canUseFreeReading) {
        _showUpgradeDialog();
        return;
      }

      // Show rewarded ad for free users
      final adShown = await AdsService.showRewardedAd(
        onRewardEarned: () {
          _performReading(user);
        },
      );

      if (!adShown) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please wait for ad to load...')),
        );
      }
    } else {
      await _performReading(user);
    }
  }

  Future<void> _performReading(UserModel user) async {
    setState(() => _isLoading = true);

    try {
      // Upload image to Firebase Storage
      final bytes = await _selectedImage!.readAsBytes();
      final imagePath = 'coffee_readings/${user.uid}/${DateTime.now().millisecondsSinceEpoch}.jpg';
      final imageUrl = await FirebaseService.uploadImage(imagePath, bytes);

      // Generate AI reading
      final aiResult = await AIService.generateCoffeeReading(
        user: user,
        imageDescription: 'Turkish coffee cup with residue patterns',
      );

      // Save to Firestore
      final reading = CoffeeReadingModel(
        id: '',
        userId: user.uid,
        imageUrl: imageUrl,
        interpretation: aiResult['overall'] ?? '',
        categories: {
          'love': aiResult['love'] ?? '',
          'career': aiResult['career'] ?? '',
          'health': aiResult['health'] ?? '',
          'advice': aiResult['advice'] ?? '',
        },
        createdAt: DateTime.now(),
        aiModel: AIService.getModelForTier(user.subscriptionTier),
      );

      await FirebaseService.saveCoffeeReading(reading);

      // Update daily count for free users
      if (user.subscriptionTier == SubscriptionTier.free) {
        await userProvider.incrementDailyReading();
      }

      setState(() {
        _reading = aiResult;
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
          'You\'ve used your free reading for today. Upgrade to Gold or Premium for unlimited readings!',
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
                'Turkish Coffee Reading',
                style: AppConstants.headingLarge,
              ),
              const SizedBox(height: AppConstants.spacingS),
              const Text(
                'Upload a photo of your coffee cup for mystical insights',
                style: AppConstants.bodyMedium,
              ),
              const SizedBox(height: AppConstants.spacingL),

              // Image picker
              if (_selectedImage == null)
                Column(
                  children: [
                    _buildImagePickerButton(
                      icon: Icons.camera_alt,
                      label: 'Take Photo',
                      onTap: () => _pickImage(ImageSource.camera),
                    ),
                    const SizedBox(height: AppConstants.spacingM),
                    _buildImagePickerButton(
                      icon: Icons.photo_library,
                      label: 'Choose from Gallery',
                      onTap: () => _pickImage(ImageSource.gallery),
                    ),
                  ],
                )
              else
                Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppConstants.radiusM),
                      child: Image.file(
                        File(_selectedImage!.path),
                        height: 300,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: AppConstants.spacingM),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => setState(() => _selectedImage = null),
                            child: const Text('Change Photo'),
                          ),
                        ),
                        const SizedBox(width: AppConstants.spacingM),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _analyzeReading,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppConstants.primaryPurple,
                            ),
                            child: _isLoading
                                ? const SpinKitThreeBounce(color: Colors.white, size: 20)
                                : const Text('Analyze'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

              // Reading results
              if (_reading != null) ...[
                const SizedBox(height: AppConstants.spacingXL),
                _buildReadingSection('Overall', _reading!['overall']),
                _buildReadingSection('Love & Relationships', _reading!['love']),
                _buildReadingSection('Career & Finances', _reading!['career']),
                _buildReadingSection('Health & Wellbeing', _reading!['health']),
                _buildReadingSection('Advice', _reading!['advice']),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePickerButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppConstants.spacingL),
        decoration: BoxDecoration(
          gradient: AppConstants.primaryGradient,
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: Colors.white),
            const SizedBox(width: AppConstants.spacingM),
            Text(
              label,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReadingSection(String title, String? content) {
    if (content == null || content.isEmpty) return const SizedBox();

    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.spacingM),
      padding: const EdgeInsets.all(AppConstants.spacingL),
      decoration: BoxDecoration(
        color: AppConstants.cardBackground,
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
        border: Border.all(color: AppConstants.primaryPurple.withOpacity(0.3)),
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
}

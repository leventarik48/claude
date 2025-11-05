import 'package:purchases_flutter/purchases_flutter.dart';
import '../models/user_model.dart';
import 'firebase_service.dart';

class SubscriptionService {
  static const String _apiKey = 'YOUR_REVENUECAT_API_KEY'; // Replace with actual key

  // Product IDs (configure in RevenueCat dashboard)
  static const String goldMonthlyProductId = 'gold_monthly';
  static const String goldYearlyProductId = 'gold_yearly';
  static const String premiumMonthlyProductId = 'premium_monthly';
  static const String premiumYearlyProductId = 'premium_yearly';

  // Initialize RevenueCat
  static Future<void> initialize(String userId) async {
    try {
      await Purchases.configure(
        PurchasesConfiguration(_apiKey)..appUserID = userId,
      );
    } catch (e) {
      print('RevenueCat initialization error: $e');
    }
  }

  // Get available products
  static Future<List<StoreProduct>> getAvailableProducts() async {
    try {
      final offerings = await Purchases.getOfferings();
      if (offerings.current != null && offerings.current!.availablePackages.isNotEmpty) {
        return offerings.current!.availablePackages
            .map((package) => package.storeProduct)
            .toList();
      }
    } catch (e) {
      print('Error getting products: $e');
    }
    return [];
  }

  // Get subscription offerings
  static Future<Map<String, dynamic>> getOfferings() async {
    try {
      final offerings = await Purchases.getOfferings();
      if (offerings.current != null) {
        return {
          'current': offerings.current,
          'all': offerings.all,
        };
      }
    } catch (e) {
      print('Error getting offerings: $e');
    }
    return {};
  }

  // Purchase product
  static Future<bool> purchaseProduct(Package package, String userId) async {
    try {
      final customerInfo = await Purchases.purchasePackage(package);

      // Update user subscription in Firestore
      final tier = _getTierFromCustomerInfo(customerInfo);
      final expiry = _getExpiryFromCustomerInfo(customerInfo);

      await FirebaseService.updateUser(userId, {
        'subscriptionTier': tier.toString(),
        'subscriptionExpiry': expiry,
      });

      return true;
    } catch (e) {
      print('Purchase error: $e');
      return false;
    }
  }

  // Restore purchases
  static Future<bool> restorePurchases(String userId) async {
    try {
      final customerInfo = await Purchases.restorePurchases();

      final tier = _getTierFromCustomerInfo(customerInfo);
      final expiry = _getExpiryFromCustomerInfo(customerInfo);

      await FirebaseService.updateUser(userId, {
        'subscriptionTier': tier.toString(),
        'subscriptionExpiry': expiry,
      });

      return tier != SubscriptionTier.free;
    } catch (e) {
      print('Restore error: $e');
      return false;
    }
  }

  // Check subscription status
  static Future<CustomerInfo?> getCustomerInfo() async {
    try {
      return await Purchases.getCustomerInfo();
    } catch (e) {
      print('Error getting customer info: $e');
      return null;
    }
  }

  // Helper: Determine tier from customer info
  static SubscriptionTier _getTierFromCustomerInfo(CustomerInfo customerInfo) {
    if (customerInfo.entitlements.active.isEmpty) {
      return SubscriptionTier.free;
    }

    // Check for premium entitlement
    if (customerInfo.entitlements.active.containsKey('premium')) {
      return SubscriptionTier.premium;
    }

    // Check for gold entitlement
    if (customerInfo.entitlements.active.containsKey('gold')) {
      return SubscriptionTier.gold;
    }

    return SubscriptionTier.free;
  }

  // Helper: Get expiry date from customer info
  static DateTime? _getExpiryFromCustomerInfo(CustomerInfo customerInfo) {
    if (customerInfo.entitlements.active.isEmpty) {
      return null;
    }

    // Get the latest expiry date from active entitlements
    DateTime? latestExpiry;
    for (var entitlement in customerInfo.entitlements.active.values) {
      final expiryDate = entitlement.expirationDate;
      if (expiryDate != null) {
        if (latestExpiry == null || expiryDate.isAfter(latestExpiry)) {
          latestExpiry = expiryDate;
        }
      }
    }

    return latestExpiry;
  }

  // Get mock pricing for display (when RevenueCat is not configured)
  static Map<String, Map<String, String>> getMockPricing() {
    return {
      'gold': {
        'monthly': '\$9.99/month',
        'yearly': '\$99.99/year',
        'description': 'Unlimited readings, advanced AI, no ads',
      },
      'premium': {
        'monthly': '\$19.99/month',
        'yearly': '\$199.99/year',
        'description': 'Ultra-personalized AI, voice features, exclusive content',
      },
    };
  }
}

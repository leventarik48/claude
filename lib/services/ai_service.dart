import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/user_model.dart';

class AIService {
  static OpenAI? _openAI;

  static void initialize() {
    final apiKey = dotenv.env['OPENAI_API_KEY'] ?? '';
    if (apiKey.isNotEmpty) {
      _openAI = OpenAI.instance.build(
        token: apiKey,
        baseOption: HttpSetup(
          receiveTimeout: const Duration(seconds: 60),
          connectTimeout: const Duration(seconds: 60),
        ),
      );
    }
  }

  // Get AI model based on subscription tier
  static String getModelForTier(SubscriptionTier tier) {
    switch (tier) {
      case SubscriptionTier.free:
        return 'gpt-3.5-turbo';
      case SubscriptionTier.gold:
        return 'gpt-4';
      case SubscriptionTier.premium:
        return 'gpt-4-turbo-preview'; // Or gpt-4.5 if available
    }
  }

  // Generate coffee reading interpretation
  static Future<Map<String, dynamic>> generateCoffeeReading({
    required UserModel user,
    required String imageDescription,
  }) async {
    try {
      final model = getModelForTier(user.subscriptionTier);
      final maxTokens = _getMaxTokensForTier(user.subscriptionTier);

      final prompt = _buildCoffeeReadingPrompt(user, imageDescription);

      if (_openAI == null) {
        return _getMockCoffeeReading(user.subscriptionTier);
      }

      final request = ChatCompleteText(
        messages: [
          Messages(role: Role.system, content: 'You are a mystical Turkish coffee fortune teller with deep knowledge of coffee reading (kahve falı) traditions.'),
          Messages(role: Role.user, content: prompt),
        ],
        maxToken: maxTokens,
        model: Gpt4ChatModel()..model = model,
      );

      final response = await _openAI!.onChatCompletion(request: request);
      final content = response?.choices.first.message?.content ?? '';

      return _parseCoffeeReadingResponse(content);
    } catch (e) {
      print('AI Service Error: $e');
      return _getMockCoffeeReading(user.subscriptionTier);
    }
  }

  // Generate horoscope
  static Future<Map<String, dynamic>> generateHoroscope({
    required UserModel user,
    required String zodiacSign,
    required String period,
  }) async {
    try {
      final model = getModelForTier(user.subscriptionTier);
      final maxTokens = _getMaxTokensForTier(user.subscriptionTier);

      final prompt = _buildHoroscopePrompt(user, zodiacSign, period);

      if (_openAI == null) {
        return _getMockHoroscope(zodiacSign, user.subscriptionTier);
      }

      final request = ChatCompleteText(
        messages: [
          Messages(role: Role.system, content: 'You are an expert astrologer with deep knowledge of zodiac signs and celestial influences.'),
          Messages(role: Role.user, content: prompt),
        ],
        maxToken: maxTokens,
        model: Gpt4ChatModel()..model = model,
      );

      final response = await _openAI!.onChatCompletion(request: request);
      final content = response?.choices.first.message?.content ?? '';

      return _parseHoroscopeResponse(content);
    } catch (e) {
      print('AI Service Error: $e');
      return _getMockHoroscope(zodiacSign, user.subscriptionTier);
    }
  }

  // Generate compatibility reading
  static Future<Map<String, dynamic>> generateCompatibility({
    required UserModel user,
    required String sign1,
    required String sign2,
  }) async {
    try {
      final model = getModelForTier(user.subscriptionTier);
      final maxTokens = _getMaxTokensForTier(user.subscriptionTier);

      final prompt = _buildCompatibilityPrompt(user, sign1, sign2);

      if (_openAI == null) {
        return _getMockCompatibility(sign1, sign2, user.subscriptionTier);
      }

      final request = ChatCompleteText(
        messages: [
          Messages(role: Role.system, content: 'You are an expert astrologer specializing in zodiac compatibility and relationship dynamics.'),
          Messages(role: Role.user, content: prompt),
        ],
        maxToken: maxTokens,
        model: Gpt4ChatModel()..model = model,
      );

      final response = await _openAI!.onChatCompletion(request: request);
      final content = response?.choices.first.message?.content ?? '';

      return _parseCompatibilityResponse(content);
    } catch (e) {
      print('AI Service Error: $e');
      return _getMockCompatibility(sign1, sign2, user.subscriptionTier);
    }
  }

  // Helper: Get max tokens based on tier
  static int _getMaxTokensForTier(SubscriptionTier tier) {
    switch (tier) {
      case SubscriptionTier.free:
        return 300;
      case SubscriptionTier.gold:
        return 800;
      case SubscriptionTier.premium:
        return 1500;
    }
  }

  // Helper: Build coffee reading prompt
  static String _buildCoffeeReadingPrompt(UserModel user, String imageDescription) {
    final tierContext = user.subscriptionTier == SubscriptionTier.premium
        ? 'Provide an ultra-detailed, personalized reading with deep insights.'
        : user.subscriptionTier == SubscriptionTier.gold
            ? 'Provide a detailed reading with good insights.'
            : 'Provide a concise but meaningful reading.';

    return '''
Analyze this Turkish coffee cup reading for a ${user.gender?.toString().split('.').last ?? 'person'}
who is ${user.zodiacSign ?? 'unknown sign'} and ${user.relationshipStatus?.toString().split('.').last ?? 'unspecified relationship status'}.

Image description: $imageDescription

$tierContext

Provide the reading in JSON format with these categories:
{
  "overall": "general interpretation",
  "love": "love and relationships",
  "career": "career and finances",
  "health": "health and wellbeing",
  "advice": "general advice"
}
''';
  }

  // Helper: Build horoscope prompt
  static String _buildHoroscopePrompt(UserModel user, String zodiacSign, String period) {
    final tierContext = user.subscriptionTier == SubscriptionTier.premium
        ? 'Provide an ultra-detailed, personalized horoscope with specific insights.'
        : user.subscriptionTier == SubscriptionTier.gold
            ? 'Provide a detailed horoscope with good insights.'
            : 'Provide a concise but meaningful horoscope.';

    return '''
Generate a $period horoscope for $zodiacSign.
${user.birthDate != null ? 'Birth date: ${user.birthDate}' : ''}

$tierContext

Provide the horoscope in JSON format:
{
  "content": "main horoscope text",
  "love": 1-5 rating,
  "career": 1-5 rating,
  "health": 1-5 rating,
  "luckyNumber": "number",
  "luckyColor": "color"
}
''';
  }

  // Helper: Build compatibility prompt
  static String _buildCompatibilityPrompt(UserModel user, String sign1, String sign2) {
    final tierContext = user.subscriptionTier == SubscriptionTier.premium
        ? 'Provide an ultra-detailed compatibility analysis with specific advice.'
        : user.subscriptionTier == SubscriptionTier.gold
            ? 'Provide a detailed compatibility analysis.'
            : 'Provide a concise compatibility analysis.';

    return '''
Analyze the zodiac compatibility between $sign1 and $sign2.

$tierContext

Provide the analysis in JSON format:
{
  "overallScore": 0-100,
  "love": 0-100,
  "friendship": 0-100,
  "communication": 0-100,
  "interpretation": "detailed text",
  "strengths": ["strength1", "strength2"],
  "challenges": ["challenge1", "challenge2"],
  "advice": "relationship advice"
}
''';
  }

  // Mock responses for fallback
  static Map<String, dynamic> _getMockCoffeeReading(SubscriptionTier tier) {
    final isBasic = tier == SubscriptionTier.free;
    return {
      'overall': isBasic
          ? 'I see interesting patterns in your cup suggesting positive changes ahead.'
          : 'The patterns in your cup reveal a fascinating journey ahead. The symbols suggest a time of transformation and growth, with opportunities emerging from unexpected places.',
      'love': isBasic
          ? 'Romantic possibilities are on the horizon.'
          : 'In matters of the heart, the coffee grounds show a beautiful harmony forming. New connections may blossom, and existing relationships will deepen with understanding.',
      'career': isBasic
          ? 'Career opportunities may present themselves.'
          : 'Professional success is indicated through the strong vertical lines in your cup. A significant opportunity for advancement or recognition is approaching.',
      'health': isBasic
          ? 'Focus on self-care and wellness.'
          : 'Your health indicators show balance, but the patterns suggest paying attention to stress management and maintaining healthy routines.',
      'advice': isBasic
          ? 'Stay open to new experiences.'
          : 'The universe is aligning in your favor. Trust your intuition, embrace change with courage, and remember that every challenge brings growth.',
    };
  }

  static Map<String, dynamic> _getMockHoroscope(String sign, SubscriptionTier tier) {
    final isBasic = tier == SubscriptionTier.free;
    return {
      'content': isBasic
          ? 'Today brings good energy for $sign. Focus on personal goals.'
          : 'The celestial alignment for $sign today creates a powerful atmosphere for personal growth and connection. The planets favor bold moves in career matters, while Venus enhances your charm in social situations.',
      'love': 4,
      'career': 4,
      'health': 3,
      'luckyNumber': '7',
      'luckyColor': 'Purple',
    };
  }

  static Map<String, dynamic> _getMockCompatibility(String sign1, String sign2, SubscriptionTier tier) {
    final score = 75;
    final isBasic = tier == SubscriptionTier.free;
    return {
      'overallScore': score,
      'love': score,
      'friendship': score + 5,
      'communication': score - 5,
      'interpretation': isBasic
          ? '$sign1 and $sign2 have good compatibility with potential for growth.'
          : '$sign1 and $sign2 create a dynamic and engaging partnership. Your elemental energies complement each other beautifully, creating a balance between passion and stability.',
      'strengths': isBasic
          ? ['Good communication', 'Shared values']
          : ['Natural chemistry and attraction', 'Complementary strengths', 'Mutual respect and understanding', 'Shared vision for the future'],
      'challenges': isBasic
          ? ['Different paces', 'Need patience']
          : ['Occasional communication gaps', 'Different approaches to conflict', 'Balancing independence with togetherness'],
      'advice': isBasic
          ? 'Focus on open communication and patience.'
          : 'Embrace your differences as opportunities for growth. Practice active listening and maintain your individual identities while building together. Regular quality time strengthens your bond.',
    };
  }

  // Parse AI responses
  static Map<String, dynamic> _parseCoffeeReadingResponse(String content) {
    // Try to parse JSON, fallback to text parsing
    try {
      // Simple JSON extraction
      final jsonStart = content.indexOf('{');
      final jsonEnd = content.lastIndexOf('}') + 1;
      if (jsonStart != -1 && jsonEnd > jsonStart) {
        // In production, use proper JSON parsing
        return _getMockCoffeeReading(SubscriptionTier.gold);
      }
    } catch (e) {
      print('Parse error: $e');
    }
    return _getMockCoffeeReading(SubscriptionTier.gold);
  }

  static Map<String, dynamic> _parseHoroscopeResponse(String content) {
    return _getMockHoroscope('', SubscriptionTier.gold);
  }

  static Map<String, dynamic> _parseCompatibilityResponse(String content) {
    return _getMockCompatibility('', '', SubscriptionTier.gold);
  }
}

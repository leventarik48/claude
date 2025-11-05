import 'package:cloud_firestore/cloud_firestore.dart';

enum SubscriptionTier { free, gold, premium }

enum Gender { male, female, other, preferNotToSay }

enum RelationshipStatus { single, inRelationship, married, complicated, preferNotToSay }

class UserModel {
  final String uid;
  final String email;
  final String? displayName;
  final String? photoURL;
  final DateTime? birthDate;
  final Gender? gender;
  final RelationshipStatus? relationshipStatus;
  final String? zodiacSign;
  final SubscriptionTier subscriptionTier;
  final DateTime? subscriptionExpiry;
  final int dailyFreeReadingsUsed;
  final DateTime? lastFreeReadingDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserModel({
    required this.uid,
    required this.email,
    this.displayName,
    this.photoURL,
    this.birthDate,
    this.gender,
    this.relationshipStatus,
    this.zodiacSign,
    this.subscriptionTier = SubscriptionTier.free,
    this.subscriptionExpiry,
    this.dailyFreeReadingsUsed = 0,
    this.lastFreeReadingDate,
    required this.createdAt,
    required this.updatedAt,
  });

  // Calculate zodiac sign from birth date
  static String calculateZodiacSign(DateTime birthDate) {
    final month = birthDate.month;
    final day = birthDate.day;

    if ((month == 3 && day >= 21) || (month == 4 && day <= 19)) return 'Aries';
    if ((month == 4 && day >= 20) || (month == 5 && day <= 20)) return 'Taurus';
    if ((month == 5 && day >= 21) || (month == 6 && day <= 20)) return 'Gemini';
    if ((month == 6 && day >= 21) || (month == 7 && day <= 22)) return 'Cancer';
    if ((month == 7 && day >= 23) || (month == 8 && day <= 22)) return 'Leo';
    if ((month == 8 && day >= 23) || (month == 9 && day <= 22)) return 'Virgo';
    if ((month == 9 && day >= 23) || (month == 10 && day <= 22)) return 'Libra';
    if ((month == 10 && day >= 23) || (month == 11 && day <= 21)) return 'Scorpio';
    if ((month == 11 && day >= 22) || (month == 12 && day <= 21)) return 'Sagittarius';
    if ((month == 12 && day >= 22) || (month == 1 && day <= 19)) return 'Capricorn';
    if ((month == 1 && day >= 20) || (month == 2 && day <= 18)) return 'Aquarius';
    return 'Pisces';
  }

  bool get isPremiumActive {
    if (subscriptionTier == SubscriptionTier.free) return false;
    if (subscriptionExpiry == null) return true;
    return subscriptionExpiry!.isAfter(DateTime.now());
  }

  bool get canUseFreeReading {
    if (subscriptionTier != SubscriptionTier.free) return true;

    final now = DateTime.now();
    if (lastFreeReadingDate == null) return true;

    final lastDate = DateTime(
      lastFreeReadingDate!.year,
      lastFreeReadingDate!.month,
      lastFreeReadingDate!.day,
    );
    final today = DateTime(now.year, now.month, now.day);

    if (today.isAfter(lastDate)) return true;
    return dailyFreeReadingsUsed < 1;
  }

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      email: data['email'] ?? '',
      displayName: data['displayName'],
      photoURL: data['photoURL'],
      birthDate: data['birthDate'] != null
          ? (data['birthDate'] as Timestamp).toDate()
          : null,
      gender: data['gender'] != null
          ? Gender.values.firstWhere(
              (e) => e.toString() == data['gender'],
              orElse: () => Gender.preferNotToSay,
            )
          : null,
      relationshipStatus: data['relationshipStatus'] != null
          ? RelationshipStatus.values.firstWhere(
              (e) => e.toString() == data['relationshipStatus'],
              orElse: () => RelationshipStatus.preferNotToSay,
            )
          : null,
      zodiacSign: data['zodiacSign'],
      subscriptionTier: SubscriptionTier.values.firstWhere(
        (e) => e.toString() == data['subscriptionTier'],
        orElse: () => SubscriptionTier.free,
      ),
      subscriptionExpiry: data['subscriptionExpiry'] != null
          ? (data['subscriptionExpiry'] as Timestamp).toDate()
          : null,
      dailyFreeReadingsUsed: data['dailyFreeReadingsUsed'] ?? 0,
      lastFreeReadingDate: data['lastFreeReadingDate'] != null
          ? (data['lastFreeReadingDate'] as Timestamp).toDate()
          : null,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'displayName': displayName,
      'photoURL': photoURL,
      'birthDate': birthDate != null ? Timestamp.fromDate(birthDate!) : null,
      'gender': gender?.toString(),
      'relationshipStatus': relationshipStatus?.toString(),
      'zodiacSign': zodiacSign,
      'subscriptionTier': subscriptionTier.toString(),
      'subscriptionExpiry': subscriptionExpiry != null
          ? Timestamp.fromDate(subscriptionExpiry!)
          : null,
      'dailyFreeReadingsUsed': dailyFreeReadingsUsed,
      'lastFreeReadingDate': lastFreeReadingDate != null
          ? Timestamp.fromDate(lastFreeReadingDate!)
          : null,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  UserModel copyWith({
    String? displayName,
    String? photoURL,
    DateTime? birthDate,
    Gender? gender,
    RelationshipStatus? relationshipStatus,
    String? zodiacSign,
    SubscriptionTier? subscriptionTier,
    DateTime? subscriptionExpiry,
    int? dailyFreeReadingsUsed,
    DateTime? lastFreeReadingDate,
  }) {
    return UserModel(
      uid: uid,
      email: email,
      displayName: displayName ?? this.displayName,
      photoURL: photoURL ?? this.photoURL,
      birthDate: birthDate ?? this.birthDate,
      gender: gender ?? this.gender,
      relationshipStatus: relationshipStatus ?? this.relationshipStatus,
      zodiacSign: zodiacSign ?? this.zodiacSign,
      subscriptionTier: subscriptionTier ?? this.subscriptionTier,
      subscriptionExpiry: subscriptionExpiry ?? this.subscriptionExpiry,
      dailyFreeReadingsUsed: dailyFreeReadingsUsed ?? this.dailyFreeReadingsUsed,
      lastFreeReadingDate: lastFreeReadingDate ?? this.lastFreeReadingDate,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}

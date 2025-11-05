import 'package:cloud_firestore/cloud_firestore.dart';

enum HoroscopePeriod { daily, weekly, monthly }

class HoroscopeModel {
  final String id;
  final String zodiacSign;
  final HoroscopePeriod period;
  final DateTime date;
  final String content;
  final Map<String, dynamic> ratings; // love, career, health ratings
  final String? luckyNumber;
  final String? luckyColor;
  final String aiModel;

  HoroscopeModel({
    required this.id,
    required this.zodiacSign,
    required this.period,
    required this.date,
    required this.content,
    required this.ratings,
    this.luckyNumber,
    this.luckyColor,
    required this.aiModel,
  });

  factory HoroscopeModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return HoroscopeModel(
      id: doc.id,
      zodiacSign: data['zodiacSign'] ?? '',
      period: HoroscopePeriod.values.firstWhere(
        (e) => e.toString() == data['period'],
        orElse: () => HoroscopePeriod.daily,
      ),
      date: (data['date'] as Timestamp).toDate(),
      content: data['content'] ?? '',
      ratings: Map<String, dynamic>.from(data['ratings'] ?? {}),
      luckyNumber: data['luckyNumber'],
      luckyColor: data['luckyColor'],
      aiModel: data['aiModel'] ?? 'gpt-3.5-turbo',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'zodiacSign': zodiacSign,
      'period': period.toString(),
      'date': Timestamp.fromDate(date),
      'content': content,
      'ratings': ratings,
      'luckyNumber': luckyNumber,
      'luckyColor': luckyColor,
      'aiModel': aiModel,
    };
  }
}

class UserHoroscopeHistory {
  final String id;
  final String userId;
  final String horoscopeId;
  final DateTime viewedAt;

  UserHoroscopeHistory({
    required this.id,
    required this.userId,
    required this.horoscopeId,
    required this.viewedAt,
  });

  factory UserHoroscopeHistory.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserHoroscopeHistory(
      id: doc.id,
      userId: data['userId'] ?? '',
      horoscopeId: data['horoscopeId'] ?? '',
      viewedAt: (data['viewedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'horoscopeId': horoscopeId,
      'viewedAt': Timestamp.fromDate(viewedAt),
    };
  }
}

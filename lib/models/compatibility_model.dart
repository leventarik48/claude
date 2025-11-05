import 'package:cloud_firestore/cloud_firestore.dart';

class CompatibilityModel {
  final String id;
  final String userId;
  final String sign1;
  final String sign2;
  final int overallScore; // 0-100
  final Map<String, int> categoryScores; // love, friendship, communication, etc.
  final String interpretation;
  final List<String> strengths;
  final List<String> challenges;
  final String advice;
  final DateTime createdAt;
  final String aiModel;

  CompatibilityModel({
    required this.id,
    required this.userId,
    required this.sign1,
    required this.sign2,
    required this.overallScore,
    required this.categoryScores,
    required this.interpretation,
    required this.strengths,
    required this.challenges,
    required this.advice,
    required this.createdAt,
    required this.aiModel,
  });

  factory CompatibilityModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CompatibilityModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      sign1: data['sign1'] ?? '',
      sign2: data['sign2'] ?? '',
      overallScore: data['overallScore'] ?? 0,
      categoryScores: Map<String, int>.from(data['categoryScores'] ?? {}),
      interpretation: data['interpretation'] ?? '',
      strengths: List<String>.from(data['strengths'] ?? []),
      challenges: List<String>.from(data['challenges'] ?? []),
      advice: data['advice'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      aiModel: data['aiModel'] ?? 'gpt-3.5-turbo',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'sign1': sign1,
      'sign2': sign2,
      'overallScore': overallScore,
      'categoryScores': categoryScores,
      'interpretation': interpretation,
      'strengths': strengths,
      'challenges': challenges,
      'advice': advice,
      'createdAt': Timestamp.fromDate(createdAt),
      'aiModel': aiModel,
    };
  }
}

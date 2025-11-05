import 'package:cloud_firestore/cloud_firestore.dart';

class CoffeeReadingModel {
  final String id;
  final String userId;
  final String imageUrl;
  final String interpretation;
  final Map<String, String> categories; // love, career, health, etc.
  final DateTime createdAt;
  final String aiModel; // Which AI model was used
  final bool hasAudio;
  final String? audioUrl;

  CoffeeReadingModel({
    required this.id,
    required this.userId,
    required this.imageUrl,
    required this.interpretation,
    required this.categories,
    required this.createdAt,
    required this.aiModel,
    this.hasAudio = false,
    this.audioUrl,
  });

  factory CoffeeReadingModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CoffeeReadingModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      interpretation: data['interpretation'] ?? '',
      categories: Map<String, String>.from(data['categories'] ?? {}),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      aiModel: data['aiModel'] ?? 'gpt-3.5-turbo',
      hasAudio: data['hasAudio'] ?? false,
      audioUrl: data['audioUrl'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'imageUrl': imageUrl,
      'interpretation': interpretation,
      'categories': categories,
      'createdAt': Timestamp.fromDate(createdAt),
      'aiModel': aiModel,
      'hasAudio': hasAudio,
      'audioUrl': audioUrl,
    };
  }
}

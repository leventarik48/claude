import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/user_model.dart';
import '../models/coffee_reading_model.dart';
import '../models/horoscope_model.dart';
import '../models/compatibility_model.dart';

class FirebaseService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseStorage _storage = FirebaseStorage.instance;

  // User operations
  static Future<void> createUser(UserModel user) async {
    await _firestore.collection('users').doc(user.uid).set(user.toFirestore());
  }

  static Future<UserModel?> getUser(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Error getting user: $e');
      return null;
    }
  }

  static Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    data['updatedAt'] = FieldValue.serverTimestamp();
    await _firestore.collection('users').doc(uid).update(data);
  }

  static Stream<UserModel?> userStream(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .snapshots()
        .map((doc) => doc.exists ? UserModel.fromFirestore(doc) : null);
  }

  // Coffee reading operations
  static Future<String> saveCoffeeReading(CoffeeReadingModel reading) async {
    final docRef = await _firestore.collection('coffeeReadings').add(reading.toFirestore());
    return docRef.id;
  }

  static Future<List<CoffeeReadingModel>> getUserCoffeeReadings(String userId, {int limit = 20}) async {
    final snapshot = await _firestore
        .collection('coffeeReadings')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .get();

    return snapshot.docs.map((doc) => CoffeeReadingModel.fromFirestore(doc)).toList();
  }

  // Horoscope operations
  static Future<String> saveHoroscope(HoroscopeModel horoscope) async {
    final docRef = await _firestore.collection('horoscopes').add(horoscope.toFirestore());
    return docRef.id;
  }

  static Future<HoroscopeModel?> getHoroscope(String zodiacSign, HoroscopePeriod period, DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final snapshot = await _firestore
        .collection('horoscopes')
        .where('zodiacSign', isEqualTo: zodiacSign)
        .where('period', isEqualTo: period.toString())
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('date', isLessThan: Timestamp.fromDate(endOfDay))
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      return HoroscopeModel.fromFirestore(snapshot.docs.first);
    }
    return null;
  }

  static Future<void> saveHoroscopeView(String userId, String horoscopeId) async {
    await _firestore.collection('horoscopeHistory').add({
      'userId': userId,
      'horoscopeId': horoscopeId,
      'viewedAt': FieldValue.serverTimestamp(),
    });
  }

  static Future<List<UserHoroscopeHistory>> getUserHoroscopeHistory(String userId, {int limit = 20}) async {
    final snapshot = await _firestore
        .collection('horoscopeHistory')
        .where('userId', isEqualTo: userId)
        .orderBy('viewedAt', descending: true)
        .limit(limit)
        .get();

    return snapshot.docs.map((doc) => UserHoroscopeHistory.fromFirestore(doc)).toList();
  }

  // Compatibility operations
  static Future<String> saveCompatibility(CompatibilityModel compatibility) async {
    final docRef = await _firestore.collection('compatibilities').add(compatibility.toFirestore());
    return docRef.id;
  }

  static Future<List<CompatibilityModel>> getUserCompatibilities(String userId, {int limit = 20}) async {
    final snapshot = await _firestore
        .collection('compatibilities')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .get();

    return snapshot.docs.map((doc) => CompatibilityModel.fromFirestore(doc)).toList();
  }

  // Storage operations
  static Future<String> uploadImage(String path, List<int> imageData) async {
    final ref = _storage.ref().child(path);
    final uploadTask = await ref.putData(imageData as Uint8List);
    return await uploadTask.ref.getDownloadURL();
  }

  // Update daily reading count
  static Future<void> updateDailyReadingCount(String uid) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    await _firestore.collection('users').doc(uid).update({
      'dailyFreeReadingsUsed': FieldValue.increment(1),
      'lastFreeReadingDate': Timestamp.fromDate(today),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Reset daily reading count if new day
  static Future<void> checkAndResetDailyCount(String uid, DateTime? lastReadingDate) async {
    if (lastReadingDate == null) return;

    final now = DateTime.now();
    final lastDate = DateTime(
      lastReadingDate.year,
      lastReadingDate.month,
      lastReadingDate.day,
    );
    final today = DateTime(now.year, now.month, now.day);

    if (today.isAfter(lastDate)) {
      await _firestore.collection('users').doc(uid).update({
        'dailyFreeReadingsUsed': 0,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
  }
}

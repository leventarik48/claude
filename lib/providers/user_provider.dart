import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/firebase_service.dart';
import '../services/auth_service.dart';

class UserProvider with ChangeNotifier {
  UserModel? _user;
  bool _isLoading = false;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;

  // Load user data
  Future<void> loadUser() async {
    final currentUser = AuthService.currentUser;
    if (currentUser != null) {
      _isLoading = true;
      notifyListeners();

      _user = await FirebaseService.getUser(currentUser.uid);

      _isLoading = false;
      notifyListeners();
    }
  }

  // Update user data
  Future<void> updateUser(Map<String, dynamic> updates) async {
    if (_user != null) {
      await FirebaseService.updateUser(_user!.uid, updates);
      await loadUser();
    }
  }

  // Update user model locally
  void setUser(UserModel? user) {
    _user = user;
    notifyListeners();
  }

  // Clear user data
  void clearUser() {
    _user = null;
    notifyListeners();
  }

  // Check if user can use free reading
  bool canUseFreeReading() {
    return _user?.canUseFreeReading ?? false;
  }

  // Update daily reading count
  Future<void> incrementDailyReading() async {
    if (_user != null) {
      await FirebaseService.updateDailyReadingCount(_user!.uid);
      await loadUser();
    }
  }

  // Check and reset daily count if needed
  Future<void> checkDailyReset() async {
    if (_user != null) {
      await FirebaseService.checkAndResetDailyCount(
        _user!.uid,
        _user!.lastFreeReadingDate,
      );
      await loadUser();
    }
  }
}

import '../models/user_characteristics.dart';
import 'package:flutter/foundation.dart';

class AppState extends ValueNotifier<UserCharacteristics?> {
  AppState._internal() : super(null);
  static final AppState instance = AppState._internal();

  Future<void> init() async {
    notifyListeners();
  }

  void updateUserCharacteristics(UserCharacteristics? next) {
    value = next;
    notifyListeners();
  }

  UserCharacteristics? get profile => value;

  void setProfile(UserCharacteristics v) {
    value = v;
  }

  void clear() {
    value = null;
  }
}

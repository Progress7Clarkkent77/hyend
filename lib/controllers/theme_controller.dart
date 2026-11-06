import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hyend/userAuth/authController.dart';

class ThemeController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthController _auth = Get.find<AuthController>();

  final isDarkMode = false.obs;

  String get uid => _auth.currentUser!.uid;

  /// 🔹 Load theme when user logs in
  Future<void> loadTheme() async {
    final doc = await _firestore.collection('e-users').doc(uid).get();

    if (!doc.exists) return;

    final theme = doc.data()?['theme'];

    if (theme == 'dark') {
      isDarkMode.value = true;
    } else {
      isDarkMode.value = false;
    }
  }

  /// 🔹 Set DARK mode & save
  Future<void> setDark() async {
    isDarkMode.value = true;

    await _firestore.collection('e-users').doc(uid).set({
      'theme': 'dark',
    }, SetOptions(merge: true));
  }

  /// 🔹 Set LIGHT mode & save
  Future<void> setLight() async {
    isDarkMode.value = false;

    await _firestore.collection('e-users').doc(uid).set({
      'theme': 'light',
    }, SetOptions(merge: true));
  }
}

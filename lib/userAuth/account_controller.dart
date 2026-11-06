import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:get/get.dart';
import 'package:hyend/userAuth/authController.dart';

//import 'package:the_splendid_market/CowriexController/history_controller.dart';

class AccountController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthController authController = Get.find<AuthController>();

  var userName = ''.obs;
  var userEmail = ''.obs;
  RxDouble loadingProgress = 0.0.obs;
  RxInt dailyTapCount = 0.obs;
  DateTime? lastTapDate;

  RxString avatarName = ''.obs;

  Timer? _balanceTimer;

  // Auth + realtime user-doc subscriptions. They are (re)bound every time the
  // signed-in user changes, so this controller no longer depends on a user
  // already being logged in at the moment it is created.
  StreamSubscription<User?>? _authSub;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _userDocSub;

  // void startRealtimeBalance() {
  //   _balanceTimer?.cancel();
  //   _balanceTimer = Timer.periodic(const Duration(seconds: 5), (_) async {
  //     await fetchBalances();
  //   });
  // }

  @override
  void onInit() {
    super.onInit();

    // authStateChanges() emits the current user immediately on listen, and
    // again on every login / logout / account switch. This fixes the
    // "name & email are Null until I restart the app" bug: if this controller
    // is created before login, it now still picks the user up once they sign in.
    _authSub = FirebaseAuth.instance.authStateChanges().listen(_bindUser);
  }

  @override
  void onClose() {
    _balanceTimer?.cancel();
    _authSub?.cancel();
    _userDocSub?.cancel();
    super.onClose();
  }

  /// Called whenever the signed-in user changes (including app start).
  void _bindUser(User? user) {
    // Drop the previous user's realtime listener first.
    _userDocSub?.cancel();
    _userDocSub = null;

    if (user == null) {
      _resetState();
      return;
    }

    // Show something right away from Firebase Auth, so the UI is never "Null"
    // while Firestore is loading (or if the e-users doc doesn't exist yet,
    // e.g. it is created a moment after sign-in in AuthController.login()).
    userName.value = user.displayName ?? '';
    userEmail.value = user.email ?? '';

    fetchUserInfo();

    // Real-time updates for user data
    _userDocSub = _firestore
        .collection('e-users')
        .doc(user.uid)
        .snapshots()
        .listen((snapshot) {
          final data = snapshot.data();
          if (data == null) return;

          // update name & email dynamically
          userName.value = data['name'] ?? user.displayName ?? "Unknown";
          userEmail.value = data['email'] ?? user.email ?? "Unknown";
          avatarName.value = data['avatar'] ?? '';
        }, onError: (_) {});
  }

  /// Clears everything tied to the previous user so the next person who logs
  /// in on this device never sees stale data.
  void _resetState() {
    userName.value = '';
    userEmail.value = '';
    avatarName.value = '';
  }

  Future<void> setAvatar(String avatarName) async {
    final user = authController.currentUser;
    if (user == null) return;

    await _firestore.collection('e-users').doc(user.uid).set({
      'avatar': avatarName,
    }, SetOptions(merge: true));

    this.avatarName.value = avatarName;
  }

  Future<void> fetchUserInfo() async {
    final user = authController.currentUser;
    if (user == null) return;

    try {
      final doc = await _firestore.collection('e-users').doc(user.uid).get();
      if (doc.exists) {
        final data = doc.data()!;
        userName.value = data['name'] ?? user.displayName ?? "Unknown";
        userEmail.value = data['email'] ?? user.email ?? "Unknown";
        // ✅ AVATAR
        avatarName.value = data['avatar'] ?? '';
      } else {
        // Doc not created yet (it can appear a moment after sign-in).
        // Fall back to Firebase Auth; the realtime listener will fill in
        // the rest as soon as the doc exists.
        if (userName.value.isEmpty) userName.value = user.displayName ?? '';
        if (userEmail.value.isEmpty) userEmail.value = user.email ?? '';
      }
    } catch (e) {
      // Ignore if the user signed out while the request was in flight.
      if (authController.currentUser != null) {
        Get.snackbar("Error", "Failed to fetch user info");
      }
    }
  }

  Future<void> deleteAccount() async {
    final user = authController.currentUser;
    if (user == null) {
      Get.snackbar("Error", "No user is currently signed in.");
      return;
    }

    final String email = user.email ?? "";
    final TextEditingController passwordController = TextEditingController();

    Get.defaultDialog(
      title: "Confirm Password",
      titleStyle: TextStyle(
        color: Colors.black.withOpacity(0.69),
        fontSize: 14,
        fontWeight: FontWeight.bold,
      ),
      content: Column(
        children: [
          Text(
            "For your security, please re-enter your password to permanently delete your account.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: Colors.black54),
          ),
          SizedBox(height: 12),
          TextField(
            controller: passwordController,
            obscureText: true,
            maxLength: 8,
            decoration: InputDecoration(
              hintText: "Password",
              counterText: "",
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.black),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.black, width: 1),
              ),
            ),
            inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r"\s"))],
          ),
          SizedBox(height: 10),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              final String password = passwordController.text.trim();

              if (password.isEmpty) {
                Get.snackbar("Error", "Please enter your password");
                return;
              }

              // loading dialog
              Get.dialog(
                StatefulBuilder(
                  builder: (context, setState) {
                    final AnimationController _controller = AnimationController(
                      vsync: Navigator.of(context),
                      duration: Duration(seconds: 1),
                    )..repeat();

                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          RotationTransition(
                            turns: _controller,
                            child: Image.asset(
                              'assets/images/Textido Logo.jpeg',
                              width: 50,
                              height: 50,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            "Deleting Account...",
                            style: TextStyle(
                              color: Colors.deepOrange,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                barrierDismissible: false,
              );

              try {
                // 1. Re-authenticate — required by Firebase before deletion
                final bool isValid = await authController.verifyPassword(
                  email,
                  password,
                );

                if (!isValid) {
                  Get.back(); // close loading
                  Get.snackbar("Error", "Incorrect password. Try again.");
                  return;
                }

                // 2. Delete Firestore user doc
                await _firestore.collection('e-users').doc(user.uid).delete();

                // 3. Delete the Firebase Auth account itself
                await user.delete();

                // Close loading + password dialogs
                Get.back();
                Get.back();

                Get.offAllNamed('/login');

                Get.snackbar(
                  "Account Deleted",
                  "Your account has been permanently deleted.",
                );
              } on FirebaseAuthException catch (e) {
                Get.back(); // close loading
                if (e.code == 'requires-recent-login') {
                  Get.snackbar(
                    "Error",
                    "Please log in again before deleting your account.",
                  );
                } else {
                  Get.snackbar(
                    "Error",
                    e.message ?? "Failed to delete account.",
                  );
                }
              } catch (e) {
                Get.back(); // close loading
                Get.snackbar(
                  "Error",
                  "Something went wrong. Please try again.",
                );
              }
            },
            child: Text(
              "Confirm Delete",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

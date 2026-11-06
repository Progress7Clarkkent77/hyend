import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoadingDialog extends StatefulWidget {
  @override
  _LoadingDialogState createState() => _LoadingDialogState();
}

class _LoadingDialogState extends State<LoadingDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1), // 1-second fade animation
    )..repeat(reverse: true); // Loops animation

    _animation = Tween<double>(begin: 0.2, end: 1.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Center(
        child: FadeTransition(
          opacity: _animation,
          child: Text(
            "LOADING",
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: Colors.orange,
            ),
          ),
        ),
      ),
    );
  }
}

void showLoadingDialog(String message) {
  Get.dialog(
    Dialog(
      backgroundColor: Colors.transparent,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: Colors.black),
            SizedBox(height: 16),
            Obx(
              () => Text(
                loadingMessage.value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
    barrierDismissible: false, // Prevent dismissing
  );
  loadingMessage.value = message;
}

void updateLoadingDialog(String newMessage) {
  loadingMessage.value = newMessage;
}

final RxString loadingMessage = "Loading...".obs;

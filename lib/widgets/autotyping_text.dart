import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AutoTypingText extends StatefulWidget {
  final RxString text;

  AutoTypingText({required this.text});

  @override
  _AutoTypingTextState createState() => _AutoTypingTextState();
}

class _AutoTypingTextState extends State<AutoTypingText> {
  String _currentText = "";

  @override
  void initState() {
    super.initState();
    widget.text.listen((newText) {
      if (newText != _currentText) {
        setState(() {
          _currentText = newText;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return _currentText.isEmpty
        ? Container() // Show nothing if the text is empty
        : AnimatedTextKit(
            animatedTexts: [
              TypewriterAnimatedText(
                _currentText,
                textStyle: const TextStyle(color: Colors.black, fontSize: 15),
                speed: const Duration(milliseconds: 100),
              ),
            ],
            isRepeatingAnimation: false,
            totalRepeatCount: 1,
          );
  }
}

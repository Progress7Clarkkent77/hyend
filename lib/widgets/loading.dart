import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hyend/constant/colors.dart';

class LoadingContainer extends StatelessWidget {
  final RxDouble loadingProgress;

  LoadingContainer({required this.loadingProgress});

  @override
  Widget build(BuildContext context) {
    Color mainColor = getMainColor(context);
    return Obx(
      () => Container(
        width: 250,
        height: 20,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Stack(
          children: [
            Container(
              width: 250 * loadingProgress.value,
              height: 20,
              decoration: BoxDecoration(
                color: mainColor,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class ParallelogramClipper extends CustomClipper<Path> {
  final double radius;

  ParallelogramClipper(this.radius);

  @override
  Path getClip(Size size) {
    Path path = Path();
    path.moveTo(radius, 0.0);
    path.lineTo(size.width - radius, 0.0);
    path.lineTo(size.width, size.height);
    path.lineTo(radius, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}

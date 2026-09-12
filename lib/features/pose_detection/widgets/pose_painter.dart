import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

class PosePainter extends CustomPainter {
  final Pose pose;
  final Size imageSize;
  final bool isFrontCamera;

  PosePainter({
    required this.pose,
    required this.imageSize,
    required this.isFrontCamera,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final pointPaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;

    final linePaint = Paint()
      ..color = Colors.green
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    Offset convertPoint(PoseLandmark landmark) {
      // ML Kit coordinates are portrait-oriented in our current setup.
      final double inputWidth = imageSize.height;
      final double inputHeight = imageSize.width;

      final double scale = max(
        size.width / inputWidth,
        size.height / inputHeight,
      );

      final double displayWidth = inputWidth * scale;
      final double displayHeight = inputHeight * scale;

      final double offsetX = (size.width - displayWidth) / 2;
      final double offsetY = (size.height - displayHeight) / 2;

      double x = landmark.x * scale + offsetX;
      final double y = landmark.y * scale + offsetY;

      if (isFrontCamera) {
        x = size.width - x;
      }

      return Offset(x, y);
    }

    void drawLine(PoseLandmarkType type1, PoseLandmarkType type2) {
      final point1 = pose.landmarks[type1];
      final point2 = pose.landmarks[type2];

      if (point1 != null && point2 != null) {
        canvas.drawLine(convertPoint(point1), convertPoint(point2), linePaint);
      }
    }

    // Draw all landmarks
    for (final landmark in pose.landmarks.values) {
      canvas.drawCircle(convertPoint(landmark), 6, pointPaint);
    }

    // Head
    drawLine(PoseLandmarkType.leftEye, PoseLandmarkType.rightEye);

    // Shoulders
    drawLine(PoseLandmarkType.leftShoulder, PoseLandmarkType.rightShoulder);

    // Left arm
    drawLine(PoseLandmarkType.leftShoulder, PoseLandmarkType.leftElbow);

    drawLine(PoseLandmarkType.leftElbow, PoseLandmarkType.leftWrist);

    // Right arm
    drawLine(PoseLandmarkType.rightShoulder, PoseLandmarkType.rightElbow);

    drawLine(PoseLandmarkType.rightElbow, PoseLandmarkType.rightWrist);

    // Body
    drawLine(PoseLandmarkType.leftShoulder, PoseLandmarkType.leftHip);

    drawLine(PoseLandmarkType.rightShoulder, PoseLandmarkType.rightHip);

    drawLine(PoseLandmarkType.leftHip, PoseLandmarkType.rightHip);

    // Left leg
    drawLine(PoseLandmarkType.leftHip, PoseLandmarkType.leftKnee);

    drawLine(PoseLandmarkType.leftKnee, PoseLandmarkType.leftAnkle);

    // Right leg
    drawLine(PoseLandmarkType.rightHip, PoseLandmarkType.rightKnee);

    drawLine(PoseLandmarkType.rightKnee, PoseLandmarkType.rightAnkle);
  }

  @override
  bool shouldRepaint(covariant PosePainter oldDelegate) {
    return oldDelegate.pose != pose ||
        oldDelegate.imageSize != imageSize ||
        oldDelegate.isFrontCamera != isFrontCamera;
  }
}

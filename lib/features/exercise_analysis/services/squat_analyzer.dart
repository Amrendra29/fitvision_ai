import 'dart:math';

import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

class SquatAnalyzer {
  // ----------------------------
  // REP COUNTING VARIABLES
  // ----------------------------

  bool _reachedBottom = false;

  int repCount = 0;

  String status = 'Stand';

  // ----------------------------
  // ANGLE SMOOTHING
  // ----------------------------

  double? _previousAngle;

  // ----------------------------
  // CALCULATE ANGLE
  // ----------------------------

  double calculateAngle(
    PoseLandmark point1,
    PoseLandmark point2,
    PoseLandmark point3,
  ) {
    final radians =
        atan2(
          point3.y - point2.y,
          point3.x - point2.x,
        ) -
        atan2(
          point1.y - point2.y,
          point1.x - point2.x,
        );

    double angle = radians.abs() * 180 / pi;

    if (angle > 180) {
      angle = 360 - angle;
    }

    return angle;
  }

  // ----------------------------
  // CALCULATE RAW KNEE ANGLE
  // ----------------------------

  double? calculateKneeAngle(Pose pose) {
    final hip =
        pose.landmarks[PoseLandmarkType.leftHip];

    final knee =
        pose.landmarks[PoseLandmarkType.leftKnee];

    final ankle =
        pose.landmarks[PoseLandmarkType.leftAnkle];

    if (hip == null || knee == null || ankle == null) {
      return null;
    }

    return calculateAngle(
      hip,
      knee,
      ankle,
    );
  }

  // ----------------------------
  // SMOOTH ANGLE FOR UI DISPLAY
  // ----------------------------

  double? smoothAngle(double? rawAngle) {
    if (rawAngle == null) return null;

    const double factor = 0.25;

    if (_previousAngle == null) {
      _previousAngle = rawAngle;
    } else {
      _previousAngle =
          _previousAngle! * factor +
          rawAngle * (1 - factor);
    }

    return _previousAngle;
  }

  // ----------------------------
  // ANALYZE SQUAT AND COUNT REP
  // ----------------------------

  void analyzeSquat(double angle) {
    // Person reached squat bottom
    if (angle < 115) {
      _reachedBottom = true;
      status = 'Down';
    }

    // Person stood up after reaching bottom
    else if (_reachedBottom && angle > 155) {
      repCount++;
      _reachedBottom = false;
      status = 'Rep Complete!';
    }

    // Person is standing
    else if (!_reachedBottom && angle >= 155) {
      status = 'Stand';
    }

    // Person is moving
    else {
      status = 'Moving';
    }
  }

  // ----------------------------
  // RESET EXERCISE
  // ----------------------------

  void reset() {
    _reachedBottom = false;
    repCount = 0;
    status = 'Stand';
    _previousAngle = null;
  }
}
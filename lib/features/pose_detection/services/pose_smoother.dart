import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

class PoseSmoother {
  final double smoothingFactor;

  final Map<PoseLandmarkType, PoseLandmark> _previousLandmarks = {};

  PoseSmoother({this.smoothingFactor = 0.7});

  Map<PoseLandmarkType, PoseLandmark> smooth(
    Map<PoseLandmarkType, PoseLandmark> landmarks,
  ) {
    final Map<PoseLandmarkType, PoseLandmark> smoothedLandmarks = {};

    for (final entry in landmarks.entries) {
      final type = entry.key;
      final current = entry.value;

      final previous = _previousLandmarks[type];

      double factor = smoothingFactor;

     
      if (previous == null) {
        smoothedLandmarks[type] = current;
      } else {
        final x = previous.x * factor + current.x * (1 - factor);

        final y = previous.y * factor + current.y * (1 - factor);

        final z = previous.z * factor + current.z * (1 - factor);

        smoothedLandmarks[type] = PoseLandmark(
          type: current.type,
          x: x,
          y: y,
          z: z,
          likelihood: current.likelihood,
        );
      }
    }

    _previousLandmarks
      ..clear()
      ..addAll(smoothedLandmarks);

    return smoothedLandmarks;
  }

  void reset() {
    _previousLandmarks.clear();
  }
}

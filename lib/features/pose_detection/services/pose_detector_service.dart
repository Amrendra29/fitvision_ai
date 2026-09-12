import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

class PoseDetectorService {
  final PoseDetector _poseDetector = PoseDetector(
    options: PoseDetectorOptions(
      mode: PoseDetectionMode.stream,
      model: PoseDetectionModel.base,
    ),
  );

  Future<List<Pose>> processImage(InputImage inputImage) async {
    return await _poseDetector.processImage(inputImage);
  }

  void dispose() {
    _poseDetector.close();
  }
}
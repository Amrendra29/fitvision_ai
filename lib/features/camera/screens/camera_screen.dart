import 'package:camera/camera.dart';
import 'package:fitvision_ai/features/exercise_analysis/services/squat_analyzer.dart';
import 'package:fitvision_ai/features/pose_detection/services/pose_smoother.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

import '../../pose_detection/widgets/pose_painter.dart';
import '../../pose_detection/services/pose_detector_service.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _controller;
  List<CameraDescription> _cameras = [];
  final PoseDetectorService _poseDetectorService = PoseDetectorService();
  bool _isFrontCamera = true;
  bool _isProcessing = false;
  Pose? _currentPose;
  Size? _imageSize;
  final PoseSmoother _poseSmoother = PoseSmoother(smoothingFactor: 0.15);
  final SquatAnalyzer _squatAnalyzer = SquatAnalyzer();
  int _repCount = 0;
  String _exerciseStatus = 'Stand';
  double? _kneeAngle;
  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    _cameras = await availableCameras();

    if (_cameras.isEmpty) return;

    final camera = _cameras.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.front,
      orElse: () => _cameras.first,
    );

    _controller = CameraController(
      camera,
      ResolutionPreset.medium,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.nv21,
    );

    await _controller!.initialize();
    await _controller!.startImageStream(_processCameraImage);
    if (!mounted) return;

    setState(() {});
  }

  Future<void> _switchCamera() async {
    if (_cameras.length < 2) return;

    // Stop current image stream first
    if (_controller != null && _controller!.value.isStreamingImages) {
      await _controller!.stopImageStream();
    }

    await _controller?.dispose();

    final newCamera = _cameras.firstWhere(
      (camera) => _isFrontCamera
          ? camera.lensDirection == CameraLensDirection.back
          : camera.lensDirection == CameraLensDirection.front,
      orElse: () => _cameras.first,
    );

    _isFrontCamera = !_isFrontCamera;

    _controller = CameraController(
      newCamera,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.nv21,
    );

    await _controller!.initialize();

    await _controller!.startImageStream(_processCameraImage);

    if (mounted) {
      setState(() {
        _currentPose = null;
      });
    }
  }

  Future<void> _processCameraImage(CameraImage image) async {
    if (!mounted || _isProcessing) return;

    _isProcessing = true;

    try {
      final inputImage = _inputImageFromCameraImage(image);

      if (inputImage == null) return;

      final poses = await _poseDetectorService.processImage(inputImage);

      if (poses.isNotEmpty && mounted) {
        final rawPose = poses.first;

        // 1. Calculate RAW knee angle
        final rawKneeAngle = _squatAnalyzer.calculateKneeAngle(rawPose);

        // 2. Use RAW angle for rep counting
        if (rawKneeAngle != null) {
          _squatAnalyzer.analyzeSquat(rawKneeAngle);
        }

        // 3. Smooth angle only for UI display
        final displayKneeAngle = _squatAnalyzer.smoothAngle(rawKneeAngle);

        // 4. Smooth landmarks only for skeleton display
        final smoothedLandmarks = _poseSmoother.smooth(rawPose.landmarks);

        final smoothedPose = Pose(landmarks: smoothedLandmarks);

        // 5. Update UI
        setState(() {
          _imageSize = Size(image.width.toDouble(), image.height.toDouble());

          _currentPose = smoothedPose;
          _kneeAngle = displayKneeAngle;

          _repCount = _squatAnalyzer.repCount;
          _exerciseStatus = _squatAnalyzer.status;
        });
      } else if (mounted) {
        setState(() {
          _currentPose = null;
          _kneeAngle = null;
        });
      }
    } catch (e) {
      debugPrint('Pose detection error: $e');
    } finally {
      _isProcessing = false;
    }
  }

  InputImage? _inputImageFromCameraImage(CameraImage image) {
    if (_controller == null) return null;

    final rotation = InputImageRotationValue.fromRawValue(
      _controller!.description.sensorOrientation,
    );

    if (rotation == null) return null;

    if (image.planes.isEmpty) return null;

    final format = InputImageFormatValue.fromRawValue(image.format.raw);

    if (format == null) return null;

    return InputImage.fromBytes(
      bytes: image.planes.first.bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: format,
        bytesPerRow: image.planes.first.bytesPerRow,
      ),
    );
  }

  @override
  void dispose() {
    _isProcessing = true;

    _controller?.stopImageStream().catchError((_) {});

    _controller?.dispose();
    _poseDetectorService.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('AI Workout')),
      body: Stack(
        fit: StackFit.expand,
        children: [
          SizedBox.expand(
            child: Stack(
              fit: StackFit.expand,
              children: [
                CameraPreview(_controller!),

                if (_currentPose != null && _imageSize != null)
                  CustomPaint(
                    painter: PosePainter(
                      pose: _currentPose!,
                      imageSize: _imageSize!,
                      isFrontCamera:
                          _controller!.description.lensDirection ==
                          CameraLensDirection.front,
                    ),
                  ),
              ],
            ),
          ),

          // Pose status
          Positioned(
            top: 20,
            left: 20,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                _currentPose != null ? 'Pose Detected' : 'Detecting...',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // Camera switch
          Positioned(
            top: 20,
            right: 20,
            child: IconButton(
              onPressed: _switchCamera,
              icon: const Icon(
                Icons.cameraswitch,
                color: Colors.white,
                size: 32,
              ),
              style: IconButton.styleFrom(backgroundColor: Colors.black54),
            ),
          ),

          // Knee angle
          Positioned(
            bottom: 30,
            left: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _kneeAngle != null
                    ? 'Knee: ${_kneeAngle!.toStringAsFixed(1)}°'
                    : 'Detecting knee...',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // Rep counter
          Positioned(
            bottom: 30,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                children: [
                  const Text(
                    'SQUATS',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  Text(
                    '$_repCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    _exerciseStatus,
                    style: const TextStyle(
                      color: Colors.greenAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

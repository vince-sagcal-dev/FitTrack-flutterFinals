import 'dart:async';

import 'package:camera/camera.dart';
import 'package:material_ui/material_ui.dart';

class CameraCaptureScreen extends StatefulWidget {
  const CameraCaptureScreen({super.key});

  @override
  State<CameraCaptureScreen> createState() => _CameraCaptureScreenState();
}

class _CameraCaptureScreenState extends State<CameraCaptureScreen> {
  CameraController? _controller;
  String? _error;
  bool _initializing = true;
  bool _capturing = false;

  @override
  void initState() {
    super.initState();
    unawaited(_initializeCamera());
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (!mounted) return;
      if (cameras.isEmpty) {
        throw StateError('No camera was found on this device.');
      }

      final camera = cameras.firstWhere(
        (description) =>
            description.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );
      final controller = CameraController(
        camera,
        ResolutionPreset.medium,
        enableAudio: false,
      );
      _controller = controller;
      await controller.initialize();
      if (!mounted) {
        await controller.dispose();
        return;
      }
    } on CameraException catch (error) {
      if (mounted) {
        setState(() => _error = error.description ?? error.code);
      }
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _initializing = false);
    }
  }

  Future<void> _retry() async {
    setState(() {
      _initializing = true;
      _error = null;
    });
    await _controller?.dispose();
    _controller = null;
    await _initializeCamera();
  }

  Future<void> _takePicture() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized || _capturing) {
      return;
    }

    setState(() => _capturing = true);
    try {
      final image = await controller.takePicture();
      if (mounted) Navigator.of(context).pop<XFile>(image);
    } on CameraException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Could not take photo: ${error.description ?? error.code}',
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _capturing = false);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    return Scaffold(
      appBar: AppBar(title: const Text('Take a photo')),
      body: SafeArea(
        child: _initializing
            ? const Center(child: CircularProgressIndicator())
            : _error != null
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Could not open the camera: $_error',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      FilledButton(
                        onPressed: _retry,
                        child: const Text('Try again'),
                      ),
                    ],
                  ),
                ),
              )
            : Column(
                children: [
                  Expanded(
                    child: Center(
                      child: AspectRatio(
                        aspectRatio: controller!.value.aspectRatio,
                        child: CameraPreview(controller),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: FilledButton.icon(
                        onPressed: _capturing ? null : _takePicture,
                        icon: const Icon(Icons.camera_alt_outlined),
                        label: Text(_capturing ? 'Taking photo...' : 'Capture'),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:image_picker/image_picker.dart';

import '../../services/ai_food_service.dart';
import '../../utils/app_colors.dart';
import 'camera_capture_screen.dart';
import 'food_result_screen.dart';

class FoodScannerScreen extends StatefulWidget {
  const FoodScannerScreen({super.key});

  @override
  State<FoodScannerScreen> createState() => _FoodScannerScreenState();
}

class _FoodScannerScreenState extends State<FoodScannerScreen> {
  final _picker = ImagePicker();
  bool _analyzing = false;

  Future<void> _chooseImage(ImageSource source) async {
    try {
      final picked =
          source == ImageSource.camera &&
              defaultTargetPlatform == TargetPlatform.windows
          ? await Navigator.of(context).push<XFile>(
              MaterialPageRoute<XFile>(
                builder: (_) => const CameraCaptureScreen(),
              ),
            )
          : await _picker.pickImage(
              source: source,
              imageQuality: 85,
              maxWidth: 1600,
            );
      if (picked == null || !mounted) return;
      setState(() => _analyzing = true);
      final bytes = await picked.readAsBytes();
      final food = await AiFoodService().analyzeBytes(
        bytes,
        mimeType: picked.mimeType ?? 'image/jpeg',
      );
      if (!mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => FoodResultScreen(
            food: food,
            imageBytes: bytes,
            imageMimeType: picked.mimeType ?? 'image/jpeg',
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Food analysis failed: $error')));
    } finally {
      if (mounted) setState(() => _analyzing = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Scan your food')),
    body: SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: Column(
              children: [
                Container(
                  height: 230,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.photo_camera_outlined,
                        size: 74,
                        color: AppColors.primary,
                      ),
                      SizedBox(height: 12),
                      Text(
                        'A quick snap, a helpful estimate',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Take a photo of your meal and AI will estimate the '
                  'food, serving size, calories, and macros.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.muted, height: 1.5),
                ),
                const SizedBox(height: 12),
                const Text(
                  'AI estimates are approximate. Review and adjust before saving.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: AppColors.muted),
                ),
                const SizedBox(height: 24),
                if (_analyzing) ...[
                  const CircularProgressIndicator(),
                  const SizedBox(height: 12),
                  const Text('Looking at your meal...'),
                ] else ...[
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: FilledButton.icon(
                      onPressed: () => _chooseImage(ImageSource.camera),
                      icon: const Icon(Icons.camera_alt_outlined),
                      label: const Text('Take a photo'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton.icon(
                      onPressed: () => _chooseImage(ImageSource.gallery),
                      icon: const Icon(Icons.photo_library_outlined),
                      label: const Text('Choose from gallery'),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

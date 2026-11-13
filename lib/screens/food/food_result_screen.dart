import 'dart:typed_data';

import 'package:material_ui/material_ui.dart';

import '../../models/food_model.dart';
import '../../utils/app_colors.dart';
import 'add_food_screen.dart';

class FoodResultScreen extends StatelessWidget {
  const FoodResultScreen({
    required this.food,
    required this.imageBytes,
    required this.imageMimeType,
    super.key,
  });

  final FoodModel food;
  final Uint8List imageBytes;
  final String imageMimeType;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Your estimate')),
    body: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Image.memory(
            imageBytes,
            height: 230,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          food.foodName,
          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
        ),
        Text(
          '${food.servingSize} · ${food.mealType}',
          style: const TextStyle(color: AppColors.muted),
        ),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              Text(
                '${food.calories.round()}',
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
              const Text('estimated calories'),
              const Divider(height: 28),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _Macro(label: 'Protein', grams: food.protein),
                  _Macro(label: 'Carbs', grams: food.carbohydrates),
                  _Macro(label: 'Fat', grams: food.fat),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        const Text(
          'This is an AI estimate, not a nutritional measurement. Edit any values before adding it to your diary.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.muted, fontSize: 12),
        ),
        const SizedBox(height: 22),
        FilledButton(
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => AddFoodScreen(
                initialFood: food,
                imageBytes: imageBytes,
                imageMimeType: imageMimeType,
              ),
            ),
          ),
          child: const Text('Review and save'),
        ),
      ],
    ),
  );
}

class _Macro extends StatelessWidget {
  const _Macro({required this.label, required this.grams});

  final String label;
  final double grams;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(
        '${grams.round()} g',
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
      Text(label, style: const TextStyle(color: AppColors.muted)),
    ],
  );
}

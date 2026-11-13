import 'dart:convert';
import 'dart:typed_data';

import 'package:firebase_ai/firebase_ai.dart';
import 'package:image_picker/image_picker.dart';

import '../models/food_model.dart';

class AiFoodService {
  AiFoodService({GenerativeModel? model})
    : _model =
          model ??
          FirebaseAI.googleAI().generativeModel(
            model: 'gemini-3.8-flash',
            generationConfig: GenerationConfig(
              responseMimeType: 'application/json',
              temperature: 0.2,
            ),
          );

  final GenerativeModel _model;

  Future<FoodModel> analyzeImage(XFile image) async {
    final bytes = await image.readAsBytes();
    return analyzeBytes(bytes, mimeType: _mimeType(image.name));
  }

  Future<FoodModel> analyzeBytes(
    Uint8List bytes, {
    String mimeType = 'image/jpeg',
  }) async {
    final response = await _model.generateContent([
      Content.multi([
        TextPart(
          'Identify the visible food and estimate nutrition for the portion '
          'shown. Return only JSON with keys foodName, calories, protein, '
          'carbohydrates, fat, servingSize, mealType. Use numeric values for '
          'nutrients, calories in kcal, grams for macros. mealType must be '
          'Breakfast, Lunch, Dinner, or Snack. Estimates are approximate.',
        ),
        InlineDataPart(mimeType, bytes),
      ]),
    ]);
    final text = response.text;
    if (text == null || text.trim().isEmpty) {
      throw const FormatException(
        'The image could not be analyzed. Try a clearer food photo.',
      );
    }
    final decoded = jsonDecode(text) as Map<String, dynamic>;
    final calories = _number(decoded['calories']);
    if (calories <= 0 || decoded['foodName'] == null) {
      throw const FormatException(
        'The AI did not return a usable food estimate. Please try again.',
      );
    }
    return FoodModel(
      id: '',
      foodName: decoded['foodName'].toString(),
      calories: calories,
      protein: _number(decoded['protein']),
      carbohydrates: _number(decoded['carbohydrates']),
      fat: _number(decoded['fat']),
      servingSize: decoded['servingSize']?.toString() ?? '1 serving',
      mealType: _mealType(decoded['mealType']?.toString()),
      foodDate: DateTime.now(),
    );
  }

  double _number(Object? value) =>
      value is num ? value.toDouble() : double.tryParse('$value') ?? 0;

  String _mealType(String? value) {
    const meals = ['Breakfast', 'Lunch', 'Dinner', 'Snack'];
    return meals.firstWhere(
      (meal) => meal.toLowerCase() == value?.toLowerCase(),
      orElse: () => 'Snack',
    );
  }

  String _mimeType(String path) {
    final extension = path.split('.').last.toLowerCase();
    return switch (extension) {
      'png' => 'image/png',
      'webp' => 'image/webp',
      _ => 'image/jpeg',
    };
  }
}

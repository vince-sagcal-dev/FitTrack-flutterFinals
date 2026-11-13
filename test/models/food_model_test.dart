import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_calorie_tracker/models/food_model.dart';

void main() {
  group('FoodModel', () {
    test('round trips Firestore-compatible values', () {
      final date = DateTime(2026, 11, 13, 12, 30);
      final food = FoodModel(
        id: 'meal-1',
        foodName: 'Grilled chicken',
        calories: 320,
        protein: 42,
        carbohydrates: 8,
        fat: 12,
        servingSize: '150 g',
        mealType: 'Lunch',
        foodDate: date,
        imageUrl: 'https://example.test/meal.jpg',
      );

      final restored = FoodModel.fromMap(food.id, food.toMap());

      expect(restored.id, food.id);
      expect(restored.foodName, food.foodName);
      expect(restored.calories, food.calories);
      expect(restored.foodDate, date);
      expect(restored.imageUrl, food.imageUrl);
    });

    test('uses safe defaults for missing optional stored fields', () {
      final food = FoodModel.fromMap('legacy', {
        'foodName': 'Apple',
        'calories': 95,
        'foodDate': Timestamp.fromDate(DateTime(2026, 1, 2)),
      });

      expect(food.mealType, 'Breakfast');
      expect(food.protein, 0);
      expect(food.imageUrl, isNull);
    });
  });
}

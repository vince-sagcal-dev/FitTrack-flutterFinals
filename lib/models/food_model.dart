import 'package:cloud_firestore/cloud_firestore.dart';

class FoodModel {
  final String id;
  final String foodName;
  final double calories;
  final double protein;
  final double carbohydrates;
  final double fat;
  final String servingSize;
  final String mealType;
  final DateTime foodDate;
  final String? imageUrl;

  const FoodModel({
    required this.id,
    required this.foodName,
    required this.calories,
    required this.protein,
    required this.carbohydrates,
    required this.fat,
    required this.servingSize,
    required this.mealType,
    required this.foodDate,
    this.imageUrl,
  });

  factory FoodModel.fromMap(String id, Map<String, dynamic> map) {
    final rawDate = map['foodDate'];
    final date = rawDate is Timestamp
        ? rawDate.toDate()
        : rawDate is DateTime
        ? rawDate
        : DateTime.tryParse(rawDate?.toString() ?? '') ?? DateTime.now();
    return FoodModel(
      id: id,
      foodName: map['foodName']?.toString() ?? '',
      calories: _number(map['calories']),
      protein: _number(map['protein']),
      carbohydrates: _number(map['carbohydrates']),
      fat: _number(map['fat']),
      servingSize: map['servingSize']?.toString() ?? '',
      mealType: map['mealType']?.toString() ?? 'Breakfast',
      foodDate: date,
      imageUrl: map['imageUrl']?.toString(),
    );
  }

  static double _number(Object? value) =>
      value is num ? value.toDouble() : double.tryParse('$value') ?? 0;

  Map<String, dynamic> toMap() {
    return {
      'foodName': foodName,
      'calories': calories,
      'protein': protein,
      'carbohydrates': carbohydrates,
      'fat': fat,
      'servingSize': servingSize,
      'mealType': mealType,
      'foodDate': Timestamp.fromDate(foodDate),
      'imageUrl': imageUrl,
    };
  }

  FoodModel copyWith({
    String? id,
    String? foodName,
    double? calories,
    double? protein,
    double? carbohydrates,
    double? fat,
    String? servingSize,
    String? mealType,
    DateTime? foodDate,
    String? imageUrl,
  }) => FoodModel(
    id: id ?? this.id,
    foodName: foodName ?? this.foodName,
    calories: calories ?? this.calories,
    protein: protein ?? this.protein,
    carbohydrates: carbohydrates ?? this.carbohydrates,
    fat: fat ?? this.fat,
    servingSize: servingSize ?? this.servingSize,
    mealType: mealType ?? this.mealType,
    foodDate: foodDate ?? this.foodDate,
    imageUrl: imageUrl ?? this.imageUrl,
  );
}

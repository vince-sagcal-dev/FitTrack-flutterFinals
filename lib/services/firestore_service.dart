import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/food_model.dart';

class FirestoreService {
  FirestoreService({FirebaseFirestore? firestore})
    : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> _foods(String uid) =>
      _db.collection('users').doc(uid).collection('foods');

  Stream<List<FoodModel>> watchFoods(String uid) =>
      _foods(uid)
          .orderBy('foodDate', descending: true)
          .snapshots()
          .map(
            (snapshot) => snapshot.docs
                .map((doc) => FoodModel.fromMap(doc.id, doc.data()))
                .toList(),
          );

  Stream<List<FoodModel>> watchFoodsForDay(String uid, DateTime day) {
    final start = DateTime(day.year, day.month, day.day);
    final end = start.add(const Duration(days: 1));
    return _foods(uid)
        .where('foodDate', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('foodDate', isLessThan: Timestamp.fromDate(end))
        .orderBy('foodDate', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => FoodModel.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  Future<String> addFood(String uid, FoodModel food) async {
    final ref = await _foods(uid).add(food.toMap());
    return ref.id;
  }

  Future<void> updateFood(String uid, FoodModel food) =>
      _foods(uid).doc(food.id).update(food.toMap());

  Future<void> deleteFood(String uid, String foodId) =>
      _foods(uid).doc(foodId).delete();
}

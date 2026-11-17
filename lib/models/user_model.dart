import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  const UserModel({
    required this.uid,
    required this.fullName,
    required this.email,
    this.dailyCalorieGoal = 2000,
    this.photoUrl,
    this.age,
    this.weightKg,
    this.heightCm,
    this.sex,
    this.activityLevel,
    this.bodyFatPercent,
  });

  final String uid;
  final String fullName;
  final String email;
  final int dailyCalorieGoal;
  final String? photoUrl;
  final int? age;
  final double? weightKg;
  final double? heightCm;
  final String? sex;
  final String? activityLevel;
  final double? bodyFatPercent;

  factory UserModel.fromMap(String uid, Map<String, dynamic> map) => UserModel(
    uid: uid,
    fullName: map['fullName']?.toString() ?? '',
    email: map['email']?.toString() ?? '',
    dailyCalorieGoal: (map['dailyCalorieGoal'] as num?)?.toInt() ?? 2000,
    photoUrl: map['photoUrl']?.toString(),
    age: (map['age'] as num?)?.toInt(),
    weightKg: (map['weightKg'] as num?)?.toDouble(),
    heightCm: (map['heightCm'] as num?)?.toDouble(),
    sex: map['sex']?.toString(),
    activityLevel: map['activityLevel']?.toString(),
    bodyFatPercent: (map['bodyFatPercent'] as num?)?.toDouble(),
  );

  Map<String, dynamic> toMap() => {
    'fullName': fullName,
    'email': email,
    'dailyCalorieGoal': dailyCalorieGoal,
    'photoUrl': photoUrl,
    if (age != null) 'age': age,
    if (weightKg != null) 'weightKg': weightKg,
    if (heightCm != null) 'heightCm': heightCm,
    if (sex != null) 'sex': sex,
    if (activityLevel != null) 'activityLevel': activityLevel,
    if (bodyFatPercent != null) 'bodyFatPercent': bodyFatPercent,
    'updatedAt': FieldValue.serverTimestamp(),
  };
}

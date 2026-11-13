import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  const UserModel({
    required this.uid,
    required this.fullName,
    required this.email,
    this.dailyCalorieGoal = 2000,
    this.photoUrl,
  });

  final String uid;
  final String fullName;
  final String email;
  final int dailyCalorieGoal;
  final String? photoUrl;

  factory UserModel.fromMap(String uid, Map<String, dynamic> map) => UserModel(
    uid: uid,
    fullName: map['fullName']?.toString() ?? '',
    email: map['email']?.toString() ?? '',
    dailyCalorieGoal: (map['dailyCalorieGoal'] as num?)?.toInt() ?? 2000,
    photoUrl: map['photoUrl']?.toString(),
  );

  Map<String, dynamic> toMap() => {
    'fullName': fullName,
    'email': email,
    'dailyCalorieGoal': dailyCalorieGoal,
    'photoUrl': photoUrl,
    'updatedAt': FieldValue.serverTimestamp(),
  };
}

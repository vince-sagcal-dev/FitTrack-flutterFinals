enum BiologicalSex {
  male('male', 'Male'),
  female('female', 'Female');

  const BiologicalSex(this.key, this.label);

  final String key;
  final String label;
}

enum ActivityLevel {
  sedentary('sedentary', 'Sedentary', 1.2),
  light('light', 'Lightly active', 1.375),
  moderate('moderate', 'Moderately active', 1.55),
  veryActive('veryActive', 'Very active', 1.725),
  extraActive('extraActive', 'Extra active', 1.9);

  const ActivityLevel(this.key, this.label, this.factor);

  final String key;
  final String label;
  final double factor;
}

class CalorieTargets {
  const CalorieTargets({
    required this.restingCalories,
    required this.maintenanceCalories,
    required this.bulkingCalories,
    required this.cuttingCalories,
    required this.usedBodyFat,
  });

  final int restingCalories;
  final int maintenanceCalories;
  final int bulkingCalories;
  final int cuttingCalories;
  final bool usedBodyFat;
}

CalorieTargets calculateCalorieTargets({
  required int age,
  required double weightKg,
  required double heightCm,
  required BiologicalSex sex,
  required ActivityLevel activityLevel,
  double? bodyFatPercent,
}) {
  final restingCalories = bodyFatPercent == null
      ? 10 * weightKg +
            6.25 * heightCm -
            5 * age +
            (sex == BiologicalSex.male ? 5 : -161)
      : 370 + 21.6 * weightKg * (1 - bodyFatPercent / 100);
  final maintenanceCalories = (restingCalories * activityLevel.factor).round();
  final cuttingCalories = maintenanceCalories <= 1000
      ? maintenanceCalories
      : (maintenanceCalories - 500).clamp(1000, 100000).toInt();

  return CalorieTargets(
    restingCalories: restingCalories.round(),
    maintenanceCalories: maintenanceCalories,
    bulkingCalories: maintenanceCalories + 250,
    cuttingCalories: cuttingCalories,
    usedBodyFat: bodyFatPercent != null,
  );
}

import 'package:flutter_test/flutter_test.dart';
import 'package:food_calorie_tracker/utils/calorie_calculator.dart';

void main() {
  group('calculateCalorieTargets', () {
    test(
      'uses the sex-specific Mifflin-St Jeor equation when body fat is absent',
      () {
        final male = calculateCalorieTargets(
          age: 30,
          weightKg: 80,
          heightCm: 180,
          sex: BiologicalSex.male,
          activityLevel: ActivityLevel.moderate,
        );
        final female = calculateCalorieTargets(
          age: 30,
          weightKg: 80,
          heightCm: 180,
          sex: BiologicalSex.female,
          activityLevel: ActivityLevel.moderate,
        );

        expect(male.restingCalories, 1780);
        expect(female.restingCalories, 1614);
        expect(male.maintenanceCalories, 2759);
        expect(male.bulkingCalories, 3009);
        expect(male.cuttingCalories, 2259);
        expect(male.usedBodyFat, isFalse);
      },
    );

    test('does not suggest a cut below the maintenance estimate', () {
      final targets = calculateCalorieTargets(
        age: 80,
        weightKg: 30,
        heightCm: 120,
        sex: BiologicalSex.female,
        activityLevel: ActivityLevel.sedentary,
      );

      expect(targets.maintenanceCalories, lessThan(1000));
      expect(targets.cuttingCalories, targets.maintenanceCalories);
    });

    test('uses body-fat-derived lean mass when body fat is provided', () {
      final targets = calculateCalorieTargets(
        age: 30,
        weightKg: 80,
        heightCm: 180,
        sex: BiologicalSex.female,
        activityLevel: ActivityLevel.sedentary,
        bodyFatPercent: 20,
      );

      expect(targets.restingCalories, 1752);
      expect(targets.maintenanceCalories, 2103);
      expect(targets.usedBodyFat, isTrue);
    });
  });
}

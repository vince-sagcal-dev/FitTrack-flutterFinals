import 'package:flutter_test/flutter_test.dart';
import 'package:food_calorie_tracker/utils/validators.dart';

void main() {
  group('Validators', () {
    test('rejects malformed email and accepts a trimmed address', () {
      expect(Validators.email('not-an-email'), isNotNull);
      expect(Validators.email('  person@example.com  '), isNull);
    });

    test('requires a strong-enough password and positive calories', () {
      expect(Validators.password('short'), isNotNull);
      expect(Validators.password('long-enough'), isNull);
      expect(Validators.positiveNumber('0', label: 'Calories'), isNotNull);
      expect(Validators.positiveNumber('210.5'), isNull);
    });

    test('requires non-negative numeric values for food macros', () {
      expect(
        Validators.requiredNonNegativeNumber('', label: 'Protein'),
        isNotNull,
      );
      expect(
        Validators.requiredNonNegativeNumber('-1', label: 'Protein'),
        isNotNull,
      );
      expect(
        Validators.requiredNonNegativeNumber('0', label: 'Protein'),
        isNull,
      );
      expect(
        Validators.requiredNonNegativeNumber('12.5', label: 'Protein'),
        isNull,
      );
    });
  });
}

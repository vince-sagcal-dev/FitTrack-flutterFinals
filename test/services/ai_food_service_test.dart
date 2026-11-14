import 'dart:typed_data';

import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_calorie_tracker/services/ai_food_service.dart';

void main() {
  test('retries a 503 once and reports a clear temporary failure', () async {
    var attempts = 0;
    final service = AiFoodService(
      contentGenerator: (_) {
        attempts++;
        return Future<GenerateContentResponse>.error(
          FirebaseAIException('Server Error [503]: deadline expired'),
        );
      },
    );

    await expectLater(
      service.analyzeBytes(Uint8List(0)),
      throwsA(
        isA<FirebaseAIException>().having(
          (error) => error.message,
          'message',
          contains('temporarily unavailable'),
        ),
      ),
    );
    expect(attempts, 2);
  });
}

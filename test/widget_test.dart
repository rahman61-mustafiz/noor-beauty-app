import 'package:flutter_test/flutter_test.dart';
import 'package:noor_beauty_app/utils/validators.dart';

void main() {
  group('Validators', () {
    test('validateEmail accepts valid email', () {
      expect(Validators.validateEmail('user@example.com'), isNull);
    });

    test('validateEmail rejects invalid email', () {
      expect(Validators.validateEmail('invalid'), isNotNull);
    });

    test('validatePassword enforces complexity', () {
      expect(Validators.validatePassword('weak'), isNotNull);
      expect(Validators.validatePassword('Strong1!'), isNull);
    });

    test('validatePhone accepts Bangladesh number', () {
      expect(Validators.validatePhone('+8801712345678'), isNull);
    });
  });
}

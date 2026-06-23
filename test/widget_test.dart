import 'package:flutter_test/flutter_test.dart';
import 'package:noor_beauty_app/utils/constants.dart';
import 'package:noor_beauty_app/utils/validators.dart';

void main() {
  group('Validators', () {
    test('validatePhone accepts Bangladesh local number', () {
      expect(Validators.validatePhone('01711726728'), isNull);
      expect(Validators.validatePhone('1711726728'), isNull);
    });

    test('validatePhone accepts international number with country code', () {
      expect(Validators.validatePhone('+14155552671'), isNull);
      expect(Validators.validatePhone('00441234567890'), isNull);
    });

    test('validatePhone rejects foreign number without country code', () {
      expect(Validators.validatePhone('4155552671'), isNotNull);
    });

    test('validateOtp requires 6 digits', () {
      expect(Validators.validateOtp('123456'), isNull);
      expect(Validators.validateOtp('123'), isNotNull);
    });
  });

  group('AppConstants.normalizePhone', () {
    test('prefixes Bangladesh local numbers with +880', () {
      expect(AppConstants.normalizePhone('01711726728'), '+8801711726728');
      expect(AppConstants.normalizePhone('1711726728'), '+8801711726728');
    });

    test('keeps international numbers with + prefix', () {
      expect(AppConstants.normalizePhone('+14155552671'), '+14155552671');
    });

    test('converts 00 prefix to +', () {
      expect(AppConstants.normalizePhone('00441234567890'), '+441234567890');
    });

    test('throws for foreign numbers without country code', () {
      expect(
        () => AppConstants.normalizePhone('4155552671'),
        throwsFormatException,
      );
    });
  });
}

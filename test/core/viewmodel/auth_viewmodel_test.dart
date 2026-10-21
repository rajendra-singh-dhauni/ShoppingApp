import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import '../../../lib/core/viewmodel/auth_viewmodel.dart';

void main() {
  setUp(() {
    Get.testMode = true;
  });

  tearDown(() {
    Get.reset();
  });

  // CR-001: biometric availability and OS cancellation preserve normal sign-in.
  test('biometric unlock reports unavailable devices', () async {
    final viewModel = AuthViewModel(
      availabilityCheck: () async => false,
      onMessage: (_, __) {},
    );

    expect(await viewModel.authenticateWithBiometrics(), isFalse);
  });

  test('biometric cancellation does not unlock the session', () async {
    final viewModel = AuthViewModel(
      availabilityCheck: () async => true,
      authentication: () async => false,
      onMessage: (_, __) {},
    );

    expect(await viewModel.authenticateWithBiometrics(), isFalse);
  });

  test('local success without a valid Firebase session stays locked', () async {
    final viewModel = AuthViewModel(
      availabilityCheck: () async => true,
      authentication: () async => true,
      sessionValidator: () async => false,
      onMessage: (_, __) {},
    );

    expect(await viewModel.authenticateWithBiometrics(), isFalse);
  });

  test('valid existing session unlocks after biometrics succeed', () async {
    var continued = false;
    final viewModel = AuthViewModel(
      availabilityCheck: () async => true,
      authentication: () async => true,
      sessionValidator: () async => true,
      onAuthenticated: () => continued = true,
    );

    expect(await viewModel.authenticateWithBiometrics(), isTrue);
    expect(continued, isTrue);
  });
}

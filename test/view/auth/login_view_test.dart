import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import '../../../lib/core/viewmodel/auth_viewmodel.dart';
import '../../../lib/view/auth/login_view.dart';

void main() {
  // CR-001: biometric unlock is offered without removing existing sign-in paths.
  testWidgets('login keeps biometric, email, Facebook, and Google options',
      (tester) async {
    Get.testMode = true;
    Get.put(AuthViewModel());

    await tester.pumpWidget(GetMaterialApp(home: LoginView()));

    expect(find.text('Unlock with biometrics'), findsOneWidget);
    expect(find.text('SIGN IN'), findsOneWidget);
    expect(find.text('Sign In with Facebook'), findsOneWidget);
    expect(find.text('Sign In with Google'), findsOneWidget);

    Get.reset();
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import '../../lib/core/viewmodel/cart_viewmodel.dart';
import '../../lib/model/cart_model.dart';
import '../../lib/view/cart_view.dart';

// CR-001: verify coupon entry, application, failure, and cancellation on CartView.
void main() {
  late _FakeCartViewModel cartViewModel;

  setUp(() {
    Get.testMode = true;
    cartViewModel = _FakeCartViewModel();
    Get.put<CartViewModel>(cartViewModel);
  });

  tearDown(() {
    Get.reset();
  });

  Future<void> pumpCart(WidgetTester tester) async {
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(375, 812),
        builder: () => GetMaterialApp(home: CartView()),
      ),
    );
    await tester.pump();
  }

  testWidgets('applies SAVE10 and shows the discounted cart total', (tester) async {
    await pumpCart(tester);
    await tester.tap(find.text('Apply Coupon'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'SAVE10');
    await tester.tap(find.text('Apply').last);
    await tester.pump();

    expect(find.text('\$90.0'), findsOneWidget);
    expect(find.text('Coupon applied'), findsOneWidget);
  });

  testWidgets('invalid code keeps the total unchanged and cancel does not apply', (tester) async {
    await pumpCart(tester);
    await tester.tap(find.text('Apply Coupon'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'INVALID');
    await tester.tap(find.text('Apply').last);
    await tester.pump();

    expect(find.text('\$100.0'), findsOneWidget);
    expect(find.text('Invalid coupon'), findsOneWidget);

    await tester.tap(find.text('Apply Coupon'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pump();

    expect(find.text('\$100.0'), findsOneWidget);
  });
}

class _FakeCartViewModel extends CartViewModel {
  final List<CartModel> _products = [
    CartModel.fromJson({
      'name': 'Test item',
      'image': '',
      'price': 100.0,
      'productId': 'test-item',
      'quantity': 1,
    }),
  ];
  double _totalPrice = 100;

  @override
  // ignore: must_call_super
  void onInit() {}

  @override
  List<CartModel> get cartProducts => _products;

  @override
  double get totalPrice => _totalPrice;

  @override
  bool applyCoupon(String code) {
    if (code.trim().toUpperCase() != CartViewModel.couponCode) {
      return false;
    }
    _totalPrice = CartViewModel.calculateDiscountedTotal(100, code);
    update();
    return true;
  }
}

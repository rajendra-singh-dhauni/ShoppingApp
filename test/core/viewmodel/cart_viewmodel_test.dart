import 'package:flutter_test/flutter_test.dart';

import '../../../lib/core/viewmodel/cart_viewmodel.dart';

// CR-001: coupon validation and discounted-total calculation.
void main() {
  test('SAVE10 applies a rounded ten percent discount', () {
    expect(CartViewModel.calculateDiscountedTotal(100, 'SAVE10'), 90);
    expect(CartViewModel.calculateDiscountedTotal(19.99, ' save10 '), 17.99);
  });

  test('invalid coupon codes leave the subtotal unchanged', () {
    expect(CartViewModel.calculateDiscountedTotal(100, 'UNKNOWN'), 100);
  });

  test('a coupon cannot be applied to an empty cart', () {
    expect(CartViewModel().applyCoupon('SAVE10'), isFalse);
  });
}

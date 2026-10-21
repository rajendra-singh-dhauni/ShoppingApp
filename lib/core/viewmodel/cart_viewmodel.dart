import 'package:get/get.dart';

import '../services/local_database_cart.dart';
import '../../model/cart_model.dart';

class CartViewModel extends GetxController {
  List<CartModel> _cartProducts = [];

  List<CartModel> get cartProducts => _cartProducts;

  double _totalPrice = 0;

  double get totalPrice => _totalPrice;

  @override
  void onInit() {
    super.onInit();
    getCartProducts();
  }

  getCartProducts() async {
    _cartProducts = await LocalDatabaseCart.db.getAllProducts();
    getTotalPrice();
    update();
  }

  addProduct(CartModel cartModel) async {
    bool _isExist = false;
    _cartProducts.forEach((element) {
      if (element.productId == cartModel.productId) {
        _isExist = true;
      }
    });
    if (!_isExist) {
      await LocalDatabaseCart.db.insertProduct(cartModel);
      getCartProducts();
    }
  }

  removeProduct(String productId) async {
    await LocalDatabaseCart.db.deleteProduct(productId);
    getCartProducts();
  }

  removeAllProducts() async {
    await LocalDatabaseCart.db.deleteAllProducts();
    getCartProducts();
  }

void getTotalPrice() {
  final subtotal = _cartProducts.fold<double>(
    0,
    (total, product) => total + (double.parse(product.price) * product.quantity),
  );
  if (_cartProducts.isEmpty) {
    _appliedCouponCode = null;
  }
  _totalPrice = calculateDiscountedTotal(subtotal, _appliedCouponCode);
}

  increaseQuantity(int index) async {
    _cartProducts[index].quantity++;
    getTotalPrice();
    await LocalDatabaseCart.db.update(_cartProducts[index]);
    update();
  }

  decreaseQuantity(int index) async {
    if (_cartProducts[index].quantity != 0) {
      _cartProducts[index].quantity--;
      getTotalPrice();
      await LocalDatabaseCart.db.update(_cartProducts[index]);
      update();
    }
  }

  String? _appliedCouponCode;

  static const String couponCode = 'SAVE10';
  static const double couponDiscountRate = 0.10;

  String? get appliedCouponCode => _appliedCouponCode;

  bool applyCoupon(String code) {
    if (_cartProducts.isEmpty || code.trim().toUpperCase() != couponCode) {
      return false;
    }
    _appliedCouponCode = couponCode;
    getTotalPrice();
    update();
    return true;
  }

  static double calculateDiscountedTotal(double subtotal, String? code) {
    if (code?.trim().toUpperCase() != couponCode) {
      return subtotal;
    }
    return (subtotal * (1 - couponDiscountRate) * 100).roundToDouble() / 100;
  }
}

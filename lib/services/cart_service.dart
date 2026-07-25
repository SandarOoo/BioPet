import 'package:flutter/foundation.dart';
import '../models/product.dart';

class CartItem {
  final Product product;
  int quantity;

  CartItem({
    required this.product,
    this.quantity = 1,
  });

  double get lineTotal => product.price * quantity;
}

class CartService extends ChangeNotifier {
  CartService._internal();
  static final CartService _instance = CartService._internal();
  factory CartService() => _instance;

  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);

  bool get isEmpty => _items.isEmpty;

  int get itemCount {
    int count = 0;
    for (final item in _items) {
      count += item.quantity;
    }
    return count;
  }

  double get subtotal {
    double total = 0;
    for (final item in _items) {
      total += item.lineTotal;
    }
    return total;
  }

  void addProduct(Product product, {int quantity = 1}) {
    final index = _items.indexWhere((i) => i.product.id == product.id);

    if (index >= 0) {
      _items[index].quantity += quantity;
    } else {
      _items.add(CartItem(product: product, quantity: quantity));
    }
    notifyListeners();
  }

  void increment(String productId) {
    final index = _items.indexWhere((i) => i.product.id == productId);
    if (index >= 0) {
      _items[index].quantity++;
      notifyListeners();
    }
  }

  void decrement(String productId) {
    final index = _items.indexWhere((i) => i.product.id == productId);
    if (index >= 0 && _items[index].quantity > 1) {
      _items[index].quantity--;
      notifyListeners();
    }
  }

  void remove(String productId) {
    _items.removeWhere((i) => i.product.id == productId);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}
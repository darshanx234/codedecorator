import 'package:flutter/material.dart';
import './cart.dart';

class CartProvider extends ChangeNotifier {
  List<CartItem> _cartItems = [];

  List<CartItem> get items => _cartItems;

  void addToCart(CartItem item) {
    int index = _cartItems.indexWhere((element) => element.sku == item.sku);
    print(item);
    print(index);
    if (index != -1) {
      _cartItems[index].quantity += 1;
      print(_cartItems[index].quantity);
    } else {
      _cartItems.add(item);
    }
    notifyListeners();
  }

  void removeFromCart(CartItem item) {
    _cartItems.remove(item);
    notifyListeners();
  }

  void updateToCart(item) {
    notifyListeners();
  }
}

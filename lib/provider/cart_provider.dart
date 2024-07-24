import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import './cart.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CartProvider extends ChangeNotifier {
  int _cartCount = 0;
  Future<int> fatchcartcount() async {
    Box box = Hive.box('userToken');
    var token = box.get('token');
    var cartToken = box.get('cartToken');
    var rdata = await http.post(
      Uri.parse('https://wecancustomize.com/graphql/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        // 'Authorization': 'Bearer $token'
      },
      body: jsonEncode(<String, String>{
        'query': '''
          {
  cart(cart_id: "$cartToken") {
    total_quantity
   }
}
        ''',
      }),
    );
    // rdata = jsonDecode(rdata.body);

    print(rdata.body);
    int cartquentity = jsonDecode(rdata.body)['data']['cart']['total_quantity'];
    print(cartquentity);

    int cartcount = cartquentity;

    return cartcount;
  }

  CartProvider() {
    initializeCartCount();
    notifyListeners();
  }

  void initializeCartCount() async {
    _cartCount = await fatchcartcount();

    print('cart count $_cartCount');
    // _cartCount = 13;

    notifyListeners();
  }

  int get cartCount => _cartCount;

  void addToCart() {
    _cartCount++;
    notifyListeners();
  }

  void removeFromCart() {
    _cartCount--;
    notifyListeners();
  }

  void addincart(int count) {
    _cartCount = _cartCount + count;
    notifyListeners();
  }

  void refreshCart() {
    initializeCartCount();
    notifyListeners();
  }
}

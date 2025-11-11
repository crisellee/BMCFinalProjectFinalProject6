import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CartItem {
  final String id;
  final String name;
  final double price;
  int quantity;

  CartItem({
    required this.id,
    required this.name,
    required this.price,
    this.quantity = 1,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'quantity': quantity,
    };
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'],
      name: json['name'],
      price: (json['price'] ?? 0.0).toDouble(),
      quantity: json['quantity'] ?? 1,
    );
  }
}

class CartProvider with ChangeNotifier {
  List<CartItem> _items = [];

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<CartItem> get items => _items;

  int get itemCount => _items.fold(0, (total, item) => total + item.quantity);

  double get subtotal =>
      _items.fold(0.0, (total, item) => total + (item.price * item.quantity));

  double get vat => subtotal * 0.12;

  double get totalPriceWithVat => subtotal + vat;

  void addItem(String id, String name, double price, int quantity) {
    final index = _items.indexWhere((item) => item.id == id);
    if (index != -1) {
      _items[index].quantity += quantity;
    } else {
      _items.add(CartItem(id: id, name: name, price: price, quantity: quantity));
    }
    notifyListeners();
  }

  void removeItem(String id) {
    _items.removeWhere((item) => item.id == id);
    notifyListeners();
  }

  Future<void> placeOrder({String paymentMethod = 'GCash'}) async {
    final user = _auth.currentUser;
    if (user == null || _items.isEmpty) return;

    final orderData = {
      'userId': user.uid,
      'items': _items.map((item) => item.toJson()).toList(),
      'subtotal': subtotal,
      'vat': vat,
      'totalPrice': totalPriceWithVat,
      'itemCount': itemCount,
      'paymentMethod': paymentMethod,
      'status': 'Pending',
      'createdAt': FieldValue.serverTimestamp(),
    };

    try {
      await _firestore.collection('orders').add(orderData);
      if (kDebugMode) print('Order placed successfully.');
    } catch (e) {
      if (kDebugMode) print('Error placing order: $e');
      rethrow;
    }
  }

  Future<void> clearCart() async {
    _items = [];
    notifyListeners();
  }
}

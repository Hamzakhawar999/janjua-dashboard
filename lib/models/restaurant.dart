import 'package:flutter/foundation.dart';
import 'food.dart';
import 'cart.dart';

/// ✅ Holds the user-selected delivery location
class UserLocation {
  final String address; // Always English / Roman English
  final double latitude;
  final double longitude;

  UserLocation({
    required this.address,
    required this.latitude,
    required this.longitude,
  });

  Map<String, dynamic> toMap() => {
        "address": address,
        "latitude": latitude,
        "longitude": longitude,
      };
}

/// ✅ Restaurant model with cart + user location
class Restaurant extends ChangeNotifier {
  final String id;
  final String name;
  final String deliverTo;
  final double deliveryFee;
  final int minDeliveryMinutes;
  final int maxDeliveryMinutes;
  final List<Food> menu;

  List<CartItem> cart = [];
  UserLocation? _userLocation;

  Restaurant({
    required this.id,
    required this.name,
    required this.deliverTo,
    required this.deliveryFee,
    required this.minDeliveryMinutes,
    required this.maxDeliveryMinutes,
    required this.menu,
  });

  UserLocation? get userLocation => _userLocation;

  /// ✅ Update user location (cleans non-English chars)
  void setUserLocation({
    required String address,
    required double latitude,
    required double longitude,
  }) {
    final cleanAddress = address.replaceAll(RegExp(r'[^\x00-\x7F]+'), '');
    _userLocation = UserLocation(
      address: cleanAddress,
      latitude: latitude,
      longitude: longitude,
    );
    notifyListeners();
  }

  /// ✅ Menu helpers
  List<String> get categories => menu.map((f) => f.category).toSet().toList();
  List<Food> byCategory(String category) =>
      menu.where((f) => f.category == category).toList();

  /// ✅ Cart management
  void addToCart(Food food, List<AddOn> addons) {
    final index = cart.indexWhere((item) => item.food.id == food.id);
    if (index >= 0) {
      cart[index].quantity += 1;
    } else {
      cart.add(CartItem(food: food, selectedAddons: addons));
    }
    notifyListeners();
  }

  void incrementQuantity(CartItem item) {
    final index = cart.indexOf(item);
    if (index != -1) {
      cart[index].quantity++;
      notifyListeners();
    }
  }

  void decrementQuantity(CartItem item) {
    final index = cart.indexOf(item);
    if (index != -1) {
      if (cart[index].quantity > 1) {
        cart[index].quantity--;
      } else {
        cart.removeAt(index);
      }
      notifyListeners();
    }
  }

  void clearCart() {
    cart.clear();
    notifyListeners();
  }
}

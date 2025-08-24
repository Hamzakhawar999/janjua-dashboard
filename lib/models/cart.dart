import 'food.dart';

class CartItem {
  final Food food;
  final List<AddOn> selectedAddons;
  int quantity;

  CartItem({
    required this.food,
    required this.selectedAddons,
    this.quantity = 1,
  });

  double get totalPrice {
    final addonsPrice =
        selectedAddons.fold(0.0, (sum, addon) => sum + addon.price);
    return (food.price + addonsPrice) * quantity;
  }

  // 🔥 Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      "food": food.toMap(),
      "selectedAddons": selectedAddons.map((a) => a.toMap()).toList(),
      "quantity": quantity,
      "totalPrice": totalPrice,
    };
  }

  // 🔥 Restore from Firestore
  factory CartItem.fromMap(Map<String, dynamic> map) {
    return CartItem(
      food: Food.fromMap(map["food"]),
      selectedAddons: (map["selectedAddons"] as List<dynamic>)
          .map((a) => AddOn.fromMap(a))
          .toList(),
      quantity: map["quantity"] ?? 1,
    );
  }
}

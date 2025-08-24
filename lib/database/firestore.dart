import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_auth/models/restaurant.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final User? _user = FirebaseAuth.instance.currentUser;

  /// ✅ Save user info
  Future<void> saveUserToDatabase(User user) async {
    await _db.collection("users").doc(user.uid).set({
      "name": user.displayName,
      "email": user.email,
      "photoUrl": user.photoURL,
      "createdAt": FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// ✅ Save order with delivery location
  Future<void> saveOrderToDatabase(Restaurant restaurant) async {
    if (_user == null) return;

    final items = restaurant.cart.map((item) {
      return {
        "foodId": item.food.id,
        "name": item.food.name,
        "price": item.food.price,
        "quantity": item.quantity,
        "addons": item.selectedAddons.map((a) => {
              "name": a.name,
              "price": a.price,
            }).toList(),
        "totalPrice": item.totalPrice,
      };
    }).toList();

    final order = {
      "userId": _user!.uid,
      "restaurantId": restaurant.id,
      "restaurantName": restaurant.name,
      // ✅ Use deliverTo consistently
      "deliverTo": restaurant.userLocation?.address ?? restaurant.deliverTo,
      "deliveryLocation": restaurant.userLocation?.toMap(),
      "items": items,
      "totalItems": restaurant.cart.fold(0, (s, i) => s + i.quantity),
      "totalPrice": restaurant.cart.fold(0.0, (s, i) => s + i.totalPrice) +
          restaurant.deliveryFee,
      "deliveryFee": restaurant.deliveryFee,
      "estimatedDeliveryMinutes": {
        "min": restaurant.minDeliveryMinutes,
        "max": restaurant.maxDeliveryMinutes,
      },
      "status": "in_progress",
      "createdAt": FieldValue.serverTimestamp(),
    };

    await _db.collection("orders").add(order);
  }
}

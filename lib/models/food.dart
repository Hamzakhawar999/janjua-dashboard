import 'package:flutter/material.dart';

class AddOn {
  final String name;
  final double price;

  const AddOn({
    required this.name,
    required this.price,
  });

  Map<String, dynamic> toMap() {
    return {
      "name": name,
      "price": price,
    };
  }

  factory AddOn.fromMap(Map<String, dynamic> map) {
    return AddOn(
      name: map["name"],
      price: (map["price"] as num).toDouble(),
    );
  }
}

class Food {
  final String id;
  final String name;
  final String description;
  final double price;
  final String image; // ✅ use "image"
  final String category;
  final bool isAsset;
  final List<AddOn> addons; // ✅ use "addons"

  const Food({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.image,
    required this.category,
    this.isAsset = false,
    this.addons = const [],
  });

  /// ✅ Correct image handling
  ImageProvider get imageProvider =>
      isAsset ? AssetImage(image) : NetworkImage(image) as ImageProvider;

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "name": name,
      "description": description,
      "price": price,
      "image": image,
      "category": category,
      "isAsset": isAsset,
      "addons": addons.map((a) => a.toMap()).toList(),
    };
  }

  factory Food.fromMap(Map<String, dynamic> map) {
    return Food(
      id: map["id"],
      name: map["name"],
      description: map["description"],
      price: (map["price"] as num).toDouble(),
      image: map["image"],
      category: map["category"],
      isAsset: map["isAsset"] ?? false,
      addons: (map["addons"] as List<dynamic>? ?? [])
          .map((a) => AddOn.fromMap(a))
          .toList(),
    );
  }
}

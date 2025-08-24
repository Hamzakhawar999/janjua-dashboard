import 'package:my_auth/models/food.dart';
import 'package:my_auth/models/restaurant.dart';

final sampleRestaurant = Restaurant(
  id: 'resto001',
  name: 'Janjua"s Cafe',
  deliverTo: '123 Main Street, Springfield',
  deliveryFee: 2.99,
  minDeliveryMinutes: 20,
  maxDeliveryMinutes: 40,
  menu: [
    Food(
      id: 'f1',
      name: 'Loaded Sweet Potato Fries',
      description:
          'Savory sweet potato fries loaded with melted cheese, smoky bacon bits, and a dollop of sour cream.',
      price: 4.49,
      image: 'assets/images/burger.jpeg',
      category: 'sides',
      isAsset: true,
      addons: [
        AddOn(name: 'Sour Cream', price: 0.99),
        AddOn(name: 'Bacon Bits', price: 1.49),
        AddOn(name: 'Green Onions', price: 0.99),
      ],
    ),
    Food(
      id: 'f2',
      name: 'Classic Cheeseburger',
      description:
          'Juicy grilled beef patty topped with melted cheddar, lettuce, tomato, and house sauce.',
      price: 7.99,
      image: 'assets/images/burger.jpeg',
      category: 'burgers',
      isAsset: true,
      addons: [
        AddOn(name: 'Extra Cheese', price: 1.50),
        AddOn(name: 'Bacon', price: 2.00),
      ],
    ),
    Food(
      id: 'f3',
      name: 'Caesar Salad',
      description:
          'Crisp romaine lettuce tossed with Caesar dressing, parmesan cheese, and crunchy croutons.',
      price: 5.99,
      image: 'assets/images/burger.jpeg',
      category: 'salads',
      isAsset: true,
      addons: [
        AddOn(name: 'Grilled Chicken', price: 2.99),
        AddOn(name: 'Shrimp', price: 3.49),
      ],
    ),
    Food(
      id: 'f4',
      name: 'Chocolate Cake',
      description:
          'Moist chocolate sponge layered with rich chocolate ganache and topped with chocolate shavings.',
      price: 5.99,
      image: 'assets/images/burger.jpg',
      category: 'dessert',
      isAsset: true,
      addons: [],
    ),
    Food(
      id: 'f5',
      name: 'Iced Coffee',
      description: 'Chilled coffee over ice with a splash of milk.',
      price: 2.49,
      image: 'assets/images/burger.jpg',
      category: 'drinks',
      isAsset: true,
      addons: [
        AddOn(name: 'Vanilla Syrup', price: 0.50),
        AddOn(name: 'Caramel Syrup', price: 0.70),
      ],
    ),
  ],
);

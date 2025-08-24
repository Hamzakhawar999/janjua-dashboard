import 'package:flutter/material.dart';
import 'package:my_auth/pages/card&checkout/DeliveryInProgressPage.dart';
import 'package:provider/provider.dart';
import 'package:my_auth/database/firestore.dart';
import 'package:my_auth/models/restaurant.dart';
import 'package:my_auth/pages/card&checkout/payment_page.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  String selectedPayment = "Cash on Delivery";

  @override
  Widget build(BuildContext context) {
    final restaurant = context.watch<Restaurant>();
    final cartItems = restaurant.cart;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.background,
      appBar: AppBar(
        backgroundColor: cs.background,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: cs.onBackground.withOpacity(0.8)),
        title: Text(
          "Cart",
          style: TextStyle(
            color: cs.onBackground,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
      ),
      body: cartItems.isEmpty
          ? Center(
              child: Text(
                "Cart is empty..",
                style: TextStyle(
                  fontSize: 16,
                  color: cs.onBackground.withOpacity(0.6),
                ),
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Estimated Delivery Time
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: cs.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: cs.outlineVariant),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.delivery_dining, color: cs.primary, size: 40),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Est. Delivery Time",
                                style: TextStyle(
                                    fontSize: 14,
                                    color: cs.onBackground.withOpacity(0.7))),
                            Text(
                              "Standard (${restaurant.minDeliveryMinutes}-${restaurant.maxDeliveryMinutes} mins)",
                              style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                  color: cs.onBackground),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),

               Padding(
  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
  child: Text(
    "${restaurant.name} - ${restaurant.userLocation?.address ?? restaurant.deliverTo}",
    style: TextStyle(
      fontWeight: FontWeight.w600,
      color: cs.onBackground,
    ),
  ),
),

                const SizedBox(height: 20),

                // Cart Items
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) {
                      final item = cartItems[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: Image(
                            image: item.food.imageProvider,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          ),
                          title: Text(item.food.name),
                          subtitle: Text(
                              "\$${item.totalPrice.toStringAsFixed(2)}"),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon:
                                    const Icon(Icons.remove_circle_outline),
                                onPressed: () =>
                                    restaurant.decrementQuantity(item),
                              ),
                              Text("${item.quantity}"),
                              IconButton(
                                icon: const Icon(Icons.add_circle_outline),
                                onPressed: () =>
                                    restaurant.incrementQuantity(item),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Payment method dropdown
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: DropdownButtonFormField<String>(
                    value: selectedPayment,
                    decoration: InputDecoration(
                      labelText: "Payment Method",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    items: ["Cash on Delivery", "Card Payment"]
                        .map((method) => DropdownMenuItem(
                              value: method,
                              child: Text(method),
                            ))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => selectedPayment = value);
                      }
                    },
                  ),
                ),

                // Checkout Button
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () async {
                          final firestore = FirestoreService();

                          // ✅ Save order once before navigating
                          await firestore.saveOrderToDatabase(restaurant);

                          if (selectedPayment == "Card Payment") {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const PaymentPage()),
                            );
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) =>
                                      const DeliveryInProgressPage()),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: cs.primary,
                          foregroundColor: cs.onPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          "Confirm payment and address",
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

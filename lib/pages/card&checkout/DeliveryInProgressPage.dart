import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:my_auth/models/restaurant.dart';
import 'package:intl/intl.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart' as fm;


class DeliveryInProgressPage extends StatelessWidget {
  const DeliveryInProgressPage({super.key});

  @override
  Widget build(BuildContext context) {
    final restaurant = context.watch<Restaurant>();
    final cs = Theme.of(context).colorScheme;

    final now = DateTime.now();
    final deliveryTime =
        now.add(Duration(minutes: restaurant.minDeliveryMinutes));
    final formattedTime = DateFormat.jm().format(deliveryTime);

    // Receipt build
    String receipt = "";
    double totalPrice = 0;
    int totalItems = 0;

    for (var item in restaurant.cart) {
      totalItems += item.quantity;
      totalPrice += item.totalPrice;

      receipt +=
          "${item.quantity} x ${item.food.name} - \$${item.food.price.toStringAsFixed(2)}\n";
      if (item.selectedAddons.isNotEmpty) {
        receipt +=
            "  Add-ons: ${item.selectedAddons.map((a) => "${a.name} (\$${a.price.toStringAsFixed(2)})").join(", ")}\n";
      }
      receipt += "\n";
    }

    return Scaffold(
      backgroundColor: cs.background,
      appBar: AppBar(
        backgroundColor: cs.background,
        elevation: 0,
        iconTheme: IconThemeData(color: cs.onBackground.withOpacity(0.8)),
        centerTitle: true,
        title: Text(
          "Delivery in progress..",
          style: TextStyle(
            color: cs.onBackground,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: SizedBox(
                      height: 200,
                      child: Lottie.asset(
                        "assets/animations/TRUCK.json",
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Center(
                    child: Text(
                      "Thank you for your order!",
                      style: TextStyle(fontSize: 16, color: cs.onBackground),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Center(
                    child: Text(
                      "Here's your receipt.",
                      style: TextStyle(color: cs.onBackground.withOpacity(0.8)),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Center(
                    child: Text(
                      DateFormat("yyyy-MM-dd HH:mm:ss").format(now),
                      style: TextStyle(
                        fontSize: 13,
                        color: cs.onBackground.withOpacity(0.7),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ✅ Delivery location section
                  if (restaurant.userLocation != null) ...[
                    Text(
                      "Delivery Location:",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: cs.onBackground,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      restaurant.userLocation!.address,
                      style: TextStyle(
                        fontSize: 14,
                        color: cs.onBackground.withOpacity(0.85),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 180,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: FlutterMap(
                          options: MapOptions(
                            center: LatLng(
                              restaurant.userLocation!.latitude,
                              restaurant.userLocation!.longitude,
                            ),
                            zoom: 14,
                          ),
                          children: [
                            TileLayer(
                              urlTemplate:
                                  "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                              userAgentPackageName: "com.example.my_auth",
                            ),
                            MarkerLayer(
                              markers: [
                               fm.Marker(
  point: LatLng(
    restaurant.userLocation!.latitude,
    restaurant.userLocation!.longitude,
  ),
  child: const Icon(
    Icons.location_pin,
    color: Colors.red,
    size: 40,
  ),
),

                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // ✅ Receipt box
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: cs.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: cs.outlineVariant),
                    ),
                    child: Text(
                      "$receipt-----------\nTotal Items: $totalItems\nTotal Price: \$${totalPrice.toStringAsFixed(2)}",
                      style: TextStyle(color: cs.onBackground, height: 1.35),
                    ),
                  ),

                  const SizedBox(height: 16),
                  Center(
                    child: Text(
                      "Estimated delivery time is: $formattedTime",
                      style: TextStyle(
                        fontSize: 15,
                        color: cs.onBackground.withOpacity(0.8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Driver Info pinned bottom
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: cs.outlineVariant),
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 24,
                  backgroundImage: AssetImage("assets/images/IMG_6551.jpg"),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text("Hamza Khawar",
                          style: TextStyle(fontWeight: FontWeight.w600)),
                      SizedBox(height: 4),
                      Text("Driver",
                          style: TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.message_outlined),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.call_outlined),
                  onPressed: () {},
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

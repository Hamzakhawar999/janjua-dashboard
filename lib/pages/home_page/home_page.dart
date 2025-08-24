import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_auth/pages/home_page/location_picker_page.dart';
import 'package:provider/provider.dart';

import 'package:my_auth/pages/card&checkout/CartPage.dart';

import '../../component/drawer_page.dart';
import '../../models/food.dart';
import '../../models/restaurant.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});
  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  void signUserOut() async => FirebaseAuth.instance.signOut();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final r = context.watch<Restaurant>();

    // ✅ Categories from restaurant model
    final categories = List<String>.from(r.categories)..sort();

    return DefaultTabController(
      length: categories.isEmpty ? 1 : categories.length,
      child: Scaffold(
        backgroundColor: cs.background,
        appBar: AppBar(
          backgroundColor: cs.background,
          elevation: 0,
          iconTheme: IconThemeData(color: cs.onBackground.withOpacity(0.8)),
          centerTitle: true,
          title: Text(
            r.name,
            style: TextStyle(
              color: cs.onBackground,
              fontWeight: FontWeight.w600,
              fontSize: 22,
              letterSpacing: 0.2,
            ),
          ),
          actions: [
            Stack(
              children: [
                IconButton(
                  tooltip: 'Cart',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CartPage()),
                    );
                  },
                  icon: Icon(
                    Icons.shopping_cart_outlined,
                    color: cs.onBackground.withOpacity(0.8),
                  ),
                ),
                if (r.cart.isNotEmpty)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${r.cart.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Divider(color: cs.outlineVariant, height: 1),
          ),
        ),
        drawer: DrawerPage(signUserOut: signUserOut),

        // ================= BODY =================
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),

            // ✅ Delivery location row
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Deliver now to',
                      style:
                          TextStyle(color: cs.onBackground.withOpacity(0.6))),
                  const SizedBox(height: 6),
                  InkWell(
                    onTap: () async {
                      // Navigate to location picker
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const LocationPickerPage(),
                        ),
                      );
                      setState(() {}); // refresh after returning
                    },
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            r.userLocation?.address ?? r.deliverTo,
                            style: TextStyle(
                              color: cs.onBackground,
                              fontWeight: FontWeight.w700,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Icon(Icons.expand_more,
                            size: 18, color: cs.onBackground),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // ✅ Delivery fee + time
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Container(
                decoration: BoxDecoration(
                  color: cs.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: cs.outlineVariant),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    Expanded(
                      child: _InfoTile(
                        label: 'Delivery Fee',
                        value: '\$${r.deliveryFee.toStringAsFixed(2)}',
                      ),
                    ),
                    Expanded(
                      child: _InfoTile(
                        label: 'Delivery time',
                        value:
                            '${r.minDeliveryMinutes}-${r.maxDeliveryMinutes} min',
                        alignRight: true,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            // ✅ Tab bar (menu categories)
            if (categories.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: TabBar(
                  isScrollable: true,
                  labelColor: cs.onBackground,
                  unselectedLabelColor: cs.onBackground.withOpacity(0.5),
                  indicatorColor: cs.onBackground,
                  indicatorSize: TabBarIndicatorSize.label,
                  labelStyle: const TextStyle(fontWeight: FontWeight.w700),
                  tabs: categories.map((c) => Tab(text: c)).toList(),
                ),
              ),

            // ✅ Menu items list
            Expanded(
              child: categories.isEmpty
                  ? const Center(child: Text("No menu available"))
                  : TabBarView(
                      children: categories.map((c) {
                        final items = r.byCategory(c);
                        return ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                          itemCount: items.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 12),
                          itemBuilder: (_, i) => _FoodRow(food: items[i]),
                        );
                      }).toList(),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// =================== COMPONENTS ===================

class _InfoTile extends StatelessWidget {
  const _InfoTile(
      {required this.value, required this.label, this.alignRight = false});
  final String value;
  final String label;
  final bool alignRight;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textAlign = alignRight ? TextAlign.right : TextAlign.left;

    return Column(
      crossAxisAlignment:
          alignRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(
          value,
          textAlign: textAlign,
          style: TextStyle(
            color: cs.onSurface,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          textAlign: textAlign,
          style: TextStyle(
            color: cs.onSurface.withOpacity(0.6),
            fontSize: 12.5,
          ),
        ),
      ],
    );
  }
}

class _FoodRow extends StatelessWidget {
  const _FoodRow({required this.food});
  final Food food;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return InkWell(
      onTap: () => showFoodDetailsSheet(context, food),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: cs.outlineVariant),
        ),
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      food.name,
                      style: TextStyle(
                        color: cs.onSurface,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '\$${food.price.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: cs.onSurface.withOpacity(0.7),
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      food.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: cs.onSurface.withOpacity(0.75),
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image(
                image: food.imageProvider,
                width: 86,
                height: 86,
                fit: BoxFit.cover,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> showFoodDetailsSheet(BuildContext context, Food food) async {
  final cs = Theme.of(context).colorScheme;
  final selectedAddons = <AddOn>{};

  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: cs.surface,
    barrierColor: Colors.black54,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) {
      return StatefulBuilder(
        builder: (context, setModalState) {
          double totalPrice = food.price +
              selectedAddons.fold(0.0, (sum, addon) => sum + addon.price);

          return DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.75,
            minChildSize: 0.55,
            maxChildSize: 0.95,
            builder: (context, scrollController) {
              return SingleChildScrollView(
                controller: scrollController,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    Center(
                      child: Container(
                        width: 48,
                        height: 5,
                        decoration: BoxDecoration(
                          color: cs.outlineVariant,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: AspectRatio(
                          aspectRatio: 16 / 10,
                          child: Image(
                            image: food.imageProvider,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              food.name,
                              style: TextStyle(
                                color: cs.onSurface,
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          Text(
                            '\$${food.price.toStringAsFixed(2)}',
                            style: TextStyle(
                              color: cs.onSurface,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        food.description,
                        style: TextStyle(
                          color: cs.onSurface.withOpacity(0.8),
                          fontSize: 14.5,
                          height: 1.35,
                        ),
                      ),
                    ),
                    if (food.addons.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'Add-ons',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            color: cs.onSurface,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Column(
                          children: food.addons.map((addon) {
                            final isSelected = selectedAddons.contains(addon);
                            return CheckboxListTile(
                              title: Text(addon.name),
                              subtitle: Text(
                                '\$${addon.price.toStringAsFixed(2)}',
                                style: TextStyle(
                                  color: cs.onSurface.withOpacity(0.7),
                                  fontSize: 13,
                                ),
                              ),
                              value: isSelected,
                              onChanged: (val) {
                                setModalState(() {
                                  if (val == true) {
                                    selectedAddons.add(addon);
                                  } else {
                                    selectedAddons.remove(addon);
                                  }
                                });
                              },
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: SizedBox(
                        width: double.infinity,
                        height: 58,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: cs.tertiary,
                            foregroundColor: cs.onSurface,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(color: cs.outlineVariant),
                            ),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                            context.read<Restaurant>().addToCart(
                                  food,
                                  selectedAddons.toList(),
                                );
                          },
                          child: Text(
                            'Add to cart • \$${totalPrice.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              );
            },
          );
        },
      );
    },
  );
}

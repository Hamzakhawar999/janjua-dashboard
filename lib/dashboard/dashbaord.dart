import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'order_table.dart';
import 'users_table.dart';
import 'widgets.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: cs.background,
      appBar: AppBar(
        backgroundColor: cs.background,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Janjua Café Admin Dashboard",
          style: TextStyle(
            color: cs.onBackground,
            fontWeight: FontWeight.w700,
            fontSize: width < 600 ? 18 : 22,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushReplacementNamed(context, "/auth");
            },
            icon: const Icon(Icons.logout),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(color: cs.outlineVariant, height: 1),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ---------- STATS ----------
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection("users").snapshots(),
              builder: (context, userSnap) {
                return StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection("orders").snapshots(),
                  builder: (context, orderSnap) {
                    if (!userSnap.hasData || !orderSnap.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final totalUsers = userSnap.data!.docs.length;
                    final totalOrders = orderSnap.data!.docs.length;
                    final revenue = orderSnap.data!.docs.fold<double>(
                      0,
                      (sum, doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        final price = data['totalPrice'];
                        return sum + (price is num ? price.toDouble() : 0);
                      },
                    );

                    return Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      alignment: WrapAlignment.center,
                      children: [
                        StatsCard(
                          icon: Icons.people_alt,
                          title: "Users",
                          value: "$totalUsers",
                          color: Colors.green,
                          width: width < 600 ? width * 0.9 : 260,
                        ),
                        StatsCard(
                          icon: Icons.shopping_cart_outlined,
                          title: "Orders",
                          value: "$totalOrders",
                          color: Colors.orange,
                          width: width < 600 ? width * 0.9 : 260,
                        ),
                        StatsCard(
                          icon: Icons.attach_money,
                          title: "Revenue",
                          value: "PKR ${revenue.toStringAsFixed(0)}",
                          color: Colors.blue,
                          width: width < 600 ? width * 0.9 : 260,
                        ),
                      ],
                    );
                  },
                );
              },
            ),

            const SizedBox(height: 32),

            // ---------- ORDERS ----------
            Text("Recent Orders", style: _headerStyle(cs)),
            const SizedBox(height: 16),
            OrderTable(),

            const SizedBox(height: 32),

            // ---------- USERS ----------
            Text("Users", style: _headerStyle(cs)),
            const SizedBox(height: 16),
            UsersTable(),
          ],
        ),
      ),
    );
  }

  static TextStyle _headerStyle(ColorScheme cs) => TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: cs.onBackground,
      );
}

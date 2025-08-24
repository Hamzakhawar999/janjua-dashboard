import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth_page.dart'; // <-- adjust path if auth_page.dart is in another folder

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

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
            fontSize: 22,
          ),
        ),
        actions: [
          IconButton(
            tooltip: "Logout",
            icon: Icon(Icons.logout, color: cs.onBackground),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text("Confirm Logout"),
                  content: const Text("Are you sure you want to log out?"),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text("Cancel"),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text("Logout"),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const AuthPage()),
                  (route) => false,
                );
              }
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(color: cs.outlineVariant, height: 1),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
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

                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _StatsCard(
                          icon: Icons.people_alt,
                          title: "Users",
                          value: "$totalUsers",
                          color: Colors.green,
                        ),
                        _StatsCard(
                          icon: Icons.shopping_cart_outlined,
                          title: "Orders",
                          value: "$totalOrders",
                          color: Colors.orange,
                        ),
                        _StatsCard(
                          icon: Icons.attach_money,
                          title: "Revenue",
                          value: "PKR ${revenue.toStringAsFixed(0)}",
                          color: Colors.blue,
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
            HoverCard(
              child: Container(
                padding: const EdgeInsets.all(16),
                child: _buildOrdersTable(cs, context),
              ),
            ),

            const SizedBox(height: 32),

            // ---------- USERS ----------
            Text("Users", style: _headerStyle(cs)),
            const SizedBox(height: 16),
            HoverCard(
              child: Container(
                padding: const EdgeInsets.all(16),
                child: _buildUsersTable(cs),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------- ORDERS TABLE ----------
  static Widget _buildOrdersTable(ColorScheme cs, BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection("orders")
          .orderBy("createdAt", descending: true)
          .limit(10)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        if (snapshot.data!.docs.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(20),
            child: Text("No orders found", style: TextStyle(color: cs.onBackground)),
          );
        }

        final orders = snapshot.data!.docs;

        return DataTable(
          columnSpacing: 28,
          horizontalMargin: 20,
          headingRowHeight: 56,
          dataRowHeight: 70,
          headingRowColor: MaterialStateProperty.all(cs.surfaceVariant),
          columns: const [
            DataColumn(label: Text("Order ID")),
            DataColumn(label: Text("Customer")),
            DataColumn(label: Text("Email")),
            DataColumn(label: Text("Location")),
            DataColumn(label: Text("Total")),
            DataColumn(label: Text("Status")),
          ],
          rows: orders.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final userId = data['userId'];
            final address = data['deliverTo'];
            final total = data['totalPrice'];
            final totalFormatted = (total is num) ? total.toStringAsFixed(2) : "0.00";

            return DataRow(
              onSelectChanged: (_) {
                _showOrderDetails(context, doc.id, data, userId);
              },
              cells: [
                DataCell(_HoverCell(child: Text(doc.id))),
                DataCell(_HoverCell(
                  child: FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance.collection("users").doc(userId).get(),
                    builder: (context, userSnap) {
                      if (!userSnap.hasData) return const Text("...");
                      final userData = userSnap.data!.data() as Map<String, dynamic>?;
                      return Text(userData?['name'] ?? "Unknown");
                    },
                  ),
                )),
                DataCell(_HoverCell(
                  child: FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance.collection("users").doc(userId).get(),
                    builder: (context, userSnap) {
                      if (!userSnap.hasData) return const Text("...");
                      final userData = userSnap.data!.data() as Map<String, dynamic>?;
                      return Text(userData?['email'] ?? "");
                    },
                  ),
                )),
                DataCell(_HoverCell(
                  child: SizedBox(
                    width: 280,
                    child: Text(address ?? "No address", overflow: TextOverflow.ellipsis),
                  ),
                )),
                DataCell(_HoverCell(child: Text("PKR $totalFormatted"))),
                DataCell(_HoverCell(
                  child: Text(
                    data['status'] ?? 'Pending',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: (data['status'] == "delivered")
                          ? Colors.green
                          : (data['status'] == "in_progress")
                              ? Colors.orange
                              : Colors.red,
                    ),
                  ),
                )),
              ],
            );
          }).toList(),
        );
      },
    );
  }

  // ---------- SHOW ORDER DETAILS MODAL ----------
  static void _showOrderDetails(
      BuildContext context, String orderId, Map<String, dynamic> data, String userId) {
    final cs = Theme.of(context).colorScheme;
    final items = (data['items'] as List?) ?? [];

    showDialog(
      context: context,
      builder: (_) => Dialog(
        insetPadding: const EdgeInsets.all(24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(20),
          width: 600,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Order Details",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: cs.onSurface)),
                const SizedBox(height: 16),

                Text("Order ID: $orderId"),
                Text("Status: ${data['status']}"),
                const SizedBox(height: 10),

                FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance.collection("users").doc(userId).get(),
                  builder: (context, snap) {
                    if (!snap.hasData) return const SizedBox();
                    final userData = snap.data!.data() as Map<String, dynamic>?;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Customer: ${userData?['name'] ?? ''}"),
                        Text("Email: ${userData?['email'] ?? ''}"),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 10),

                Text("Delivery To: ${data['deliverTo'] ?? ''}"),
                Text("Delivery Fee: PKR ${data['deliveryFee'] ?? 0}"),
                Text("Total: PKR ${data['totalPrice']}"),
                const SizedBox(height: 20),

                Text("Items:",
                    style: TextStyle(fontWeight: FontWeight.bold, color: cs.primary)),
                const SizedBox(height: 8),

                Column(
                  children: items.map((item) {
                    final i = item as Map<String, dynamic>;
                    final addons = (i['addons'] as List?) ?? [];
                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: cs.surfaceVariant.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("${i['name']} x${i['quantity']}",
                              style: const TextStyle(fontWeight: FontWeight.w600)),
                          Text("Price: PKR ${i['price']}"),
                          if (addons.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Text("Add-ons: ${addons.map((a) => a['name']).join(", ")}"),
                            ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),

                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Close"),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------- USERS TABLE ----------
  static Widget _buildUsersTable(ColorScheme cs) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection("users").snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        if (snapshot.data!.docs.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(20),
            child: Text("No users found", style: TextStyle(color: cs.onBackground)),
          );
        }

        final users = snapshot.data!.docs;

        return DataTable(
          columnSpacing: 28,
          horizontalMargin: 20,
          headingRowHeight: 56,
          dataRowHeight: 70,
          headingRowColor: MaterialStateProperty.all(cs.surfaceVariant),
          columns: const [
            DataColumn(label: Text("Name")),
            DataColumn(label: Text("Email")),
            DataColumn(label: Text("Photo")),
          ],
          rows: users.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return DataRow(cells: [
              DataCell(_HoverCell(child: Text(data['name'] ?? ''))),
              DataCell(_HoverCell(child: Text(data['email'] ?? ''))),
              DataCell(_HoverCell(
                child: data['photoUrl'] != null
                    ? CircleAvatar(
                        backgroundImage: NetworkImage(data['photoUrl']),
                        radius: 22,
                      )
                    : const Icon(Icons.person),
              )),
            ]);
          }).toList(),
        );
      },
    );
  }

  static TextStyle _headerStyle(ColorScheme cs) => TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: cs.onBackground,
      );
}

// ---------- HOVERABLE STATS CARD ----------
class _StatsCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;

  const _StatsCard(
      {required this.icon, required this.title, required this.value, required this.color});

  @override
  State<_StatsCard> createState() => _StatsCardState();
}

class _StatsCardState extends State<_StatsCard> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: _hovering ? (Matrix4.identity()..translate(0, -6, 0)) : Matrix4.identity(),
        margin: const EdgeInsets.symmetric(horizontal: 12),
        width: 260,
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: widget.color,
            width: 1.5,
          ),
          boxShadow: _hovering
              ? [
                  BoxShadow(
                    color: widget.color.withOpacity(0.35),
                    blurRadius: 14,
                    spreadRadius: 2,
                    offset: const Offset(0, 6),
                  )
                ]
              : [],
        ),
        child: Column(
          children: [
            Icon(widget.icon, size: 42, color: widget.color),
            const SizedBox(height: 14),
            Text(widget.title,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: cs.onSurface)),
            const SizedBox(height: 6),
            Text(widget.value,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: cs.onSurface)),
          ],
        ),
      ),
    );
  }
}

// ---------- HOVERABLE CARD FOR FULL SECTIONS ----------
class HoverCard extends StatefulWidget {
  final Widget child;
  const HoverCard({super.key, required this.child});

  @override
  State<HoverCard> createState() => _HoverCardState();
}

class _HoverCardState extends State<HoverCard> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: _hovering ? (Matrix4.identity()..translate(0, -6, 0)) : Matrix4.identity(),
        width: double.infinity,
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: cs.outlineVariant,
            width: 1.5,
          ),
          boxShadow: _hovering
              ? [
                  BoxShadow(
                    color: cs.primary.withOpacity(0.25),
                    blurRadius: 18,
                    spreadRadius: 2,
                    offset: const Offset(0, 6),
                  )
                ]
              : [],
        ),
        child: widget.child,
      ),
    );
  }
}

// ---------- HOVERABLE CELL (for rows) ----------
class _HoverCell extends StatefulWidget {
  final Widget child;
  const _HoverCell({required this.child});

  @override
  State<_HoverCell> createState() => _HoverCellState();
}

class _HoverCellState extends State<_HoverCell> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: _hovering ? cs.surface.withOpacity(0.08) : Colors.transparent,
          border: Border.all(
            color: _hovering ? cs.primary.withOpacity(0.5) : Colors.transparent,
            width: 1.2,
          ),
          borderRadius: BorderRadius.circular(6),
          boxShadow: _hovering
              ? [
                  BoxShadow(
                    color: cs.primary.withOpacity(0.25),
                    blurRadius: 6,
                    spreadRadius: 1,
                    offset: const Offset(0, 2),
                  )
                ]
              : [],
        ),
        child: widget.child,
      ),
    );
  }
}

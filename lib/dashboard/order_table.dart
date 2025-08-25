import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OrderTable extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final width = MediaQuery.of(context).size.width;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: ConstrainedBox(
        constraints: BoxConstraints(minWidth: width),
        child: StreamBuilder<QuerySnapshot>(
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
                    DataCell(Text(doc.id)),
                    DataCell(Text(userId ?? "Unknown")),
                    DataCell(Text(data['email'] ?? "")),
                    DataCell(SizedBox(
                      width: 220,
                      child: Text(address ?? "No address", overflow: TextOverflow.ellipsis),
                    )),
                    DataCell(Text("PKR $totalFormatted")),
                    DataCell(Text(
                      data['status'] ?? 'Pending',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: (data['status'] == "delivered")
                            ? Colors.green
                            : (data['status'] == "in_progress")
                                ? Colors.orange
                                : Colors.red,
                      ),
                    )),
                  ],
                );
              }).toList(),
            );
          },
        ),
      ),
    );
  }

  static void _showOrderDetails(
      BuildContext context, String orderId, Map<String, dynamic> data, String userId) {
    final cs = Theme.of(context).colorScheme;
    final items = (data['items'] as List?) ?? [];
    final isMobile = MediaQuery.of(context).size.width < 600;

    if (isMobile) {
      // ---------- BOTTOM SHEET ----------
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        builder: (_) => _OrderDetails(orderId: orderId, data: data, cs: cs, items: items),
      );
    } else {
      // ---------- DIALOG ----------
      showDialog(
        context: context,
        builder: (_) => Dialog(
          insetPadding: const EdgeInsets.all(24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: _OrderDetails(orderId: orderId, data: data, cs: cs, items: items),
        ),
      );
    }
  }
}

class _OrderDetails extends StatelessWidget {
  final String orderId;
  final Map<String, dynamic> data;
  final List items;
  final ColorScheme cs;

  const _OrderDetails({
    required this.orderId,
    required this.data,
    required this.items,
    required this.cs,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      width: double.infinity,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Order ID: $orderId", style: TextStyle(fontWeight: FontWeight.bold)),
            Text("Status: ${data['status']}"),
            const SizedBox(height: 12),
            Text("Delivery To: ${data['deliverTo'] ?? ''}"),
            Text("Total: PKR ${data['totalPrice']}"),
            const SizedBox(height: 20),

            Text("Items:", style: TextStyle(fontWeight: FontWeight.bold, color: cs.primary)),
            ...items.map((i) => ListTile(
                  title: Text("${i['name']} x${i['quantity']}"),
                  subtitle: Text("PKR ${i['price']}"),
                )),
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
    );
  }
}

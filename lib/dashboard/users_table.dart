import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UsersTable extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final width = MediaQuery.of(context).size.width;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: ConstrainedBox(
        constraints: BoxConstraints(minWidth: width),
        child: StreamBuilder<QuerySnapshot>(
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
                  DataCell(Text(data['name'] ?? '')),
                  DataCell(Text(data['email'] ?? '')),
                  DataCell(
                    data['photoUrl'] != null
                        ? CircleAvatar(
                            backgroundImage: NetworkImage(data['photoUrl']),
                            radius: 22,
                          )
                        : const Icon(Icons.person),
                  ),
                ]);
              }).toList(),
            );
          },
        ),
      ),
    );
  }
}

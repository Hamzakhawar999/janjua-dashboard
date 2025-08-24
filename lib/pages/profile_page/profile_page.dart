import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: cs.background,
      appBar: AppBar(
        backgroundColor: cs.background,
        elevation: 0,
        iconTheme: IconThemeData(color: cs.onBackground.withOpacity(0.8)),
        title: Text(
          "Profile",
          style: TextStyle(
            color: cs.onBackground,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            CircleAvatar(
              radius: 48,
              backgroundColor: cs.primary.withOpacity(0.1),
              child: Icon(Icons.person, size: 50, color: cs.primary),
            ),
            const SizedBox(height: 16),
            Text(
              user?.displayName ?? "Guest User",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: cs.onBackground,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              user?.email ?? "No email available",
              style: TextStyle(
                fontSize: 14,
                color: cs.onBackground.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 30),
            ListTile(
              leading: Icon(Icons.phone, color: cs.primary),
              title: const Text("Phone"),
              subtitle: Text(user?.phoneNumber ?? "Not set"),
            ),
            const Divider(),
            ListTile(
              leading: Icon(Icons.location_on, color: cs.primary),
              title: const Text("Address"),
              subtitle: const Text("Update in settings"),
            ),
          ],
        ),
      ),
    );
  }
}

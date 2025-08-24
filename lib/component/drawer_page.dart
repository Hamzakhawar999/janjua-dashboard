import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_auth/pages/profile_page/profile_page.dart';
import 'package:provider/provider.dart';

import 'package:my_auth/pages/home_page/home_page.dart';
import 'package:my_auth/themes/theme_provider.dart';

class DrawerPage extends StatelessWidget {
  final User? user = FirebaseAuth.instance.currentUser;
  final VoidCallback signUserOut;

  DrawerPage({super.key, required this.signUserOut});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Drawer(
      elevation: 0,
      width: MediaQuery.of(context).size.width * 0.78,
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
        child: Container(
          color: cs.surface,
          child: SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 24),

                Icon(
                  Icons.settings,
                  size: 64,
                  color: cs.onSurfaceVariant,
                ),

                const SizedBox(height: 24),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Divider(color: cs.outlineVariant, thickness: 0.6),
                ),

                const SizedBox(height: 8),

                _DrawerItem(
                  icon: Icons.home_outlined,
                  label: 'HOME',
                  onTap: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (_) => HomePage(title: 'home'),
                      ),
                    );
                  },
                ),
                _DrawerItem(
                  icon: Icons.person_outline,
                  label: 'PROFILE',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => ProfilePage()),
                    );
                  },
                ),

                // Settings now toggles theme directly
                _DrawerItem(
                  icon: Icons.settings_outlined,
                  label: 'TOGGLE THEME',
                  onTap: () {
                    context.read<ThemeProvider>().toggleTheme();
                    Navigator.pop(context); // close drawer
                  },
                ),

                const Spacer(),

                Padding(
                  padding: const EdgeInsets.only(left: 12, bottom: 16),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: signUserOut,
                    child: Row(
                      children: [
                        Icon(Icons.logout_outlined, color: cs.onSurfaceVariant),
                        const SizedBox(width: 8),
                        Text(
                          'LOGOUT',
                          style: TextStyle(
                            letterSpacing: 2,
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return ListTile(
      leading: Icon(icon, color: cs.onSurfaceVariant),
      title: Text(
        label,
        style: TextStyle(
          color: cs.onSurfaceVariant,
          letterSpacing: 4,
        ),
      ),
      horizontalTitleGap: 8,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24),
      onTap: onTap,
    );
  }
}

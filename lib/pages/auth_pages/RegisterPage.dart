import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:my_auth/component/my_TextField.dart';
import 'package:my_auth/component/my_button.dart';
import 'package:my_auth/component/squareTile.dart';
import 'package:my_auth/services/auth_service.dart';

class RegisterPage extends StatefulWidget {
  final VoidCallback ontap;
  const RegisterPage({super.key, required this.ontap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final emailController = TextEditingController();
  final nameController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    nameController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> signUserUp() async {
    if (!mounted) return;

    // loader
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final email = emailController.text.trim();
      final pass = passwordController.text.trim();
      final pass2 = confirmPasswordController.text.trim();

      if (pass != pass2) {
        Navigator.pop(context);
        _showErrorDialog('Passwords do not match. Please try again.');
        return;
      }

      final cred = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: pass);

      if (cred.user != null) {
        // update display name
        final displayName = nameController.text.trim();
        if (displayName.isNotEmpty) {
          await cred.user!.updateDisplayName(displayName);
          await cred.user!.reload();
        }

        // create Firestore doc
        await FirebaseFirestore.instance
            .collection('users')
            .doc(cred.user!.uid)
            .set({
          'uid': cred.user!.uid,
          'email': cred.user!.email,
          'name': displayName.isNotEmpty ? displayName : 'Anonymous',
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      if (mounted) Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      if (mounted) Navigator.pop(context);
      _showErrorDialog(e.message ?? 'Something went wrong. Please try again.');
    } catch (_) {
      if (mounted) Navigator.pop(context);
      _showErrorDialog('Something went wrong. Please try again.');
    }
  }

  void _showErrorDialog(String message) {
    final cs = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: cs.surface,
        title: Text('Error', style: TextStyle(color: cs.onSurface)),
        content: Text(message, style: TextStyle(color: cs.onSurface)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK', style: TextStyle(color: cs.primary)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Title (mirrors login style)
                Text(
                  "Let's Get Started",
                  style: TextStyle(
                    fontSize: 18,
                    color: cs.onBackground,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 24),

                // Name
                MyTextField(
                  controller: nameController,
                  hintText: "Full Name",
                  obscureText: false,
                ),
                const SizedBox(height: 16),

                // Email
                MyTextField(
                  controller: emailController,
                  hintText: "Email",
                  obscureText: false,
                ),
                const SizedBox(height: 16),

                // Password
                MyTextField(
                  controller: passwordController,
                  hintText: 'Password',
                  obscureText: true,
                ),
                const SizedBox(height: 16),

                // Confirm Password
                MyTextField(
                  controller: confirmPasswordController,
                  hintText: 'Confirm Password',
                  obscureText: true,
                ),
                const SizedBox(height: 20),

                // Sign Up button (same slab style & height as login)
                MyButton(
                  text: 'Sign Up',
                  onTap: signUserUp,
                ),
                const SizedBox(height: 28),

                // Divider (theme-aware)
                Row(
                  children: [
                    Expanded(
                      child: Divider(color: cs.outlineVariant, thickness: 0.5),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        'Or continue with',
                        style: TextStyle(color: cs.onBackground),
                      ),
                    ),
                    Expanded(
                      child: Divider(color: cs.outlineVariant, thickness: 0.5),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Social auth tiles (theme-aware)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SquareTile(
                      imagePath: 'assets/images/google_logo.png',
                      // imageColor: Theme.of(context).brightness == Brightness.dark
                      //     ? Colors.white
                      //     : null,
                      ontap: () => AuthService().signInWithGoogle(),
                    ),
                    const SizedBox(width: 12),
                    SquareTile(
                      imagePath: 'assets/images/apple_logo.png',
                      imageColor: Colors.grey[700], // optionally force color
                      ontap: _noop, // replace if you add Apple Sign-In
                    ),
                  ],
                ),
                const SizedBox(height: 26),

                // Already have account?
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account?',
                      style: TextStyle(color: cs.primary),
                    ),
                    const SizedBox(width: 6),
                    GestureDetector(
                      onTap: widget.ontap,
                      child: Text(
                        'Login Now',
                        style: TextStyle(
                          color: cs.onBackground,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// temporary no-op for the Apple tile; replace with your handler when ready
void _noop() {}

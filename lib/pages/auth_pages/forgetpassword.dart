import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_auth/component/my_TextField.dart';
import 'package:my_auth/component/my_button.dart';

class ForgetPassword extends StatefulWidget {
  const ForgetPassword({super.key});

  @override
  State<ForgetPassword> createState() => _ForgetPasswordState();
}

class _ForgetPasswordState extends State<ForgetPassword> {
  final emailController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  Future<void> _passwordReset() async {
    final cs = Theme.of(context).colorScheme;
    final email = emailController.text.trim();

    if (email.isEmpty) {
      _showDialog(
        title: 'Email required',
        message: 'Please enter your email to receive a reset link.',
      );
      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      _showDialog(
        title: 'Link sent',
        message:
            'We’ve emailed a password reset link to\n$email.\nPlease check your inbox (and spam).',
      );
    } on FirebaseAuthException catch (e) {
      _showDialog(
        title: 'Couldn’t send link',
        message: e.message ?? 'Please check the email and try again.',
      );
    } catch (_) {
      _showDialog(
        title: 'Something went wrong',
        message: 'Please try again in a moment.',
      );
    }
  }

  void _showDialog({required String title, required String message}) {
    final cs = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: cs.surface,
        title: Text(title, style: TextStyle(color: cs.onSurface)),
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
      appBar: AppBar(
        backgroundColor: cs.background,
        elevation: 0,
        iconTheme: IconThemeData(color: cs.onBackground),
        title: Text(
          'Reset Password',
          style: TextStyle(color: cs.onBackground, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Title (mirrors login’s typography/spacing)
                Text(
                  'Enter your email',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    color: cs.onBackground,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 24),

                // Email field (same height/radius/padding as login)
                MyTextField(
                  controller: emailController,
                  hintText: 'Email',
                  obscureText: false,
                ),

                const SizedBox(height: 20),

                // Send Link button (same button component as login)
                MyButton(
                  text: 'Send Link',
                  onTap: _passwordReset,
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:firebase_auth/firebase_auth.dart'
    show FirebaseAuth, FirebaseAuthException;
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:my_auth/component/my_TextField.dart';
import 'package:my_auth/component/my_button.dart';
import 'package:my_auth/component/squareTile.dart';
import 'package:my_auth/pages/auth_pages/forgetpassword.dart';
import 'package:my_auth/services/auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({
    super.key,
    required String title,
    required this.ontap,
  });

  final void Function() ontap;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailcontroller = TextEditingController();
  final passwordController = TextEditingController();

  Future<void> signUserIn() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailcontroller.text.trim(),
        password: passwordController.text.trim(),
      );
      if (!mounted) return;
      Navigator.of(context).pop();
    } on FirebaseAuthException catch (e) {
      if (mounted) Navigator.of(context).pop();

      if (e.code == 'user-not-found') {
        _showErrorDialog(
          'Incorrect Email',
          'No user found with this email. Please check and try again.',
        );
      } else if (e.code == 'wrong-password') {
        _showErrorDialog(
          'Incorrect Password',
          'The password is incorrect. Please try again.',
        );
      } else {
        _showErrorDialog(
          'Login Failed',
          'Incorrect email or password. Please try again.',
        );
      }
    }
  }

  void _showErrorDialog(String title, String message) {
    final cs = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: cs.surface,
        title: Text(title, style: TextStyle(color: cs.onSurface)),
        content: Text(message, style: TextStyle(color: cs.onSurface)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.background,
      body: Center(
        child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Truck Animation
                Padding(
                  padding: const EdgeInsets.only(top: 35.0),
                  child: Center(
                    child: SizedBox(
                      width: 360,
                      height: 300,
                      child: Lottie.asset(
                        'assets/animations/TRUCK.json',
                        repeat: true,
                        reverse: false,
                        animate: true,
                      ),
                    ),
                  ),
                ),

                // Title
                Padding(
                  padding: const EdgeInsets.only(bottom: 40.0),
                  child: Text(
                    'Food Delivery App',
                    style: TextStyle(
                      fontSize: 22,
                      color: Colors.grey[400],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                // Email field
                MyTextField(
                  controller: emailcontroller,
                  hintText: "Email",
                  obscureText: false,
                ),
                const SizedBox(height: 16),

                // Password field
                MyTextField(
                  controller: passwordController,
                  hintText: 'Password',
                  obscureText: true,
                ),
                const SizedBox(height: 14),

                // Forgot password link
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ForgetPassword(),
                        ),
                      );
                    },
                    child: Text(
                      'Forgot Password?',
                      style: TextStyle(
                        color: cs.onBackground,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 22),

                // Login button
                MyButton(
                  text: 'LogIn',
                  onTap: signUserIn,
                ),
                const SizedBox(height: 28),

                // Divider
                Row(
                  children: [
                    Expanded(
                        child:
                            Divider(color: cs.outlineVariant, thickness: 0.5)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        'Or continue with',
                        style: TextStyle(color: cs.onBackground),
                      ),
                    ),
                    Expanded(
                        child:
                            Divider(color: cs.outlineVariant, thickness: 0.5)),
                  ],
                ),
                const SizedBox(height: 25),

                // Social buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SquareTile(
                      imagePath: 'assets/images/google_logo.png',
                      ontap: () => AuthService().signInWithGoogle(),
                    ),
                    const SizedBox(width: 10),
                    SquareTile(
                      imagePath: 'assets/images/apple_logo.png',
                      imageColor: Colors.grey[700], // ✅ matches dark theme
                      ontap: () {},
                    ),
                  ],
                ),
                const SizedBox(height: 25),

                // Register link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Not a member?',
                      style: TextStyle(color: cs.primary),
                    ),
                    const SizedBox(width: 5),
                    GestureDetector(
                      onTap: widget.ontap,
                      child: Text(
                        'Register now',
                        style: TextStyle(
                          color: cs.onBackground,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 120,
                )
              ],
            )),
      ),
    );
  }
}

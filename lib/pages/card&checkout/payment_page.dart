import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:my_auth/pages/card&checkout/DeliveryInProgressPage.dart';
import 'package:provider/provider.dart';
import 'package:my_auth/database/firestore.dart';
import 'package:my_auth/models/restaurant.dart';


class PaymentPage extends StatefulWidget {
  const PaymentPage({super.key});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final _formKey = GlobalKey<FormState>();

  String cardNumber = "";
  String expiryDate = "";
  String cvv = "";
  String cardHolder = "";

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.background,
      appBar: AppBar(
        backgroundColor: cs.background,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: cs.onBackground.withOpacity(0.8)),
        title: Text(
          "Checkout",
          style: TextStyle(
            color: cs.onBackground,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card animation
            SizedBox(
              width: double.infinity,
              height: 200,
              child: Lottie.asset(
                "assets/animations/Credit Card Blue.json",
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 24),

            // Payment Form
            Expanded(
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: "Card Number",
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (val) => cardNumber = val,
                        validator: (val) => val == null || val.isEmpty
                            ? "Enter card number"
                            : null,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              decoration: const InputDecoration(
                                labelText: "Expiry Date (MM/YY)",
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.datetime,
                              onChanged: (val) => expiryDate = val,
                              validator: (val) => val == null || val.isEmpty
                                  ? "Enter expiry date"
                                  : null,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              decoration: const InputDecoration(
                                labelText: "CVV",
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              obscureText: true,
                              onChanged: (val) => cvv = val,
                              validator: (val) => val == null || val.isEmpty
                                  ? "Enter CVV"
                                  : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: "Card Holder Name",
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.name,
                        onChanged: (val) => cardHolder = val,
                        validator: (val) => val == null || val.isEmpty
                            ? "Enter card holder name"
                            : null,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Pay Now Button
            SafeArea(
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      final restaurant = context.read<Restaurant>();
                      final firestore = FirestoreService();

                      // ✅ Save order to Firestore
                      await firestore.saveOrderToDatabase(restaurant);

                      // ✅ Navigate to delivery page
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const DeliveryInProgressPage(),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: cs.primary,
                    foregroundColor: cs.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Pay Now",
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

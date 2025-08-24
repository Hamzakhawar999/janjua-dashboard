import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:my_auth/dashboard/dashbaord.dart';
import 'package:my_auth/data/sample_restaurant.dart';
import 'package:provider/provider.dart';

import 'package:my_auth/themes/theme_provider.dart';
import 'package:my_auth/pages/auth_pages/auth_page.dart';
import 'package:my_auth/firebase_options.dart';
import 'package:my_auth/models/restaurant.dart'; // ✅ only keep this

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

 runApp(
  MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ChangeNotifierProvider<Restaurant>(
        create: (_) => sampleRestaurant, // ✅ use the dummy restaurant
      ),
    ],
    child: const MyApp(),
  ),
);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, theme, _) {
        return MaterialApp(
          title: 'Flutter Demo',
          debugShowCheckedModeBanner: false,
          theme: theme.themeData, // uses light/dark from ThemeProvider
          home: const DashboardPage(),
        );
      },
    );
  }
}

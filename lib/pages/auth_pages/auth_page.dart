import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_auth/pages/auth_pages/LoginOrRegisterPage.dart';
import 'package:my_auth/pages/home_page/home_page.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key, required String title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
builder: (context, snapshot) {
  if(snapshot.hasData){
    return HomePage(title: 'home');
  } else {
    return LoginOrRegisterPage(title: 'login');
  }
},
    ));
  }
}
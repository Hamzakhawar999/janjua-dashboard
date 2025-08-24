import 'package:flutter/material.dart';
import 'package:my_auth/pages/auth_pages/RegisterPage.dart';
import 'package:my_auth/pages/auth_pages/login_page.dart';

class LoginOrRegisterPage extends StatefulWidget {
  const LoginOrRegisterPage({super.key, required String title});

  @override
  State<LoginOrRegisterPage> createState() => _LoginOrRegisterPageState();
}

class _LoginOrRegisterPageState extends State<LoginOrRegisterPage> {

bool ShowLoginPage  = true;

void togglePages(){
setState(() {
  ShowLoginPage = !ShowLoginPage; 
});

}
  @override
  Widget build(BuildContext context) {
    if(ShowLoginPage){
      return LoginPage(ontap: togglePages, title: '',);
    }else{
      return RegisterPage(  ontap: togglePages,);
    }
  }
}
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:habit_tracker/auth/login_or_register.dart';
import 'package:habit_tracker/pages/home_page.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            //user is login
            if (snapshot.hasData) {
              return const HomePage();
            }

            //user is NOT logged in
            else {
              return const LoginOrRegister();
            }
          }),
    );
  }
}

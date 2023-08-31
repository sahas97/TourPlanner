import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:island_tour_planner/screens/admin_page.dart';
import 'package:island_tour_planner/screens/home_page.dart';

import 'login_or_register_page.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
            User? user = snapshot.data;
            if (user != null) {
              // If user is logged in, redirect to the appropriate page
              bool isAdmin = user.uid ==
                  'Pkp49AbNgbWB7f0XIyumx69UOWS2'; // Replace 'YOUR_ADMIN_UID' with the actual Admin user UID.
              if (isAdmin) {
                return const AdminPanel();
              } else {
                return const HomePage();
              }
            } else {
              // User is not logged in, show login/register page
              return const LoginOrRegisterPage();
            }
          } else {
            // Show a loading indicator if the connection state is not active
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}

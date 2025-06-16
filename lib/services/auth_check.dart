import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:seedina/login_page/getpage/signinorsignup.dart';
import 'package:seedina/services/auth_service.dart';
import 'package:seedina/services/setupwrapper.dart';

class AuthCheck extends StatelessWidget {
  const AuthCheck({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: AuthService.authStateChanges,
        builder: _authStateBuilder,
      ),
    );
  }

  static Widget _authStateBuilder(BuildContext context, AsyncSnapshot<User?> snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator());
    }
    if (snapshot.hasData && snapshot.data != null) {
      return SetupCheckWrapper(user: snapshot.data!); // If the user is authenticated, proceed to the setup
    } else {
      // If the user is not authenticated, show the login/signup screen
      return SignInOrSignUp();
    }
  }
}

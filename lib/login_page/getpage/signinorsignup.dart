import 'package:flutter/material.dart';
import 'package:seedina/login_page/sign_in.dart';
import 'package:seedina/login_page/sign_up.dart';

class SignInOrSignUp extends StatefulWidget {
  const SignInOrSignUp({super.key});

  @override
  State<SignInOrSignUp> createState() => _SignInOrSignUpState();
}

class _SignInOrSignUpState extends State<SignInOrSignUp> {
  // Boolean to track whether to show the login page or sign up page
  bool showLoginPage = true;

  // Function to toggle between login and sign up pages
  void togglePages() {
    setState(() {
      showLoginPage = !showLoginPage;
    });
  }

  @override
  Widget build(BuildContext context) {

    if (showLoginPage) {
      return SignInPage(onTap: togglePages); // Show login page
    } else {
      return SignUpPage(onTap: togglePages); // Show sign up page
    }

  }
}
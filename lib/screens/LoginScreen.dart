import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  final authProviders = [EmailAuthProvider()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('De Right Place'),
        leading: BackButton(
          onPressed: () => GoRouter.of(context).pop(),
        ),
      ),
      body: SignInScreen(
        providers: authProviders,
        actions: [
          AuthStateChangeAction<SignedIn>((context, state) {
            GoRouter.of(context).go('/');
          }),
        ],
      ),
    );
  }
}

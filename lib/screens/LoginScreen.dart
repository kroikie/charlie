import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  final authProviders = [EmailAuthProvider()];

  @override
  Widget build(BuildContext context) {
    return SignInScreen(
      providers: authProviders,
      actions: [
        AuthStateChangeAction<SignedIn>((context, state) {
          GoRouter.of(context).go('/');
        }),
      ],
    );
  }
}

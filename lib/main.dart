import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/models/company.dart';
import 'package:myapp/screens/DetailScreen.dart';
import 'package:myapp/screens/EditScreen.dart';
import 'package:myapp/screens/HomeScreen.dart';
import 'package:myapp/screens/LoginScreen.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

final GoRouter _router = GoRouter(
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) {
        return const HomeScreen(title: 'Charlie',);
      },
      routes: <RouteBase>[
        GoRoute(
          path: 'details/:companyId',
          builder: (BuildContext context, GoRouterState state) {
            final wasteCompany = state.extra as WasteCompany;
            return DetailScreen(company: wasteCompany);
          },
          routes: <RouteBase>[
            GoRoute(
              name: 'edit_company',
              path: 'edit',
              builder: (BuildContext context, GoRouterState state) {
                final wasteCompany = state.extra as WasteCompany;
                return EditScreen(company: wasteCompany);
              }
            )
          ],
        )
      ]
    ),
    GoRoute(
        path: '/login',
        builder: (BuildContext context, GoRouterState state) {
          return LoginScreen();
        }
    ),
  ]
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return StreamProvider<List<WasteCompany>>(
      initialData: const [],
      create: (_) => WasteCompanyModel().stream,
      child: MaterialApp.router(
          routerConfig: _router
      ),
    );
  }
}



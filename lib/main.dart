import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/models/company.dart';
import 'package:myapp/screens/AddScreen.dart';
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
      name: 'home',
      path: '/',
      builder: (BuildContext context, GoRouterState state) {
        return const HomeScreen(title: 'Charlie',);
      },
      routes: <RouteBase>[
        GoRoute(
          name: 'detail',
          path: 'details/:companyId',
          builder: (BuildContext context, GoRouterState state) {
            return DetailScreen(companyId: state.pathParameters['companyId']!);
          },
          routes: <RouteBase>[
            GoRoute(
              name: 'edit_company',
              path: 'edit',
              builder: (BuildContext context, GoRouterState state) {
                return EditScreen(companyId: state.pathParameters['companyId']!);
              }
            )
          ],
        ),
        GoRoute(
          name: 'add_company',
          path: 'add',
          builder: (BuildContext context, GoRouterState state) {
            return const AddScreen();
          }
        ),
      ]
    ),
    GoRoute(
      name: 'login',
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



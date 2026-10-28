import 'package:flutter/material.dart';
import './app/app_routes.dart';
//import './pages/splash_page.dart';
//import 'pages/profile_page.dart';
import 'app/app_router.dart';
import 'app/log_observer.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Kartu Profil Digital',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
      routerConfig: appRouter,
    );
  }
}
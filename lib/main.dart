import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:wallpaperapp/loginPage.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await Supabase.initialize(
    url: 'https://psprryrpxttgheivzsvd.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBzcHJyeXJweHR0Z2hlaXZ6c3ZkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzQ0OTIyNzcsImV4cCI6MjA1MDA2ODI3N30.r2pxGPrW4qMVqSK-Y8fV2XhSXvrTPsqNKBt0PTvBRL8',
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NodeWally',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      // Automatically follow system theme
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light, // Light theme settings
        ),
        useMaterial3: true,
        textTheme: GoogleFonts.poppinsTextTheme(),
        appBarTheme: AppBarTheme(
          iconTheme: IconThemeData(color: Colors.black),
          titleTextStyle: GoogleFonts.playfairDisplay(
            color: Colors.black,
            fontSize: 24,
          ),
        ),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark, // Dark theme settings
        ),
        useMaterial3: true,
        textTheme: GoogleFonts.poppinsTextTheme().apply(
          bodyColor: Colors.white, // White text in dark theme
          displayColor: Colors.white,
        ),
        appBarTheme: AppBarTheme(
          iconTheme: IconThemeData(color: Colors.white),
          titleTextStyle: GoogleFonts.playfairDisplay(
            color: Colors.white,
            fontSize: 24,
          ),
          backgroundColor: Colors.black,
        ),
      ),

      home: loginPage(),
    );
  }
}

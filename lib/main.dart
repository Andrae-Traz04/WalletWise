import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // Import dotenv
import 'pages/login_page.dart';
import 'pages/home_page.dart'; // Import Home Page
import 'package:firebase_auth/firebase_auth.dart'; // Import Auth to check login status

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 1. Load the .env file
  await dotenv.load(fileName: ".env");

  // 2. Initialize Firebase using values from .env
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: dotenv.env['API_KEY']!,
      appId: dotenv.env['APP_ID']!,
      messagingSenderId: dotenv.env['MESSAGING_SENDER_ID']!,
      projectId: dotenv.env['PROJECT_ID']!,
      storageBucket: dotenv.env['STORAGE_BUCKET'],
      databaseURL: dotenv.env['DATABASE_URL'],
      authDomain: dotenv.env['AUTH_DOMAIN'], // Important for Realtime DB
    ),
  );
  
  runApp(const BudgetBuddyApp());
}

class BudgetBuddyApp extends StatelessWidget {
  const BudgetBuddyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'WalletWise',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4CAF50)),
        useMaterial3: true,
      ),
      // Check if user is already logged in
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            // User is logged in, verify if their profile exists or just go home
            return HomePage(username: snapshot.data!.displayName ?? "Student");
          }
          return const LoginPage();
        },
      ),
    );
  }
}
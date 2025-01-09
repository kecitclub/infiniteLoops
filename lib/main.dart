import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'symptoms_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp();

    // Optional: Enable database logging for debugging
    FirebaseDatabase.instance.setLoggingEnabled(true);

    print("Firebase initialized successfully");
    runApp(const MyApp());
  } catch (e) {
    print("Firebase initialization error: $e");
    rethrow;
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Medical App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const SymptomsPage(),
    );
  }
}

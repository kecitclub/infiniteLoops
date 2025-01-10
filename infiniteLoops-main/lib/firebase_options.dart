import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    return const FirebaseOptions(
      apiKey: 'YOUR-ACTUAL-API-KEY',
      appId: 'YOUR-ACTUAL-APP-ID',
      messagingSenderId: 'YOUR-ACTUAL-SENDER-ID',
      projectId: 'YOUR-ACTUAL-PROJECT-ID',
      databaseURL: 'YOUR-DATABASE-URL',
      storageBucket: 'YOUR-ACTUAL-BUCKET',
    );
  }
} 
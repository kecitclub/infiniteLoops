import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    return const FirebaseOptions(
      apiKey: 'AIzaSCmdfwa9BPUC6xeNFd0KPXOGClqOysDl3cy',
      appId: '1:278079399793:android:adc962ee33807cd7f878d0',
      messagingSenderId: '278079399793',
      projectId: 'swasthasewa-final',
      databaseURL: 'https://swasthasewa-final-default-rtdb.firebaseio.com',
      storageBucket: 'swasthasewa-final.appspot.com',
    );
  }
} 
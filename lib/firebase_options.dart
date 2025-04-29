import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    // Füge hier andere Plattformen hinzu, falls nötig

    throw UnsupportedError(
      'DefaultFirebaseOptions sind für diese Plattform nicht konfiguriert.',
    );
  }

  static const FirebaseOptions web = FirebaseOptions(
      apiKey: ",
      authDomain: "kinderstory-4e5ee.firebaseapp.com",
      projectId: "kinderstory-4e5ee",
      storageBucket: "kinderstory-4e5ee.firebasestorage.app",
      messagingSenderId: "",
      appId: "",
      measurementId: ""
  );
}

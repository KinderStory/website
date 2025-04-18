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
      apiKey: "AIzaSyCnHnoW-ZGr9jQFnaPcIAcaFdvE1sowGvs",
      authDomain: "kinderstory-4e5ee.firebaseapp.com",
      projectId: "kinderstory-4e5ee",
      storageBucket: "kinderstory-4e5ee.firebasestorage.app",
      messagingSenderId: "477520693450",
      appId: "1:477520693450:web:f94171c43e32df64a68c33",
      measurementId: "G-X3SZ6F2B73"
  );
}
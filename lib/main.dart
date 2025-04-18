import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'firebase_options.dart';
import 'screens/home_page.dart';
import 'utils/constants.dart';

// Für Übersetzungen
class TranslationService extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
    'de_DE': {
      'app_name': 'KinderStory',
      'discover': 'Entdecken',
      'stories': 'Geschichten',
      'characters': 'Charaktere',
      'privacy_policy': 'Datenschutzerklärung',
      'imprint': 'Impressum',
      'delete_account': 'Account löschen',
      'ai_charter': 'KI Charta',
      'store_links': 'Erhältlich in',
      'download_app': 'App herunterladen',
      'featured_stories': 'Aktuelle Geschichten',
      'featured_characters': 'Aktuelle Charaktere',
      'see_all': 'Alle anzeigen',
      'create_story': 'Erstelle deine eigene Geschichte',
      'create_character': 'Erstelle deinen eigenen Charakter',
      'about_app': 'Über KinderStory',
      'app_description': 'KinderStory ist eine App, die personalisierte Geschichten für Kinder erstellt und vorliest.',
      'contact': 'Kontakt',
      'newsletter': 'Newsletter',
      'subscribe': 'Abonnieren',
      'email_placeholder': 'Deine E-Mail-Adresse',
      'subscribe_success': 'Erfolgreich abonniert!',
      'subscribe_error': 'Ein Fehler ist aufgetreten. Bitte versuche es später erneut.',
      'copyright': '© 2025 KinderStory. Alle Rechte vorbehalten.',
    },
    // Englische Übersetzungen (optional)
    'en_US': {
      'app_name': 'KinderStory',
      'discover': 'Discover',
      'stories': 'Stories',
      'characters': 'Characters',
      'privacy_policy': 'Privacy Policy',
      'imprint': 'Imprint',
      'delete_account': 'Delete Account',
      'ai_charter': 'AI Charter',
      'store_links': 'Available on',
      'download_app': 'Download App',
      'featured_stories': 'Featured Stories',
      'featured_characters': 'Featured Characters',
      'see_all': 'See all',
      'create_story': 'Create your own story',
      'create_character': 'Create your own character',
      'about_app': 'About KinderStory',
      'app_description': 'KinderStory is an app that creates personalized stories for children and reads them aloud.',
      'contact': 'Contact',
      'newsletter': 'Newsletter',
      'subscribe': 'Subscribe',
      'email_placeholder': 'Your email address',
      'subscribe_success': 'Successfully subscribed!',
      'subscribe_error': 'An error occurred. Please try again later.',
      'copyright': '© 2025 KinderStory. All rights reserved.',
    },
  };
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // WebView-Plattforminitialisierung nur für echte mobile Geräte, nicht für Web
  // WebView-Code wurde entfernt, da er für Web-Anwendungen nicht notwendig ist

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FlutterSizer(
      builder: (context, orientation, screenType) {
        return GetMaterialApp(
          title: 'KinderStory',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          translations: TranslationService(),
          locale: const Locale('de', 'DE'), // Standard-Sprache
          fallbackLocale: const Locale('en', 'US'),
          home: const HomePage(),
        );
      },
    );
  }
}
// widgets/responsive_app_bar.dart
import 'package:flutter/material.dart';
import '../screens/delete_account.dart';
import '../utils/constants.dart';
import '../screens/home_page.dart';
import '../screens/privacy_screen.dart';
import '../screens/imprint_screen.dart';
import '../screens/ai_charter.dart';


class ResponsiveAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool showBackButton;

  // Optional: Back-Button-Parameter, standardmäßig true für Unterseiten
  const ResponsiveAppBar({Key? key, this.showBackButton = true}) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.bookRed,
      foregroundColor: Colors.white,
      elevation: 2,
      // Nur den Back-Button anzeigen, wenn eine Seite auf dem Stack liegt
      // UND showBackButton true ist
      leading: showBackButton && Navigator.of(context).canPop()
          ? IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.of(context).pop(),
      )
          : null,
      title: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Image.asset(
              'assets/images/logo.png',
              width: 32,
              height: 32,
              fit: BoxFit.cover,
              errorBuilder: (context, error, _) => Container(
                width: 32,
                height: 32,
                color: Colors.white24,
                child: const Icon(Icons.auto_stories, color: Colors.white, size: 20),
              ),
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            'KinderStory',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ],
      ),
      actions: [
        PopupMenuButton<String>(
          icon: const Icon(Icons.menu, color: Colors.white),
          onSelected: (value) {
            // Navigation zu den verschiedenen Seiten
            switch (value) {
              case 'home':
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const HomePage()),
                      (route) => false,  // Entfernt alle Seiten vom Stack
                );
                break;
              case 'privacy':
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => PrivacyScreen()),
                );
                break;
              case 'imprint':
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const ImprintScreen()),
                );
                break;
              case 'ai_charter':
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const AICharterScreen()),
                );
                break;
              case 'delete_account':
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const DeleteAccountScreen()),
                );
                break;
            }
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
            PopupMenuItem<String>(
              value: 'home',
              child: Row(
                children: [
                  const Icon(Icons.home, color: AppColors.bookRed, size: 20),
                  const SizedBox(width: 8),
                  Text('Startseite'),
                ],
              ),
            ),
            const PopupMenuDivider(),
            PopupMenuItem<String>(
              value: 'privacy',
              child: Row(
                children: [
                  const Icon(Icons.privacy_tip, color: AppColors.bookRed, size: 20),
                  const SizedBox(width: 8),
                  Text('Datenschutz'),
                ],
              ),
            ),
            PopupMenuItem<String>(
              value: 'imprint',
              child: Row(
                children: [
                  const Icon(Icons.info, color: AppColors.bookRed, size: 20),
                  const SizedBox(width: 8),
                  Text('Impressum'),
                ],
              ),
            ),
            PopupMenuItem<String>(
              value: 'ai_charter',
              child: Row(
                children: [
                  const Icon(Icons.science, color: AppColors.bookRed, size: 20),
                  const SizedBox(width: 8),
                  Text('KI-Charta'),
                ],
              ),
            ),
            PopupMenuItem<String>(
              value: 'delete_account',
              child: Row(
                children: [
                  const Icon(Icons.delete, color: AppColors.bookRed, size: 20),
                  const SizedBox(width: 8),
                  Text('Konto löschen'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
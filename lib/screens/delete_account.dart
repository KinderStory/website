import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/responsive_app_bar.dart';
import '../utils/constants.dart';
import '../utils/responsive_helper.dart';

class DeleteAccountScreen extends StatelessWidget {
  const DeleteAccountScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgCream,
      appBar: ResponsiveAppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: ResponsiveHelper.getHorizontalPadding(context),
            vertical: 24,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              Icon(
                Icons.delete_forever,
                size: ResponsiveHelper.isDesktop(context) ? 80 : 64,
                color: AppColors.bookRed,
              ),
              const SizedBox(height: 20),
              Text(
                'Account löschen',
                style: TextStyle(
                  fontSize: ResponsiveHelper.isDesktop(context) ? 32 : 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPurple,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'So löschst du deinen Account:',
                        style: TextStyle(
                          fontSize: ResponsiveHelper.isDesktop(context) ? 20 : 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPurple,
                        ),
                      ),
                      const SizedBox(height: 24),

                      const _DeleteStep(
                        number: '1',
                        title: 'In der App anmelden',
                        description: 'Öffne die KinderStory App und melde dich mit deinem Account an.',
                      ),

                      const _DeleteStep(
                        number: '2',
                        title: 'Einstellungen öffnen',
                        description: 'Tippe auf das Profilsymbol in der oberen rechten Ecke und wähle "Einstellungen".',
                      ),

                      const _DeleteStep(
                        number: '3',
                        title: 'Account-Einstellungen',
                        description: 'Scrolle nach unten zu den Account-Einstellungen und tippe auf "Account löschen".',
                      ),

                      const _DeleteStep(
                        number: '4',
                        title: 'Bestätigung',
                        description: 'Bestätige die Löschung deines Accounts. Diese Aktion kann nicht rückgängig gemacht werden.',
                      ),

                      const SizedBox(height: 32),

                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.amber.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  color: Colors.amber.shade800,
                                  size: 24,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Wichtige Informationen',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.amber.shade900,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Mit dem Löschen deines Accounts werden alle deine persönlichen Daten, erstellten Geschichten und Charaktere unwiderruflich gelöscht. Dieser Vorgang kann nicht rückgängig gemacht werden.',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.amber.shade900,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      Center(
                        child: Text(
                          'Alternativ kannst du uns auch eine E-Mail senden:',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade700,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 16),

                      Center(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            launchUrl(Uri.parse('mailto:deletion@kinderstory.app?subject=Account%20Löschung'));
                          },
                          icon: const Icon(Icons.email),
                          label: const Text('E-Mail zur Account-Löschung senden'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.bookRed,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

class _DeleteStep extends StatelessWidget {
  final String number;
  final String title;
  final String description;

  const _DeleteStep({
    Key? key,
    required this.number,
    required this.title,
    required this.description,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.bookRed,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
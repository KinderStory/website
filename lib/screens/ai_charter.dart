import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../widgets/responsive_app_bar.dart';
import '../utils/constants.dart';
import '../utils/responsive_helper.dart';

class AICharterScreen extends StatelessWidget {
  const AICharterScreen({Key? key}) : super(key: key);

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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'KI-Charta',
                style: TextStyle(
                  fontSize: ResponsiveHelper.isDesktop(context) ? 32 : 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPurple,
                ),
              ),
              const SizedBox(height: 16),

              Text(
                'Unsere Grundsätze für verantwortungsvolle KI bei KinderStory',
                style: TextStyle(
                  fontSize: ResponsiveHelper.isDesktop(context) ? 20 : 18,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 32),

              _buildCharterSection(
                context,
                icon: Icons.child_care,
                title: 'Kindgerechte KI',
                content: '''
Unsere KI ist speziell für Kinder entwickelt und bietet altersgerechte, sichere und wertvolle Inhalte. Alle Geschichten werden für die angegebene Altersgruppe optimiert und enthalten keine unangemessenen Inhalte.

Wir sorgen für eine positive Lernumgebung durch:
• Kindgerechte Sprache und Themen
• Positive Rollenbilder und Botschaften
• Förderung von Kreativität und Fantasie
''',
              ),

              _buildCharterSection(
                context,
                icon: Icons.security,
                title: 'Sicherheit & Datenschutz',
                content: '''
Der Schutz der Daten unserer jungen Nutzer hat bei uns höchste Priorität:

• Keine Sammlung persönlicher Daten von Kindern ohne elterliche Zustimmung
• Minimale Datenerfassung zur Funktionalität der App
• Transparente Aufklärung über Datennutzung
• Regelmäßige Sicherheitsaudits unserer KI-Systeme
• Einhaltung aller relevanten Datenschutzbestimmungen (DSGVO, COPPA)
''',
              ),

              _buildCharterSection(
                context,
                icon: Icons.diversity_3,
                title: 'Fairness & Inklusion',
                content: '''
Unsere KI ist so konzipiert, dass sie Vielfalt respektiert und fördert:

• Vermeidung von Stereotypen und Vorurteilen
• Repräsentation verschiedener Kulturen, Identitäten und Fähigkeiten
• Regelmäßige Überprüfung auf unfaire Verzerrungen
• Förderung von Empathie und Verständnis für Unterschiede
''',
              ),

              _buildCharterSection(
                context,
                icon: Icons.auto_fix_high,
                title: 'Transparenz & Kontrolle',
                content: '''
Wir setzen auf Offenheit bezüglich unserer KI-Technologie:

• Klare Information, dass Inhalte KI-generiert sind
• Verständliche Erklärungen, wie unsere KI funktioniert
• Eltern haben volle Kontrolle über die Nutzung
• Möglichkeit zur Anpassung und Korrektur der generierten Inhalte
• Regelmäßige Updates über Verbesserungen unserer KI-Systeme
''',
              ),

              _buildCharterSection(
                context,
                icon: Icons.psychology,
                title: 'Pädagogischer Wert',
                content: '''
Unsere KI unterstützt die Entwicklung von Kindern durch:

• Förderung von Lesekompetenzen
• Anregung der Kreativität und Vorstellungskraft
• Vermittlung positiver Werte und sozialer Kompetenzen
• Unterstützung des spielerischen Lernens
• Zusammenarbeit mit Pädagogen zur Qualitätssicherung
''',
              ),

              _buildCharterSection(
                context,
                icon: Icons.feedback,
                title: 'Kontinuierliche Verbesserung',
                content: '''
Wir verpflichten uns zur ständigen Verbesserung unserer KI:

• Regelmäßiges Feedback von Kindern, Eltern und Pädagogen
• Fortlaufende Forschung zu KI-Ethik im Kinderbereich
• Anpassung an neue wissenschaftliche Erkenntnisse
• Offenheit für Kritik und Vorschläge
• Jährliche Überprüfung und Aktualisierung dieser Charta
''',
              ),

              Container(
                margin: const EdgeInsets.only(top: 40, bottom: 40),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Unser Versprechen',
                      style: TextStyle(
                        fontSize: ResponsiveHelper.isDesktop(context) ? 24 : 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPurple,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Bei KinderStory sind wir der Überzeugung, dass Technologie Kinder bereichern kann, wenn sie verantwortungsvoll eingesetzt wird. Wir verpflichten uns, unsere KI-Technologie stetig zu verbessern und an die Bedürfnisse von Kindern und Familien anzupassen. Diese Charta wird regelmäßig überprüft und aktualisiert, um den höchsten Standards der KI-Ethik und des Kinderschutzes zu entsprechen.',
                      style: TextStyle(
                        fontSize: ResponsiveHelper.isDesktop(context) ? 16 : 14,
                        height: 1.6,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Letzte Aktualisierung: ${DateTime.now().day}.${DateTime.now().month}.${DateTime.now().year}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCharterSection(
      BuildContext context, {
        required IconData icon,
        required String title,
        required String content,
      }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.textPurple.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 28,
                  color: AppColors.textPurple,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: ResponsiveHelper.isDesktop(context) ? 24 : 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPurple,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            content,
            style: TextStyle(
              fontSize: ResponsiveHelper.isDesktop(context) ? 16 : 14,
              height: 1.6,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
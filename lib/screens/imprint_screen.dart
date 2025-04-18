import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../widgets/responsive_app_bar.dart';
import '../utils/constants.dart';
import '../utils/responsive_helper.dart';

class ImprintScreen extends StatelessWidget {
  const ImprintScreen({Key? key}) : super(key: key);

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
                'Impressum',
                style: TextStyle(
                  fontSize: ResponsiveHelper.isDesktop(context) ? 32 : 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPurple,
                ),
              ),
              const SizedBox(height: 32),

              const _ImprintSection(
                title: 'Angaben gemäß § 5 TMG',
                content: '''
Schäfer, Yann Lukas und Klemmer, Robert GbR
Baseler Platz 6
60329 Frankfurt am Main
Deutschland

''',
              ),

              const _ImprintSection(
                title: 'Vertreten durch',
                content: '''
R. Klemmer & L. Schäfer
''',
              ),

              const _ImprintSection(
                title: 'Kontakt',
                content: '''
Telefon: +49 163 632 07 87
E-Mail: info@kinderstory.app
''',
              ),

              const _ImprintSection(
                title: 'Verantwortlich für den Inhalt nach § 55 Abs. 2 RStV',
                content: '''
R. Klemmer & L. Schäfer
Baseler Platz 6
60329 Frankfurt am Main
Deutschland
''',
              ),

              const _ImprintSection(
                title: 'Streitschlichtung',
                content: '''
Die Europäische Kommission stellt eine Plattform zur Online-Streitbeilegung (OS) bereit: https://ec.europa.eu/consumers/odr/

Unsere E-Mail-Adresse finden Sie oben im Impressum.

Wir sind nicht bereit oder verpflichtet, an Streitbeilegungsverfahren vor einer Verbraucherschlichtungsstelle teilzunehmen.
''',
              ),

              const _ImprintSection(
                title: 'Haftung für Inhalte',
                content: '''
Als Diensteanbieter sind wir gemäß § 7 Abs.1 TMG für eigene Inhalte auf diesen Seiten nach den allgemeinen Gesetzen verantwortlich. Nach §§ 8 bis 10 TMG sind wir als Diensteanbieter jedoch nicht verpflichtet, übermittelte oder gespeicherte fremde Informationen zu überwachen oder nach Umständen zu forschen, die auf eine rechtswidrige Tätigkeit hinweisen.
''',
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

class _ImprintSection extends StatelessWidget {
  final String title;
  final String content;

  const _ImprintSection({
    Key? key,
    required this.title,
    required this.content,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Text(
          title,
          style: TextStyle(
            fontSize: ResponsiveHelper.isDesktop(context) ? 24 : 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPurple,
          ),
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
    );
  }
}
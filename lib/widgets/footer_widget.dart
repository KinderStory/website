import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../screens/agb_screen.dart';
import '../screens/privacy_screen.dart';
import '../screens/imprint_screen.dart';
import '../screens/delete_account.dart';
import '../screens/ai_charter.dart';
import '../utils/constants.dart';
import '../utils/responsive_helper.dart';

class FooterWidget extends StatefulWidget {
  const FooterWidget({Key? key}) : super(key: key);

  @override
  State<FooterWidget> createState() => _FooterWidgetState();
}

class _FooterWidgetState extends State<FooterWidget> {
  final TextEditingController _emailController = TextEditingController();
  bool _isSubscribing = false;
  bool _isSubscribed = false;
  String _errorMessage = '';

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  // Demo-Funktion für das Newsletter-Abonnement
  Future<void> _subscribeToNewsletter() async {
    if (_emailController.text.isEmpty || !GetUtils.isEmail(_emailController.text)) {
      setState(() {
        _errorMessage = 'Bitte gib eine gültige E-Mail-Adresse ein.';
      });
      return;
    }

    setState(() {
      _isSubscribing = true;
      _errorMessage = '';
    });

    // Simuliere eine Netzwerkanfrage
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _isSubscribing = false;
      _isSubscribed = true;
      _emailController.clear();
    });

    // Nach 3 Sekunden das Erfolgsbanner ausblenden
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _isSubscribed = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.textPurple.withOpacity(0.95),
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveHelper.getHorizontalPadding(context),
        vertical: 48,
      ),
      child: Responsive(
        mobile: _buildMobileFooter(context),
        tablet: _buildTabletFooter(context),
        desktop: _buildDesktopFooter(context),
      ),
    );
  }

  Widget _buildMobileFooter(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCompanySection(context),
        const SizedBox(height: 32),

        _buildLegalLinksSection(context),
        const SizedBox(height: 32),


        const SizedBox(height: 32),

        _buildSocialSection(context),
        const SizedBox(height: 32),

        _buildCopyrightSection(context),
      ],
    );
  }

  Widget _buildTabletFooter(BuildContext context) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _buildCompanySection(context)),
            Expanded(child: _buildLegalLinksSection(context)),
          ],
        ),
        const SizedBox(height: 40),

        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Expanded(child: _buildSocialSection(context)),
          ],
        ),
        const SizedBox(height: 40),

        _buildCopyrightSection(context),
      ],
    );
  }

  Widget _buildDesktopFooter(BuildContext context) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 3, child: _buildCompanySection(context)),
            Expanded(flex: 2, child: _buildLegalLinksSection(context)),

            Expanded(flex: 2, child: _buildSocialSection(context)),
          ],
        ),
        const SizedBox(height: 48),

        _buildCopyrightSection(context),
      ],
    );
  }

  Widget _buildCompanySection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Image.asset(
              'assets/images/logo.png',
              width: 48,
              height: 48,
            ),
            const SizedBox(width: 12),
            Text(
              'KinderStory',
              style: TextStyle(
                color: Colors.white,
                fontSize: ResponsiveHelper.isDesktop(context) ? 24 : 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          'Personalisierte Kindergeschichten mit der Kraft der Künstlichen Intelligenz',
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: 14,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 16),
        const _FooterContactItem(
          icon: Icons.email,
          text: 'info@kinderstory.app',
        ),
        const SizedBox(height: 8),
        const _FooterContactItem(
          icon: Icons.phone,
          text: '+49 163 6320787',
        ),
        const SizedBox(height: 8),
        const _FooterContactItem(
          icon: Icons.location_on,
          text: 'Baseler Platz 6, 60329 DFrankfurt',
        ),
      ],
    );
  }

  Widget _buildLegalLinksSection(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: ResponsiveHelper.isDesktop(context) ? 24 : 0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Rechtliches',
            style: TextStyle(
              color: Colors.white,
              fontSize: ResponsiveHelper.isDesktop(context) ? 18 : 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          _FooterLink(
            text: 'Datenschutzerklärung',
            onTap: () => Get.to(() =>  PrivacyScreen()),
          ),
          const SizedBox(height: 8),

          _FooterLink(
            text: 'Impressum',
            onTap: () => Get.to(() => const ImprintScreen()),
          ),
          const SizedBox(height: 8),

          _FooterLink(
            text: 'Account löschen',
            onTap: () => Get.to(() => const DeleteAccountScreen()),
          ),
          const SizedBox(height: 8),

          _FooterLink(
            text: 'KI-Charta',
            onTap: () => Get.to(() => const AICharterScreen()),
          ),
          const SizedBox(height: 8),

          _FooterLink(
            text: 'AGB',
            onTap: () => Get.to(() =>  AgbScreen()), // Platzhalter
          ),
          const SizedBox(height: 8),

          _FooterLink(
            text: 'Cookie-Richtlinie',
            onTap: () => Get.to(() =>  PrivacyScreen()), // Platzhalter
          ),
        ],
      ),
    );
  }



  Widget _buildSocialSection(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: ResponsiveHelper.isDesktop(context) ? 24 : 0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Folge uns',
            style: TextStyle(
              color: Colors.white,
              fontSize: ResponsiveHelper.isDesktop(context) ? 18 : 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              // _SocialButton(
              //   icon: Icons.facebook,
              //   onTap: () => launchUrl(Uri.parse('https://facebook.com')),
              // ),
              // const SizedBox(width: 16),
              // _SocialButton(
              //   icon: Icons.tiktok,
              //   onTap: () => launchUrl(Uri.parse('https://tiktok.com')),
              // ),
              // const SizedBox(width: 16),
              _SocialButton(
                icon:  FontAwesomeIcons.instagram,
                onTap: () => launchUrl(Uri.parse('https://instagram.com')),
              ),
              const SizedBox(width: 16),
              // _SocialButton(
              //   icon: Icons.telegram,
              //   onTap: () => launchUrl(Uri.parse('https://telegram.org')),
              // ),
            ],
          ),

          const SizedBox(height: 24),

          Text(
            'Download',
            style: TextStyle(
              color: Colors.white,
              fontSize: ResponsiveHelper.isDesktop(context) ? 18 : 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              InkWell(
                onTap: () => launchUrl(Uri.parse('https://play.google.com/store')),
                child: Image.asset(
                  'assets/images/google-play-badge.png',
                  height: 40,
                ),
              ),
              const SizedBox(width: 16),
              InkWell(
                onTap: () => launchUrl(Uri.parse('https://apps.apple.com')),
                child: Image.asset(
                  'assets/images/apple-badge.png',
                  height: 40,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCopyrightSection(BuildContext context) {
    return Column(
      children: [
        const Divider(color: Colors.white24),
        const SizedBox(height: 20),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '© ${DateTime.now().year} KinderStory. Alle Rechte vorbehalten.',
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _FooterContactItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _FooterContactItem({
    Key? key,
    required this.icon,
    required this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: Colors.white.withOpacity(0.8),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}

class _FooterLink extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const _FooterLink({
    Key? key,
    required this.text,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white.withOpacity(0.8),
          fontSize: 14,
        ),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _SocialButton({
    Key? key,
    required this.icon,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }
}
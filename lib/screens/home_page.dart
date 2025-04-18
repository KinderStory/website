import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kinderstory_website/screens/ai_charter.dart';
import 'package:kinderstory_website/screens/privacy_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../models/global_story_model.dart';
import '../models/global_character_model.dart';
import '../services/global_story_service.dart';
import '../services/global_character_service.dart';
import '../utils/constants.dart'; // Deine constants.dart importieren
import '../widgets/footer_widget.dart';
import '../widgets/responsive_app_bar.dart';
import 'delete_account.dart';
import 'imprint_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _globalStoryService = GlobalStoryService();
  final _globalCharacterService = GlobalCharacterService();

  final List<GlobalStoryModel> _featuredStories = [];
  final List<GlobalCharacterModel> _featuredCharacters = [];

  bool _isLoadingStories = true;
  bool _isLoadingCharacters = true;

  @override
  void initState() {
    super.initState();
    _fetchFeaturedContent();
  }

  Future<void> _fetchFeaturedContent() async {
    try {
      // Geschichten laden
      setState(() {
        _isLoadingStories = true;
      });

      final stories = await _globalStoryService.getGlobalStoriesWithFilters(
        limit: 5,
        sortBy: 'newest',
        descending: true,
        language: 'de',
      );

      if (mounted) {
        setState(() {
          _featuredStories.clear();
          _featuredStories.addAll(stories);
          _isLoadingStories = false;
        });
      }

      // Charaktere laden
      setState(() {
        _isLoadingCharacters = true;
      });

      final characters = await _globalCharacterService.getGlobalCharactersWithFilters(
        limit: 5,
        sortBy: 'newest',
        descending: true,
        language: 'de',
      );

      if (mounted) {
        setState(() {
          _featuredCharacters.clear();
          _featuredCharacters.addAll(characters);
          _isLoadingCharacters = false;
        });
      }
    } catch (e) {
      print('Error fetching featured content: $e');

      if (mounted) {
        setState(() {
          _isLoadingStories = false;
          _isLoadingCharacters = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Fehler beim Laden der Inhalte: $e'),
            backgroundColor: AppColors.bookRed,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Für responsive Design
    double screenWidth = MediaQuery.of(context).size.width;
    bool isMobile = screenWidth < 768;
    bool isTablet = screenWidth >= 768 && screenWidth < 1200;
    bool isDesktop = screenWidth >= 1200;

    // Horizontales Padding basierend auf Bildschirmgröße
    double horizontalPadding = isMobile ? 20 : isTablet ? 40 : 60;

    return Scaffold(
      backgroundColor: AppColors.bgCream,
      // Ohne Back-Button
      appBar: const ResponsiveAppBar(showBackButton: false),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1. Hero Section - Rot mit weißem Text
            Container(
              width: double.infinity,
              color: AppColors.bookRed,
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: 40,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: isDesktop ? 1200 : screenWidth * 0.8,
                  ),
                  child: isMobile
                      ? _buildHeroMobile()
                      : _buildHeroDesktop(),
                ),
              ),
            ),

            // 3. App Features - Cremehintergrund
            Container(
              width: double.infinity,
              color: AppColors.bgCream,
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: 40,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: isDesktop ? 1200 : screenWidth * 0.8,
                  ),
                  child: Column(
                    children: [
                      Text(
                        'App-Funktionen',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppColors.bookRed,
                        ),
                      ),
                      const SizedBox(height: 40),

                      isMobile
                          ? _buildFeaturesMobile()
                          : _buildFeaturesWide(),
                    ],
                  ),
                ),
              ),
            ),
            // 2. Featured Stories Section - Weiß mit normaler Schrift
            Container(
              width: double.infinity,
              color: Colors.white,
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: 40,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: isDesktop ? 1200 : screenWidth * 0.8,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'featured_stories'.tr,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppColors.bookRed,
                            ),
                          ),

                        ],
                      ),
                      const SizedBox(height: 24),

                      _isLoadingStories
                          ? Center(
                        child: CircularProgressIndicator(
                          color: AppColors.bookRed,
                        ),
                      )
                          : _featuredStories.isEmpty
                          ? Center(child: Text('Keine Geschichten gefunden'))
                          : _buildStoriesGrid(isMobile, isDesktop),
                    ],
                  ),
                ),
              ),
            ),



            // 4. Featured Characters Section - Weiß mit normaler Schrift
            Container(
              width: double.infinity,
              color: Colors.white,
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: 40,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: isDesktop ? 1200 : screenWidth * 0.8,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'featured_characters'.tr,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppColors.bookRed,
                            ),
                          ),

                        ],
                      ),
                      const SizedBox(height: 24),

                      _isLoadingCharacters
                          ? Center(
                        child: CircularProgressIndicator(
                          color: AppColors.bookRed,
                        ),
                      )
                          : _featuredCharacters.isEmpty
                          ? Center(child: Text('Keine Charaktere gefunden'))
                          : _buildCharactersGrid(isMobile, isTablet, isDesktop),
                    ],
                  ),
                ),
              ),
            ),

            // // 5. Download Section - Rot mit weißem Text
            // Container(
            //   width: double.infinity,
            //   color: AppColors.bookRed,
            //   padding: EdgeInsets.symmetric(
            //     horizontal: horizontalPadding,
            //     vertical: 40,
            //   ),
            //   child: Center(
            //     child: ConstrainedBox(
            //       constraints: BoxConstraints(
            //         maxWidth: isDesktop ? 1200 : screenWidth * 0.8,
            //       ),
            //       child: Column(
            //         children: [
            //           const Text(
            //             'App herunterladen',
            //             style: TextStyle(
            //               fontSize: 28,
            //               fontWeight: FontWeight.bold,
            //               color: Colors.white,
            //             ),
            //           ),
            //           const SizedBox(height: 16),
            //           const Text(
            //             'Lade die KinderStory App und entdecke zahlreiche Geschichten',
            //             style: TextStyle(
            //               fontSize: 16,
            //               color: Colors.white,
            //             ),
            //             textAlign: TextAlign.center,
            //           ),
            //           const SizedBox(height: 32),
            //
            //           Wrap(
            //             alignment: WrapAlignment.center,
            //             spacing: 20,
            //             runSpacing: 20,
            //             children: [
            //               _buildDownloadButton(
            //                 platform: 'Android',
            //                 onTap: () => _launchURL('https://play.google.com/store/apps/details?id=com.kinderstory.app'),
            //               ),
            //               _buildDownloadButton(
            //                 platform: 'iOS',
            //                 onTap: () => _launchURL('https://apps.apple.com/app/kinderstory/id123456789'),
            //               ),
            //             ],
            //           ),
            //         ],
            //       ),
            //     ),
            //   ),
            // ),

            // 6. Footer
            Container(
              color: Colors.black87,
              width: double.infinity,
              child: _buildFooter(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroMobile() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          height: 100,
          width: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipOval(
            child: Image.asset(
              'assets/images/logo.jpg',
              fit: BoxFit.cover,
              errorBuilder: (context, error, _) => const Icon(
                Icons.auto_stories,
                size: 50,
                color: AppColors.bookRed,
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),

         Text(
          'KinderStory',
          style: GoogleFonts.indieFlower(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),

        const Text(
          'Personalisierte Geschichten für deine Kinder',
          style: TextStyle(
            fontSize: 16,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),

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
    );
  }

  Widget _buildHeroDesktop() {
    return Row(
      children: [
        Expanded(
          flex: 4,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'KinderStory',
                style: GoogleFonts.indieFlower(
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Personalisierte Geschichten für deine Kinder mit der Kraft der Künstlichen Intelligenz',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  InkWell(
                    onTap: () => launchUrl(Uri.parse('https://play.google.com/store')),
                    child: Image.asset(
                      'assets/images/google-play-badge.png',
                      height: 80,
                    ),
                  ),
                  const SizedBox(width: 16),
                  InkWell(
                    onTap: () => launchUrl(Uri.parse('https://apps.apple.com')),
                    child: Image.asset(
                      'assets/images/apple-badge.png',
                      height: 80,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        Expanded(
          flex: 2,
          child: Center(
            child: Image.asset(
              'assets/images/logo.png',
              width: 300, // Anpassen je nach gewünschter Größe
              fit: BoxFit.contain, // Ändere zu contain, um das Abschneiden zu vermeiden
              errorBuilder: (context, error, _) => Container(
                width: 150,
                height: 150,
                color: Colors.white24,
                child: const Icon(Icons.auto_stories, color: Colors.white, size: 50),
              ),
            ),
          ),
        ),
      ],
    );
  }





  Widget _buildDownloadButton({required String platform, required VoidCallback onTap}) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                platform == 'Android' ? Icons.android : Icons.apple,
                color: AppColors.bookRed,
              ),
              const SizedBox(width: 8),
              Text(
                platform == 'Android' ? 'Google Play' : 'App Store',
                style: TextStyle(
                  color: AppColors.bookRed,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStoriesGrid(bool isMobile, bool isDesktop) {
    if (isMobile) {
      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _featuredStories.length,
        itemBuilder: (context, index) => Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _buildStoryCard(_featuredStories[index]),
        ),
      );
    } else {
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: isDesktop ? 3 : 2,
          childAspectRatio: 1.5,
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
        ),
        itemCount: _featuredStories.length,
        itemBuilder: (context, index) => _buildStoryCard(_featuredStories[index]),
      );
    }
  }

  Widget _buildStoryCard(GlobalStoryModel story) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Story Image
          Expanded(
            flex: 3,
            child: SizedBox(
              width: double.infinity,
              child: Image.network(
                story.imageUrl ?? '',
                fit: BoxFit.cover,
                headers: const {
                  'crossOrigin': 'anonymous',
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[300],
                    child: const Icon(Icons.image, size: 50, color: Colors.grey),
                  );
                },
              ),
            ),
          ),

          // Story Details
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    story.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.bookRed,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Expanded(
                    child: Text(
                      story.overallSummary ??
                          (story.content != null && story.content!.isNotEmpty
                              ? story.content!.substring(0, story.content!.length > 100 ? 100 : story.content!.length)
                              : 'Keine Beschreibung'),
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildFeaturesMobile() {
    return Column(
      children: [
        _buildFeatureCard(
          icon: Icons.auto_stories,
          title: 'Geschichten erstellen',
          description: 'Personalisierte Geschichten mit deinen Kindern als Hauptfiguren erstellen.',
        ),
        const SizedBox(height: 16),
        _buildFeatureCard(
          icon: Icons.emoji_people,
          title: 'Charaktere gestalten',
          description: 'Erstelle eigene Charaktere für deine Geschichten.',
        ),
        const SizedBox(height: 16),
        _buildFeatureCard(
          icon: Icons.record_voice_over,
          title: 'Vorlesen lassen',
          description: 'Höre dir die Geschichten vor oder lese sie selbst vor.',
        ),
      ],
    );
  }

  Widget _buildFeaturesWide() {
    return Row(
      children: [
        Expanded(
          child: _buildFeatureCard(
            icon: Icons.auto_stories,
            title: 'Geschichten erstellen',
            description: 'Personalisierte Geschichten mit deinen Kindern als Hauptfiguren erstellen.',
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: _buildFeatureCard(
            icon: Icons.emoji_people,
            title: 'Charaktere gestalten',
            description: 'Erstelle eigene Charaktere für deine Geschichten.',
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: _buildFeatureCard(
            icon: Icons.record_voice_over,
            title: 'Vorlesen lassen',
            description: 'Höre dir die Geschichten vor oder lese sie selbst vor.',
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.bookRed.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 36,
                color: AppColors.bookRed,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.bookRed,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black54,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCharactersGrid(bool isMobile, bool isTablet, bool isDesktop) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isDesktop
            ? 5
            : isTablet
            ? 3
            : 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: _featuredCharacters.length,
      itemBuilder: (context, index) => _buildCharacterCard(_featuredCharacters[index]),
    );
  }

  Widget _buildCharacterCard(GlobalCharacterModel character) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Character Image
          Expanded(
            flex: 4,
            child: Image.network(
              character.imageUrl ?? '',
              fit: BoxFit.cover,
              headers: const {
                'crossOrigin': 'anonymous',
              },
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey[300],
                  child: const Icon(Icons.person, size: 50, color: Colors.grey),
                );
              },
            ),
          ),

          // Character Name & Age
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.all(8),
              color: Colors.white,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    character.name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: AppColors.bookRed,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    '${character.age} Jahre',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black54,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    // Versuche, das Footer-Widget zu verwenden, mit Fallback
    try {
      return const FooterWidget();
    } catch (e) {
      // Einfacher Fallback-Footer
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
        child: Center(
          child: Column(
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Image.asset(
                      'assets/images/logo.jpg',
                      width: 24,
                      height: 24,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, _) => Container(
                        width: 24,
                        height: 24,
                        color: Colors.white24,
                        child: const Icon(Icons.image, color: Colors.white, size: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'KinderStory',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Wrap(
                spacing: 20,
                runSpacing: 10,
                alignment: WrapAlignment.center,
                children: [
                  Text('Datenschutz', style: TextStyle(color: Colors.white70)),
                  Text('Impressum', style: TextStyle(color: Colors.white70)),
                  Text('Kontakt', style: TextStyle(color: Colors.white70)),
                  Text('AGB', style: TextStyle(color: Colors.white70)),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                '© 2025 KinderStory. Alle Rechte vorbehalten.',
                style: TextStyle(color: Colors.white60, fontSize: 12),
              ),
            ],
          ),
        ),
      );
    }
  }

  Future<void> _launchURL(String url) async {
    try {
      await launchUrlString(url);
    } catch (e) {
      print('Could not launch $url: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Fehler beim Öffnen der URL'),
            backgroundColor: AppColors.bookRed,
          ),
        );
      }
    }
  }
}
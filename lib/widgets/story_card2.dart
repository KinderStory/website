import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:kinderstory_website/widgets/story_card.dart';
import '../models/global_story_model.dart';
import '../utils/constants.dart';

import 'package:firebase_auth/firebase_auth.dart';

class StoryCard extends StatelessWidget {
  final GlobalStoryModel story;
  final int index;
  final VoidCallback? onTap;

  const StoryCard({
    Key? key,
    required this.story,
    required this.index,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Farbauswahl basierend auf dem Index (zyklische Farbwahl)
    final colors = [
      AppColors.accentBlue,
      AppColors.accentYellow,
      AppColors.accentGreen,
      AppColors.bookRed.withOpacity(0.7),
      AppColors.textPurple.withOpacity(0.7),
    ];
    final color = colors[index % colors.length];

    // Datumsformatierung
    String formattedDate;
    final now = DateTime.now();
    final storyDate = story.publishedAt;
    final difference = now.difference(storyDate);

    if (difference.inDays == 0) {
      formattedDate = 'Heute'.tr;
    } else if (difference.inDays == 1) {
      formattedDate = 'Gestern'.tr;
    } else if (difference.inDays < 30) {
      formattedDate = 'Vor @days Tagen'.trParams({'days': difference.inDays.toString()});
    } else {
      final day = storyDate.day.toString().padLeft(2, '0');
      final month = storyDate.month.toString().padLeft(2, '0');
      final year = storyDate.year;
      formattedDate = '$day.$month.$year';
    }

    // Prüfen ob es eine Bildergeschichte ist
    final isImageStory = story.isImageStory == true;
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

    return AnimatedOpacity(
      opacity: 1.0,
      duration: Duration(milliseconds: 500),
      child: Card(
        margin: const EdgeInsets.only(bottom: 16),
        elevation: isImageStory ? 3 : 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Column(
            children: [
              // Wenn es eine Bildergeschichte ist, ein spezielles Layout verwenden
              if (isImageStory)
                StoryCardHelper.buildImageStoryHeader(
                  context: context,
                  title: story.title,
                  authorName: story.authorName,
                  formattedDate: formattedDate,
                  childAge: story.childAge.toString(),
                  averageRating: story.averageRating,
                  ratingCount: story.ratingCount,
                  storyPages: story.storyPages,
                  onRateTap: null, // Da wir hier keine Bewertungsfunktion haben
                  currentUserId: currentUserId,
                  authorId: story.authorId,
                )
              else
              // Standard-Layout für normale und Kapitelgeschichten
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header mit Protagonist und Titel
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Prüfe ob es eine Kapitelgeschichte ist für die Anzeige des runden Charakterbildes
                          story.isMultiChapter && story.characterData != null && story.characterData!.containsKey('imageUrl')
                              ? Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 5,
                                  spreadRadius: 1,
                                ),
                              ],
                              border: Border.all(
                                color: Colors.white,
                                width: 1,
                              ),
                            ),
                            child: ClipOval(
                              child: CachedNetworkImage(
                                imageUrl: story.characterData!['imageUrl'] as String,
                                fit: BoxFit.cover,

                              ),
                            ),
                          )
                              : Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: color.withOpacity(0.1),
                            ),
                            child: story.imageUrl != null && story.imageUrl!.isNotEmpty
                                ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: CachedNetworkImage(
                                imageUrl: story.imageUrl!,
                                fit: BoxFit.cover,

                                placeholder: (context, url) => Center(
                                  child: CircularProgressIndicator(
                                    color: color,
                                  ),
                                ),
                              ),
                            )
                                : Center(
                              child: Text(
                                story.childName.isNotEmpty
                                    ? story.childName[0].toUpperCase()
                                    : "?",
                                style: TextStyle(
                                  color: color,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 24,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),

                          // Titel und Infos
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  story.title,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Von'.tr + ' ${story.authorName}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Text(
                                      'Veröffentlicht:'.tr,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade500,
                                      ),
                                    ),
                                    Text(
                                      ' $formattedDate',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade500,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                // Neue Zielgruppen-Anzeige
                                Row(
                                  children: [
                                    Text(
                                      'Zielgruppe:'.tr,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade500,
                                      ),
                                    ),
                                    Text(
                                      ' ${story.childAge} Jahre',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade500,
                                      ),
                                    ),
                                  ],
                                ),

                                // Kapitel-Badge für Kapitelgeschichten
                                if (story.isMultiChapter && story.chapterCount != null)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: AppColors.textPurple.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: AppColors.textPurple.withOpacity(0.3),
                                          width: 1,
                                        ),
                                      ),
                                      child: Text(
                                        '${story.chapterCount} ${story.chapterCount == 1 ? "Kapitel".tr : "Kapitel".tr}',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.textPurple,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      // Bewertungs-Widget
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Row(
                          children: [
                            // Sterne-Anzeige
                            Row(
                              children: List.generate(5, (index) {
                                return Icon(
                                  index < story.averageRating.floor()
                                      ? Icons.star
                                      : (index < story.averageRating
                                      ? Icons.star_half
                                      : Icons.star_border),
                                  color: AppColors.bookRed,
                                  size: 18,
                                );
                              }),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${story.averageRating.toStringAsFixed(1)} (${story.ratingCount})',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
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

  // Fallback-Avatar für Charakterbilder
  Widget _buildCharacterFallbackAvatar(GlobalStoryModel story, Color color) {
    // Ersten Buchstaben des Charakternamens oder default nehmen
    final characterName = story.characterData?['name'] as String? ?? story.childName;
    final String initial = characterName.isNotEmpty ? characterName[0].toUpperCase() : "?";

    // Zufall-Emoji basierend auf dem Namen
    final List<String> funEmojis = [
      '😊', '🦸', '👧', '👦', '🐱', '🐶', '🦄', '🐲', '🧚', '🦋'
    ];

    // Deterministischer "Zufalls"-Index basierend auf dem Namen
    int nameHash = 0;
    if (characterName.isNotEmpty) {
      for (int i = 0; i < characterName.length; i++) {
        nameHash += characterName.codeUnitAt(i);
      }
    }
    final emojiIndex = nameHash % funEmojis.length;

    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(0.8),
      ),
      child: Center(
        child: Text(
          funEmojis[emojiIndex],
          style: const TextStyle(
            fontSize: 24,
          ),
        ),
      ),
    );
  }
}
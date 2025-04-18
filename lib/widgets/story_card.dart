// In lib/utils/story_card_helper.dart oder lib/widgets/story_card_helper.dart

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../utils/constants.dart';


class StoryCardHelper {
  static Widget buildImageStoryHeader({
    required BuildContext context,
    required String title,
    required String authorName,
    required String formattedDate,
    required String childAge,
    required double averageRating,
    required int ratingCount,
    required List<dynamic>? storyPages,
    required VoidCallback? onRateTap,
    required String? currentUserId,
    required String? authorId,
  }) {
    final pageCount = storyPages?.length ?? 0;

    return Column(
      children: [
        // Titelbanner mit Informationen und Aktionsknöpfen in einer Zeile
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.white, Colors.white],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
          ),
          child: Row(
            children: [
              // Bildergeschichte-Icon
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.photo_library,
                  color: AppColors.bookRed,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),

              // Titel und Datum - mit Expanded um Überlauf zu verhindern
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    Row(
                      children: [
                        Text(
                          'Von'.tr + ' $authorName · ',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          formattedDate,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    // Zielgruppe
                    Row(
                      children: [
                        Text(
                          'Zielgruppe:'.tr,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          ' $childAge Jahre · ',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '$pageCount Seiten',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),


            ],
          ),
        ),

        // Bildergalerie-Vorschau
        if (storyPages != null && storyPages.isNotEmpty)
          ClipRRect(
            child: Container(
              height: 150,
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                clipBehavior: Clip.hardEdge,
                itemCount: storyPages.length > 5 ? 5 : storyPages.length,
                itemBuilder: (context, index) {
                  final page = storyPages[index];

                  // Anpassen an dein Modell - Hier musst du evtl. die Eigenschaftszugriffe anpassen
                  final pageNumber = page.pageNumber is int ? page.pageNumber : index + 1;
                  final imageUrl = page.imageUrl;
                  final text = page.text is String ? page.text : '';

                  return Container(
                    width: 120,
                    margin: EdgeInsets.only(
                      left: index == 0 ? 12 : 8,
                      right: index == (storyPages.length > 5 ? 5 : storyPages.length) - 1 ? 12 : 0,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 5,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        // Bild
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: imageUrl != null
                              ? Image.network(
                            imageUrl,
                            width: 120,
                            height: 150,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 120,
                                height: 150,
                                color: Colors.grey.shade200,
                                child: Center(
                                  child: Icon(
                                    Icons.image_not_supported,
                                    color: Colors.grey.shade500,
                                    size: 30,
                                  ),
                                ),
                              );
                            },
                          )
                              : Container(
                            width: 120,
                            height: 150,
                            color: Colors.grey.shade200,
                            child: Center(
                              child: Icon(
                                Icons.image,
                                color: Colors.grey.shade500,
                                size: 30,
                              ),
                            ),
                          ),
                        ),

                        // Seitennummer-Label
                        Positioned(
                          top: 8,
                          left: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.6),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '$pageNumber',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),

                        // Text-Vorschau am unteren Rand
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withOpacity(0.7),
                                ],
                              ),
                              borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(12),
                                bottomRight: Radius.circular(12),
                              ),
                            ),
                            child: Text(
                              text,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),

        // "Mehr anzeigen" für Geschichten mit mehr als 5 Seiten
        if (storyPages != null && storyPages.length > 5)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '+ ${storyPages.length - 5} weitere Seiten',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textPurple,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 12,
                        color: AppColors.textPurple,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

        // Bewertungs-Button am unteren Rand
        if (onRateTap != null)
        // Und ändere das Container-Widget mit dem Bewertungs-Button unten auf
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween, // Wichtig: Ändere zu spaceBetween
              children: [
                // Neue Sterne-Anzeige links
                Row(
                  children: [
                    Row(
                      children: List.generate(5, (index) {
                        return Icon(
                          index < averageRating.floor()
                              ? Icons.star
                              : (index < averageRating
                              ? Icons.star_half
                              : Icons.star_border),
                          color: AppColors.bookRed,
                          size: 18,
                        );
                      }),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${averageRating.toStringAsFixed(1)} ($ratingCount)',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),

                // Bewertungs-Button (bleibt rechts)
                if (authorId != currentUserId)
                  TextButton.icon(
                    onPressed: onRateTap,
                    icon: const Icon(Icons.rate_review),
                    label: Text('Bewerten'.tr),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.textPurple,
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }

  // Neue Methode aus start_screen.dart hierher verschoben
  static Widget buildStartScreenImageStoryHeader({
    required BuildContext context,
    required String storyTitle,
    required String formattedDate,
    required int pageCount,
    required List<dynamic> storyPages,
    required bool isFavorite,
    required Function(bool) onFavoriteTap,
    required VoidCallback onPublishTap,
    required VoidCallback onMoreOptionsTap,
    required bool isPublished,
  }) {
    return Column(
      children: [
        // Titelbanner mit Informationen und Aktionsknöpfen in einer Zeile
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.white, Colors.white],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
          ),
          child: Row(
            children: [
              // Bildergeschichte-Icon
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.photo_library,
                  color: AppColors.bookRed,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),

              // Titel und Datum - mit Expanded um Überlauf zu verhindern
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      storyTitle,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    Row(
                      children: [
                        Text(
                          formattedDate,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '$pageCount Seiten',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Rechte Seite: Aktionsknöpfe horizontal angeordnet
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Favoriten-Button
                  Container(
                    height: 35,
                    width: 35,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: IconButton(
                      icon: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite ? AppColors.bookRed : Colors.grey.shade700,
                        size: 20,
                      ),
                      onPressed: () => onFavoriteTap(!isFavorite),
                      tooltip: isFavorite ? 'Von Favoriten entfernen'.tr : 'Zu Favoriten hinzufügen'.tr,
                      constraints: const BoxConstraints(
                        minWidth: 36,
                        minHeight: 36,
                      ),
                    ),
                  ),

                  // Publish-Button
                  Container(
                    height: 35,
                    width: 35,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.public,
                        color: isPublished ? AppColors.textPurple : Colors.grey.shade700,
                        size: 20,
                      ),
                      onPressed: onPublishTap,
                      tooltip: isPublished ? 'Veröffentlichung zurückziehen'.tr : 'Geschichte veröffentlichen'.tr,
                      constraints: const BoxConstraints(
                        minWidth: 36,
                        minHeight: 36,
                      ),
                    ),
                  ),

                  // Mehr-Optionen-Button
                  Container(
                    height: 35,
                    width: 35,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.more_vert,
                        color: Colors.grey.shade700,
                        size: 20,
                      ),
                      onPressed: onMoreOptionsTap,
                      tooltip: 'Weitere Optionen'.tr,
                      constraints: const BoxConstraints(
                        minWidth: 36,
                        minHeight: 36,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Bildergalerie-Vorschau mit 100% Breite, aber beschränkt auf die Kartengröße
        ClipRRect(
          // Beschneiden der Scrollbar, damit sie nicht über die Karte hinausgeht
          child: Container(
            height: 150,
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              // Verhindert das Überlaufen der Scrollbar
              clipBehavior: Clip.hardEdge,
              itemCount: min(storyPages.length, 5), // Begrenzung auf maximal 5 Bilder
              itemBuilder: (context, index) {
                final pageIndex = index;
                final page = storyPages[pageIndex];

                return Container(
                  width: 120,
                  margin: EdgeInsets.only(
                    left: index == 0 ? 12 : 8,
                    right: index == min(pageCount, 5) - 1 ? 12 : 0,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 5,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      // Bild
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: page.imageUrl != null
                            ? Image.network(
                          page.imageUrl!,
                          width: 120,
                          height: 150,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 120,
                              height: 150,
                              color: Colors.grey.shade200,
                              child: Center(
                                child: Icon(
                                  Icons.image_not_supported,
                                  color: Colors.grey.shade500,
                                  size: 30,
                                ),
                              ),
                            );
                          },
                        )
                            : Container(
                          width: 120,
                          height: 150,
                          color: Colors.grey.shade200,
                          child: Center(
                            child: Icon(
                              Icons.image,
                              color: Colors.grey.shade500,
                              size: 30,
                            ),
                          ),
                        ),
                      ),

                      // Seitennummer-Label
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${page.pageNumber}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                      // Text-Vorschau am unteren Rand
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.7),
                              ],
                            ),
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(12),
                              bottomRight: Radius.circular(12),
                            ),
                          ),
                          child: Text(
                            page.text,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),

        // "Mehr anzeigen" für Geschichten mit mehr als 5 Seiten
        if (storyPages.length > 5)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '+ ${storyPages.length - 5} weitere Seiten',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textPurple,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 12,
                        color: AppColors.textPurple,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
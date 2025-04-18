import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/global_character_model.dart';
import '../utils/constants.dart';

class CharacterCard extends StatelessWidget {
  final GlobalCharacterModel character;
  final int index;
  final VoidCallback? onTap;

  const CharacterCard({
    Key? key,
    required this.character,
    required this.index,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final characterColor = character.colorValue != null
        ? Color(character.colorValue!)
        : AppColors.textPurple;

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Character Avatar/Header - Größer und prominenter
            Expanded(
              flex: 3,
              child: Container(
                decoration: BoxDecoration(
                  color: characterColor.withOpacity(0.15),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Character Image
                    if (character.imageUrl != null && character.imageUrl!.isNotEmpty)
                      ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                        child: CachedNetworkImage(
                          imageUrl: character.imageUrl!,
                          fit: BoxFit.cover,
                          height: double.infinity,
                          width: double.infinity,
                          placeholder: (context, url) => Center(
                            child: CircularProgressIndicator(color: characterColor),
                          ),
                          errorWidget: (context, url, error) => _buildFallbackIcon(characterColor),
                        ),
                      )
                    else
                      _buildFallbackIcon(characterColor),

                    // Autor-Badge in der Ecke oben rechts
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          character.authorName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Character Info Section
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Character Name - Prominenter
                    Text(
                      character.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    // Typ/Spezies als Chip
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: characterColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: characterColor.withOpacity(0.3)),
                      ),
                      child: Text(
                        character.speciesType ?? 'Unbekannt',
                        style: TextStyle(
                          fontSize: 12,
                          color: characterColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                    const Spacer(),

                    // Bewertung und Nutzung in einer Zeile
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Bewertung
                        Row(
                          children: [
                            Icon(
                              Icons.star,
                              color: AppColors.bookRed,
                              size: 16,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              character.averageRating.toStringAsFixed(1),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),

                        // Nutzungszähler
                        Row(
                          children: [
                            Icon(
                              Icons.people,
                              color: Colors.grey.shade600,
                              size: 16,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              '${character.copyCount ?? 0}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade800,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Icon basierend auf Charaktertyp auswählen
  IconData _getCharacterIcon(String? type) {
    switch (type) {
      case 'Drache':
        return Icons.pest_control_rodent;
      case 'Elfe':
        return Icons.emoji_nature;
      case 'Fee':
        return Icons.auto_fix_high;
      case 'Zauberer':
        return Icons.auto_fix_normal;
      case 'Tier':
        return Icons.pets;
      case 'Roboter':
        return Icons.smart_toy;
      case 'Alien':
        return Icons.settings_accessibility;
      case 'Fantasiewesen':
        return Icons.blur_circular;
      default:
        return Icons.emoji_emotions;
    }
  }

  // Hilfsmethode für Fallback-Icon
  Widget _buildFallbackIcon(Color color) {
    return Center(
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          shape: BoxShape.circle,
          border: Border.all(
            color: color,
            width: 2,
          ),
        ),
        child: Icon(
          _getCharacterIcon(character.speciesType),
          size: 48,
          color: color,
        ),
      ),
    );
  }
}
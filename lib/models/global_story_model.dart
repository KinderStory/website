import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/story_model.dart';
import '../providers/tts_provider.dart';

class GlobalStoryModel {
  final String id;
  final String originalStoryId;
  final String authorId;
  final String authorName;
  final String title;
  final String childName; // Protagonist
  final int childAge;
  final String childInterests; // Protagonist-Fähigkeiten
  final String currentTopics; // Thema
  final String storyElements; // Setting
  final int storyLengthMinutes;
  final String? content;
  final String? imageUrl;
  final bool isMultiChapter;
  final int? chapterCount;
  final Map<String, dynamic>? characterData;
  final DateTime createdAt;
  final DateTime publishedAt;
  final int? sentencesPerPicture; // Neues Feld hinzufügen


  // Neue Protagonisten-Felder
  final String protagonistName;
  final int protagonistAge;
  final bool isProtagonistStory;

  // Sprachfelder
  final String language;
  final String languageName;

  // TTS Felder
  final int? voiceTypeIndex;
  final String? voiceId;
  final double? speechRate;
  final String? graphicStyle;

  // Bildergeschichten-Felder
  final bool isImageStory;
  final List<StoryPageModel>? storyPages;

  // Weitere Felder
  final String? overallSummary;
  final int? wordCount;

  // Bewertungsfelder
  final double averageRating;
  final int ratingCount;
  final Map<String, double>? userRatings; // User-ID zu Bewertung

  GlobalStoryModel({
    required this.id,
    required this.originalStoryId,
    required this.authorId,
    required this.authorName,
    required this.title,
    required this.childName,
    required this.childAge,
    required this.childInterests,
    required this.currentTopics,
    required this.storyElements,
    required this.storyLengthMinutes,
    this.content,
    this.imageUrl,
    required this.isMultiChapter,
    this.chapterCount,
    this.characterData,
    required this.createdAt,
    required this.publishedAt,
    required this.protagonistName,
    required this.protagonistAge,
    required this.isProtagonistStory,
    required this.language,
    required this.languageName,
    this.voiceTypeIndex,
    this.voiceId,
    this.speechRate,
    this.graphicStyle,
    this.isImageStory = false,
    this.storyPages,
    this.overallSummary,
    this.wordCount,
    this.averageRating = 0.0,
    this.ratingCount = 0,
    this.userRatings,
    this.sentencesPerPicture, // Neuer Parameter

  });

  // Erstellen aus einer StoryModel-Instanz
  factory GlobalStoryModel.fromStoryModel(
      StoryModel story,
      String authorId,
      String authorName
      ) {
    return GlobalStoryModel(
      id: '',
      originalStoryId: story.id ?? '',
      authorId: authorId,
      authorName: authorName,
      title: story.title ?? 'Unbenannte Geschichte',
      childName: story.childName,
      childAge: story.childAge,
      childInterests: story.childInterests,
      currentTopics: story.currentTopics,
      storyElements: story.storyElements,
      storyLengthMinutes: story.storyLengthMinutes,
      content: story.content,
      imageUrl: story.imageUrl,
      isMultiChapter: story.isMultiChapter,
      chapterCount: story.chapterCount,
      characterData: story.characterData,
      createdAt: story.createdAt,
      publishedAt: DateTime.now(),
      protagonistName: story.protagonistName,
      protagonistAge: story.protagonistAge,
      isProtagonistStory: story.isProtagonistStory,
      language: story.language,
      languageName: story.languageName,
      voiceTypeIndex: story.voiceType?.index,
      voiceId: story.voiceId,
      speechRate: story.speechRate,
      graphicStyle: story.graphicStyle,
      isImageStory: story.isImageStory,
      storyPages: story.storyPages,
      overallSummary: story.overallSummary,
      wordCount: story.wordCount,
      averageRating: 0.0,
      ratingCount: 0,
      userRatings: {},
      sentencesPerPicture: story.sentencesPerPicture, // Neues Feld übernehmen

    );
  }

  // Konvertieren in eine Map für Firestore
  Map<String, dynamic> toMap() {
    return {
      'originalStoryId': originalStoryId,
      'authorId': authorId,
      'authorName': authorName,
      'title': title,
      'childName': childName,
      'childAge': childAge,
      'childInterests': childInterests,
      'currentTopics': currentTopics,
      'storyElements': storyElements,
      'storyLengthMinutes': storyLengthMinutes,
      'content': content,
      'imageUrl': imageUrl,
      'isMultiChapter': isMultiChapter,
      'chapterCount': chapterCount,
      'characterData': characterData,
      'createdAt': createdAt,
      'publishedAt': publishedAt,
      'protagonistName': protagonistName,
      'protagonistAge': protagonistAge,
      'isProtagonistStory': isProtagonistStory,
      'language': language,
      'languageName': languageName,
      'voiceTypeIndex': voiceTypeIndex,
      'voiceId': voiceId,
      'speechRate': speechRate,
      'graphicStyle': graphicStyle,
      'isImageStory': isImageStory,
      'storyPages': storyPages?.map((page) => page.toMap()).toList(),
      'overallSummary': overallSummary,
      'wordCount': wordCount,
      'averageRating': averageRating,
      'ratingCount': ratingCount,
      'userRatings': userRatings ?? {},
      'sentencesPerPicture': sentencesPerPicture, // Neues Feld speichern

    };
  }

  // Erstellen aus Firestore Map
  factory GlobalStoryModel.fromMap(Map<String, dynamic> map, String documentId) {
    // Konvertieren der storyPages-Liste
    List<StoryPageModel>? pages;
    if (map['storyPages'] != null && map['storyPages'] is List) {
      pages = (map['storyPages'] as List)
          .map((pageMap) => StoryPageModel.fromMap(pageMap as Map<String, dynamic>))
          .toList();
    }

    return GlobalStoryModel(
      id: documentId,
      originalStoryId: map['originalStoryId'] ?? '',
      authorId: map['authorId'] ?? '',
      authorName: map['authorName'] ?? 'Unbekannter Autor',
      title: map['title'] ?? 'Unbenannte Geschichte',
      childName: map['childName'] ?? '',
      childAge: map['childAge'] ?? 5,
      childInterests: map['childInterests'] ?? '',
      currentTopics: map['currentTopics'] ?? '',
      storyElements: map['storyElements'] ?? '',
      storyLengthMinutes: map['storyLengthMinutes'] ?? 3,
      content: map['content'],
      imageUrl: map['imageUrl'],
      isMultiChapter: map['isMultiChapter'] ?? false,
      chapterCount: map['chapterCount'],
      characterData: map['characterData'],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      publishedAt: (map['publishedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      protagonistName: map['protagonistName'] ?? map['childName'] ?? '',
      protagonistAge: map['protagonistAge'] ?? map['childAge'] ?? 5,
      isProtagonistStory: map['isProtagonistStory'] ?? false,
      language: map['language'] ?? 'de_DE',
      languageName: map['languageName'] ?? 'Deutsch',
      voiceTypeIndex: map['voiceTypeIndex'],
      voiceId: map['voiceId'],
      speechRate: map['speechRate'],
      graphicStyle: map['graphicStyle'],
      isImageStory: map['isImageStory'] ?? false,
      storyPages: pages,
      overallSummary: map['overallSummary'],
      wordCount: map['wordCount'],
      averageRating: (map['averageRating'] is int)
          ? (map['averageRating'] as int).toDouble()
          : map['averageRating'] ?? 0.0,
      ratingCount: map['ratingCount'] ?? 0,
      userRatings: map['userRatings'] != null
          ? Map<String, double>.from(map['userRatings'])
          : null,
      sentencesPerPicture: map['sentencesPerPicture'], // Neues Feld laden

    );
  }

  // Konvertieren zu StoryModel für lokale Anzeige
  StoryModel toStoryModel() {
    return StoryModel(
      id: originalStoryId,
      childName: childName,
      childAge: childAge,
      childInterests: childInterests,
      protagonistName: protagonistName,
      protagonistAge: protagonistAge,
      currentTopics: currentTopics,
      storyElements: storyElements,
      storyLengthMinutes: storyLengthMinutes,
      content: content,
      title: title,
      imageUrl: imageUrl,
      characterData: characterData,
      createdAt: createdAt,
      isProtagonistStory: isProtagonistStory,
      isMultiChapter: isMultiChapter,
      chapterCount: chapterCount,
      language: language,
      languageName: languageName,
      voiceType: voiceTypeIndex != null ? TTSType.values[voiceTypeIndex!] : null,
      voiceId: voiceId,
      speechRate: speechRate,
      graphicStyle: graphicStyle,
      isImageStory: isImageStory,
      storyPages: storyPages,
      overallSummary: overallSummary,
      wordCount: wordCount,
      sentencesPerPicture: sentencesPerPicture, // Neues Feld übernehmen

      additionalDetails: {
        'isGlobalStory': true,
        'globalStoryId': id,
        'authorId': authorId,
        'authorName': authorName,
        'averageRating': averageRating,
        'ratingCount': ratingCount,
        'publishedAt': publishedAt,

      },
    );
  }

  // Kopieren mit Änderungen
  GlobalStoryModel copyWith({
    String? id,
    String? originalStoryId,
    String? authorId,
    String? authorName,
    String? title,
    String? childName,
    int? childAge,
    String? childInterests,
    String? currentTopics,
    String? storyElements,
    int? storyLengthMinutes,
    String? content,
    String? imageUrl,
    bool? isMultiChapter,
    int? chapterCount,
    Map<String, dynamic>? characterData,
    DateTime? createdAt,
    DateTime? publishedAt,
    String? protagonistName,
    int? protagonistAge,
    bool? isProtagonistStory,
    String? language,
    String? languageName,
    int? voiceTypeIndex,
    String? voiceId,
    double? speechRate,
    String? graphicStyle,
    bool? isImageStory,
    List<StoryPageModel>? storyPages,
    String? overallSummary,
    int? wordCount,
    double? averageRating,
    int? ratingCount,
    Map<String, double>? userRatings,
    int? sentencesPerPicture, // Neuer Parameter

  }) {
    return GlobalStoryModel(
      id: id ?? this.id,
      originalStoryId: originalStoryId ?? this.originalStoryId,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      title: title ?? this.title,
      childName: childName ?? this.childName,
      childAge: childAge ?? this.childAge,
      childInterests: childInterests ?? this.childInterests,
      currentTopics: currentTopics ?? this.currentTopics,
      storyElements: storyElements ?? this.storyElements,
      storyLengthMinutes: storyLengthMinutes ?? this.storyLengthMinutes,
      content: content ?? this.content,
      imageUrl: imageUrl ?? this.imageUrl,
      isMultiChapter: isMultiChapter ?? this.isMultiChapter,
      chapterCount: chapterCount ?? this.chapterCount,
      characterData: characterData ?? this.characterData,
      createdAt: createdAt ?? this.createdAt,
      publishedAt: publishedAt ?? this.publishedAt,
      protagonistName: protagonistName ?? this.protagonistName,
      protagonistAge: protagonistAge ?? this.protagonistAge,
      isProtagonistStory: isProtagonistStory ?? this.isProtagonistStory,
      language: language ?? this.language,
      languageName: languageName ?? this.languageName,
      voiceTypeIndex: voiceTypeIndex ?? this.voiceTypeIndex,
      voiceId: voiceId ?? this.voiceId,
      speechRate: speechRate ?? this.speechRate,
      graphicStyle: graphicStyle ?? this.graphicStyle,
      isImageStory: isImageStory ?? this.isImageStory,
      storyPages: storyPages ?? this.storyPages,
      overallSummary: overallSummary ?? this.overallSummary,
      wordCount: wordCount ?? this.wordCount,
      averageRating: averageRating ?? this.averageRating,
      ratingCount: ratingCount ?? this.ratingCount,
      userRatings: userRatings ?? this.userRatings,
      sentencesPerPicture: sentencesPerPicture ?? this.sentencesPerPicture, // Neues Feld kopieren

    );
  }
}
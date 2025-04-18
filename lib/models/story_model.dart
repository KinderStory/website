import 'package:cloud_firestore/cloud_firestore.dart';

import '../providers/tts_provider.dart';

class StoryModel {
  String? id;
  bool isImageStory;
  List<StoryPageModel>? storyPages;
  final bool isGlobalStory;
  // Ursprüngliche Kinder-Felder
  final String childName;
  final int childAge;
  final String childInterests;

  final String language; // z.B. "de_DE", "en_GB", "es_ES", "fr_FR"
  final String languageName; // z.B. "Deutsch", "English", "Español", "Français"

  // Neue Protagonisten-Felder
  final String protagonistName;
  final int protagonistAge;

  final String currentTopics;
  final String storyElements;
  final int storyLengthMinutes;
  final DateTime createdAt;
  final DateTime? updatedAt;
  String? content;
  String? title;
  String? imageUrl;
  final TTSType? voiceType;
  final String? voiceId;
  final double? speechRate;
  final String? graphicStyle;
  final int? sentencesPerPicture;
  // Felder für die Charakter-Funktionalität
  String? characterId;
  Map<String, dynamic>? characterData;

  // Weitere Felder
  final bool isProtagonistStory;
  final bool isMultiChapter;
  final String? overallSummary;
  final int? chapterCount;
  final Map<String, dynamic>? additionalDetails;
  final int? wordCount;


  // Getter für den Favoriten-Status
  bool get isFavorite => additionalDetails != null &&
      additionalDetails!.containsKey('isFavorite') &&
      additionalDetails!['isFavorite'] == true;

  // Getter für den Veröffentlichungsstatus
  bool get isPublished => additionalDetails != null &&
      additionalDetails!.containsKey('isPublished') &&
      additionalDetails!['isPublished'] == true;

  // Getter für den Archivierungsstatus
  bool get isArchived => additionalDetails != null &&
      additionalDetails!.containsKey('isArchived') &&
      additionalDetails!['isArchived'] == true;

  StoryModel({
    this.id,
    required this.childName,
    required this.childAge,
    required this.childInterests,
    String? protagonistName, // Neue optionale Parameter
    int? protagonistAge,     // Neue optionale Parameter
    required this.currentTopics,
    required this.storyElements,
    required this.storyLengthMinutes,
    this.content,
    this.title,
    this.imageUrl,
    this.characterId,
    this.characterData,
    DateTime? createdAt,
    this.updatedAt,
    this.isImageStory = false, // Neues Feld
    this.storyPages, // Neues Feld
    this.isProtagonistStory = false,
    this.isMultiChapter = false,
    this.language = "de_DE", // Standard: Deutsch
    this.languageName = "Deutsch",
    this.overallSummary,
    this.chapterCount = 0,
    this.additionalDetails,
    this.wordCount,
    this.voiceType,
    this.voiceId,
    this.speechRate,
    this.graphicStyle,
    this.sentencesPerPicture,
    this.isGlobalStory = false,
  }) :
  // Initialisiere die Protagonisten-Felder, falls nicht explizit angegeben
        this.protagonistName = protagonistName ?? childName,
        this.protagonistAge = protagonistAge ?? childAge,
        this.createdAt = createdAt ?? DateTime.now();

  // Hilfsmethode zur Berechnung der ungefähren Wortanzahl
  int get estimatedWordCount {
    if (wordCount != null && wordCount! > 0) {
      return wordCount!;
    }
    final int wordsPerMinute = 160; // Durchschnittliche Lesegeschwindigkeit für Kindergeschichten
    return storyLengthMinutes * wordsPerMinute;
  }

  // Neue Factory-Methode für Bildergeschichten
  static StoryModel createImageStory({
    String? id,
    required String protagonistName,
    required int protagonistAge,
    required String protagonistAbilities,
    required String storyTopic,
    required String storySetting,
    required String title,
    String? imageUrl,
    required List<StoryPageModel> storyPages,
    int storyLengthMinutes = 3,
    String? characterId,
    Map<String, dynamic>? characterData,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? additionalDetails,
    TTSType? voiceType,
    String? voiceId,
    double? speechRate,
    String? graphicStyle,
    String? childName,
    int? childAge,
    int? sentencesPerPicture = 3,
    bool isGlobalStory = false,
  }) {
    return StoryModel(
      isGlobalStory: isGlobalStory,
      id: id,
      childName: childName ?? '',
      childAge: childAge ?? 0,
      childInterests: protagonistAbilities,
      protagonistName: protagonistName,
      protagonistAge: protagonistAge,
      currentTopics: storyTopic,
      storyElements: storySetting,
      storyLengthMinutes: storyLengthMinutes,
      title: title,
      imageUrl: imageUrl,
      characterId: characterId,
      characterData: characterData,
      createdAt: createdAt,
      updatedAt: updatedAt,
      isProtagonistStory: true,
      isMultiChapter: false,
      isImageStory: true,  // Wichtig: als Bildergeschichte markieren
      storyPages: storyPages,
      additionalDetails: additionalDetails,
      voiceType: voiceType,
      voiceId: voiceId,
      speechRate: speechRate,
      graphicStyle: graphicStyle,
      sentencesPerPicture: sentencesPerPicture,
    );
  }


  // Factory für neue Art von Geschichten
  static StoryModel createWithProtagonist({
    bool isGlobalStory = false,
    String? id,
    required String protagonistName,
    required int protagonistAge,
    required String protagonistAbilities,
    required String storyTopic,
    required String storySetting,
    int storyLengthMinutes = 3,
    String? content,
    String? title,
    String? imageUrl,
    String? characterId,
    Map<String, dynamic>? characterData,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool isMultiChapter = false,
    String? overallSummary,
    int? chapterCount,
    Map<String, dynamic>? additionalDetails,
    int? wordCount,
    TTSType? voiceType,
    String? voiceId,
    double? speechRate,
    String? graphicStyle,
    String? childName, // Optional für Abwärtskompatibilität
    int? childAge,     // Optional für Abwärtskompatibilität
  }) {
    return StoryModel(
      isGlobalStory: isGlobalStory,
      id: id,
      childName: childName ?? '', // Leere Werte für Kind-Felder bei Protagonist-Stories
      childAge: childAge ?? 0,    // Leere Werte für Kind-Felder bei Protagonist-Stories
      childInterests: protagonistAbilities, // Für Abwärtskompatibilität
      protagonistName: protagonistName,
      protagonistAge: protagonistAge,
      currentTopics: storyTopic,
      storyElements: storySetting,
      storyLengthMinutes: storyLengthMinutes,
      content: content,
      title: title,
      imageUrl: imageUrl,
      characterId: characterId,
      characterData: characterData,
      createdAt: createdAt,
      updatedAt: updatedAt,
      isProtagonistStory: true,
      isMultiChapter: isMultiChapter,
      overallSummary: overallSummary,
      chapterCount: chapterCount ?? 0,
      additionalDetails: additionalDetails,
      wordCount: wordCount,
      voiceType: voiceType,
      voiceId: voiceId,
      speechRate: speechRate,
      graphicStyle: graphicStyle,
    );
  }

  // Neue Factory-Methode für Kapitelgeschichten
  static StoryModel createMultiChapterStory({
    bool isGlobalStory = false,
    String? id,
    required String protagonistName,
    required int protagonistAge,
    required String protagonistAbilities,
    required String storyTopic,
    required String storySetting,
    required String title,
    String? imageUrl,
    int storyLengthMinutes = 5,
    String? characterId,
    Map<String, dynamic>? characterData,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? overallSummary,
    Map<String, dynamic>? additionalDetails,
    int? wordCount,
    TTSType? voiceType,
    String? voiceId,
    double? speechRate,
    String? graphicStyle,
    String? childName,
    int? childAge,
    bool includeChildInStory = false,
  }) {

    return StoryModel(
      isGlobalStory: isGlobalStory,
      id: id,
      childName: childName ?? '', // Leere Werte für Kind-Felder bei Protagonist-Stories
      childAge: childAge ?? 0,    // Leere Werte für Kind-Felder bei Protagonist-Stories
      childInterests: protagonistAbilities, // Für Abwärtskompatibilität
      protagonistName: protagonistName,
      protagonistAge: protagonistAge,
      currentTopics: storyTopic,
      storyElements: storySetting,
      storyLengthMinutes: storyLengthMinutes,
      title: title,
      imageUrl: imageUrl,
      characterId: characterId,
      characterData: characterData,
      createdAt: createdAt,
      updatedAt: updatedAt,
      isProtagonistStory: true,
      isMultiChapter: true,
      overallSummary: overallSummary,
      chapterCount: 0,
      additionalDetails: additionalDetails,
      wordCount: wordCount,
      voiceType: voiceType,
      voiceId: voiceId,
      speechRate: speechRate,
      graphicStyle: graphicStyle,
    );
  }

  // Erstellen von Firestore Map
  Map<String, dynamic> toMap() {
    final map = {
      'language': language,
      'languageName': languageName,
      'childName': childName,
      'childAge': childAge,
      'childInterests': childInterests,
      'protagonistName': protagonistName, // Neue Felder speichern
      'protagonistAge': protagonistAge,   // Neue Felder speichern
      'currentTopics': currentTopics,
      'storyElements': storyElements,
      'storyLengthMinutes': storyLengthMinutes,
      'content': content,
      'title': title ?? extractTitleFromContent(content),
      'createdAt': Timestamp.fromDate(createdAt),
      'imageUrl': imageUrl,
      'characterId': characterId,
      'characterData': characterData,
      'isProtagonistStory': isProtagonistStory,
      'isMultiChapter': isMultiChapter,
      'overallSummary': overallSummary,
      'chapterCount': chapterCount ?? 0,
      'additionalDetails': additionalDetails,
      'wordCount': wordCount ?? _countWords(content),
      'voiceType': voiceType?.index, // Save as int for enum
      'voiceId': voiceId,
      'speechRate': speechRate,
      'graphicStyle': graphicStyle,
      'isImageStory': isImageStory,
      'storyPages': storyPages?.map((page) => page.toMap()).toList(),
      'sentencesPerPicture': sentencesPerPicture,
    };

    if (updatedAt != null) {
      map['updatedAt'] = Timestamp.fromDate(updatedAt!);
    }

    return map;
  }

  // Hilfsmethode zum Zählen der Wörter
  static int? _countWords(String? text) {
    if (text == null || text.isEmpty) return null;
    return text.split(RegExp(r'\s+')).where((word) => word.isNotEmpty).length;
  }

  // Erstellen aus Firestore Map
  static StoryModel fromMap(Map<String, dynamic> map, String documentId) {

    // Kompatibilität mit alten Daten: isShortStory in storyLengthMinutes umwandeln
    int lengthInMinutes = 3; // Standardwert

    // Falls storyLengthMinutes bereits existiert, diesen verwenden
    if (map['storyLengthMinutes'] != null) {
      lengthInMinutes = map['storyLengthMinutes'];
    }
    // Ansonsten von isShortStory konvertieren
    else if (map['isShortStory'] != null) {
      lengthInMinutes = map['isShortStory'] ? 3 : 6; // Kurz = 3 Min., Lang = 6 Min.
    }

    TTSType? voiceType;
    if (map['voiceType'] != null) {
      voiceType = TTSType.values[map['voiceType']];
    }

    // Abwärtskompatibilität: Protagonisten-Felder aus Kind-Feldern ableiten, falls nicht vorhanden
    final String childName = map['childName'] ?? '';
    final int childAge = map['childAge'] ?? 5;
    final String protagonistName = map['protagonistName'] ?? childName;
    final int protagonistAge = map['protagonistAge'] ?? childAge;

    return StoryModel(
      isGlobalStory: map['isGlobalStory'] ?? false,
        language: map['language'] ?? 'de_DE',
        languageName: map['languageName'] ?? 'Deutsch',
        id: documentId,
        childName: childName,
        childAge: childAge,
        childInterests: map['childInterests'] ?? '',
        protagonistName: protagonistName,
        protagonistAge: protagonistAge,
        currentTopics: map['currentTopics'] ?? '',
        storyElements: map['storyElements'] ?? '',
        storyLengthMinutes: lengthInMinutes,
        content: map['content'],
        title: map['title'],
        imageUrl: map['imageUrl'],
        characterId: map['characterId'],
        characterData: map['characterData'],
        createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        updatedAt: (map['updatedAt'] as Timestamp?)?.toDate(),
        isProtagonistStory: map['isProtagonistStory'] ?? false,
        isMultiChapter: map['isMultiChapter'] ?? false,
        overallSummary: map['overallSummary'],
        chapterCount: map['chapterCount'] ?? 0,
        additionalDetails: map['additionalDetails'],
        wordCount: map['wordCount'],
        voiceType: voiceType,
        voiceId: map['voiceId'],
        speechRate: map['speechRate'],
        graphicStyle: map['graphicStyle'],
      isImageStory: map['isImageStory'] ?? false,
      storyPages: map['storyPages'] != null
          ? List<StoryPageModel>.from(
          (map['storyPages'] as List).map((x) => StoryPageModel.fromMap(x)))
          : null,
      sentencesPerPicture: map['sentencesPerPicture'],
    );
  }

  // Extrahiert einen Titel aus dem Inhalt, falls keiner angegeben ist
  static String? extractTitleFromContent(String? content) {
    if (content == null || content.isEmpty) {
      return 'Neue Geschichte';
    }

    // Versuche, eine Überschrift zu finden (# oder ## im Markdown)
    final RegExp titleRegex = RegExp(r'^#\s+(.+)$', multiLine: true);
    final match = titleRegex.firstMatch(content);

    if (match != null && match.groupCount >= 1) {
      return match.group(1);
    }

    // Wenn keine Überschrift gefunden wurde, nimm die ersten Worte
    final firstLine = content.split('\n').first.trim();
    if (firstLine.length > 40) {
      return '${firstLine.substring(0, 37)}...';
    }
    return firstLine;
  }

  // Kopie mit Änderungen erstellen
  StoryModel copyWith({
    bool? isGlobalStory,
    String? language,
    String? languageName,
    String? id,
    String? childName,
    int? childAge,
    String? childInterests,
    String? protagonistName,
    int? protagonistAge,
    String? currentTopics,
    String? storyElements,
    int? storyLengthMinutes,
    String? content,
    String? title,
    String? imageUrl,
    String? characterId,
    Map<String, dynamic>? characterData,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isProtagonistStory,
    bool? isMultiChapter,
    String? overallSummary,
    int? chapterCount,
    Map<String, dynamic>? additionalDetails,
    int? wordCount,
    TTSType? voiceType,
    String? voiceId,
    double? speechRate,
    String? graphicStyle,
    bool? isImageStory,
    List<StoryPageModel>? storyPages,
    int? sentencesPerPicture,
  }) {
    return StoryModel(
      isGlobalStory: isGlobalStory ?? this.isGlobalStory,
      language: language ?? this.language,
      languageName: languageName ?? this.languageName,
      id: id ?? this.id,
      childName: childName ?? this.childName,
      childAge: childAge ?? this.childAge,
      childInterests: childInterests ?? this.childInterests,
      protagonistName: protagonistName ?? this.protagonistName,
      protagonistAge: protagonistAge ?? this.protagonistAge,
      currentTopics: currentTopics ?? this.currentTopics,
      storyElements: storyElements ?? this.storyElements,
      storyLengthMinutes: storyLengthMinutes ?? this.storyLengthMinutes,
      content: content ?? this.content,
      title: title ?? this.title,
      imageUrl: imageUrl ?? this.imageUrl,
      characterId: characterId ?? this.characterId,
      characterData: characterData ?? this.characterData,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isProtagonistStory: isProtagonistStory ?? this.isProtagonistStory,
      isMultiChapter: isMultiChapter ?? this.isMultiChapter,
      overallSummary: overallSummary ?? this.overallSummary,
      chapterCount: chapterCount ?? this.chapterCount,
      additionalDetails: additionalDetails ?? this.additionalDetails,
      wordCount: wordCount ?? this.wordCount,
      voiceType: voiceType ?? this.voiceType,
      voiceId: voiceId ?? this.voiceId,
      speechRate: speechRate ?? this.speechRate,
      graphicStyle: graphicStyle ?? this.graphicStyle,
      isImageStory: isImageStory ?? this.isImageStory,
      storyPages: storyPages ?? this.storyPages,
      sentencesPerPicture: sentencesPerPicture ?? this.sentencesPerPicture, // Neues Feld kopieren
    );
  }

  // Inkrementiert die Kapitelanzahl und gibt die neue Anzahl zurück
  int incrementChapterCount() {
    return (chapterCount ?? 0) + 1;
  }
}
class StoryPageModel {
  final String? imageUrl;
  final String text;
  final int pageNumber;

  StoryPageModel({
    this.imageUrl,
    required this.text,
    required this.pageNumber,
  });

  Map<String, dynamic> toMap() {
    return {
      'imageUrl': imageUrl,
      'text': text,
      'pageNumber': pageNumber,
    };
  }

  factory StoryPageModel.fromMap(Map<String, dynamic> map) {
    return StoryPageModel(
      imageUrl: map['imageUrl'],
      text: map['text'] ?? '',
      pageNumber: map['pageNumber'] ?? 0,
    );
  }
}
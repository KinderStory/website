import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/character_model.dart';

class GlobalCharacterModel {
  final String id;
  final String originalCharacterId;
  final String authorId;
  final String authorName;
  final String name;
  final int age;
  final String? species;
  final String? speciesType;
  final String? speciesTypeKey; // Neues Feld
  final String? abilities;
  final String? personality;
  final String? background;
  final int? colorValue;
  final String? imageUrl;
  final String? graphicStyle; // Neues Feld
  final DateTime createdAt;
  final DateTime publishedAt;
  final int copyCount; // Neues Feld für die Anzahl der Kopien

  // Sprachfelder hinzufügen
  final String language;
  final String languageName;

  // Bewertungsfelder
  final double averageRating;
  final int ratingCount;
  final Map<String, double>? userRatings; // User-ID zu Bewertung

  GlobalCharacterModel({
    required this.id,
    required this.originalCharacterId,
    required this.authorId,
    required this.authorName,
    required this.name,
    required this.age,
    this.species,
    this.speciesType,
    this.speciesTypeKey,
    this.abilities,
    this.personality,
    this.background,
    this.colorValue,
    this.imageUrl,
    this.graphicStyle,
    required this.createdAt,
    required this.publishedAt,
    this.copyCount = 0,
    this.averageRating = 0.0,
    this.ratingCount = 0,
    this.userRatings,
    required this.language, // Standardsprache Deutsch
    required this.languageName, // Standardsprachname
  });

  // Erstellen aus einer CharacterModel-Instanz
  factory GlobalCharacterModel.fromCharacterModel(
      CharacterModel character,
      String authorId,
      String authorName,
      // Sprachparameter hinzufügen
      ) {
    return GlobalCharacterModel(
      id: '',
      originalCharacterId: character.id ?? '',
      authorId: authorId,
      authorName: authorName,
      name: character.name,
      age: character.age,
      species: character.species,
      speciesType: character.speciesType,
      speciesTypeKey: character.speciesTypeKey,
      abilities: character.abilities,
      personality: character.personality,
      background: character.background,
      colorValue: character.colorValue,
      imageUrl: character.imageUrl,
      graphicStyle: character.graphicStyle,
      createdAt: character.createdAt ?? DateTime.now(),
      publishedAt: DateTime.now(),
      copyCount: 0,
      averageRating: 0.0,
      ratingCount: 0,
      userRatings: {},
      language: character.language, // Sprachcode setzen
      languageName: character.languageName, // Sprachname setzen
    );
  }

  // Konvertieren in eine Map für Firestore
  Map<String, dynamic> toMap() {
    return {
      'originalCharacterId': originalCharacterId,
      'authorId': authorId,
      'authorName': authorName,
      'name': name,
      'age': age,
      'species': species,
      'speciesType': speciesType,
      'speciesTypeKey': speciesTypeKey,
      'abilities': abilities,
      'personality': personality,
      'background': background,
      'colorValue': colorValue,
      'imageUrl': imageUrl,
      'graphicStyle': graphicStyle,
      'createdAt': createdAt,
      'publishedAt': publishedAt,
      'copyCount': copyCount,
      'averageRating': averageRating,
      'ratingCount': ratingCount,
      'userRatings': userRatings ?? {},
      'language': language, // Sprachcode in Map einfügen
      'languageName': languageName, // Sprachname in Map einfügen
    };
  }

  // Erstellen aus Firestore Map
  factory GlobalCharacterModel.fromMap(Map<String, dynamic> map, String documentId) {
    return GlobalCharacterModel(
      id: documentId,
      originalCharacterId: map['originalCharacterId'] ?? '',
      authorId: map['authorId'] ?? '',
      authorName: map['authorName'] ?? 'Unbekannter Autor',
      name: map['name'] ?? 'Unbenannter Charakter',
      age: map['age'] ?? 100,
      species: map['species'],
      speciesType: map['speciesType'],
      speciesTypeKey: map['speciesTypeKey'],
      abilities: map['abilities'],
      personality: map['personality'],
      background: map['background'],
      colorValue: map['colorValue'],
      imageUrl: map['imageUrl'],
      graphicStyle: map['graphicStyle'],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      publishedAt: (map['publishedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      copyCount: map['copyCount'] ?? 0,
      averageRating: (map['averageRating'] is int)
          ? (map['averageRating'] as int).toDouble()
          : map['averageRating'] ?? 0.0,
      ratingCount: map['ratingCount'] ?? 0,
      userRatings: map['userRatings'] != null
          ? Map<String, double>.from(map['userRatings'])
          : null,
      language: map['language'] ?? 'de', // Sprachcode aus Map lesen
      languageName: map['languageName'] ?? 'Deutsch', // Sprachname aus Map lesen
    );
  }

  // Konvertieren zu CharacterModel für lokale Anzeige
  CharacterModel toCharacterModel() {
    return CharacterModel(
      id: originalCharacterId,
      name: name,
      age: age,
      species: species,
      speciesType: speciesType,
      speciesTypeKey: speciesTypeKey,
      abilities: abilities,
      personality: personality,
      background: background,
      colorValue: colorValue,
      imageUrl: imageUrl,
      graphicStyle: graphicStyle,
      createdAt: createdAt,
      additionalDetails: {
        'isGlobalCharacter': true,
        'globalCharacterId': id,
        'authorId': authorId,
        'authorName': authorName,
        'averageRating': averageRating,
        'ratingCount': ratingCount,
        'publishedAt': publishedAt,
        'copyCount': copyCount,
        'language': language, // Sprachcode zu additionalDetails hinzufügen
        'languageName': languageName, // Sprachname zu additionalDetails hinzufügen
      },
    );
  }

  // Kopieren mit Änderungen
  GlobalCharacterModel copyWith({
    String? id,
    String? originalCharacterId,
    String? authorId,
    String? authorName,
    String? name,
    int? age,
    String? species,
    String? speciesType,
    String? speciesTypeKey,
    String? abilities,
    String? personality,
    String? background,
    int? colorValue,
    String? imageUrl,
    String? graphicStyle,
    DateTime? createdAt,
    DateTime? publishedAt,
    int? copyCount,
    double? averageRating,
    int? ratingCount,
    Map<String, double>? userRatings,
    String? language, // Sprachcode zu copyWith hinzufügen
    String? languageName, // Sprachname zu copyWith hinzufügen
  }) {
    return GlobalCharacterModel(
      id: id ?? this.id,
      originalCharacterId: originalCharacterId ?? this.originalCharacterId,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      name: name ?? this.name,
      age: age ?? this.age,
      species: species ?? this.species,
      speciesType: speciesType ?? this.speciesType,
      speciesTypeKey: speciesTypeKey ?? this.speciesTypeKey,
      abilities: abilities ?? this.abilities,
      personality: personality ?? this.personality,
      background: background ?? this.background,
      colorValue: colorValue ?? this.colorValue,
      imageUrl: imageUrl ?? this.imageUrl,
      graphicStyle: graphicStyle ?? this.graphicStyle,
      createdAt: createdAt ?? this.createdAt,
      publishedAt: publishedAt ?? this.publishedAt,
      copyCount: copyCount ?? this.copyCount,
      averageRating: averageRating ?? this.averageRating,
      ratingCount: ratingCount ?? this.ratingCount,
      userRatings: userRatings ?? this.userRatings,
      language: language ?? this.language, // Sprachcode im copyWith berücksichtigen
      languageName: languageName ?? this.languageName, // Sprachname im copyWith berücksichtigen
    );
  }
}
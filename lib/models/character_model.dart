// In character_model.dart füge das neue Feld animalType hinzu

import 'package:cloud_firestore/cloud_firestore.dart';

class CharacterModel {
  final String? id;
  final String name;
  final int age;
  final String? species;
  final String? speciesType;
  final String? speciesTypeKey;
  final String? abilities;
  final String? personality;
  final String? background;
  final int? colorValue;
  final Map<String, dynamic>? additionalDetails;
  final String? imageUrl;
  final String? graphicStyle;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? gender;
  final String? animalType;  // Neues Feld für die Tierart
  final String language;        // z. B. "de_DE"
  final String languageName;    // z. B. "Deutsch"


  CharacterModel({
    this.id,
    required this.name,
    required this.age,
    this.species,
    this.speciesType,
    this.speciesTypeKey,
    this.abilities,
    this.personality,
    this.background,
    this.colorValue,
    this.additionalDetails,
    this.imageUrl,
    this.graphicStyle,
    this.createdAt,
    this.updatedAt,
    this.gender,
    this.animalType,
    this.language = 'de_DE',
    this.languageName = 'Deutsch'
  });

  // Factory-Konstruktor zum Erstellen eines CharacterModel aus einer Firestore-Map
  factory CharacterModel.fromMap(Map<String, dynamic> data, [String? docId]) {
    return CharacterModel(
      id: docId ?? data['id'],
      name: data['name'] ?? '',
      age: data['age'] ?? 100,
      species: data['species'],
      speciesType: data['speciesType'],
      speciesTypeKey: data['speciesTypeKey'],
      abilities: data['abilities'],
      personality: data['personality'],
      background: data['background'],
      colorValue: data['colorValue'],
      additionalDetails: data['additionalDetails'],
      imageUrl: data['imageUrl'],
      graphicStyle: data['graphicStyle'],
      gender: data['gender'],
      animalType: data['animalType'],  // Aus der Map auslesen
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : null,
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
      language: data['language'] ?? 'de_DE',
      languageName: data['languageName'] ?? 'Deutsch',
    );
  }

  // Konvertierung in eine Map für Firestore
  Map<String, dynamic> toMap() {
    final now = DateTime.now();
    return {
      'name': name,
      'age': age,
      'species': species,
      'speciesType': speciesType,
      'speciesTypeKey': speciesTypeKey,
      'abilities': abilities,
      'personality': personality,
      'background': background,
      'colorValue': colorValue,
      'additionalDetails': additionalDetails,
      'imageUrl': imageUrl,
      'graphicStyle': graphicStyle,
      'gender': gender,
      'animalType': animalType,  // In die Map schreiben
      'createdAt': createdAt ?? now,
      'updatedAt': now,
      'language': language,
      'languageName': languageName,
    };
  }

  // Erstellt eine Kopie mit aktualisierten Werten
  CharacterModel copyWith({
    String? id,
    String? name,
    int? age,
    String? species,
    String? speciesType,
    String? speciesTypeKey,
    String? abilities,
    String? personality,
    String? background,
    int? colorValue,
    Map<String, dynamic>? additionalDetails,
    String? imageUrl,
    String? graphicStyle,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? gender,
    String? animalType,
    String? language,
    String? languageName,// Zu copyWith hinzugefügt
  }) {
    return CharacterModel(
      id: id ?? this.id,
      name: name ?? this.name,
      age: age ?? this.age,
      species: species ?? this.species,
      speciesType: speciesType ?? this.speciesType,
      speciesTypeKey: speciesTypeKey ?? this.speciesTypeKey,
      abilities: abilities ?? this.abilities,
      personality: personality ?? this.personality,
      background: background ?? this.background,
      colorValue: colorValue ?? this.colorValue,
      additionalDetails: additionalDetails ?? this.additionalDetails,
      imageUrl: imageUrl ?? this.imageUrl,
      graphicStyle: graphicStyle ?? this.graphicStyle,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      gender: gender ?? this.gender,
      animalType: animalType ?? this.animalType,
      language: language ?? this.language,
      languageName: languageName ?? this.languageName,// In der Rückgabe verwenden
    );
  }
}
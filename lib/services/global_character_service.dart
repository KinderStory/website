import 'dart:async'; // Hinzufügen für StreamController
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/character_model.dart';
import '../models/global_character_model.dart';

class GlobalCharacterService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // StreamController für Bewertungsaktualisierungen
  final _ratingUpdatesController = StreamController<Map<String, dynamic>>.broadcast();

  // Öffentlicher Getter für den Stream
  Stream<Map<String, dynamic>> get ratingUpdates => _ratingUpdatesController.stream;
// Neue Methode, um den Pfad zur sprachspezifischen Collection zu erhalten
  String getLanguageCharactersPath(String language) {
    // Standardmäßig 'de' verwenden, wenn keine Sprache angegeben ist
    final languageCode = language.isNotEmpty ? language.split('_')[0] : 'de';
    return 'global_characters/$languageCode/characters';
  }
  // Prüfen, ob ein Charakter bereits veröffentlicht wurde
  Future<bool> isCharacterPublished(String characterId) async {
    // Prüfe in allen unterstützten Sprachen
    List<String> supportedLanguages = ['de', 'en', 'fr', 'es'];

    for (String language in supportedLanguages) {
      final path = getLanguageCharactersPath(language);
      final query = await _firestore
          .collection(path)
          .where('originalCharacterId', isEqualTo: characterId)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        return true;
      }
    }

    return false;
  }

  // Character veröffentlichen
  Future<String> publishCharacter(CharacterModel character) async {
    if (character.id == null) {
      throw Exception('Character has no ID');
    }

    // Prüfen, ob der Nutzer eingeloggt ist
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not logged in');
    }

    // Prüfen, ob der Charakter bereits veröffentlicht wurde
    final isPublished = await isCharacterPublished(character.id!);
    if (isPublished) {
      throw Exception('Character is already published');
    }

    // GlobalCharacterModel erstellen
    final globalCharacter = GlobalCharacterModel.fromCharacterModel(
      character,
      user.uid,
      user.displayName ?? 'Anonymer Nutzer',

    );

    String path = getLanguageCharactersPath(globalCharacter.language);

    // In Firestore speichern, wobei die Sprache jetzt im Pfad berücksichtigt wird
    final docRef = await _firestore.collection(path).add(globalCharacter.toMap());


    // Lokales Charakter-Dokument mit der Information aktualisieren, dass es veröffentlicht wurde
    await _firestore.collection('users').doc(user.uid).collection('characters').doc(character.id).update({
      'additionalDetails.isPublished': true,
      'additionalDetails.globalCharacterId': docRef.id,
    });

    return docRef.id;
  }

// Character aus der öffentlichen Bibliothek entfernen
  Future<void> unpublishCharacter(String characterId, String globalCharacterId) async {
    try {
      // Zuerst den Charakter holen, um die Sprache zu bestimmen
      final charDoc = await _firestore.collection('users')
          .doc(_auth.currentUser?.uid)
          .collection('characters')
          .doc(characterId)
          .get();

      if (!charDoc.exists || charDoc.data() == null) {
        throw Exception('Character not found');
      }

      final charData = charDoc.data()!;
      String language = 'de'; // Standardsprache

      // Versuche die Sprache zu ermitteln
      if (charData['additionalDetails'] != null &&
          charData['additionalDetails']['publishedLanguage'] != null) {
        language = charData['additionalDetails']['publishedLanguage'];
      }

      // Korrekten sprachspezifischen Pfad verwenden
      final path = getLanguageCharactersPath(language);
      await _firestore.collection(path).doc(globalCharacterId).delete();

      // Lokalen Charakter aktualisieren
      await _firestore.collection('users')
          .doc(_auth.currentUser?.uid)
          .collection('characters')
          .doc(characterId)
          .update({
        'additionalDetails.isPublished': false,
        'additionalDetails.globalCharacterId': null,
      });

      print('Character successfully unpublished');
    } catch (e) {
      print('Error unpublishing character: $e');
      throw e;
    }
  }

  Future<GlobalCharacterModel?> getGlobalCharacter(String id, {String language = 'de'}) async {
    try {
      // Korrekten Pfad zur sprachspezifischen Collection verwenden
      final path = getLanguageCharactersPath(language);
      final doc = await _firestore.collection(path).doc(id).get();

      if (doc.exists && doc.data() != null) {
        return GlobalCharacterModel.fromMap(doc.data()!, id);
      }
      return null;
    } catch (e) {
      print('Error getting global character: $e');
      return null;
    }
  }

  Future<void> rateCharacter(String characterId, double rating, {String language = 'de'}) async {
    // Prüfen, ob der Nutzer eingeloggt ist
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not logged in');
    }

    // Korrekten Pfad zur sprachspezifischen Collection verwenden
    final path = getLanguageCharactersPath(language);
    final charRef = _firestore.collection(path).doc(characterId);

    // Charakter abrufen, um zu prüfen, ob er existiert
    final charDoc = await charRef.get();
    if (!charDoc.exists) {
      throw Exception('Character not found');
    }

    // Direkt die Bewertungsaktualisierung durchführen
    return await _updateRating(charRef, user.uid, rating);
  }
  // Hilfsmethode zum Aktualisieren der Bewertung
  Future<void> _updateRating(DocumentReference charRef, String userId, double rating) async {
    await _firestore.runTransaction((transaction) async {
      // Charakter im Transaction abrufen
      final docSnapshot = await transaction.get(charRef);
      if (!docSnapshot.exists) {
        throw Exception('Character does not exist!');
      }

      // Aktuelle Daten
      Map<String, dynamic> data = docSnapshot.data() as Map<String, dynamic>;
      Map<String, double> userRatings = data['userRatings'] != null
          ? Map<String, double>.from(data['userRatings'])
          : {};

      double oldRating = userRatings[userId] ?? 0;
      int currentCount = data['ratingCount'] ?? 0;
      double currentAverage = data['averageRating'] ?? 0.0;

      // Bewertung aktualisieren
      if (rating == 0) {
        // Bewertung zurückziehen
        if (userRatings.containsKey(userId)) {
          userRatings.remove(userId);
          // Durchschnitt neu berechnen
          if (currentCount > 1) {
            // Alte Bewertung aus dem Durchschnitt entfernen
            double newSum = currentAverage * currentCount - oldRating;
            currentCount -= 1;
            currentAverage = newSum / currentCount;
          } else {
            // Wenn es die letzte Bewertung war, setze alles zurück
            currentCount = 0;
            currentAverage = 0.0;
          }
        }
      } else {
        // Neue Bewertung hinzufügen oder bestehende aktualisieren
        bool isNewRating = !userRatings.containsKey(userId) || userRatings[userId] == 0;
        userRatings[userId] = rating;

        // Durchschnitt neu berechnen
        if (isNewRating) {
          // Neue Bewertung
          double newSum = currentAverage * currentCount + rating;
          currentCount += 1;
          currentAverage = newSum / currentCount;
        } else {
          // Bestehende Bewertung aktualisieren
          double newSum = currentAverage * currentCount - oldRating + rating;
          currentAverage = newSum / currentCount;
        }
      }

      // Daten aktualisieren
      transaction.update(charRef, {
        'userRatings': userRatings,
        'ratingCount': currentCount,
        'averageRating': currentAverage,
      });

      // Aktualisierung über den Stream senden
      _ratingUpdatesController.add({
        'characterId': charRef.id,
        'averageRating': currentAverage,
        'ratingCount': currentCount
      });
    });
  }

  Future<double?> getUserRating(String characterId, {String language = 'de'}) async {
    final user = _auth.currentUser;
    if (user == null) return null;

    try {
      // Korrekten Pfad zur sprachspezifischen Collection verwenden
      final path = getLanguageCharactersPath(language);
      final doc = await _firestore.collection(path).doc(characterId).get();

      if (!doc.exists) return null;

      final data = doc.data()!;
      return _extractUserRating(data, user.uid);
    } catch (e) {
      print('Error getting user rating: $e');
      return null;
    }
  }
  // Hilfsmethode zum Extrahieren der Nutzerbewertung
  double? _extractUserRating(Map<String, dynamic> data, String userId) {
    if (data['userRatings'] != null) {
      final Map<String, dynamic> userRatings = data['userRatings'];
      if (userRatings.containsKey(userId)) {
        return userRatings[userId];
      }
    }
    return null;
  }

  // In der Datei global_character_service.dart
// Ändere die Methode getGlobalCharactersWithFilters so:

  Future<List<GlobalCharacterModel>> getGlobalCharactersWithFilters({
    int limit = 10,
    DocumentSnapshot? startAfter,
    String? filterByAuthorId,
    String? searchQuery,
    Map<String, dynamic>? filters,
    String sortBy = 'newest',
    bool descending = true,
    String language = 'de',
  }) async {
    try {
      // Hier den Pfad zur sprachspezifischen Collection holen, analog zu GlobalStoryService
      String path = getLanguageCharactersPath(language);

      // Basis-Query auf die sprachspezifische Collection
      Query query = _firestore.collection(path);

      // WICHTIG: Den Sprachfilter NICHT mehr anwenden, da wir bereits in der richtigen Sprach-Collection sind
      // ENTFERNE DIESE ZEILE: query = query.where('language', isEqualTo: language);

      // Weitere Filter anwenden
      if (filterByAuthorId != null) {
        query = query.where('authorId', isEqualTo: filterByAuthorId);
      }

      // Filter aus dem FilterManager anwenden (unverändert)
      if (filters != null) {
        // Spezies-Typ
        if (filters.containsKey('speciesType')) {
          query = query.where('speciesType', isEqualTo: filters['speciesType']);
        }

        // Grafischer Stil
        if (filters.containsKey('graphicStyle')) {
          query = query.where('graphicStyle', isEqualTo: filters['graphicStyle']);
        }

        // Altersbereich (in der Firestore-Abfrage komplexer)
        if (filters.containsKey('ageMin')) {
          query = query.where('age', isGreaterThanOrEqualTo: filters['ageMin']);
        }
        if (filters.containsKey('ageMax')) {
          query = query.where('age', isLessThanOrEqualTo: filters['ageMax']);
        }

        // Bewertung
        if (filters.containsKey('minRating')) {
          query = query.where('averageRating', isGreaterThanOrEqualTo: filters['minRating']);
        }

        // Veröffentlichungsdatum
        if (filters.containsKey('publishedAfter')) {
          query = query.where('publishedAt', isGreaterThanOrEqualTo: filters['publishedAfter']);
        }
        if (filters.containsKey('publishedBefore')) {
          query = query.where('publishedAt', isLessThanOrEqualTo: filters['publishedBefore']);
        }
      }

      // Sortierung
      String orderField;
      switch (sortBy) {
        case 'rating':
          orderField = 'averageRating';
          break;
        case 'popularity':
          orderField = 'copyCount';
          break;
        case 'name':
          orderField = 'name';
          break;
        case 'newest':
        default:
          orderField = 'publishedAt';
          break;
      }
      query = query.orderBy(orderField, descending: descending);

      // Pagination
      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }

      // Limit
      query = query.limit(limit);

      // Abfrage ausführen
      final querySnapshot = await query.get();

      // Ergebnisse konvertieren
      List<GlobalCharacterModel> characters = [];
      for (var doc in querySnapshot.docs) {
        final character = GlobalCharacterModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);

        // Textsuche (muss in Dart implementiert werden, da Firestore keine Volltextsuche unterstützt)
        if (searchQuery != null && searchQuery.isNotEmpty) {
          final searchLower = searchQuery.toLowerCase();
          final nameMatch = character.name.toLowerCase().contains(searchLower);
          final speciesMatch = character.speciesType?.toLowerCase().contains(searchLower) ?? false;
          final abilitiesMatch = character.abilities?.toLowerCase().contains(searchLower) ?? false;

          if (!(nameMatch || speciesMatch || abilitiesMatch)) {
            continue; // Überspringe, wenn kein Treffer
          }
        }

        characters.add(character);
      }

      return characters;
    } catch (e) {
      print('Error fetching characters with filters: $e');
      return [];
    }
  }

  // Methode zum Erstellen einer lokalen Kopie eines globalen Charakters
  Future<CharacterModel?> copyGlobalCharacterToLocal(String globalCharacterId, {String language = 'de'}) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not logged in');
    }

    try {
      // Globalen Charakter abrufen
      final globalCharacter = await getGlobalCharacter(globalCharacterId, language: language);
      if (globalCharacter == null) {
        throw Exception('Global character not found');
      }

      // CharacterModel erstellen
      final localCharacter = globalCharacter.toCharacterModel();

      // Zusätzliche Infos hinzufügen
      final additionalDetails = Map<String, dynamic>.from(localCharacter.additionalDetails ?? {});
      additionalDetails['isGlobalCopy'] = true;
      additionalDetails['copiedFrom'] = globalCharacterId;
      additionalDetails['originalAuthorId'] = globalCharacter.authorId;
      additionalDetails['originalAuthorName'] = globalCharacter.authorName;
      additionalDetails['copiedAt'] = DateTime.now();

      // Neue ID generieren und alte ID als originalId speichern
      final originalId = localCharacter.id;
      final newCharacter = CharacterModel(
        id: null, // Firebase gibt eine neue ID
        name: localCharacter.name,
        age: localCharacter.age,
        species: localCharacter.species,
        speciesType: localCharacter.speciesType,
        speciesTypeKey: localCharacter.speciesTypeKey,
        abilities: localCharacter.abilities,
        personality: localCharacter.personality,
        background: localCharacter.background,
        colorValue: localCharacter.colorValue,
        imageUrl: localCharacter.imageUrl,
        graphicStyle: localCharacter.graphicStyle,
        createdAt: DateTime.now(),
        additionalDetails: {
          ...additionalDetails,
          'originalGlobalCharacterId': originalId,
        },
      );

      // In Firestore speichern
      final docRef = await _firestore.collection('users').doc(user.uid).collection('characters').add(newCharacter.toMap());

      // Zähler für Kopien erhöhen
      final path = getLanguageCharactersPath(language);
      await _firestore.collection(path).doc(globalCharacterId).update({
        'copyCount': FieldValue.increment(1),
      });

      // Charakter mit neuer ID zurückgeben
      return newCharacter.copyWith(id: docRef.id);
    } catch (e) {
      print('Error copying global character: $e');
      return null;
    }
  }

  // Methode zur Bereinigung des StreamControllers
  void dispose() {
    _ratingUpdatesController.close();
  }
}
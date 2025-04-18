import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/global_story_model.dart';
import '../models/story_model.dart';

class GlobalStoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Neue Methode, um den Pfad zur sprachspezifischen Collection zu erhalten
  String getLanguageStoriesPath(String language) {
    // Standardmäßig 'de' verwenden, wenn keine Sprache angegeben ist
    final languageCode = language.isNotEmpty ? language.split('_')[0] : 'de';
    return 'global_stories/$languageCode/stories';
  }

  // Methode zum Prüfen, ob eine Geschichte bereits veröffentlicht wurde
  Future<bool> isStoryPublished(String storyId) async {
    // Da Geschichten in verschiedenen Sprachkollektionen sein könnten,
    // überprüfen wir alle unterstützten Sprachen
    List<String> supportedLanguages = ['de', 'en', 'fr', 'es'];

    for (final language in supportedLanguages) {
      final query = await _firestore.collection(getLanguageStoriesPath(language))
          .where('originalStoryId', isEqualTo: storyId)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        return true;
      }
    }

    return false;
  }

  // Methode zum Veröffentlichen einer Geschichte
  Future<String> publishStory(StoryModel story) async {
    if (story.id == null) {
      throw Exception('Story ID cannot be null');
    }

    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    // Sprachcode aus dem Story-Modell extrahieren
    final language = story.language.split('_')[0];

    // Globales Story-Objekt erstellen
    final globalStory = GlobalStoryModel.fromStoryModel(
      story,
      user.uid,
      user.displayName ?? user.email?.split('@').first ?? 'Anonymous',
    );

    // Referenz zur entsprechenden Sprachsammlung erstellen
    final docRef = _firestore.collection(getLanguageStoriesPath(language)).doc();

    // Geschichte in der Datenbank speichern
    await docRef.set(globalStory.toMap());

    // ID des neuen Dokuments zurückgeben
    final globalStoryId = docRef.id;

    // Zusätzliche Details im Original aktualisieren
    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('stories')
        .doc(story.id)
        .update({
      'additionalDetails': {
        ...story.additionalDetails ?? {},
        'isPublished': true,
        'globalStoryId': globalStoryId,
        'publishedLanguage': language,
      }
    });

    return globalStoryId;
  }

  // Methode zum Zurückziehen einer veröffentlichten Geschichte
  Future<void> unpublishStory(String originalStoryId, String globalStoryId) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    // Da wir die Sprache der veröffentlichten Geschichte benötigen, holen wir die Story-Details
    final storySnapshot = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('stories')
        .doc(originalStoryId)
        .get();

    if (!storySnapshot.exists) {
      throw Exception('Original story not found');
    }

    // PublishedLanguage aus additionalDetails extrahieren
    final storyData = storySnapshot.data() as Map<String, dynamic>;
    final String publishedLanguage = storyData['additionalDetails']?['publishedLanguage'] ?? 'de';

    // Geschichte aus der globalen Sammlung löschen
    await _firestore
        .collection(getLanguageStoriesPath(publishedLanguage))
        .doc(globalStoryId)
        .delete();

    // Zusätzliche Details im Original aktualisieren
    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('stories')
        .doc(originalStoryId)
        .update({
      'additionalDetails': {
        ...storyData['additionalDetails'] ?? {},
        'isPublished': false,
        'globalStoryId': null,
        'publishedLanguage': null,
      }
    });
  }

  // Methode zum Abrufen einer globalen Geschichte
  Future<GlobalStoryModel?> getGlobalStory(String globalStoryId, {String language = 'de'}) async {
    final doc = await _firestore
        .collection(getLanguageStoriesPath(language))
        .doc(globalStoryId)
        .get();

    if (!doc.exists) {
      return null;
    }

    return GlobalStoryModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
  }

  Future<List<GlobalStoryModel>> getGlobalStoriesWithFilters({
    required int limit,
    DocumentSnapshot? startAfter,
    String? filterByAuthorId,
    String? searchQuery,
    Map<String, dynamic>? filters,
    String? sortBy,
    bool descending = true,
    String language = 'de',
  }) async {
    // Debug-Informationen
    print("Sprache: $language, Limit: $limit, Filter: $filters");

    // Pfad zur sprachspezifischen Collection
    String path = getLanguageStoriesPath(language);
    print("Pfad: $path");

    // Query-Referenz erstellen
    Query query = _firestore.collection(path);

    // Separate Filtervariable für schrittweises Testen
    Query filteredQuery = query;

    // Filter anwenden und schrittweise testen
    if (filterByAuthorId != null) {
      filteredQuery = filteredQuery.where('authorId', isEqualTo: filterByAuthorId);
      print("Filter nach Autor hinzugefügt: $filterByAuthorId");
    }

    // Suchfilter behutsam anwenden
    if (searchQuery != null && searchQuery.isNotEmpty) {
      // Einfacherer Suchfilter - nur nach Titel
      filteredQuery = filteredQuery.where('title', isGreaterThanOrEqualTo: searchQuery)
          .where('title', isLessThanOrEqualTo: searchQuery + '\uf8ff');
      print("Suchfilter hinzugefügt: $searchQuery");
    }

    // Zusätzliche Filter vorsichtig anwenden
    if (filters != null && filters.isNotEmpty) {
      // Filterlogik vereinfachen - max. einen Filter anwenden
      if (filters.containsKey('childAge') && filters['childAge'] != null) {
        filteredQuery = filteredQuery.where('childAge', isEqualTo: filters['childAge']);
        print("Filter nach Kinderalter: ${filters['childAge']}");
      }
      else if (filters.containsKey('isMultiChapter') && filters['isMultiChapter'] != null) {
        filteredQuery = filteredQuery.where('isMultiChapter', isEqualTo: filters['isMultiChapter']);
        print("Filter nach Kapitelgeschichte: ${filters['isMultiChapter']}");
      }
      // Weitere Filter hier einzeln implementieren
    }

    // Wichtig: Sortierung als letztes anwenden
    // Temporär die Sortierung deaktivieren, um zu testen, ob sie das Problem ist
    bool useSorting = true;

    if (useSorting) {
      // Sortierung anwenden
      String sortField = 'publishedAt'; // Standardsortierung

      if (sortBy != null && sortBy.isNotEmpty) {
        // Sicherstellen, dass das Feld existiert
        if (sortBy == 'rating') sortField = 'averageRating';
        else if (sortBy == 'newest') sortField = 'publishedAt';
        else if (sortBy == 'title') sortField = 'title';
        else sortField = 'publishedAt'; // Fallback

        print("Sortierung nach: $sortField (absteigend: $descending)");
      }

      filteredQuery = filteredQuery.orderBy(sortField, descending: descending);
    } else {
      print("ACHTUNG: Sortierung deaktiviert für Testzwecke");
    }

    // Paginierung anwenden
    if (startAfter != null) {
      filteredQuery = filteredQuery.startAfterDocument(startAfter);
      print("Paginierung hinzugefügt");
    }

    // Limit anwenden
    filteredQuery = filteredQuery.limit(limit);
    print("Limit gesetzt auf: $limit");

    try {
      // Query ausführen
      final snapshot = await filteredQuery.get();
      print("Abfrage erfolgreich, Ergebnisse: ${snapshot.docs.length}");

      // Wenn keine Ergebnisse, mache eine einfache Abfrage ohne Filter
      if (snapshot.docs.isEmpty) {
        print("Keine Ergebnisse mit Filtern. Teste einfache Abfrage...");
        final simpleSnapshot = await _firestore.collection(path).limit(limit).get();
        print("Einfache Abfrage Ergebnisse: ${simpleSnapshot.docs.length}");

        if (simpleSnapshot.docs.isNotEmpty) {
          // Für Debug: Struktur des ersten Dokuments anzeigen
          Map<String, dynamic> firstDoc = simpleSnapshot.docs.first.data();
          print("Felder im ersten Dokument: ${firstDoc.keys.join(', ')}");

          // Prüfe, ob Sortierungsfeld existiert
          if (sortBy != null && !firstDoc.containsKey(sortBy)) {
            print("WARNUNG: Sortierungsfeld '$sortBy' existiert nicht im Dokument");
          }
          if (!firstDoc.containsKey('publishedAt')) {
            print("WARNUNG: Standard-Sortierungsfeld 'publishedAt' fehlt im Dokument");
          }
        }
      }

      // Ergebnisse in GlobalStoryModel-Objekte umwandeln
      final stories = snapshot.docs.map((doc) {
        try {
          return GlobalStoryModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
        } catch (e) {
          print("Fehler beim Konvertieren des Dokuments ${doc.id}: $e");
          // Rückgabe eines leeren Modells als Fallback
          return null;
        }
      }).whereType<GlobalStoryModel>().toList(); // Filtere null-Werte

      print("Erfolgreich ${stories.length} Geschichten geladen");
      return stories;

    } catch (e) {
      print("Fehler bei der Datenbankabfrage: $e");

      // Bei Index-Fehlern einen hilfreichen Hinweis geben
      if (e.toString().contains('index')) {
        print("HINWEIS: Du benötigst möglicherweise einen zusammengesetzten Index. " +
            "Folge dem Link in der Fehlermeldung in der Firebase Console.");
      }

      // Leere Liste zurückgeben bei Fehler
      return [];
    }
  }

  // Methode zum Abrufen der Bewertung eines Benutzers für eine Geschichte
  Future<double?> getUserRating(String storyId, {String language = 'de'}) async {
    final user = _auth.currentUser;
    if (user == null) {
      return null;
    }

    final doc = await _firestore
        .collection(getLanguageStoriesPath(language))
        .doc(storyId)
        .get();

    if (!doc.exists) {
      return null;
    }

    final data = doc.data() as Map<String, dynamic>;
    if (!data.containsKey('userRatings') || data['userRatings'] == null) {
      return null;
    }

    final userRatings = Map<String, dynamic>.from(data['userRatings']);
    return userRatings[user.uid]?.toDouble();
  }

  // Methode zum Bewerten einer Geschichte
  Future<void> rateStory(String storyId, double rating, {String language = 'de'}) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    // Aktuelle Bewertungsdaten abrufen
    final storyDoc = await _firestore
        .collection(getLanguageStoriesPath(language))
        .doc(storyId)
        .get();

    if (!storyDoc.exists) {
      throw Exception('Story not found');
    }

    final storyData = storyDoc.data() as Map<String, dynamic>;

    // Aktuelle Bewertungen abrufen oder neue Map erstellen
    Map<String, dynamic> userRatings = storyData.containsKey('userRatings') && storyData['userRatings'] != null
        ? Map<String, dynamic>.from(storyData['userRatings'])
        : {};

    // Prüfen, ob der Benutzer diese Geschichte bereits bewertet hat
    bool hasRated = userRatings.containsKey(user.uid);
    double? oldRating = hasRated ? userRatings[user.uid]?.toDouble() : null;

    // Durchschnittliche Bewertung und Bewertungszahl berechnen
    double averageRating = storyData.containsKey('averageRating') ? storyData['averageRating']?.toDouble() ?? 0.0 : 0.0;
    int ratingCount = storyData.containsKey('ratingCount') ? storyData['ratingCount'] ?? 0 : 0;

    // Wenn der Benutzer seine Bewertung entfernt
    if (rating == 0) {
      if (hasRated) {
        userRatings.remove(user.uid);

        // Bewertungszahl und Durchschnitt anpassen
        ratingCount--;

        if (ratingCount > 0) {
          // Gesamtsumme berechnen und alte Bewertung abziehen
          double totalRating = averageRating * (ratingCount + 1) - (oldRating ?? 0);
          averageRating = totalRating / ratingCount;
        } else {
          averageRating = 0.0;
        }
      }
    } else {
      // Neue Bewertung hinzufügen oder bestehende aktualisieren
      userRatings[user.uid] = rating;

      if (!hasRated) {
        // Neue Bewertung
        ratingCount++;
        double totalRating = averageRating * (ratingCount - 1) + rating;
        averageRating = totalRating / ratingCount;
      } else {
        // Aktualisierte Bewertung
        double totalRating = averageRating * ratingCount - (oldRating ?? 0) + rating;
        averageRating = totalRating / ratingCount;
      }
    }

    // Datenbank aktualisieren
    await _firestore
        .collection(getLanguageStoriesPath(language))
        .doc(storyId)
        .update({
      'userRatings': userRatings,
      'averageRating': averageRating,
      'ratingCount': ratingCount,
    });
  }
  // Methode zum Erstellen einer lokalen Kopie einer globalen Geschichte
// Methode zum Erstellen einer lokalen Kopie einer globalen Geschichte
  Future<StoryModel?> copyGlobalStoryToLocal(String globalStoryId, {String language = 'de'}) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not logged in');
    }

    try {
      // Globale Geschichte abrufen
      final globalStory = await getGlobalStory(globalStoryId, language: language);
      if (globalStory == null) {
        throw Exception('Global story not found');
      }

      // StoryModel erstellen
      final localStory = globalStory.toStoryModel();

      // Zusätzliche Infos hinzufügen
      final additionalDetails = Map<String, dynamic>.from(localStory.additionalDetails ?? {});
      additionalDetails['isGlobalCopy'] = true;

      additionalDetails['copiedFrom'] = globalStoryId;
      additionalDetails['originalAuthorId'] = globalStory.authorId;
      additionalDetails['originalAuthorName'] = globalStory.authorName;
      additionalDetails['copiedAt'] = DateTime.now();
      additionalDetails['globalStoryId'] = globalStoryId; // Original-ID speichern
      additionalDetails['isArchived'] = false;

      // Neue ID generieren und Story in Firestore speichern
      final docRef = await _firestore.collection('users').doc(user.uid).collection('stories').add(
          {
            ...localStory.toMap(),
            'additionalDetails': additionalDetails,
          }
      );

      // Zähler für Kopien erhöhen, wenn vorhanden
      final path = getLanguageStoriesPath(language);
      await _firestore.collection(path).doc(globalStoryId).update({
        'copyCount': FieldValue.increment(1),
      });

      // Bei Kapitelgeschichten die Kapitel separat abrufen und kopieren
      if (localStory.isMultiChapter) {
        // Kapitel der globalen Geschichte abrufen
        final chaptersSnapshot = await _firestore
            .collection(path)
            .doc(globalStoryId)
            .collection('chapters')
            .orderBy('chapterNumber')
            .get();

        if (chaptersSnapshot.docs.isNotEmpty) {
          // Collection für Kapitel erstellen
          final chaptersRef = _firestore
              .collection('users')
              .doc(user.uid)
              .collection('stories')
              .doc(docRef.id)
              .collection('chapters');

          // Alle Kapitel kopieren
          for (var chapterDoc in chaptersSnapshot.docs) {
            await chaptersRef.add(chapterDoc.data());
          }

          // Kapitelanzahl aktualisieren
          await docRef.update({
            'chapterCount': chaptersSnapshot.docs.length,
          });
        }
      }

      // Geschichte mit neuer ID zurückgeben
      return localStory.copyWith(
        id: docRef.id,
        additionalDetails: additionalDetails,
      );
    } catch (e) {
      print('Error copying global story: $e');
      throw Exception('Fehler beim Kopieren der Geschichte: $e');
    }
  }
}
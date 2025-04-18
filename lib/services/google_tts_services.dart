import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import 'package:crypto/crypto.dart';
import 'dart:math';

class GoogleTTSService {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  String? _currentText;
  String _selectedVoice = 'de-DE-Wavenet-A'; // Standard-Stimme
  double _speakingRate = 0.85; // Standardgeschwindigkeit (0.25 bis 4.0)
  String _currentLanguage = 'de_DE'; // Standardsprache

  // Überarbeitete Map für alle Sprachen und Stimmen
  final Map<String, Map<String, String>> _availableVoicesByLanguage = {
    // Deutsch
    'de_DE': {
      // Wavenet-Stimmen
      'de-DE-Wavenet-A': 'Emma',
      'de-DE-Wavenet-B': 'Philipp',
      'de-DE-Wavenet-C': 'Lena',
      'de-DE-Wavenet-E': 'Tom',
      'de-DE-Wavenet-F': 'Sophie',
      // Chirp3-HD-Stimmen
      'de-DE-Chirp3-HD-Aoede': 'Lea',
      'de-DE-Chirp3-HD-Charon': 'Felix',
      'de-DE-Chirp3-HD-Fenrir': 'Lukas',
      'de-DE-Chirp3-HD-Kore': 'Marie',
      'de-DE-Chirp3-HD-Leda': 'Julia',
      'de-DE-Chirp3-HD-Orus': 'Sebastian',
      'de-DE-Chirp3-HD-Puck': 'Karsten',
    },

    // Englisch
    'en_GB': {
      // Wavenet-Stimmen
      'en-GB-Wavenet-A': 'Emma',
      'en-GB-Wavenet-B': 'Thomas',
      'en-GB-Wavenet-C': 'Olivia',
      'en-GB-Wavenet-D': 'James',
      'en-GB-Wavenet-F': 'Sophie',
      // Chirp3-HD-Stimmen
      'en-GB-Chirp3-HD-Aoede': 'Charlotte',
      'en-GB-Chirp3-HD-Charon': 'Harry',
      'en-GB-Chirp3-HD-Fenrir': 'William',
      'en-GB-Chirp3-HD-Kore': 'Lucy',
      'en-GB-Chirp3-HD-Leda': 'Julia',
      'en-GB-Chirp3-HD-Orus': 'Thommy',
      'en-GB-Chirp3-HD-Puck': 'Jeff',
    },
    // Englisch
    'en_US': {
      // Wavenet-Stimmen
      'en-US-Wavenet-A': 'Emma',
      'en-US-Wavenet-B': 'Thomas',
      'en-US-Wavenet-C': 'Olivia',
      'en-US-Wavenet-D': 'James',
      'en-US-Wavenet-F': 'Sophie',
      // Chirp3-HD-Stimmen
      'en-US-Chirp3-HD-Achernar': 'Laura',
      'en-US-Chirp3-HD-Aoede': 'Charlotte',
      'en-US-Chirp3-HD-Charon': 'Harry',
      'en-US-Chirp3-HD-Fenrir': 'William',
      'en-US-Chirp3-HD-Kore': 'Lucy',
      'en-US-Chirp3-HD-Leda': 'Julia',
      'en-US-Chirp3-HD-Orus': 'Thommy',
      'en-US-Chirp3-HD-Puck': 'Jeff',
      'en-US-Chirp3-HD-Sulafat': 'Lisa',
      'en-US-Chirp3-HD-Zephyr': 'Lauren',
    },

    // Spanisch
    'es_ES': {
      // Wavenet-Stimmen
      'es-ES-Wavenet-B': 'Alberto',
      'es-ES-Wavenet-C': 'Laura',
      'es-ES-Wavenet-D': 'Sofia',
      'es-ES-Wavenet-E': 'Carlos',
      'es-ES-Wavenet-F': 'Elena',
      // Chirp3-HD-Stimmen

      'es-ES-Chirp3-HD-Aoede': 'Isabella',
      'es-ES-Chirp3-HD-Charon': 'Miguel',
      'es-ES-Chirp3-HD-Fenrir': 'Hugo',
      'es-ES-Chirp3-HD-Kore': 'Paula',
      'es-ES-Chirp3-HD-Leda': 'Sara',
      'es-ES-Chirp3-HD-Orus': 'Alejandro',
      'es-ES-Chirp3-HD-Puck': 'Pablo',
    },

    // Französisch
    'fr_FR': {
      // Wavenet-Stimmen
      'fr-FR-Wavenet-A': 'Marie',
      'fr-FR-Wavenet-B': 'Pierre',
      'fr-FR-Wavenet-C': 'Sophie',
      'fr-FR-Wavenet-D': 'Antoine',
      'fr-FR-Wavenet-E': 'Amélie',
      // Chirp3-HD-Stimmen
      'fr-FR-Chirp3-HD-Aoede': 'Charlotte',
      'fr-FR-Chirp3-HD-Charon': 'Francois',
      'fr-FR-Chirp3-HD-Fenrir': 'Jean',
      'fr-FR-Chirp3-HD-Kore': 'Aurelie',
      'fr-FR-Chirp3-HD-Leda': 'Juliette',
      'fr-FR-Chirp3-HD-Orus': 'Alain',
      'fr-FR-Chirp3-HD-Puck': 'Nicolas',
    },
  };

  GoogleTTSService() {
    _initPlayer();
  }
// In der GoogleTTSService-Klasse, stelle sicher, dass speakWithoutCache immer die aktuellste Stimme verwendet:

// Auch die speakWithoutCache-Methode muss aktualisiert werden,
// um das Text-Chunking zu unterstützen:

  Future<void> speakWithoutCache(String text, {String? language, String? forceVoice}) async {
    print("\n\n=== TTS STATE CHECK ===");
    print("Vor dem Sprechen: _selectedVoice=$_selectedVoice");
    print("Vor dem Sprechen: _currentLanguage=$_currentLanguage");
    print("Vor dem Sprechen: Verfügbare Stimmen für $_currentLanguage: ${availableVoices.keys.join(', ')}");
    print("========================\n\n");

    // Zuerst Stimme erzwingen, falls vorhanden (höchste Priorität)
    if (forceVoice != null) {
      print("Stimme wird erzwungen auf: $forceVoice");
      await setVoice(forceVoice);
    }

    // Dann Sprache setzen, falls angegeben
    if (language != null && language != _currentLanguage) {
      print("Sprache wird gesetzt auf: $language (vorher: $_currentLanguage)");
      // Aktuelle Stimme merken
      final currentVoice = _selectedVoice;
      // Sprache setzen
      setLanguage(language);
      // Wenn wir eine forcierte Stimme haben, setze sie erneut (um sicherzustellen, dass
      // sie nicht von setLanguage überschrieben wurde)
      if (forceVoice != null) {
        print("Stimme wird nach Sprachänderung erneut erzwungen: $forceVoice");
        await setVoice(forceVoice);
      }
      // Sonst wenn keine forcierte Stimme, aber wir vor setLanguage eine hatten,
      // versuche, sie beizubehalten, falls sie zur neuen Sprache passt
      else if (currentVoice != _selectedVoice) {
        if (currentVoice.startsWith(language.split('_')[0].toLowerCase())) {
          print("Versuche, bisherige Stimme $currentVoice beizubehalten");
          await setVoice(currentVoice);
        }
      }
    }

    print("Nach Sprach-/Stimmkonfiguration: _selectedVoice=$_selectedVoice");
    print("========================\n\n");

    if (_isPlaying) {
      await stop();
    }

    _currentText = _stripMarkdown(text);

    // Teile langen Text in Chunks auf, wenn er zu groß ist
    final List<String> textChunks = [];
    final int textBytes = utf8.encode(_currentText!).length;

    if (textBytes > 4000) { // Sicherheitsabstand zur 5000-Byte-Grenze
      print('Text ist zu lang (${textBytes} Bytes), teile in Chunks');
      textChunks.addAll(_splitTextIntoChunks(_currentText!, 3000));
    } else {
      textChunks.add(_currentText!);
    }

    try {
      // Für jeden Chunk einzeln die TTS-API aufrufen
      for (int i = 0; i < textChunks.length; i++) {
        final String chunk = textChunks[i];

        if (i > 0) {
          // Warte, bis der vorherige Audio-Chunk abgespielt wurde, bevor der nächste gestartet wird
          while (_isPlaying) {
            await Future.delayed(Duration(milliseconds: 100));
          }
        }

        final apiKey = dotenv.env['GOOGLE_TTS_API_KEY'];
        if (apiKey == null || apiKey.isEmpty) {
          throw Exception('Google TTS API-Schlüssel nicht gefunden.');
        }

        final url = 'https://texttospeech.googleapis.com/v1/text:synthesize?key=$apiKey';

        // Verwende den Sprachcode aus der ausgewählten Stimme
        final languageCode = _getLanguageCodeFromVoice(_selectedVoice);

        // Diagnostische Ausgabe
        print("=========== TTS DIAGNOSE (OHNE CACHE) ===========");
        print("Aktuelle Sprache: $_currentLanguage");
        print("Sprachcode für API: $languageCode");
        print("Ausgewählte Stimme: $_selectedVoice");
        print("Verfügbare Stimmen: ${availableVoices.keys.join(', ')}");
        print("Chunk ${i+1}/${textChunks.length}: ${utf8.encode(chunk).length} Bytes");

        final effectiveSpeakingRate = _getAppropriateSpeakingRate(_selectedVoice, _currentLanguage, _speakingRate);
        print("Effektive Sprechgeschwindigkeit ohne Cache: $effectiveSpeakingRate (angefordert: $_speakingRate)");

        final requestBody = jsonEncode({
          'input': {'text': chunk},
          'voice': {
            'languageCode': languageCode,
            'name': _selectedVoice,
          },
          'audioConfig': {
            'audioEncoding': 'MP3',
            'speakingRate': effectiveSpeakingRate,  // Hier die angepasste Rate verwenden
            'pitch': 0.0,
          },
        });

        print("API-Anfrage: $requestBody");

        // Sende die Anfrage
        final response = await http.post(
          Uri.parse(url),
          headers: {'Content-Type': 'application/json'},
          body: requestBody,
        );

        print("API-Antwort Status: ${response.statusCode}");

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);

          // Prüfe, ob die Antwort audioContent enthält
          if (data.containsKey('audioContent')) {
            final audioContent = data['audioContent'];
            print("Audio-Daten empfangen, Länge: ${audioContent.length}");

            // Spiele direkt ab
            final bytes = base64Decode(audioContent);
            await _audioPlayer.play(BytesSource(bytes));
            _isPlaying = true;

            // Optional: Cache aktualisieren
            await _saveToCacheFile(bytes, chunk, _selectedVoice, _currentLanguage, _speakingRate);

            // Warte auf das Abspielen des Chunks, bevor der nächste abgespielt wird
            if (i < textChunks.length - 1) {
              await _audioPlayer.onPlayerComplete.first;
            }
          } else {
            print("Fehler: Keine Audio-Daten in der Antwort");
            print("Antwort-Inhalt: $data");
          }
        } else {
          print("API-Fehler: ${response.statusCode}");
          print("Fehler-Details: ${response.body}");
          throw Exception('Fehler bei der Anfrage an Google TTS API');
        }
        print("====================================");
      }
    } catch (e) {
      print('Fehler beim direkten API-Aufruf: $e');
      rethrow;
    }
  }
  Future<void> listAvailableVoices() async {
    try {
      final apiKey = dotenv.env['GOOGLE_TTS_API_KEY'];
      if (apiKey == null || apiKey.isEmpty) {
        throw Exception('Google TTS API-Schlüssel nicht gefunden.');
      }

      final url = 'https://texttospeech.googleapis.com/v1/voices?key=$apiKey';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print("Verfügbare Stimmen laut API:");
        if (data.containsKey('voices')) {
          final voices = data['voices'] as List;
          for (var voice in voices) {
            print("Name: ${voice['name']}, Sprache: ${voice['languageCodes'].join(', ')}");
          }
        }
      } else {
        print("Fehler beim Abrufen der verfügbaren Stimmen: ${response.statusCode}, ${response.body}");
      }
    } catch (e) {
      print('Fehler beim Abrufen der Stimmen: $e');
    }
  }

  void _initPlayer() {
    _audioPlayer.onPlayerComplete.listen((event) {
      _isPlaying = false;
    });
  }

  // Methode zum Setzen der Sprache
// Die korrigierte setLanguage-Methode

  void setLanguage(String language) {
    print("\n### LANGUAGE DEBUG START ###");
    print("setLanguage aufgerufen mit: $language");
    print("aktueller Wert von _selectedVoice: $_selectedVoice");

    if (_availableVoicesByLanguage.containsKey(language)) {
      // Speichere aktuelle Stimme für spätere Überprüfung
      final oldVoice = _selectedVoice;

      // Sprache aktualisieren
      _currentLanguage = language;

      // WICHTIG: Prüfe ob die aktuelle Stimme zur neuen Sprache passt
      final languagePrefix = language.split('_')[0].toLowerCase();
      final voiceLanguagePrefix = _selectedVoice.split('-')[0].toLowerCase();

      // Nur wenn die Stimme nicht zur neuen Sprache passt, setze eine neue Stimme
      if (languagePrefix != voiceLanguagePrefix) {
        print("Die aktuelle Stimme ($_selectedVoice) passt nicht zur neuen Sprache ($language)");

        // Wähle erste Stimme für die neue Sprache
        final voiceMap = _availableVoicesByLanguage[_currentLanguage]!;
        _selectedVoice = voiceMap.keys.first;
        print("Neue Standardstimme gesetzt: $_selectedVoice");
      } else {
        // Wenn die Stimme zur Sprache passt, prüfe ob sie in der Liste gültiger Stimmen ist
        final voicesForLanguage = _availableVoicesByLanguage[_currentLanguage] ?? {};
        if (!voicesForLanguage.containsKey(_selectedVoice)) {
          print("Stimme $_selectedVoice nicht in der Liste gültiger Stimmen für $_currentLanguage gefunden.");
          // Wähle erste Stimme aus der Liste
          _selectedVoice = voicesForLanguage.keys.first;
          print("Stimme auf erste verfügbare Stimme gesetzt: $_selectedVoice");
        } else {
          print("Die aktuelle Stimme ($_selectedVoice) passt zur neuen Sprache - behalte sie bei");
        }
      }

      print("Stimme geändert von $oldVoice zu $_selectedVoice");
    } else {
      print("WARNUNG: Sprache '$language' nicht gefunden!");
    }

    print("Wert von _selectedVoice nach setLanguage: $_selectedVoice");
    print("### LANGUAGE DEBUG END ###\n");
  }

  // Getter für verfügbare Stimmen der aktuellen Sprache
  Map<String, String> get availableVoices {
    return _availableVoicesByLanguage[_currentLanguage] ?? _availableVoicesByLanguage['de_DE']!;
  }

  String getVoiceName(String voiceId) {
    final voicesForCurrentLanguage = _availableVoicesByLanguage[_currentLanguage] ?? _availableVoicesByLanguage['de_DE']!;
    return voicesForCurrentLanguage[voiceId] ?? voiceId;
  }

  String get selectedVoice => _selectedVoice;

  String get currentLanguage => _currentLanguage;

  bool get isPlaying => _isPlaying;

  // Generiert einen eindeutigen Dateinamen basierend auf Text, Stimme, Sprache und Geschwindigkeit
// In der GoogleTTSService-Klasse, ändere die Methode _generateCacheFileName:

// Generiert einen eindeutigen Dateinamen basierend auf Text, Stimme, Sprache und Geschwindigkeit
  String _generateCacheFileName(String text, String voice, String language, double rate) {
    // Debug-Ausgabe, um zu sehen, welche Werte in die Hash-Generierung einfließen
    print("CACHE-SCHLÜSSEL: Text=${text.substring(0, min(20, text.length))}, Stimme=$voice, Sprache=$language, Rate=$rate");

    // Explizites Anhängen der Stimmen-ID am Dateinamen, damit wir sie leichter erkennen können
    final hash = md5.convert(utf8.encode('$text-$voice-$language-$rate')).toString();
    return '${voice}_${hash}.mp3';
  }

  // Prüft, ob eine Cache-Datei existiert
  Future<File?> _getCachedFile(String text, String voice, String language, double rate) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final fileName = _generateCacheFileName(text, voice, language, rate);
      final file = File('${directory.path}/tts_cache/$fileName');

      if (await file.exists()) {
        print('Cached file exists: ${file.path}');
        return file;
      }
      print('No cached file found');
      return null;
    } catch (e) {
      print('Fehler beim Prüfen des Cache: $e');
      return null;
    }
  }

  // Neue öffentliche Methode, um zu prüfen, ob Text bereits im Cache ist
  Future<bool> isInCache(String text) async {
    final processedText = _stripMarkdown(text);
    final cachedFile = await _getCachedFile(processedText, _selectedVoice, _currentLanguage, _speakingRate);
    return cachedFile != null;
  }

  // Speichert eine MP3-Datei im Cache
  Future<File> _saveToCacheFile(List<int> bytes, String text, String voice, String language, double rate) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final cacheDir = Directory('${directory.path}/tts_cache');
      if (!await cacheDir.exists()) {
        await cacheDir.create(recursive: true);
        print('Cache directory created: ${cacheDir.path}');
      }

      final fileName = _generateCacheFileName(text, voice, language, rate);
      final file = File('${cacheDir.path}/$fileName');
      await file.writeAsBytes(bytes);
      print('File saved to cache: ${file.path}');
      return file;
    } catch (e) {
      print('Fehler beim Speichern der Cache-Datei: $e');
      rethrow;
    }
  }

  // Private Methode, um die Markdown-Formatierung zu entfernen
  // Verbesserte Methode zum Entfernen der Markdown-Formatierung und unerwünschter Zeichen
  String _stripMarkdown(String markdownText) {
    // Zuerst den gesamten Text in einzelne Zeilen aufteilen
    List<String> lines = markdownText.split('\n');
    List<String> cleanedLines = [];

    // Alle Zeilen durchgehen und individuell bereinigen
    for (int i = 0; i < lines.length; i++) {
      String line = lines[i];

      // Überschriftenzeilen komplett überspringen
      if (line.trim().startsWith('#')) {
        continue;
      }

      // Andere Zeilen bereinigen und hinzufügen
      cleanedLines.add(line);
    }

    // Text wieder zusammenfügen ohne die Überschriftenzeilen
    String plainText = cleanedLines.join('\n');

    // Restliche Markdown-Formatierungen entfernen
    plainText = plainText.replaceAll(RegExp(r'#{1,6}\s+(.+)'), r'$1');  // Überschriften im Text
    plainText = plainText.replaceAll(RegExp(r'\*\*(.*?)\*\*'), r'$1');  // Fett
    plainText = plainText.replaceAll(RegExp(r'\*(.*?)\*'), r'$1');      // Kursiv
    plainText = plainText.replaceAll(RegExp(r'\_\_(.*?)\_\_'), r'$1');  // Fett mit Unterstrichen
    plainText = plainText.replaceAll(RegExp(r'\_(.*?)\_'), r'$1');      // Kursiv mit Unterstrichen

    // Links entfernen
    plainText = plainText.replaceAll(RegExp(r'\[(.*?)\]\(.*?\)'), r'$1');

    // Listen-Marker ersetzen
    plainText = plainText.replaceAll(RegExp(r'^\s*[-*+]\s', multiLine: true), '. ');

    // Absätze und Zeilenumbrüche verarbeiten
    plainText = plainText.replaceAll(RegExp(r'\n\s*\n'), '. ');
    plainText = plainText.replaceAll(RegExp(r'(?<!\.)(?<!\?)(?<!\!)\n'), ', ');

    // Überflüssige Leerzeichen und Satzzeichen bereinigen
    plainText = plainText.replaceAll(RegExp(r'\s{2,}'), ' ');
    plainText = plainText.replaceAll(',.', '.');
    plainText = plainText.replaceAll('..', '.');
    plainText = plainText.replaceAll(',,', ',');

    // Alle Unicode-Zeichen außerhalb des Standardbereichs entfernen
    plainText = plainText.replaceAll(RegExp(r'[^\x20-\x7E\xA0-\xFF\u0100-\u017F]'), '');

    return plainText.trim();
  }
  // Korrigierte setVoice-Methode

// 1. Füge eine Debug-Variable hinzu, um die Stimme zu verfolgen
  String get debugVoiceInfo {
    return "DIAGNOSE: _selectedVoice=$_selectedVoice, Sprache=$_currentLanguage, Verfügbare Stimmen: ${availableVoices.keys.take(3).join(', ')}...";
  }

// 2. Ändere die setVoice-Methode, um sicherzustellen, dass sie korrekt funktioniert
// In google_tts_services.dart
// Überprüfe die setVoice-Methode:

  Future<void> setVoice(String voiceId) async {
    print("\n### VOICE DEBUG START ###");
    print("setVoice aufgerufen mit: $voiceId");
    print("aktueller Wert von _selectedVoice: $_selectedVoice");

    // Hier liegt möglicherweise das Problem!
    // Die Abfrage filtert möglicherweise die Stimme heraus
    final currentVoices = _availableVoicesByLanguage[_currentLanguage] ?? _availableVoicesByLanguage['de_DE']!;

    print("Verfügbare Stimmen für $_currentLanguage: ${currentVoices.keys.join(', ')}");
    print("Ist $voiceId in der Liste enthalten? ${currentVoices.containsKey(voiceId)}");

    // Die Bedingung prüft, ob die Stimme für die aktuelle Sprache verfügbar ist
    if (currentVoices.containsKey(voiceId)) {
      // Speichere die Stimme
      _selectedVoice = voiceId;
      print("Stimme erfolgreich auf $_selectedVoice gesetzt");
    } else {
      print("FEHLER: Stimme $voiceId nicht gefunden für Sprache $_currentLanguage!");
      // Hier ist ein wichtiger Fix - falls die Stimme nicht gefunden wird,
      // überprüfe ob es sich um eine Stimme handelt, die zur aktuellen Sprache passt
      if (voiceId.startsWith(_currentLanguage.split('_')[0])) {
        print("Stimme scheint zur Sprache zu passen. Setze sie trotzdem.");
        _selectedVoice = voiceId;
      }
    }

    print("Wert von _selectedVoice nach Methode: $_selectedVoice");
    print("### VOICE DEBUG END ###\n");
  }

// WICHTIG: Prüfe auch die setLanguage-Methode:



// Neue Methode zum Löschen von Cache-Dateien für eine bestimmte Stimme
  Future<void> clearVoiceCache(String voiceId) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final cacheDir = Directory('${directory.path}/tts_cache');

      if (!await cacheDir.exists()) {
        return;
      }

      // Dateien im Cache-Verzeichnis durchsuchen
      final files = await cacheDir.list().toList();
      for (var entity in files) {
        if (entity is File) {
          // Hier prüfen wir nur, ob der Dateiname die Stimmen-ID enthält
          // Das ist eine vereinfachte Lösung, aber funktioniert für diesen Zweck
          if (entity.path.contains(voiceId)) {
            await entity.delete();
            print("Gelöschte Cache-Datei für Stimme $voiceId: ${entity.path}");
          }
        }
      }
    } catch (e) {
      print('Fehler beim Löschen des Stimmen-Cache: $e');
    }
  }

  Future<void> setSpeakingRate(double rate) async {
    // Beschränke die Rate auf den gültigen Bereich (0.25 bis 4.0)
    _speakingRate = rate.clamp(0.25, 4.0);
  }

  // Hilfsmethode zum Extrahieren des Sprachcodes aus der Stimmen-ID
  String _getLanguageCodeFromVoice(String voiceId) {
    final parts = voiceId.split('-');
    if (parts.length >= 2) {
      return '${parts[0]}-${parts[1]}';
    }
    return 'de-DE'; // Fallback
  }

// Korrigierte speak-Methode für GoogleTTSService
// Neue Funktion zum Aufteilen langer Texte in kleinere Chunks
// Füge diese Funktion zur GoogleTTSService-Klasse hinzu

// Diese Funktion teilt langen Text in Chunks auf, wobei die Grenzen an Satzenden liegen
  List<String> _splitTextIntoChunks(String text, int maxChunkBytes) {
    // Ungefähr 3000 Bytes als sicherer Grenzwert (unter der 5000-Byte-Grenze)
    final int safeChunkSize = maxChunkBytes;

    // Text in Sätze aufteilen
    final RegExp sentenceRegex = RegExp(r'[.!?]+\s+');
    final List<String> sentences = text.split(sentenceRegex)
        .map((s) => s.trim() + '. ') // Satzzeichen wieder hinzufügen
        .where((s) => s.trim().isNotEmpty)
        .toList();

    final List<String> chunks = [];
    String currentChunk = '';

    for (final sentence in sentences) {
      // Wenn die aktuelle Chunk-Größe + neue Sätze die maximale Größe überschreitet,
      // speichere den aktuellen Chunk und starte einen neuen
      if (utf8.encode(currentChunk + sentence).length > safeChunkSize && currentChunk.isNotEmpty) {
        chunks.add(currentChunk);
        currentChunk = sentence;
      } else {
        currentChunk += sentence;
      }
    }

    // Letzten Chunk hinzufügen, wenn nicht leer
    if (currentChunk.isNotEmpty) {
      chunks.add(currentChunk);
    }

    // Debug-Informationen
    print('Text wurde in ${chunks.length} Chunks aufgeteilt:');
    for (int i = 0; i < chunks.length; i++) {
      print('Chunk $i: ${utf8.encode(chunks[i]).length} Bytes, beginnt mit: ${chunks[i].substring(0, min(30, chunks[i].length))}...');
    }

    return chunks;
  }

// Modifizierte speak-Methode, die mit Chunks arbeitet
  Future<void> speak(String text, {String? language, String? forceVoice}) async {
    // Debug: Zeige die aktuellen Einstellungen vor dem Sprechen
    print("SPRECHE MIT STIMME: $_selectedVoice, SPRACHE: $_currentLanguage, TEXT: ${text.substring(0, min(50, text.length))}");
    // Zuerst Stimme erzwingen, falls vorhanden (höchste Priorität)
    if (forceVoice != null) {
      print("Stimme wird erzwungen auf: $forceVoice");
      await setVoice(forceVoice);
    }
    // Wenn eine Sprache angegeben wurde, setze sie
    if (language != null && _availableVoicesByLanguage.containsKey(language)) {
      setLanguage(language);
    }

    if (_isPlaying) {
      await stop();
    }

    _currentText = _stripMarkdown(text);

    // Teile langen Text in Chunks auf, wenn er zu groß ist
    final List<String> textChunks = [];
    final int textBytes = utf8.encode(_currentText!).length;

    if (textBytes > 4000) { // Sicherheitsabstand zur 5000-Byte-Grenze
      print('Text ist zu lang (${textBytes} Bytes), teile in Chunks');
      textChunks.addAll(_splitTextIntoChunks(_currentText!, 3000));
    } else {
      textChunks.add(_currentText!);
    }

    try {
      // Für jeden Chunk einzeln die TTS-API aufrufen
      for (int i = 0; i < textChunks.length; i++) {
        final String chunk = textChunks[i];

        if (i > 0) {
          // Warte, bis der vorherige Audio-Chunk abgespielt wurde, bevor der nächste gestartet wird
          // Implementiere hier eine Lösung, um auf das Ende des Abspielens zu warten
          while (_isPlaying) {
            await Future.delayed(Duration(milliseconds: 100));
          }
        }

        // Prüfe, ob die Audiodatei bereits im Cache ist
        final cachedFile = await _getCachedFile(chunk, _selectedVoice, _currentLanguage, _speakingRate);

        if (cachedFile != null) {
          print('Verwende gecachte Audiodatei für Chunk ${i+1}/${textChunks.length}: ${cachedFile.path}');
          // Spiele die gecachte Datei ab
          await _audioPlayer.play(DeviceFileSource(cachedFile.path));
          _isPlaying = true;

          // Warte auf das Abspielen des Chunks, bevor der nächste abgespielt wird
          if (i < textChunks.length - 1) {
            await _audioPlayer.onPlayerComplete.first;
          }

          continue;
        }

        // Wenn nicht im Cache, rufe die Google TTS API auf
        print('Keine gecachte Datei gefunden, generiere neue Audio für Chunk ${i+1}/${textChunks.length}');
        final apiKey = dotenv.env['GOOGLE_TTS_API_KEY'];

        if (apiKey == null || apiKey.isEmpty) {
          throw Exception('Google TTS API-Schlüssel nicht gefunden. Bitte in .env Datei hinzufügen.');
        }

        final url = 'https://texttospeech.googleapis.com/v1/text:synthesize?key=$apiKey';

        // Extrahiere den Sprachcode aus der ausgewählten Stimme
        final languageCode = _getLanguageCodeFromVoice(_selectedVoice);

        // Debug: API-Anfrage protokollieren
        print("TTS API-Anfrage für Chunk ${i+1}/${textChunks.length}: Stimme=$_selectedVoice, Sprache=$languageCode");
        print("Chunk-Größe: ${utf8.encode(chunk).length} Bytes");

        final effectiveSpeakingRate = _getAppropriateSpeakingRate(_selectedVoice, _currentLanguage, _speakingRate);
        print("Effektive Sprechgeschwindigkeit: $effectiveSpeakingRate (angefordert: $_speakingRate)");

        final response = await http.post(
          Uri.parse(url),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'input': {'text': chunk},
            'voice': {
              'languageCode': languageCode,
              'name': _selectedVoice,
            },
            'audioConfig': {
              'audioEncoding': 'MP3',
              'speakingRate': effectiveSpeakingRate,  // Hier die angepasste Rate verwenden
              'pitch': 0.0, // Neutrale Tonhöhe
            },
          }),
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final audioContent = data['audioContent'];

          // Konvertiere Base64 zu Bytes
          final bytes = base64Decode(audioContent);

          // Speichere die Audiodaten im Cache
          final cachedFile = await _saveToCacheFile(bytes, chunk, _selectedVoice, _currentLanguage, _speakingRate);
          print("Neue Audio gespeichert in: ${cachedFile.path}");

          // Spiele die Audio-Bytes ab
          await _audioPlayer.play(BytesSource(bytes));
          _isPlaying = true;

          // Warte auf das Abspielen des Chunks, bevor der nächste abgespielt wird
          if (i < textChunks.length - 1) {
            await _audioPlayer.onPlayerComplete.first;
          }
        } else {
          print("API-Fehler: ${response.statusCode}, ${response.body}");
          throw Exception('Fehler bei der Anfrage an Google TTS API: ${response.body}');
        }
      }
    } catch (e) {
      print('Fehler bei der Text-to-Speech-Umwandlung: $e');
      rethrow;
    }
  }
  Future<void> stop() async {
    try {
      // Stoppe den Audio-Player
      if (_isPlaying) {
        await _audioPlayer.stop();
        _isPlaying = false;
        _currentText = null; // Text zurücksetzen

        // Debug-Ausgabe
        print('TTS: Audio wurde gestoppt.');
      }
    } catch (e) {
      print('Fehler beim Stoppen der Audio-Wiedergabe: $e');
    }
  }
  Future<void> dispose() async {
    await stop();
    await _audioPlayer.dispose();
  }

// Hilfsmethode, um zu prüfen, ob es sich um eine Chirp-HD-Stimme handelt
  bool _isChirpHDVoice(String voiceId) {
    return voiceId.contains('-HD-');
  }

// Hilfsmethode, um die richtige Sprechgeschwindigkeit zu bestimmen
  double _getAppropriateSpeakingRate(String voiceId, String language, double requestedRate) {
    // Wenn es eine Chirp-HD-Stimme ist und NICHT en-US ist, verwende 1.0 als Standardgeschwindigkeit
    if (_isChirpHDVoice(voiceId) && !language.startsWith('en_US')) {
      return 1.0;  // Standardgeschwindigkeit für HD-Stimmen
    }

    // Ansonsten verwende die angeforderte Rate
    return requestedRate;
  }
  // Cache-Verwaltung
  Future<void> clearCache() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final cacheDir = Directory('${directory.path}/tts_cache');
      if (await cacheDir.exists()) {
        await cacheDir.delete(recursive: true);
        print('TTS-Cache gelöscht');
      }
    } catch (e) {
      print('Fehler beim Löschen des Cache: $e');
    }
  }

  // Gibt die Gesamtgröße des Caches zurück
  Future<String> getCacheSize() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final cacheDir = Directory('${directory.path}/tts_cache');
      if (!await cacheDir.exists()) {
        return "0 MB";
      }

      int totalSize = 0;
      final files = await cacheDir.list().toList();
      for (var file in files) {
        if (file is File) {
          totalSize += await file.length();
        }
      }

      // In MB konvertieren
      final sizeMB = totalSize / (1024 * 1024);
      return "${sizeMB.toStringAsFixed(2)} MB";
    } catch (e) {
      print('Fehler beim Ermitteln der Cache-Größe: $e');
      return "Unbekannt";
    }
  }
}
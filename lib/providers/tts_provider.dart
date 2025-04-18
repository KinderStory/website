import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/story_model.dart';
import '../services/flutter_tts.dart';
import '../services/google_tts_services.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:permission_handler/permission_handler.dart';

enum TTSType { local, google }

class TTSProvider extends ChangeNotifier {
  final TTSService _localTTS = TTSService();
  final GoogleTTSService _googleTTS = GoogleTTSService();
  FlutterTts? _flutterTts;
  TTSType _currentType = TTSType.local;
  bool _isPlaying = false;
  String? _currentVoiceId;
  double _speechRate = 0.5;
  String _currentLanguage = 'de_DE';
  TTSProvider() {
    _loadSettings();
  }

  TTSType get currentType => _currentType;
  bool get isPlaying => _isPlaying;
  double get speechRate => _speechRate;
  String? get currentVoiceId => _currentVoiceId;
  String get currentLanguage => _currentLanguage;

  Map<String, String> get availableGoogleVoices {
    _googleTTS.setLanguage(_currentLanguage);
    return _googleTTS.availableVoices;
  }

// In TTSProvider.setLanguage
  Future<void> setLanguage(String language) async {
    if (_currentLanguage == language) return;

    _currentLanguage = language;
    _googleTTS.setLanguage(language);

    // Cache leeren beim Sprachwechsel
    await _googleTTS.clearCache();

    // Stimme wählen
    final voices = _googleTTS.availableVoices;
    if (voices.isNotEmpty) {
      String newVoiceId = voices.keys.first;
      await setGoogleVoice(newVoiceId);
      print("Sprache geändert auf: $language, neue Stimme: $newVoiceId");
    }

    await _saveSettings();
    notifyListeners();
  }
  // Methode zum Initialisieren der FlutterTts-Instanz
  Future<void> _initTts() async {
    _flutterTts = FlutterTts();

    // Grundeinstellungen
    await _flutterTts!.setLanguage("de-DE");
    await _flutterTts!.setSpeechRate(_speechRate);
    await _flutterTts!.setPitch(1.0);

    // Plattformspezifische Einstellungen
    if (Platform.isAndroid) {
      await _flutterTts!.setEngine("com.google.android.tts");

      // Weitere Android-spezifische Einstellungen
      await _flutterTts!.setSilence(200); // Pause zwischen Chunks

      // Format auf ein weitverbreitetes, kompatibles Format setzen
      // Für Audio-Export ist ein unterstütztes Format wichtig
      var ttsOptions = {
        "audio_encoding": "mp3", // MP3-Format explizit anfordern
        "voice_name": "de-de-x-deb-local", // Standardstimme verwenden
      };
      await _flutterTts!.setIosAudioCategory(IosTextToSpeechAudioCategory.playback, [
        IosTextToSpeechAudioCategoryOptions.allowBluetooth,
        IosTextToSpeechAudioCategoryOptions.allowBluetoothA2DP,
        IosTextToSpeechAudioCategoryOptions.mixWithOthers
      ]);

      await _flutterTts!.awaitSpeakCompletion(true);
      await _flutterTts!.awaitSynthCompletion(true);
    } else if (Platform.isIOS) {
      // iOS-spezifische Einstellungen
      await _flutterTts!.setSharedInstance(true);
      await _flutterTts!.setIosAudioCategory(
        IosTextToSpeechAudioCategory.playback,
        [
          IosTextToSpeechAudioCategoryOptions.allowBluetooth,
          IosTextToSpeechAudioCategoryOptions.allowBluetoothA2DP,
          IosTextToSpeechAudioCategoryOptions.mixWithOthers
        ],
      );
    }
  }
  // Methode zum Exportieren von Audio
  Future<String?> exportAudio({
    required String text,
    required String fileName,
    Function(double)? onProgress,
  }) async {
    try {
      // Überprüfe und fordere Berechtigungen an (für Android)
      if (Platform.isAndroid) {
        // Bei neueren Android-Versionen ist es besser, App-spezifischen Speicher zu verwenden
        final tempDir = await getApplicationDocumentsDirectory(); // App-spezifisches Verzeichnis
        final filePath = '${tempDir.path}/$fileName.mp3';

        // Stelle sicher, dass TTS-Engine bereit ist
        if (_flutterTts == null) {
          await _initTts();
        }

        // Fortschrittsschätzung initialisieren
        int totalChunks = 0;
        int processedChunks = 0;

        // Text in Abschnitte aufteilen, um Fortschritt zu verfolgen
        List<String> chunks = _splitTextIntoChunks(text);
        totalChunks = chunks.length;

        if (onProgress != null) {
          onProgress(0.0);
        }

        // Audio-Datei erstellen
        File file = File(filePath);
        if (await file.exists()) {
          await file.delete();
        }
        await file.create();

        // Temporäres Verzeichnis für Chunks
        final chunkDir = await Directory('${tempDir.path}/chunks').create(recursive: true);
        List<String> chunkPaths = [];

        // Jedes Chunk in separate Datei synthetisieren
        for (int i = 0; i < chunks.length; i++) {
          final chunkPath = '${chunkDir.path}/chunk_$i.mp3';
          await _flutterTts!.synthesizeToFile(
            chunks[i],
            chunkPath,
          );
          chunkPaths.add(chunkPath);

          processedChunks++;
          if (onProgress != null) {
            onProgress(processedChunks / totalChunks);
          }

          // Kurze Pause, um die TTS-Engine zu entlasten
          await Future.delayed(const Duration(milliseconds: 100));
        }

        // Alle Chunks zusammenführen
        await _mergeAudioFiles(chunkPaths, filePath);

        // Temporäre Chunk-Dateien löschen
        await chunkDir.delete(recursive: true);

        if (onProgress != null) {
          onProgress(1.0);
        }

        return filePath;
      }
      // Bei iOS
      else if (Platform.isIOS) {
        final tempDir = await getTemporaryDirectory();
        final filePath = '${tempDir.path}/$fileName.mp3';

        if (_flutterTts == null) {
          await _initTts();
        }

        if (onProgress != null) {
          onProgress(0.0);
        }

        await _flutterTts!.synthesizeToFile(
          text,
          filePath,
        );

        if (onProgress != null) {
          onProgress(1.0);
        }

        return filePath;
      } else {
        throw Exception('Plattform wird nicht unterstützt');
      }
    } catch (e) {
      print('Fehler beim Audio-Export: $e');
      return null;
    }
  }

// Text in Chunks aufteilen, um den Fortschritt besser zu verfolgen
  List<String> _splitTextIntoChunks(String text, {int chunkSize = 500}) {
    List<String> chunks = [];

    // Teile Text in Sätze auf
    final sentences = text.split(RegExp(r'(?<=[.!?])\s+'));

    String currentChunk = '';
    for (final sentence in sentences) {
      if ((currentChunk + sentence).length <= chunkSize) {
        currentChunk += sentence + ' ';
      } else {
        if (currentChunk.isNotEmpty) {
          chunks.add(currentChunk.trim());
        }
        currentChunk = sentence + ' ';
      }
    }

    if (currentChunk.isNotEmpty) {
      chunks.add(currentChunk.trim());
    }

    // Wenn keine Sätze erkannt wurden, teile nach Länge
    if (chunks.isEmpty) {
      for (int i = 0; i < text.length; i += chunkSize) {
        int end = (i + chunkSize < text.length) ? i + chunkSize : text.length;
        chunks.add(text.substring(i, end));
      }
    }

    return chunks;
  }


// Audio-Dateien zusammenführen (benötigt ffmpeg oder eine native Implementierung)
  Future<void> _mergeAudioFiles(List<String> inputFiles, String outputFile) async {
    try {
      // Hier würde eine Implementierung mit ffmpeg oder einer nativen Audio-Bibliothek folgen
      // Da dies komplex ist, verwenden wir eine vereinfachte Lösung für dieses Beispiel

      // In einer realen Implementierung würden wir ffmpeg verwenden:
      // await FFmpegKit.execute('-i "concat:${inputFiles.join('|')}" -acodec copy $outputFile');

      // Vereinfachte Lösung: Dateien einfach aneinanderhängen (nicht perfekt, aber funktional)
      final outputFileObj = File(outputFile);
      final sink = outputFileObj.openWrite();

      for (final inputFile in inputFiles) {
        final bytes = await File(inputFile).readAsBytes();
        sink.add(bytes);
      }

      await sink.flush();
      await sink.close();
    } catch (e) {
      print('Fehler beim Zusammenführen der Audio-Dateien: $e');
      rethrow;
    }
  }

  // Aktualisierte _loadSettings-Methode, um auch die Sprache zu laden
  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // TTS-Typ laden (0 = lokal, 1 = Google)
      final typeIndex = prefs.getInt('tts_type') ?? 0;
      _currentType = TTSType.values[typeIndex];

      // Sprachgeschwindigkeit laden
      _speechRate = prefs.getDouble('speech_rate') ?? 0.5;
      await setRate(_speechRate);

      // Sprache laden
      final language = prefs.getString('tts_language') ?? 'de_DE';
      _currentLanguage = language;
       _googleTTS.setLanguage(language);

      // Stimme laden (falls Google TTS)
      if (_currentType == TTSType.google) {
        final voiceId = prefs.getString('google_voice_id');
        if (voiceId != null) {
          _currentVoiceId = voiceId;
          await _googleTTS.setVoice(voiceId);
        }
      }

      notifyListeners();
    } catch (e) {
      print('Fehler beim Laden der TTS-Einstellungen: $e');
    }
  }

  // Aktualisierte _saveSettings-Methode, um auch die Sprache zu speichern
  Future<void> _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      await prefs.setInt('tts_type', _currentType.index);
      await prefs.setDouble('speech_rate', _speechRate);
      await prefs.setString('tts_language', _currentLanguage);

      if (_currentType == TTSType.google && _currentVoiceId != null) {
        await prefs.setString('google_voice_id', _currentVoiceId!);
      }
    } catch (e) {
      print('Fehler beim Speichern der TTS-Einstellungen: $e');
    }
  }

// In der TTSProvider-Klasse

  Future<void> speak(String text, {String? language}) async {
    print("\n### SPEAK-METHODE AUFGERUFEN ###");
    print("Aktuelle Einstellungen: Typ=$_currentType, Sprache=$_currentLanguage, Stimme=$_currentVoiceId");

    if (_isPlaying) {
      await stop();
    }

    try {
      if (_currentType == TTSType.local) {
        await _localTTS.speak(text);
      } else {
        print("Google TTS wird verwendet");

        // LÖSUNG: speakWithoutCache durch speak ersetzen
        // Dadurch wird der Cache verwendet
        await _googleTTS.speak(
            text,
            language: language ?? _currentLanguage,
            forceVoice: _currentVoiceId
        );
      }

      _isPlaying = true;
      notifyListeners();

      _checkPlaybackStatus();
    } catch (e) {
      print('Fehler beim Vorlesen: $e');
      rethrow;
    }

    print("### SPEAK-METHODE BEENDET ###\n");
  }

  // Method to get current settings as a map for updating a story
  Map<String, dynamic> getCurrentVoiceSettings() {
    return {
      'voiceType': _currentType,
      'voiceId': _currentVoiceId,
      'speechRate': _speechRate,
      'language': _currentLanguage,  // Neue Eigenschaft
    };
  }

  // Method to apply story-specific settings
  void applyStorySettings(StoryModel story) {
    if (story.voiceType != null) {
      setType(story.voiceType!);
    }

    // Wenn die Geschichte eine Sprache hat, diese setzen
    if (story.language != null) {
      setLanguage(story.language);
    }

    if (story.voiceId != null) {
      setGoogleVoice(story.voiceId!);
    }

    if (story.speechRate != null) {
      setRate(story.speechRate!);
    }
  }

  // TTS-Typ ändern (lokal oder Google)
  Future<void> setType(TTSType type) async {
    if (_isPlaying) {
      await stop();
    }

    _currentType = type;
    await _saveSettings();
    notifyListeners();
  }

  // Sprachgeschwindigkeit setzen
  Future<void> setRate(double rate) async {
    _speechRate = rate;

    if (_currentType == TTSType.local) {
      await _localTTS.setSpeechRate(rate);
    } else {
      // Für Google TTS: 0.25 bis 4.0, mappen von 0.2-0.8 auf 0.5-1.5
      final googleRate = 0.5 + (rate - 0.2) * (1.0 / 0.6);
      await _googleTTS.setSpeakingRate(googleRate);
    }

    await _saveSettings();
    notifyListeners();
  }
// In TTSProvider-Klasse hinzufügen:
  String getVoiceDisplayName(String? voiceId) {
    if (voiceId == null) return "Standard";

    // Direkte Suche in der aktuellen Sprache
    final currentVoices = availableGoogleVoices;
    if (currentVoices.containsKey(voiceId)) {
      return currentVoices[voiceId]!;
    }

    // Wenn nicht gefunden, in allen Sprachen suchen
    for (var language in ["de_DE", "en_GB", "en_US", "fr_FR", "es_ES"]) {
      final voices = getAvailableVoicesForLanguage(language);
      if (voices.containsKey(voiceId)) {
        return voices[voiceId]!;
      }
    }

    // Als Fallback die ID selbst zurückgeben
    return voiceId;
  }
  // Stimme setzen (für Google TTS)
  Future<void> setGoogleVoice(String voiceId) async {
    if (_currentType == TTSType.google) {
      print("\n\n### TTSProvider.setGoogleVoice: voiceId=$voiceId ###");

      // Prüfe den Zustand von GoogleTTSService vor der Änderung
      print("### GoogleTTSService VOR dem Setzen: ${_googleTTS.debugVoiceInfo} ###");

      // Setze die Stimme
      await _googleTTS.setVoice(voiceId);

      // Aktualisiere den lokalen Zustand
      _currentVoiceId = voiceId;

      // Prüfe, ob die Änderung erfolgreich war
      print("### GoogleTTSService NACH dem Setzen: ${_googleTTS.debugVoiceInfo} ###");

      // Speichern und Benachrichtigen
      await _saveSettings();
      notifyListeners();

      // Zusätzlicher Test, direkt die Stimme abfragen
      print("### Stimmenvergleich: TTSProvider._currentVoiceId=$_currentVoiceId, GoogleTTS._selectedVoice=${_googleTTS.selectedVoice} ###");

      // NOTLÖSUNG: Falls die Stimmen nicht übereinstimmen, einen erneuten Versuch unternehmen
      if (_googleTTS.selectedVoice != voiceId) {
        print("### WARNUNG: Stimmenänderung fehlgeschlagen! Versuche erneut... ###");
        await _googleTTS.setVoice(voiceId);
        print("### Nach erneutem Versuch: GoogleTTS._selectedVoice=${_googleTTS.selectedVoice} ###");
      }

      print("### TTSProvider.setGoogleVoice: ENDE ###\n\n");
    }
  }
// In TTSProvider-Klasse
  String? getValidVoiceIdForLanguage(String language) {
    // Speichert die aktuelle Sprache
    final originalLanguage = _currentLanguage;

    try {
      // Setzt temporär die Sprache für die Überprüfung
      _googleTTS.setLanguage(language);

      // Holt verfügbare Stimmen für diese Sprache
      final availableVoices = _googleTTS.availableVoices;

      // Prüft, ob die aktuelle Stimme in dieser Sprache verfügbar ist
      if (_currentVoiceId != null && availableVoices.containsKey(_currentVoiceId)) {
        return _currentVoiceId; // Die aktuelle Stimme ist gültig
      } else {
        // Wählt die erste verfügbare Stimme als Fallback
        return availableVoices.isNotEmpty ? availableVoices.keys.first : null;
      }
    } finally {
      // Stellt die ursprüngliche Sprache wieder her
      _googleTTS.setLanguage(originalLanguage);
    }
  }
  Map<String, String> getAvailableVoicesForLanguage(String language) {
    _googleTTS.setLanguage(language);
    return _googleTTS.availableVoices;
  }
  // Vorlesen stoppen
  Future<void> stop() async {
    if (_currentType == TTSType.local) {
      await _localTTS.stop();
    } else {
      await _googleTTS.stop();
    }

    _isPlaying = false;
    notifyListeners();
  }

  // Status der Wiedergabe überprüfen
  void _checkPlaybackStatus() {
    Future.delayed(const Duration(milliseconds: 500), () {
      bool stillPlaying = false;

      if (_currentType == TTSType.local) {
        stillPlaying = _localTTS.isPlaying;
      } else {
        stillPlaying = _googleTTS.isPlaying;
      }

      if (stillPlaying != _isPlaying) {
        _isPlaying = stillPlaying;
        notifyListeners();
      }

      if (_isPlaying) {
        _checkPlaybackStatus();
      }
    });
  }

  // Neue Methode: Prüfen, ob eine Story im Cache ist
  Future<bool> isStoryInCache(String text) async {
    if (_currentType == TTSType.google) {
      return await _googleTTS.isInCache(text);
    }
    return false;
  }
// In TTSProvider-Klasse hinzufügen:
  Future<void> speakTestSample(String text) async {
    // Testsample abspielen ohne Status zu ändern
    if (currentType == TTSType.local) {
      await _localTTS.speak(text);
    } else {
      await _googleTTS.speak(text);
    }
  }
  // Neue Methode: Cache leeren
  Future<void> clearCache() async {
    if (_currentType == TTSType.google) {
      await _googleTTS.clearCache();
    }
  }

  Future<void> testDirectAPI(String text) async {
    await _googleTTS.speakWithoutCache(text);
  }
  // Neue Methode: Cache-Größe abrufen
  Future<String> getCacheSize() async {
    if (_currentType == TTSType.google) {
      return await _googleTTS.getCacheSize();
    }
    return "0 MB";
  }
  Future<void> checkAvailableVoices() async {
    await _googleTTS.listAvailableVoices();
  }
  // Ressourcen freigeben
  @override
  void dispose() {
    _localTTS.dispose();
    _googleTTS.dispose();
    super.dispose();
  }
}
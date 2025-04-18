import 'package:flutter_tts/flutter_tts.dart';

class TTSService {
  final FlutterTts _flutterTts = FlutterTts();
  bool _isPlaying = false;

  TTSService() {
    _initTts();
  }

  Future<void> _initTts() async {
    // Setze grundlegende TTS-Konfigurationen
    await _flutterTts.setLanguage('de-DE'); // Deutsch
    await _flutterTts.setSpeechRate(0.5); // Langsamer für Kinder
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);

    // Registriere Callback für Zustandsänderungen
    _flutterTts.setCompletionHandler(() {
      _isPlaying = false;
    });
  }

  // Markdown-Text in reinen Text umwandeln
  String _stripMarkdown(String markdownText) {
    // Entferne Überschriften
    String plainText = markdownText.replaceAll(RegExp(r'#{1,6}\s'), '');

    // // Entferne fett und kursiv
    plainText = plainText.replaceAll(RegExp(r'\*\*(.*?)\*\*'),r'$1');
     plainText = plainText.replaceAll(RegExp(r'\*(.*?)\*'), r'$1');
    //
    // // Entferne Links
     plainText = plainText.replaceAll(RegExp(r'\[(.*?)\]\(.*?\)'), r'$1');

    // Ersetze Listen-Marker
    plainText = plainText.replaceAll(RegExp(r'^\s*[-*+]\s', multiLine: true), '');

    // Entferne Codeblocks und Inline-Code
    plainText = plainText.replaceAll(RegExp(r'```.*?```', dotAll: true), '');
     plainText = plainText.replaceAll(RegExp(r'`(.*?)`'), r'$1');

    return plainText;
  }

  // Text vorlesen
  Future<void> speak(String text) async {
    if (_isPlaying) {
      await stop();
    }

    String plainText = _stripMarkdown(text);
    _isPlaying = true;
    await _flutterTts.speak(plainText);
  }

  // Vorlesen pausieren
  Future<void> pause() async {
    if (_isPlaying) {
      _isPlaying = false;
      await _flutterTts.pause();
    }
  }

  // // Vorlesen fortsetzen
  // Future<void> resume() async {
  //   if (!_isPlaying) {
  //     _isPlaying = true;
  //     await _flutterTts.speak(_currentText);
  //   }
  // }

  // Vorlesen stoppen
  Future<void> stop() async {
    _isPlaying = false;
    await _flutterTts.stop();
  }

  // Ist gerade am Vorlesen?
  bool get isPlaying => _isPlaying;

  // Aktuelle Sprache ändern
  Future<void> setLanguage(String language) async {
    await _flutterTts.setLanguage(language);
  }

  // Sprechgeschwindigkeit ändern (0.0 bis 1.0)
  Future<void> setSpeechRate(double rate) async {
    await _flutterTts.setSpeechRate(rate);
  }

  // Verfügbare Stimmen abrufen
  Future<List<dynamic>> getVoices() async {
    return await _flutterTts.getVoices;
  }

  // Stimme nach ID setzen
  Future<void> setVoice(String voiceId) async {
    await _flutterTts.setVoice({"name": voiceId, "locale": "de-DE"});
  }

  // Ressourcen freigeben
  Future<void> dispose() async {
    await stop();
  }
}
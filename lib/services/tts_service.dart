import 'dart:ui';

import 'package:flutter_tts/flutter_tts.dart';
import 'package:stacked/stacked.dart';

enum TtsState { playing, stopped }

class TtsService with ListenableServiceMixin {
  late FlutterTts flutterTts;
  double volume = 1;
  double pitch = 1.0;
  static const SPEECH_RATE_EN = 0.45;
  static const SPEECH_RATE_ES = 0.37;

  final ReactiveValue<TtsState> _ttsState =
      ReactiveValue<TtsState>(TtsState.stopped);

  TtsState get ttsState => _ttsState.value;

  get isPlaying => _ttsState.value == TtsState.playing;

  get isStopped => _ttsState.value == TtsState.stopped;

  TtsService() {
    flutterTts = FlutterTts();

    _setAwaitOptions();

    _initialiseSetting();

    flutterTts.setStartHandler(() {
      print("Playing");
      _ttsState.value = TtsState.playing;
      notifyListeners();
    });

    flutterTts.setCompletionHandler(() {
      print("Complete");
      _ttsState.value = TtsState.stopped;
      notifyListeners();
    });

    flutterTts.setCancelHandler(() {
      print("Cancel");
      _ttsState.value = TtsState.stopped;
      notifyListeners();
    });

    flutterTts.setErrorHandler((msg) {
      // print("error: $msg");
      _ttsState.value = TtsState.stopped;
      notifyListeners();
    });
  }

  Future _setAwaitOptions() async {
    await flutterTts.awaitSpeakCompletion(true);
  }

  Future _initialiseSetting() async {
    await flutterTts.setVolume(volume);
    await flutterTts.setSpeechRate(SPEECH_RATE_EN);
    await flutterTts.setPitch(pitch);
  }

  Future setLanguage(Locale language) async {
    if (language.languageCode == 'es') {
      await flutterTts.setSpeechRate(SPEECH_RATE_ES);
    } else {
      await flutterTts.setSpeechRate(SPEECH_RATE_EN);
    }
    await flutterTts.setLanguage(language.languageCode);
  }

  Future speak(String text) async {
    if (text != null && text.isNotEmpty) {
      text = applyRules(text);
      await flutterTts.speak(text);
    }
  }

  String applyRules(String text) {
    String appliedText = dashRule(text);
    appliedText = periodRule(appliedText);
    appliedText = poundsRule(appliedText);
    appliedText = pluralRule(appliedText);
    appliedText = NARule(appliedText);
    appliedText = slashRule(appliedText);
    appliedText = egRule(appliedText);

    return appliedText;
  }

  // Rule 1. Convert dash
  String dashRule(String text) {
    if (text.contains('-')) {
      text = text.replaceAll('-', 'to');
    }
    return text;
  }

  // Rule 2. Add period
  String periodRule(String text) {
    RegExp regex = RegExp(r"[a-zA-Z]$");
    if (regex.hasMatch(text.substring(text.length - 1))) {
      text = '$text.';
    }
    return text;
  }

  // Rule 3. Convert lbs
  String poundsRule(String text) {
    if (text.contains('lbs')) {
      text = text.replaceAll('lbs', 'pounds');
    }
    return text;
  }

  // Rule 4. Convert plural
  String pluralRule(String text) {
    if (text.contains('(s)')) {
      text = text.replaceAll('(s)', '');
    }
    return text;
  }

  // Rule 5. N/A
  String NARule(String text) {
    if (text.contains('N/A')) {
      text = text.replaceAll('N/A', 'N.A');
    }
    return text;
  }

  // Rule 6. Covert slash
  String slashRule(String text) {
    if (text.contains('/')) {
      text = text.replaceAll('/', ' or ');
    }
    return text;
  }

  // Rule 7. Convert e.g.
  String egRule(String text) {
    if (text.contains('e.g.')) {
      text = text.replaceAll('e.g.', 'for example');
    }
    return text;
  }

  Future stop() async {
    await flutterTts.stop();
    _ttsState.value = TtsState.stopped;
    notifyListeners();
  }
}

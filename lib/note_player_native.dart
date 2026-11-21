import 'package:flutter_soloud/flutter_soloud.dart';
import 'keyboard_mapping.dart';

class NotePlayerImpl {
  static final _soloud = SoLoud.instance;
  static final Map<String, AudioSource> _sources = {};
  static double _volume = 4.0;

  // Standard 88-key piano range: A0 (MIDI 21) to C8 (MIDI 108)
  static final _allNotes = List.generate(88, (i) => midiToNoteName(i + 21));

  static Future<void> init() async {
    await _soloud.init();
    for (final note in _allNotes) {
      try {
        _sources[note] = await _soloud.loadAsset('assets/notes/$note.mp3');
      } catch (_) {}
    }
  }

  static void play(String note) {
    final source = _sources[note];
    if (source != null) {
      _soloud.play(source, volume: _volume);
    }
  }

  static void setVolume(double volume) {
    _volume = volume * 8.0;
  }

  static void dispose() {
    _soloud.disposeAllSources();
    _soloud.deinit();
  }
}

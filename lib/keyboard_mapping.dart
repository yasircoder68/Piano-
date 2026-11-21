import 'package:flutter/services.dart';

// Maps each physical key to a note name + which octave slot it belongs to (0 = first, 1 = second)
// White keys: Q W E R T Y U  →  octave1: C D E F G A B
//             I O P [ ] \ '  →  octave2: C D E F G A B
// Black keys: 2 3 4 5 6      →  octave1: Db Eb Gb Ab Bb
//             7 8 9 0 -      →  octave2: Db Eb Gb Ab Bb

const _whiteKeys1 = [
  LogicalKeyboardKey.keyQ,
  LogicalKeyboardKey.keyW,
  LogicalKeyboardKey.keyE,
  LogicalKeyboardKey.keyR,
  LogicalKeyboardKey.keyT,
  LogicalKeyboardKey.keyY,
  LogicalKeyboardKey.keyU,
];

const _whiteKeys2 = [
  LogicalKeyboardKey.keyI,
  LogicalKeyboardKey.keyO,
  LogicalKeyboardKey.keyP,
  LogicalKeyboardKey.bracketLeft,
  LogicalKeyboardKey.bracketRight,
  LogicalKeyboardKey.backslash,
  LogicalKeyboardKey.quote,
];

const _blackKeys1 = [
  LogicalKeyboardKey.digit2,
  LogicalKeyboardKey.digit3,
  LogicalKeyboardKey.digit4,
  LogicalKeyboardKey.digit5,
  LogicalKeyboardKey.digit6,
];

const _blackKeys2 = [
  LogicalKeyboardKey.digit7,
  LogicalKeyboardKey.digit8,
  LogicalKeyboardKey.digit9,
  LogicalKeyboardKey.digit0,
  LogicalKeyboardKey.minus,
];

// White note semitone offsets within an octave: C D E F G A B
const _whiteOffsets = [0, 2, 4, 5, 7, 9, 11];

// Black note semitone offsets: Db Eb Gb Ab Bb (C#=1, D#=3, F#=6, G#=8, A#=10)
const _blackOffsets = [1, 3, 6, 8, 10];

// Key label shown on screen for each physical key
final Map<LogicalKeyboardKey, String> keyLabels = {
  LogicalKeyboardKey.keyQ: 'Q',
  LogicalKeyboardKey.keyW: 'W',
  LogicalKeyboardKey.keyE: 'E',
  LogicalKeyboardKey.keyR: 'R',
  LogicalKeyboardKey.keyT: 'T',
  LogicalKeyboardKey.keyY: 'Y',
  LogicalKeyboardKey.keyU: 'U',
  LogicalKeyboardKey.keyI: 'I',
  LogicalKeyboardKey.keyO: 'O',
  LogicalKeyboardKey.keyP: 'P',
  LogicalKeyboardKey.bracketLeft: '[',
  LogicalKeyboardKey.bracketRight: ']',
  LogicalKeyboardKey.backslash: '\\',
  LogicalKeyboardKey.quote: "'",
  LogicalKeyboardKey.digit2: '2',
  LogicalKeyboardKey.digit3: '3',
  LogicalKeyboardKey.digit4: '4',
  LogicalKeyboardKey.digit5: '5',
  LogicalKeyboardKey.digit6: '6',
  LogicalKeyboardKey.digit7: '7',
  LogicalKeyboardKey.digit8: '8',
  LogicalKeyboardKey.digit9: '9',
  LogicalKeyboardKey.digit0: '0',
  LogicalKeyboardKey.minus: '-',
};

const _noteNames = ['C', 'Db', 'D', 'Eb', 'E', 'F', 'Gb', 'G', 'Ab', 'A', 'Bb', 'B'];

/// Converts a MIDI note number to a note name string (e.g. 60 → "C4").
String midiToNoteName(int midi) {
  final octave = (midi ~/ 12) - 1;
  return '${_noteNames[midi % 12]}$octave';
}

/// Builds a map of LogicalKeyboardKey → MIDI note number.
/// [octave1] and [octave2] are the two octaves selected by the user (1–7).
/// MIDI note = 12 * (octave + 1) + semitoneOffset  (Middle C = C4 = MIDI 60)
Map<LogicalKeyboardKey, int> buildMidiMap(int octave1, int octave2) {
  final map = <LogicalKeyboardKey, int>{};

  for (int i = 0; i < _whiteKeys1.length; i++) {
    map[_whiteKeys1[i]] = 12 * (octave1 + 1) + _whiteOffsets[i];
  }
  for (int i = 0; i < _whiteKeys2.length; i++) {
    map[_whiteKeys2[i]] = 12 * (octave2 + 1) + _whiteOffsets[i];
  }
  for (int i = 0; i < _blackKeys1.length; i++) {
    map[_blackKeys1[i]] = 12 * (octave1 + 1) + _blackOffsets[i];
  }
  for (int i = 0; i < _blackKeys2.length; i++) {
    map[_blackKeys2[i]] = 12 * (octave2 + 1) + _blackOffsets[i];
  }

  return map;
}

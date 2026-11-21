import 'package:flutter/material.dart';
import 'piano_key.dart';
import '../note_player.dart';

const double _blackKeyWidthRatio = 0.6;
const double _blackKeyHeightRatio = 0.62;
const double _pressedLightnessShift = 0.25;

const List<Map<String, dynamic>> _octaveLayout = [
  {'white': 'C', 'black': 'Db'},
  {'white': 'D', 'black': 'Eb'},
  {'white': 'E', 'black': null},
  {'white': 'F', 'black': 'Gb'},
  {'white': 'G', 'black': 'Ab'},
  {'white': 'A', 'black': 'Bb'},
  {'white': 'B', 'black': null},
];

class PianoKeyboard extends StatefulWidget {
  final List<int> octaves;
  final double whiteKeyWidth;
  final double whiteKeyHeight;
  final Color whiteKeyColor;
  final Color blackKeyColor;
  final bool showLabels;
  final Set<String> externalPressedNotes;
  final Map<String, String> noteToKeyLabel;

  const PianoKeyboard({
    super.key,
    required this.octaves,
    required this.whiteKeyWidth,
    required this.whiteKeyHeight,
    required this.whiteKeyColor,
    required this.blackKeyColor,
    required this.showLabels,
    this.externalPressedNotes = const {},
    this.noteToKeyLabel = const {},
  });

  @override
  State<PianoKeyboard> createState() => _PianoKeyboardState();
}

class _PianoKeyboardState extends State<PianoKeyboard> {
  final Map<int, String> _activePointers = {};
  final Set<String> _pressedNotes = {};
  List<_KeyRegion> _regions = [];

  @override
  void didUpdateWidget(PianoKeyboard old) {
    super.didUpdateWidget(old);
    _buildRegions();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _buildRegions();
  }

  void _buildRegions() {
    final blackKeyWidth = widget.whiteKeyWidth * _blackKeyWidthRatio;
    final blackKeyHeight = widget.whiteKeyHeight * _blackKeyHeightRatio;
    _regions = [];

    for (int oi = 0; oi < widget.octaves.length; oi++) {
      final octave = widget.octaves[oi];
      final octaveXOffset = oi * widget.whiteKeyWidth * 7;

      // Black keys first (higher priority)
      double x = octaveXOffset;
      for (final entry in _octaveLayout) {
        if (entry['black'] != null) {
          final left = x + widget.whiteKeyWidth - blackKeyWidth / 2;
          _regions.add(_KeyRegion(
            note: '${entry['black']}$octave',
            left: left,
            right: left + blackKeyWidth,
            top: 0,
            bottom: blackKeyHeight,
          ));
        }
        x += widget.whiteKeyWidth;
      }

      // White keys after
      x = octaveXOffset;
      for (final entry in _octaveLayout) {
        _regions.add(_KeyRegion(
          note: '${entry['white']}$octave',
          left: x,
          right: x + widget.whiteKeyWidth,
          top: 0,
          bottom: widget.whiteKeyHeight,
        ));
        x += widget.whiteKeyWidth;
      }
    }
  }

  String? _noteAt(Offset local) {
    for (final region in _regions) {
      if (local.dx >= region.left &&
          local.dx <= region.right &&
          local.dy >= region.top &&
          local.dy <= region.bottom) {
        return region.note;
      }
    }
    return null;
  }

  void _pressNote(int pointerId, String note) {
    if (_activePointers[pointerId] == note) return;
    _releasePointer(pointerId);
    _activePointers[pointerId] = note;
    setState(() => _pressedNotes.add(note));
    NotePlayer.play(note);
  }

  void _releasePointer(int pointerId) {
    final note = _activePointers.remove(pointerId);
    if (note != null && !_activePointers.containsValue(note)) {
      setState(() => _pressedNotes.remove(note));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_regions.isEmpty) _buildRegions();

    final blackKeyWidth = widget.whiteKeyWidth * _blackKeyWidthRatio;
    final blackKeyHeight = widget.whiteKeyHeight * _blackKeyHeightRatio;
    final totalWidth = widget.whiteKeyWidth * 7 * widget.octaves.length;

    final whites = <Widget>[];
    final blacks = <Widget>[];

    for (int oi = 0; oi < widget.octaves.length; oi++) {
      final octave = widget.octaves[oi];
      final octaveXOffset = oi * widget.whiteKeyWidth * 7;
      double xOffset = octaveXOffset;

      for (final entry in _octaveLayout) {
        final whiteNote = '${entry['white']}$octave';
        whites.add(PianoKey(
          note: whiteNote,
          isBlack: false,
          width: widget.whiteKeyWidth,
          height: widget.whiteKeyHeight,
          color: widget.whiteKeyColor,
          showLabel: widget.showLabels,
          pressed: _pressedNotes.contains(whiteNote) ||
              widget.externalPressedNotes.contains(whiteNote),
          keyboardLabel: widget.noteToKeyLabel[whiteNote],
        ));

        if (entry['black'] != null) {
          final blackNote = '${entry['black']}$octave';
          blacks.add(Positioned(
            left: xOffset + widget.whiteKeyWidth - blackKeyWidth / 2,
            top: 0,
            child: PianoKey(
              note: blackNote,
              isBlack: true,
              width: blackKeyWidth,
              height: blackKeyHeight,
              color: widget.blackKeyColor,
              showLabel: widget.showLabels,
              pressed: _pressedNotes.contains(blackNote) ||
                  widget.externalPressedNotes.contains(blackNote),
              keyboardLabel: widget.noteToKeyLabel[blackNote],
            ),
          ));
        }
        xOffset += widget.whiteKeyWidth;
      }
    }

    return Listener(
      behavior: HitTestBehavior.opaque,
      onPointerDown: (e) {
        final note = _noteAt(e.localPosition);
        if (note != null) _pressNote(e.pointer, note);
      },
      onPointerMove: (e) {
        final note = _noteAt(e.localPosition);
        if (note != null) _pressNote(e.pointer, note);
      },
      onPointerUp: (e) => _releasePointer(e.pointer),
      onPointerCancel: (e) => _releasePointer(e.pointer),
      child: SizedBox(
        width: totalWidth,
        height: widget.whiteKeyHeight,
        child: Stack(
          children: [
            Row(children: whites),
            ...blacks,
          ],
        ),
      ),
    );
  }
}

class _KeyRegion {
  final String note;
  final double left, right, top, bottom;
  const _KeyRegion({
    required this.note,
    required this.left,
    required this.right,
    required this.top,
    required this.bottom,
  });
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_settings.dart';
import 'keyboard_mapping.dart';
import 'note_player.dart';
import 'widgets/piano_keyboard.dart';
import 'widgets/settings_dialog.dart';

class PianoScreen extends StatefulWidget {
  const PianoScreen({super.key});

  @override
  State<PianoScreen> createState() => _PianoScreenState();
}

class _PianoScreenState extends State<PianoScreen> {
  AppSettings _settings = AppSettings.defaults;
  bool _loaded = false;

  final Set<String> _kbPressedNotes = {};
  final Map<LogicalKeyboardKey, String> _kbActiveKeys = {};

  late Map<LogicalKeyboardKey, int> _midiMap;
  late Map<String, String> _noteToKeyLabel;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _midiMap = buildMidiMap(_settings.kbOctave1, _settings.kbOctave2);
    _noteToKeyLabel = _buildNoteToKeyLabel(_midiMap);
    _loadSettings();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  Map<String, String> _buildNoteToKeyLabel(Map<LogicalKeyboardKey, int> midiMap) {
    final result = <String, String>{};
    midiMap.forEach((key, midi) {
      final label = keyLabels[key];
      if (label != null) result[midiToNoteName(midi)] = label;
    });
    return result;
  }

  Future<void> _loadSettings() async {
    final s = await AppSettings.load();
    NotePlayer.setVolume(s.volume);
    _applyFullscreen(s.fullscreen);
    final midiMap = buildMidiMap(s.kbOctave1, s.kbOctave2);
    setState(() {
      _settings = s;
      _midiMap = midiMap;
      _noteToKeyLabel = _buildNoteToKeyLabel(midiMap);
      _loaded = true;
    });
  }

  void _applyFullscreen(bool enable) {
    SystemChrome.setEnabledSystemUIMode(
      enable ? SystemUiMode.immersiveSticky : SystemUiMode.edgeToEdge,
    );
  }

  void _applySettings(AppSettings s) {
    final kbOctavesChanged = s.kbOctave1 != _settings.kbOctave1 || s.kbOctave2 != _settings.kbOctave2;
    final fullscreenChanged = s.fullscreen != _settings.fullscreen;
    final volumeChanged = s.volume != _settings.volume;
    final kbDisabled = !s.kbEnabled && _settings.kbEnabled;

    if (volumeChanged) NotePlayer.setVolume(s.volume);
    if (fullscreenChanged) _applyFullscreen(s.fullscreen);

    final midiMap = kbOctavesChanged ? buildMidiMap(s.kbOctave1, s.kbOctave2) : _midiMap;

    setState(() {
      _settings = s;
      if (kbOctavesChanged) {
        _midiMap = midiMap;
        _noteToKeyLabel = _buildNoteToKeyLabel(midiMap);
        _kbPressedNotes.clear();
        _kbActiveKeys.clear();
      }
      if (kbDisabled) {
        _kbPressedNotes.clear();
        _kbActiveKeys.clear();
      }
    });

    s.save();
  }

  void _onKeyDown(LogicalKeyboardKey key) {
    if (!_settings.kbEnabled) return;
    if (_kbActiveKeys.containsKey(key)) return;
    final midi = _midiMap[key];
    if (midi == null) return;
    final noteName = midiToNoteName(midi);
    _kbActiveKeys[key] = noteName;
    setState(() => _kbPressedNotes.add(noteName));
    NotePlayer.play(noteName);
  }

  void _onKeyUp(LogicalKeyboardKey key) {
    if (!_settings.kbEnabled) return;
    final noteName = _kbActiveKeys.remove(key);
    if (noteName != null) {
      setState(() => _kbPressedNotes.remove(noteName));
    }
  }

  void _openSettings() {
    showDialog(
      context: context,
      builder: (_) => SettingsDialog(
        settings: _settings,
        onChanged: _applySettings,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) return const Scaffold(backgroundColor: Colors.black);

    final activeIndices = [
      for (int i = 0; i < _settings.rowOctaves.length; i++)
        if (_settings.rowEnabled[i] && _settings.rowOctaves[i].isNotEmpty) i
    ];
    final rowCount = activeIndices.isEmpty ? 1 : activeIndices.length;

    return Focus(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent) {
          _onKeyDown(event.logicalKey);
          return KeyEventResult.handled;
        } else if (event is KeyUpEvent) {
          _onKeyUp(event.logicalKey);
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: Scaffold(
        backgroundColor: Colors.grey[900],
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final rowHeight = constraints.maxHeight / rowCount;
              return Stack(
                children: [
                  Column(
                    children: activeIndices.map((i) {
                      final keyWidth =
                          constraints.maxWidth / (7 * _settings.rowOctaves[i].length);
                      return SizedBox(
                        height: rowHeight,
                        width: constraints.maxWidth,
                        child: PianoKeyboard(
                          octaves: _settings.rowOctaves[i],
                          whiteKeyWidth: keyWidth,
                          whiteKeyHeight: rowHeight,
                          whiteKeyColor: _settings.whiteColor,
                          blackKeyColor: _settings.blackColor,
                          showLabels: _settings.showLabels,
                          externalPressedNotes: _kbPressedNotes,
                          noteToKeyLabel: _settings.kbEnabled ? _noteToKeyLabel : const {},
                        ),
                      );
                    }).toList(),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: FloatingActionButton.small(
                      onPressed: _openSettings,
                      backgroundColor: Colors.grey[800],
                      child: const Icon(Icons.settings, color: Colors.white),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

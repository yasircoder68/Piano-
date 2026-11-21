import 'note_player_shim.dart';

class NotePlayer {
  static Future<void> init() => NotePlayerImpl.init();
  static void play(String note) => NotePlayerImpl.play(note);
  static void setVolume(double volume) => NotePlayerImpl.setVolume(volume);
  static void dispose() => NotePlayerImpl.dispose();
}

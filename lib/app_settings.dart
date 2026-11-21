import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettings {
  final List<List<int>> rowOctaves;
  final List<bool> rowEnabled;
  final bool showLabels;
  final Color whiteColor;
  final Color blackColor;
  final double volume;
  final bool fullscreen;
  final bool kbEnabled;
  final int kbOctave1;
  final int kbOctave2;

  const AppSettings({
    required this.rowOctaves,
    required this.rowEnabled,
    required this.showLabels,
    required this.whiteColor,
    required this.blackColor,
    required this.volume,
    required this.fullscreen,
    required this.kbEnabled,
    required this.kbOctave1,
    required this.kbOctave2,
  });

  static AppSettings get defaults => AppSettings(
        rowOctaves: [[3, 4]],
        rowEnabled: [true],
        showLabels: true,
        whiteColor: Colors.white,
        blackColor: Colors.black,
        volume: 1.0,
        fullscreen: false,
        kbEnabled: false,
        kbOctave1: 4,
        kbOctave2: 5,
      );

  static Future<AppSettings> load() async {
    final p = await SharedPreferences.getInstance();
    final rowCount = p.getInt('rowCount');
    if (rowCount == null) return defaults;

    final rowOctaves = <List<int>>[];
    final rowEnabled = <bool>[];
    for (int i = 0; i < rowCount; i++) {
      final octaves = p.getStringList('rowOctaves_$i');
      rowOctaves.add(octaves != null ? octaves.map(int.parse).toList() : [4]);
      rowEnabled.add(p.getBool('rowEnabled_$i') ?? true);
    }

    return AppSettings(
      rowOctaves: rowOctaves,
      rowEnabled: rowEnabled,
      showLabels: p.getBool('showLabels') ?? true,
      whiteColor: Color(p.getInt('whiteColor') ?? Colors.white.toARGB32()),
      blackColor: Color(p.getInt('blackColor') ?? Colors.black.toARGB32()),
      volume: p.getDouble('volume') ?? 1.0,
      fullscreen: p.getBool('fullscreen') ?? false,
      kbEnabled: p.getBool('kbEnabled') ?? false,
      kbOctave1: p.getInt('kbOctave1') ?? 4,
      kbOctave2: p.getInt('kbOctave2') ?? 5,
    );
  }

  Future<void> save() async {
    final p = await SharedPreferences.getInstance();
    await p.setInt('rowCount', rowOctaves.length);
    for (int i = 0; i < rowOctaves.length; i++) {
      await p.setStringList('rowOctaves_$i', rowOctaves[i].map((e) => '$e').toList());
      await p.setBool('rowEnabled_$i', rowEnabled[i]);
    }
    await p.setBool('showLabels', showLabels);
    await p.setInt('whiteColor', whiteColor.toARGB32());
    await p.setInt('blackColor', blackColor.toARGB32());
    await p.setDouble('volume', volume);
    await p.setBool('fullscreen', fullscreen);
    await p.setBool('kbEnabled', kbEnabled);
    await p.setInt('kbOctave1', kbOctave1);
    await p.setInt('kbOctave2', kbOctave2);
  }

  AppSettings copyWith({
    List<List<int>>? rowOctaves,
    List<bool>? rowEnabled,
    bool? showLabels,
    Color? whiteColor,
    Color? blackColor,
    double? volume,
    bool? fullscreen,
    bool? kbEnabled,
    int? kbOctave1,
    int? kbOctave2,
  }) {
    return AppSettings(
      rowOctaves: rowOctaves ?? this.rowOctaves,
      rowEnabled: rowEnabled ?? this.rowEnabled,
      showLabels: showLabels ?? this.showLabels,
      whiteColor: whiteColor ?? this.whiteColor,
      blackColor: blackColor ?? this.blackColor,
      volume: volume ?? this.volume,
      fullscreen: fullscreen ?? this.fullscreen,
      kbEnabled: kbEnabled ?? this.kbEnabled,
      kbOctave1: kbOctave1 ?? this.kbOctave1,
      kbOctave2: kbOctave2 ?? this.kbOctave2,
    );
  }
}

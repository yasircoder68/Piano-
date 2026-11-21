import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../app_settings.dart';

class SettingsDialog extends StatefulWidget {
  final AppSettings settings;
  final ValueChanged<AppSettings> onChanged;

  const SettingsDialog({
    super.key,
    required this.settings,
    required this.onChanged,
  });

  @override
  State<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog> {
  late AppSettings _s;

  @override
  void initState() {
    super.initState();
    _s = widget.settings;
  }

  void _update(AppSettings next) {
    setState(() => _s = next);
    widget.onChanged(next);
  }

  void _addRow() {
    if (_s.rowOctaves.length >= 7) return;
    _update(_s.copyWith(
      rowOctaves: [..._s.rowOctaves, [4]],
      rowEnabled: [..._s.rowEnabled, true],
    ));
  }

  void _removeRow(int i) {
    if (_s.rowOctaves.length <= 1) return;
    final octaves = [..._s.rowOctaves]..removeAt(i);
    final enabled = [..._s.rowEnabled]..removeAt(i);
    _update(_s.copyWith(rowOctaves: octaves, rowEnabled: enabled));
  }

  void _toggleRow(int i, bool val) {
    final enabled = [..._s.rowEnabled];
    enabled[i] = val;
    _update(_s.copyWith(rowEnabled: enabled));
  }

  void _toggleOctave(int rowIndex, int octave, bool selected) {
    final octaves = _s.rowOctaves.map((r) => List<int>.from(r)).toList();
    final row = octaves[rowIndex];
    if (selected) {
      if (!row.contains(octave)) {
        row.add(octave);
        row.sort();
      }
    } else {
      if (row.length > 1) row.remove(octave);
    }
    _update(_s.copyWith(rowOctaves: octaves));
  }

  void _pickColor(bool isWhite) {
    Color temp = isWhite ? _s.whiteColor : _s.blackColor;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(isWhite ? 'White Key Color' : 'Black Key Color'),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: temp,
            onColorChanged: (c) => temp = c,
            enableAlpha: false,
            labelTypes: const [],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              _update(isWhite ? _s.copyWith(whiteColor: temp) : _s.copyWith(blackColor: temp));
              Navigator.pop(context);
            },
            child: const Text('Select'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Dialog(
      child: Container(
        width: screenWidth * 0.85,
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Settings',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Keyboard rows
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Keyboard Rows',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline),
                          tooltip: 'Add row',
                          onPressed: _s.rowOctaves.length < 7 ? _addRow : null,
                        ),
                      ],
                    ),
                    ...List.generate(_s.rowOctaves.length, (i) {
                      final enabled = _s.rowEnabled[i];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade700),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Switch(
                                  value: enabled,
                                  onChanged: (v) => _toggleRow(i, v),
                                ),
                                Text('Row ${i + 1}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: enabled ? null : Colors.grey,
                                    )),
                                const Spacer(),
                                if (_s.rowOctaves.length > 1)
                                  IconButton(
                                    icon: const Icon(Icons.remove_circle_outline,
                                        color: Colors.redAccent, size: 20),
                                    onPressed: () => _removeRow(i),
                                  ),
                              ],
                            ),
                            Wrap(
                              spacing: 4,
                              children: List.generate(7, (o) {
                                final octave = o + 1;
                                final checked = _s.rowOctaves[i].contains(octave);
                                return FilterChip(
                                  label: Text('Oct $octave'),
                                  selected: checked,
                                  onSelected: enabled
                                      ? (val) => _toggleOctave(i, octave, val)
                                      : null,
                                );
                              }),
                            ),
                            const SizedBox(height: 4),
                          ],
                        ),
                      );
                    }),
                    const Divider(),
                    // Volume
                    Row(
                      children: [
                        const Icon(Icons.volume_up, size: 20),
                        const SizedBox(width: 8),
                        const Text('Volume'),
                        Expanded(
                          child: Slider(
                            value: _s.volume,
                            min: 0.0,
                            max: 1.0,
                            onChanged: (v) => _update(_s.copyWith(volume: v)),
                          ),
                        ),
                        Text('${(_s.volume * 100).round()}%',
                            style: const TextStyle(fontSize: 12)),
                      ],
                    ),
                    const Divider(),
                    // Computer keyboard
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Computer Keyboard'),
                      value: _s.kbEnabled,
                      onChanged: (v) => _update(_s.copyWith(kbEnabled: v)),
                    ),
                    if (_s.kbEnabled)
                      Padding(
                        padding: const EdgeInsets.only(left: 4, bottom: 8),
                        child: Row(
                          children: [
                            const Text('Octave 1:'),
                            const SizedBox(width: 12),
                            DropdownButton<int>(
                              value: _s.kbOctave1,
                              items: List.generate(7, (i) => i + 1)
                                  .map((o) => DropdownMenuItem(
                                        value: o,
                                        child: Text('Oct $o'),
                                      ))
                                  .toList(),
                              onChanged: (v) {
                                if (v != null) _update(_s.copyWith(kbOctave1: v));
                              },
                            ),
                            const SizedBox(width: 24),
                            const Text('Octave 2:'),
                            const SizedBox(width: 12),
                            DropdownButton<int>(
                              value: _s.kbOctave2,
                              items: List.generate(7, (i) => i + 1)
                                  .map((o) => DropdownMenuItem(
                                        value: o,
                                        child: Text('Oct $o'),
                                      ))
                                  .toList(),
                              onChanged: (v) {
                                if (v != null) _update(_s.copyWith(kbOctave2: v));
                              },
                            ),
                          ],
                        ),
                      ),
                    const Divider(),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Fullscreen'),
                      value: _s.fullscreen,
                      onChanged: (v) => _update(_s.copyWith(fullscreen: v)),
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Show note labels'),
                      value: _s.showLabels,
                      onChanged: (v) => _update(_s.copyWith(showLabels: v)),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _colorSwatch('White Keys', _s.whiteColor, () => _pickColor(true)),
                        _colorSwatch('Black Keys', _s.blackColor, () => _pickColor(false)),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _colorSwatch(String label, Color color, VoidCallback onTap) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 13)),
        const SizedBox(height: 4),
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color,
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        ),
      ],
    );
  }
}

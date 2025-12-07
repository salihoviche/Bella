import 'package:flutter/material.dart';
import 'package:flex_color_picker/flex_color_picker.dart';

// Orange color scheme matching the app
const Color _orangePrimary = Color(0xFFFF8C42);
const Color _orangeDark = Color(0xFFFF6B1A);

/// A reusable advanced color picker widget that matches the app's design language
class BaseColorPicker extends StatelessWidget {
  final Color? selectedColor;
  final ValueChanged<Color> onColorChanged;
  final String? label;
  final IconData? prefixIcon;

  const BaseColorPicker({
    super.key,
    this.selectedColor,
    required this.onColorChanged,
    this.label,
    this.prefixIcon,
  });

  String _colorToHex(Color color) {
    return '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
  }

  Future<void> _showColorPickerDialog(BuildContext context) async {
    final Color initialColor = selectedColor ?? Colors.grey;
    Color pickedColor = initialColor;
    
    final bool colorChanged = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return _AdvancedColorPickerDialog(
          initialColor: initialColor,
          onColorChanged: (Color color) {
            pickedColor = color;
          },
        );
      },
    ) ?? false;

    if (colorChanged) {
      onColorChanged(pickedColor);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentColor = selectedColor ?? Colors.grey[300]!;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: TextStyle(
              color: Colors.grey[700],
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
        ],
        InkWell(
          onTap: () => _showColorPickerDialog(context),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.grey[300]!,
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                if (prefixIcon != null) ...[
                  Icon(
                    prefixIcon,
                    color: Colors.grey[600],
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                ],
                // Color preview
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: currentColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.grey.withOpacity(0.3),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    selectedColor != null
                        ? _colorToHex(selectedColor!)
                        : 'No color selected',
                    style: TextStyle(
                      fontSize: 14,
                      color: selectedColor != null
                          ? const Color(0xFF1F2937)
                          : Colors.grey[500],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_drop_down_rounded,
                  color: Colors.grey[600],
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _AdvancedColorPickerDialog extends StatefulWidget {
  final Color initialColor;
  final ValueChanged<Color> onColorChanged;

  const _AdvancedColorPickerDialog({
    required this.initialColor,
    required this.onColorChanged,
  });

  @override
  State<_AdvancedColorPickerDialog> createState() => _AdvancedColorPickerDialogState();
}

class _AdvancedColorPickerDialogState extends State<_AdvancedColorPickerDialog> {
  late Color _tempColor;

  @override
  void initState() {
    super.initState();
    _tempColor = widget.initialColor;
  }

  String _colorToHex(Color color) {
    return '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: 600,
        constraints: const BoxConstraints(maxHeight: 700),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        _orangePrimary,
                        _orangeDark,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.palette_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Advanced Color Picker',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  icon: const Icon(Icons.close_rounded),
                  color: Colors.grey[600],
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Color preview section
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.grey[200]!,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  // Large color preview
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: _tempColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.grey.withOpacity(0.3),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),
                  // Color info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildColorInfoItem('Hex', _colorToHex(_tempColor)),
                        const SizedBox(height: 12),
                        _buildColorInfoItem(
                          'RGB',
                          '${_tempColor.red}, ${_tempColor.green}, ${_tempColor.blue}',
                        ),
                        const SizedBox(height: 12),
                        _buildColorInfoItem(
                          'HSV',
                          () {
                            final hsv = HSVColor.fromColor(_tempColor);
                            return '${hsv.hue.round()}°, ${(hsv.saturation * 100).round()}%, ${(hsv.value * 100).round()}%';
                          }(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Advanced color picker
            Flexible(
              child: SingleChildScrollView(
                child: ColorPicker(
                  color: _tempColor,
                  onColorChanged: (Color color) {
                    setState(() {
                      _tempColor = color;
                    });
                    widget.onColorChanged(color);
                  },
                  width: 40,
                  height: 40,
                  borderRadius: 8,
                  spacing: 5,
                  runSpacing: 5,
                  wheelDiameter: 200,
                  wheelWidth: 20,
                  heading: const Text(
                    'Select Color',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  subheading: const Text(
                    'Choose from presets or use the color wheel',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                  wheelSubheading: const Text(
                    'Color Wheel',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  showMaterialName: true,
                  showColorName: true,
                  showColorCode: true,
                  copyPasteBehavior: const ColorPickerCopyPasteBehavior(
                    copyButton: true,
                    pasteButton: true,
                    longPressMenu: true,
                  ),
                  pickersEnabled: const <ColorPickerType, bool>{
                    ColorPickerType.both: true,
                    ColorPickerType.primary: true,
                    ColorPickerType.accent: true,
                    ColorPickerType.bw: true,
                    ColorPickerType.custom: true,
                    ColorPickerType.wheel: true,
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        _orangePrimary,
                        _orangeDark,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: _orangePrimary.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(true);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Select Color',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorInfoItem(String label, String value) {
    return Row(
      children: [
        SizedBox(
          width: 50,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF1F2937),
          ),
        ),
      ],
    );
  }
}

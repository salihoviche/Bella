import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// Orange color scheme matching the app
const Color _orangePrimary = Color(0xFFFF8C42);

/// A reusable date picker widget that matches the app's design language
/// and has the same height as BaseDropdown and BaseTextField
class BaseDatePicker extends StatelessWidget {
  /// The label text for the date picker
  final String label;

  /// The currently selected date
  final DateTime? selectedDate;

  /// Callback when date changes
  final ValueChanged<DateTime?>? onChanged;

  /// Optional prefix icon
  final IconData? prefixIcon;

  /// Optional hint text
  final String? hintText;

  /// Whether the field has an error
  final bool isError;

  /// Optional fixed width (if null, will expand to fill available space)
  final double? width;

  /// Whether the date picker is enabled
  final bool enabled;

  /// First selectable date
  final DateTime? firstDate;

  /// Last selectable date
  final DateTime? lastDate;

  /// Initial date to show in picker
  final DateTime? initialDate;

  const BaseDatePicker({
    super.key,
    required this.label,
    this.selectedDate,
    this.onChanged,
    this.prefixIcon,
    this.hintText,
    this.isError = false,
    this.width,
    this.enabled = true,
    this.firstDate,
    this.lastDate,
    this.initialDate,
  });

  Future<void> _selectDate(BuildContext context) async {
    if (!enabled || onChanged == null) return;

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? initialDate ?? DateTime.now(),
      firstDate: firstDate ?? DateTime(2000),
      lastDate: lastDate ?? DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: _orangePrimary,
              onPrimary: Colors.white,
              onSurface: Colors.black87,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != selectedDate) {
      onChanged!(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final decoration = _buildDecoration();
    final displayText = selectedDate != null
        ? DateFormat('yyyy-MM-dd').format(selectedDate!)
        : (hintText ?? 'Select date');

    Widget datePicker = InkWell(
      onTap: enabled ? () => _selectDate(context) : null,
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        decoration: decoration,
        child: Row(
          children: [
            if (prefixIcon != null) ...[
              Icon(
                prefixIcon,
                color: isError
                    ? const Color(0xFFE53E3E)
                    : enabled
                        ? Colors.grey[600]
                        : Colors.grey[400],
                size: 20,
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Text(
                displayText,
                style: TextStyle(
                  fontSize: 14,
                  color: selectedDate != null
                      ? const Color(0xFF1F2937)
                      : Colors.grey[500],
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            if (selectedDate != null && enabled) ...[
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.clear, size: 18),
                color: Colors.grey[600],
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () {
                  onChanged!(null);
                },
              ),
            ],
            const SizedBox(width: 8),
            Icon(
              Icons.calendar_today_outlined,
              color: enabled ? Colors.grey[600] : Colors.grey[400],
              size: 20,
            ),
          ],
        ),
      ),
    );

    // Wrap in a container that handles overflow
    Widget constrainedDatePicker = Container(
      constraints: width != null
          ? BoxConstraints(maxWidth: width!)
          : const BoxConstraints(),
      child: datePicker,
    );

    // If width is specified, align it
    if (width != null) {
      return Align(
        alignment: Alignment.centerLeft,
        child: constrainedDatePicker,
      );
    }

    return constrainedDatePicker;
  }

  InputDecoration _buildDecoration() {
    return InputDecoration(
      labelText: label,
      hintText: hintText,
      filled: true,
      fillColor: enabled ? Colors.grey[50] : Colors.grey[100],
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(color: Colors.grey[300]!, width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(color: Colors.grey[300]!, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: const BorderSide(
          color: _orangePrimary,
          width: 2.0,
        ),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(color: Colors.grey[300]!, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: const BorderSide(color: Color(0xFFE53E3E), width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: const BorderSide(color: Color(0xFFE53E3E), width: 2.0),
      ),
      labelStyle: TextStyle(
        color: isError
            ? const Color(0xFFE53E3E)
            : enabled
                ? Colors.grey[700]
                : Colors.grey[500],
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
    );
  }
}


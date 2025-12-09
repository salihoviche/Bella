import 'package:flutter/material.dart';

/// A reusable dropdown widget that matches the app's design language
/// and handles overflow gracefully by truncating text instead of overflowing
class BaseDropdown<T> extends StatelessWidget {
  /// The label text for the dropdown
  final String label;

  /// The current selected value
  final T? value;

  /// The list of dropdown items
  final List<DropdownMenuItem<T>> items;

  /// Callback when value changes
  final ValueChanged<T?>? onChanged;

  /// Optional prefix icon
  final IconData? prefixIcon;

  /// Optional hint text
  final String? hintText;

  /// Whether the field has an error
  final bool isError;

  /// Optional fixed width (if null, will expand to fill available space)
  final double? width;

  /// Whether the dropdown is enabled
  final bool enabled;

  const BaseDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    this.prefixIcon,
    this.hintText,
    this.isError = false,
    this.width,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    Widget dropdown = DropdownButtonFormField<T>(
      decoration: _buildDecoration(),
      value: value,
      items: items,
      onChanged: enabled ? onChanged : null,
      isExpanded: true, // This ensures the dropdown respects constraints
      selectedItemBuilder: (BuildContext context) {
        // Custom builder to handle text overflow in selected item
        return items.map<Widget>((DropdownMenuItem<T> item) {
          // If child is a Row (e.g., with image), show it as is but with overflow handling
          if (item.child is Row) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 0.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: item.child,
              ),
            );
          }
          
          // Preserve original text style if available, otherwise use default
          TextStyle? originalStyle;
          if (item.child is Text) {
            originalStyle = (item.child as Text).style;
          } else if (item.child is Container) {
            final container = item.child as Container;
            if (container.child is Text) {
              originalStyle = (container.child as Text).style;
            }
          }
          
          // Use original style or default (matching regular dropdown)
          final textStyle = originalStyle ?? const TextStyle(
            fontSize: 14,
            color: Color(0xFF1F2937),
            fontWeight: FontWeight.w500,
          );
          
          return Container(
            alignment: Alignment.centerLeft,
            child: Text(
              _getItemText(item),
              style: textStyle,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          );
        }).toList();
      },
      hint: hintText != null
          ? Text(
              hintText!,
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 14,
                            fontWeight: FontWeight.w500,

              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            )
          : null,
      style: const TextStyle(
        fontSize: 14,
        color: Color(0xFF1F2937),
        fontWeight: FontWeight.w500,
      ),
      icon: Icon(
        Icons.arrow_drop_down_rounded,
        color: enabled ? Colors.grey[600] : Colors.grey[400],
        size: 24,
      ),
      dropdownColor: Colors.white,
      menuMaxHeight: 300,
    );

    // Wrap in a container that handles overflow
    Widget constrainedDropdown = Container(
      constraints: width != null
          ? BoxConstraints(maxWidth: width!)
          : const BoxConstraints(),
      child: dropdown,
    );

    // If width is specified, align it
    if (width != null) {
      return Align(
        alignment: Alignment.centerLeft,
        child: constrainedDropdown,
      );
    }

    return constrainedDropdown;
  }

  InputDecoration _buildDecoration() {
    return InputDecoration(
      labelText: label,
      hintText: hintText,
      filled: true,
      fillColor: enabled ? Colors.grey[50] : Colors.grey[100],
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
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
          color: Color(0xFFFF8C42), // Orange
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
      prefixIcon: prefixIcon != null
          ? Icon(
              prefixIcon,
              color: isError
                  ? const Color(0xFFE53E3E)
                  : enabled
                      ? Colors.grey[600]
                      : Colors.grey[400],
              size: 20,
            )
          : null,
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

  String _getItemText(DropdownMenuItem<T> item) {
    if (item.child is Text) {
      return (item.child as Text).data ?? '';
    } else if (item.child is Row) {
      // Extract text from Row widget (assumes last child is Expanded with Text)
      final row = item.child as Row;
      for (var child in row.children.reversed) {
        if (child is Expanded) {
          if (child.child is Text) {
            return ((child.child as Text).data ?? '');
          }
        } else if (child is Text) {
          return (child.data ?? '');
        }
      }
    } else if (item.child is Container) {
      final container = item.child as Container;
      if (container.child is Text) {
        return ((container.child as Text).data ?? '');
      }
    }
    return item.value?.toString() ?? '';
  }
}


import 'package:flutter/material.dart';

// Orange color scheme
const Color _orangePrimary = Color(0xFFFF8C42);
const Color _orangeDark = Color(0xFFFF6B1A);

/// A modern switch widget with orange theme
/// 
/// This switch is designed to match the app's orange color scheme
/// and provides a smooth, modern toggle experience.
class BaseSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  final double width;
  final double height;
  final bool enabled;

  const BaseSwitch({
    super.key,
    required this.value,
    this.onChanged,
    this.width = 50,
    this.height = 28,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled && onChanged != null
          ? () => onChanged!(!value)
          : null,
      child: MouseRegion(
        cursor: enabled && onChanged != null
            ? SystemMouseCursors.click
            : SystemMouseCursors.basic,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          width: width,
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(height / 2),
            gradient: value && enabled
                ? const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      _orangePrimary,
                      _orangeDark,
                    ],
                  )
                : null,
            color: value && !enabled
                ? _orangePrimary.withOpacity(0.5)
                : !value
                    ? Colors.grey[300]
                    : null,
            boxShadow: value && enabled
                ? [
                    BoxShadow(
                      color: _orangePrimary.withOpacity(0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Stack(
            children: [
              // Animated thumb
              AnimatedPositioned(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                left: value ? width - height + 2 : 2,
                top: 2,
                child: Container(
                  width: height - 4,
                  height: height - 4,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


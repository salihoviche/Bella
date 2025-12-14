import 'dart:convert';
import 'package:flutter/material.dart';

// Orange color scheme matching the app
const Color _orangePrimary = Color(0xFFFF8C42);

/// A reusable picture cover widget that matches the app's design language
/// 
/// Supports both circular and rectangular shapes with enhanced styling
class BasePictureCover extends StatelessWidget {
  final String? base64;
  final double size;
  final double? width;
  final double? height;
  final IconData fallbackIcon;
  final Color borderColor;
  final Color iconColor;
  final Color? backgroundColor;
  final double borderWidth;
  final bool showShadow;
  final bool isCircular;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final Widget? overlay;

  const BasePictureCover({
    super.key,
    required this.base64,
    this.size = 140,
    this.width,
    this.height,
    this.fallbackIcon = Icons.account_circle,
    this.borderColor = _orangePrimary,
    this.iconColor = _orangePrimary,
    this.backgroundColor,
    this.borderWidth = 2.0,
    this.showShadow = true,
    this.isCircular = true,
    this.borderRadius = 12.0,
    this.padding,
    this.overlay,
  });

  double get _width => width ?? size;
  double get _height => height ?? size;

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? _orangePrimary.withOpacity(0.1);
    
    return Container(
      width: _width,
      height: _height,
      decoration: BoxDecoration(
        shape: isCircular ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: isCircular
            ? null
            : BorderRadius.circular(borderRadius),
        border: Border.all(
          color: borderColor,
          width: borderWidth,
        ),
        boxShadow: showShadow
            ? [
                BoxShadow(
                  color: borderColor.withOpacity(0.25),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                  spreadRadius: 0,
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                  spreadRadius: -2,
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: isCircular
            ? BorderRadius.circular(_width / 2)
            : BorderRadius.circular(borderRadius),
        child: Stack(
          fit: StackFit.expand,
          children: [
            _buildBackground(bgColor),
            if (overlay != null) overlay!,
          ],
        ),
      ),
    );
  }

  Widget _buildBackground(Color bgColor) {
    if (base64 == null || base64!.isEmpty) {
      return _buildFallback(bgColor);
    }

    try {
      final bytes = base64Decode(base64!);
      return Image.memory(
        bytes,
        width: _width,
        height: _height,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildFallback(bgColor),
      );
    } catch (e) {
      return _buildFallback(bgColor);
    }
  }

  Widget _buildFallback(Color bgColor) {
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            bgColor,
            bgColor.withOpacity(0.7),
          ],
        ),
      ),
      child: Icon(
        fallbackIcon,
        size: isCircular ? _width * 0.5 : (_width * 0.4).clamp(24.0, 64.0),
        color: iconColor,
      ),
    );
  }
}

